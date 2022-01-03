% This script imports a data set of tweets by Hillary Clinton and Donald
% Trump from the 2016 election year. It then examines a histogram of their
% tweets over the course of the year, identifies their most retweeted
% tweets, identifies topics in Trump's tweets, and conducts a sentiment
% analysis of the tweets from both. 


%% IMPORT

% Import tweets.
cd('D:\Dropbox\files\Jobs\2017_TexasTech\teaching\2021_Fall\VPA5300_DH\inclass\tutorials\tutorial_04_topics_sentiments\data')
tweets = readtable('tweets.csv');

% Preprocess. Remove retweets.
idx = strcmp(tweets.is_retweet,'True');
tweets(idx,:) = [];

% Separate into Clinton and Trump tables.
% Clinton
idx = strcmp(tweets.handle,'HillaryClinton');
clinton_tab = tweets(idx,:);

% Trump
idx = strcmp(tweets.handle,'realDonaldTrump');
trump_tab = tweets(idx,:);



%% TIMELINE.  When did the tweets occur? Plot using time stamp.

% Clinton
clinton_dates = datetime(clinton_tab.time(:,1));

% Trump
trump_dates = datetime(trump_tab.time(:,1));

% Plot
figure; 
subplot(1,2,1); histogram(clinton_dates(:,1),20,'EdgeColor','b','FaceColor','b')
ylim([0 400])
title('Clinton')
subplot(1,2,2); histogram(trump_dates(:,1),20,'EdgeColor','r','FaceColor','r')
title('Trump')
ylim([0 400])


%% TOP TWEET -- retweet count.

% Clinton
[mx idx] = max(clinton_tab.retweet_count);
clinton_toptweet = clinton_tab.text(idx);

% https://variety.com/2016/digital/news/hillary-clinton-donald-trump-twitter-delete-your-account-retweet-1201912895/

% Trump
[mx idx] = max(trump_tab.retweet_count);
trump_toptweet = trump_tab.text(idx);

% Who had higher retweet counts on average?
retweets = [clinton_tab.retweet_count; trump_tab.retweet_count];
groups = [clinton_tab.handle; trump_tab.handle];
p = kruskalwallis(retweets,groups,'on')
ylim([0 20000])
ax = gca; % axes handle
ax.YAxis.Exponent = 0;


%% PREPROCESS TWEETS

% Clinton.
clinton_tokens = tokenizedDocument(clinton_tab.text); % preprocess tweets into list of words (i.e., clinton_tokens).
clinton_tokens = erasePunctuation(clinton_tokens); % erase punctuation
clinton_tokens = correctSpelling(clinton_tokens); % correct spelling
clinton_tokens = removeStopWords(clinton_tokens); % remove stop (or function) words.
clinton_tokens = regexprep(clinton_tokens,{'https:\S*','#\S*','@\S*'},''); % remove hyperlinks and hash tags.

% Trump.
trump_tokens = tokenizedDocument(trump_tab.text); % preprocess tweets into list of words (i.e., trump_tokens).
trump_tokens = erasePunctuation(trump_tokens); % erase punctuation
trump_tokens = correctSpelling(trump_tokens); % correct spelling
trump_tokens = removeStopWords(trump_tokens); % remove stop (or function) words.
trump_tokens = regexprep(trump_tokens,{'https:\S*','#\S*','@\S*'},''); % remove hyperlinks and hash tags.


%% TOPIC MODELS -- What are they tweeting about?

% Intro to topic modeling: https://monkeylearn.com/blog/introduction-to-topic-modeling/

% bag of words.
bag = bagOfWords(trump_tokens);

% train lda.
n = 3; % number of topics
mdl = fitlda(bag,n,'Verbose',0);

% word clouds.
fig_cloud = figure;
k = 20; % top 20 words
for i = 1:n
    
    % word cloud
    set(0,'CurrentFigure',fig_cloud);
    if rem(n,2)==0
        subplot(2,n/2,i);
    else
        subplot(1,n,i);
    end
    wordcloud(mdl,i);
    title("Topic " + i);
    
    % create table.
    name = strcat('topic_',num2str(i));
    tbl.(name).top = topkwords(mdl,k,i);
    
    clear name
end


%% SENTIMENT ANALYSIS -- Are Clinton's tweets more positive overall?

% Intro to VADER: https://github.com/cjhutto/vaderSentiment

clinton_emo = vaderSentimentScores(clinton_tokens); % clinton
trump_emo = vaderSentimentScores(trump_tokens); % trump

emo_scores = [clinton_emo; trump_emo];
groups = [clinton_tab.handle; trump_tab.handle];
p = kruskalwallis(emo_scores,groups,'on')
ax = gca; % axes handle
ax.YAxis.Exponent = 0;


    






