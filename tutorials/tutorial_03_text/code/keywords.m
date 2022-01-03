function [keywords_table] = keywords(text_corpus,reference_corpus,varargin)
%
% [table] = keywords(text_corpus, reference_corpus, varargin);
%
% Ranks the word types in text_corpus using Fisher's exact test by
% comparing the frequencies of each word type with the
% corresponding frequencies in reference_corpus.
%
% Input arguments:
%  text_corpus      (required) -- A corpus of text (e.g., from the 
%                                 Gutenberg dataset).
%
%  reference_corpus (required) -- A corpus of text (e.g., from the
%                                 Gutenberg dataset).
%
% 'threshold'       (optional) -- The minimum number of required tokens for
%                                 each word type (default = 5).
%
% 'cloud_maxwords'  (optional) -- The number of permitted words in each
%                                 cloud (default = 80).
%
% Output:
%  table -- A table consisting of all word types ranked by the Odds Ratio 
%           from Fisher's exact test. Columns denote word types
%           (table.Types), counts (table.Count), and odds ratio
%           (table.OddsRatio).
%
% Example:
% table = keywords('austen-emma.txt','austen-sense.txt','threshold',10,'cloud_maxwords',100);
%
% Change History:
% 10.09.2018  	14:45	David Sears	    Created under MATLAB 9.4 (R2018a, PC)


%% OPTIONAL ARGUMENTS.
threshold = 5;
cloud_maxwords = 80;

var_i = 1;
while var_i <= length(varargin)
    if strcmp(varargin{var_i},'threshold')
        threshold = varargin{var_i+1};
        var_i = var_i+2;
    elseif strcmp(varargin{var_i},'cloud_maxwords')
        cloud_maxwords = varargin{var_i+1};
        var_i = var_i+2;
    end
end
    
        


%% TEXT CORPUS: Import, preprocess, and count words.

% Import.
text = fileread(text_corpus);

% Split lines.
text = splitlines(text);

% Deleting empty rows.
idx = (text == "");
text(idx) = [];
clear idx

% Removing punctuation marks.
text = erasePunctuation(text);

% Removing case.
text = lower(text);

% To count the unique word in the text, tokenize the text.
tokens = strings(0);
for ii = 1:length(text)
    tokens = [tokens; split(text(ii))];
end

% Delete stop words.
idx = ismember(tokens,stopWords);
tokens(idx) = [];

% Count all of the unique word types in our list of tokens.
[text_types,~,idx] = unique(tokens);
count = [histcounts(idx,numel(text_types))]';

% Make a table of types and counts.
T = table;
T.Types = text_types;
T.Count = count;

% Sort table by frequency, from most to least common.
text_table = sortrows(T,-2);




%% REFERENCE CORPUS: Import, preprocess, and count words.

% Import.
reference = fileread(reference_corpus);

% Split lines.
reference = splitlines(reference);

% Deleting empty rows.
idx = (reference == "");
reference(idx) = [];
clear idx

% Removing punctuation marks.
reference = erasePunctuation(reference);

% Removing case.
reference = lower(reference);

% To count the unique word in the reference, tokenize the reference.
tokens = strings(0);
for ii = 1:length(reference)
    tokens = [tokens; split(reference(ii))];
end

% Delete stop words.
idx = ismember(tokens,stopWords);
tokens(idx) = [];

% Count all of the unique word types in our list of tokens.
[ref_types,~,idx] = unique(tokens);
count = [histcounts(idx,numel(ref_types))]';

% Make a table of types and counts.
T = table;
T.Types = ref_types;
T.Count = count;

% Sort table by frequency, from most to least common.
reference_table = sortrows(T,-2);



%% WORDCLOUD

% Create a subfigure with both wordclouds.
colors_1 = rand(size(text_types,1),3);
colors_2 = rand(size(ref_types,1),3);
figure; subplot(1,2,1);
wordcloud(text_table,'Types','Count','Color',colors_1,'MaxDisplayWords',cloud_maxwords);
title(text_corpus)
subplot(1,2,2)
wordcloud(reference_table,'Types','Count','Color',colors_2,'MaxDisplayWords',cloud_maxwords);
title(reference_corpus)




%% KEYWORDS

% Cut words with counts lower than threshold in the text corpus table.
idx = find(text_table.Count < threshold, 1, 'first');
text_table(idx:end,:) = [];

% Calculate Odds Ratio for all words in Emma.
for ii = 1:size(text_table,1)
    data = [nan nan; sum(text_table.Count) sum(reference_table.Count)];
    data(1,1) = text_table.Count(ii);
    [~,idx] = ismember(text_table.Types(ii),reference_table.Types);
    if idx~=0
        data(1,2) = reference_table.Count(idx);
    else
        data(1,2) = 1;
    end
    data(2,1) = data(2,1) - data(1,1);
    data(2,2) = data(2,2) - data(1,2);
    [~,~,stats] = fishertest(data);
    OddsRatio(ii,1) = stats.OddsRatio;
    clear stats
end
text_table.OddsRatio = OddsRatio;

% Sort by Odds Ratio.
text_table = sortrows(text_table,-3);

keywords_table = text_table;

end

