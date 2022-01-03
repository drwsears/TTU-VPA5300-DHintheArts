%% Importing the dataset for Jane Austen's Emma. We'll preprocess the text, we'll count the words, and we'll visualize the most frequent words.

%% IMPORT

cd('D:\Dropbox\files\Jobs\2017_TexasTech\teaching\2021_Fall\VPA5300_DH\inclass\tutorials\tutorial_03_text\data\gutenberg')
emma = fileread('austen-emma.txt');


%% PREPROCESS

% Split lines.
emma = splitlines(emma);

% Deleting empty rows.
idx = (emma == "");
emma(idx) = [];
clear idx

% Removing punctuation marks.
emma = erasePunctuation(emma);

% Removing case.
emma = lower(emma);


%% COUNT

% To count the unique word in the text, we need to tokenize the text.
tokens = strings(0);
for i = 1:length(emma)
    tokens = [tokens; split(emma(i))];
end

% Delete stop words.
idx = ismember(tokens,stopWords);
tokens(idx) = [];

% Count all of the unique word types in our list of tokens.
[types,~,idx] = unique(tokens);
count = histcounts(idx,numel(types));
count = count';

% OR use my function.
cd('D:\Dropbox\files\Jobs\2017_TexasTech\teaching\2021_Fall\VPA5300_DH\inclass\tutorials\tutorial_03_text\code')
alpha = unique(tokens);
[types counts] = ngrams(tokens,1,'alphabet',alpha);

% Make a table of types and counts.
T = table;
T.Types = alpha(types);
T.Count = count;

% Sort table by frequency, from most to least common.
T = sortrows(T,-2);


%% VISUALIZE

% Create a wordcloud.
colors = rand(size(types,1),3);
figure; wordcloud(T,'Types','Count','Color',colors,'MaxDisplayWords',50)

% keywords analysis (put code directory in the Matlab path!)
cd('D:\Dropbox\files\Jobs\2017_TexasTech\teaching\2021_Fall\VPA5300_DH\inclass\tutorials\tutorial_03_text\data\gutenberg')
tab = keywords('austen-emma.txt','austen-sense.txt','threshold',10,'cloud_maxwords',50);







