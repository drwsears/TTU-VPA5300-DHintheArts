function [LIA, LOCB] = nanismember(varargin1,varargin2,token)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
  if nargin<3
    token=[];
  end
  x = varargin1;
  y = varargin2;
  t = rand;
  if isnumeric(x) && isnumeric(y)
      while any(x(:)==t) | any(y(:)==t) 
          t = rand;
      end
      x(isnan(x)) = t;
      y(isnan(y)) = t;
  end
  if isempty(token)==0
    [LIA, LOCB] = ismember(x,y,'rows');
  else [LIA, LOCB] = ismember(x,y);
  end
end

