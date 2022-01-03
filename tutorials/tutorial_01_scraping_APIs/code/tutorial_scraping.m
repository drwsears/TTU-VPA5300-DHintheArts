
%% PREPROCESS NETFLIX VIEWING HISTORY

% Import.
cd('D:\Dropbox\files\Jobs\2017_TexasTech\teaching\2021_Fall\VPA5300_DH\tutorials\wk02_scraping_APIs')
netflix = readtable('NetflixViewingHistory.csv');

% Remove episode listings (this is coarse).
idx = contains(netflix.Title,':');
netflix.Title(idx) = extractBefore(netflix.Title(idx),':');
[Title, idx] = unique(netflix.Title);
ViewDate = netflix.Date(idx);
netflix = table(Title,ViewDate);

% Bug. The OMDB API replaces '%' symbol with 'percent'.
netflix.Title = replace(netflix.Title,'3%', '3 Percent');


%% SCRAPING EXAMPLE

% First entry -- Star Trek
page = webread('https://www.imdb.com/title/tt0796366/?ref_=fn_al_tt_2');
text = extractHTMLText(page);
text = splitlines(text);
text(all(cellfun('isempty',text),2),:) = [];


%% OMDB API

% Query information about Netflix viewing history.
tab = table;
labels = {'Title' 'ViewDate' 'Year' 'Rated' 'Genre' 'Director' 'Writer' 'Actors' 'Language' 'imdbRating' 'imdbID'};
for i = 1:size(netflix,1)
    tmp = netflix.Title(i);
    tmp2 = replace(tmp,{' '},'+');
    url = char(strcat('http://www.omdbapi.com/?apikey=ac603c01&t=',tmp2));
    data = webread(url);
    
    if isfield(data,'Error')==0 
        data = struct2table(data,'AsArray',1);
        ViewDate = netflix.ViewDate(i);
        data = addvars(data,ViewDate,'Before','Year');
        [~,idx] = ismember(labels,fieldnames(data));
        data = data(1,idx);
        tab = [tab; data];
        clear ViewDate idx
    end
    clear tmp url data
end
writetable(tab,'Netflix_OMDB_API_v3.csv');

%% GENDER

% First names of first director.
director = tab.Director;
director = extractBefore(director,{' '});
director = upper(director);
director(all(cellfun('isempty',director),2),:) = [];

% First names of first writer.
writer = tab.Writer;
writer = extractBefore(writer,{' '});
writer = upper(writer);
writer(all(cellfun('isempty',writer),2),:) = [];

% First names of first actor.
actor = tab.Actors;
actor = extractBefore(actor,{' '});
actor = upper(actor);
actor(all(cellfun('isempty',actor),2),:) = [];

% Import World Gender Name Dictionary (WGND)
names = readtable('wgnd_ctry.csv');

% Percentage of actors who are male.
[~,idx] = ismember(actor,names.name);
actor(idx==0) = [];
idx(idx==0) = [];
actor = names.gender(idx);
actor_percentage = sum(strcmp(actor,'M')) / length(actor);

% Percentage of writers who are male.
[~,idx] = ismember(writer,names.name);
writer(idx==0) = [];
idx(idx==0) = [];
writer = names.gender(idx);
writer_percentage = sum(strcmp(writer,'M')) / length(writer);

% Percentage of directors who are male.
[~,idx] = ismember(director,names.name);
director(idx==0) = [];
idx(idx==0) = [];
director = names.gender(idx);
director_percentage = sum(strcmp(director,'M')) / length(director);


%% LANGUAGE

% Percentage of entries that feature more than one language.
multi_percentage = sum(contains(tab.Language,',')) / size(tab,1);


%% GENRE

genres = tab.Genre;
idx = contains(genres,',');
genres(idx) = extractBefore(genres(idx),',');
[types,~,k] = unique(genres);
counts = histc(k, 1:size(types, 1));
proportions = counts/sum(counts);
genre = table(types,proportions);
genre = sortrows(genre,'proportions','descend');

% Plot top 4.
figure; bar(genre.proportions(1:4))
set(gca,'xticklabel',genre.types(1:4))






