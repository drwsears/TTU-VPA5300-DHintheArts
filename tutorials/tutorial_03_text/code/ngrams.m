function [types counts tokens] = ngrams(sequence, cardinality, varargin)
%
% [types counts tokens] = ngrams(sequence, cardinality, varargin);
%
% Calculates contiguous ngram types and tokens of cardinality n. If onset 
% times is specified as an optional input argument, counts are weighted by
% the average inter-onset interval between members of each ngram. Tokens
% that are further separated in time receive lower weights in the final
% count.
%
%
% Input arguments:
%  sequence       (required) -- A m-dimensional array or m x n dimensional
%                               matrix where rows represent events or event 
%                               combinations (e.g., the notes of a chord). 
%                               In the latter case, an alphabet consisting 
%                               of n columns is required.
%
%  cardinality    (required) -- n, the length of the n-gram.
%
%  'times'        (optional) -- onset times for events in the sequence.
%
%  'relations'    (optional) -- relational events. At present, the
%                               algorithm estimates the melodic interval 
%                               class (mod 12) between the pitches 
%                               representing each event in sequence.
%
%  'alphabet'     (optional) -- If sequence is a matrix where rows
%                               represent event combinations, alphabet 
%                               provides the alphabet for all possible 
%                               combinations.
%
% Output:
%  types    -- All ngram types.
%  counts   -- Counts associated with all types.
%  tokens   -- All ngram tokens.
%
% Example:
% [types,counts,tokens] = ngrams(chord_sequence,3,'times',onset_times,'relations',bass_sequence,'alphabet',alpha);
%
%          
%
% Change History :
% Date          Time	Prog            Note
% 6.12.2017  	13:19	David Sears	    Created under MATLAB 8.6 (R2015b, PC)

if nargin<2, disp('You must indicate the cardinality.'); return
end

%% CHECK OPTIONAL ARGUMENTS

times = [];
relations = [];
ending = [];
alphabet = [];

var_i = 1;
while var_i <= length(varargin)           
    if strcmp(varargin{var_i},'times')       
        times = varargin{var_i+1};
        var_i = var_i+2;        
    elseif strcmp(varargin{var_i},'relations')        
        relations = varargin{var_i+1};
        var_i = var_i+2;
    elseif strcmp(varargin{var_i},'end')
        ending = 1;
        var_i = var_i+1;
    elseif strcmp(varargin{var_i},'alphabet')        
        alphabet= varargin{var_i+1};
        if isempty(alphabet)==0
            [~,sequence] = nanismember(sequence,alphabet,'rows');
        end
        var_i = var_i+2;
    elseif isempty(varargin{var_i})
        var_i = var_i+1;
    end   
end

%% GET N-GRAM TOKENS

%Ensure the sequence only contains positive values.
mn = min(sequence(:,1));
if mn<1
    x = 1-mn;
    sequence(:,1)=sequence(:,1)+x;
end


if cardinality > 1
    % Calculate indices.
    tmp =  (1:size(sequence,1)-cardinality+1)';
    k=1;
    indices=[];
    while k <= cardinality
        indices(:,end+1) = tmp+k-1;
        k=k+1;
    end
    
    % Get rid of indices that don't terminate with the final event in
    % sequence.
    if isempty(ending)==0
        indices(indices(:,end)~=size(sequence,1),:) = [];
    end
    
    fin = sequence(indices);
    
%% CALCULATE RELATIONS AND WEIGHTED COUNTS
    
    % Calculates melodic interval class for sequence of pitches (0-127).
    if isempty(relations)==0 
        relations = mod(diff(relations(indices),[],2),12);
    end
    
    % Calculate weighted counts.
    if isempty(times)==0     
        wt_ct = 2.^-mean(diff(times(indices),[],2),2);       
    end
    
    if size(fin,2)~=cardinality
        fin=fin';
    end
    
else
    if isempty(ending)
        fin=sequence; 
    else fin = sequence(end);
    end
end

%% GET N-GRAM TYPES AND COUNTS

if mn<1
    tokens = fin-x;
else tokens = fin;
end

% Place relations into n-grams before calculating types and counts.
if isempty(relations)==0
    tokens = interleave2(tokens,relations,'col');
end

% Types and counts.
[types,~,k] = unique(tokens, 'rows');
if ~isempty(alphabet) && iscell(alphabet)
    types = alphabet(types);
end
if nargout > 1
    counts = histc(k, 1:size(types, 1));
    if isempty(times)==0 && isempty(fin)==0 && cardinality > 1
        weight = accumarray(k,wt_ct);
        counts = [weight counts];
    end
end

end

