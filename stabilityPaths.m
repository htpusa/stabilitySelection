function [selProb,maxProb,numSel,Lambda] = stabilityPaths(X,Y,varargin)

% stabilityPaths(X,Y)
%  [selProb] = stabilityPaths(X,Y) calculates stability paths for predictors
%  in the columns of X using the built-in function lassoglm.
%  A stability path is the estimated selection probability of a variable
%  as a function of model sparsity. See the references for more details.

%  INPUTS:
%  X        -       NxP matrix of observations
%  Y        -       Nx1 vector of outcome values
%
%  OPTIONAL INPUTS:
%  'distr'  -       distribution argument to be passed on to lassoglm
%                       (if not given, defaults to guessing between
%                       'normal' and 'binomial')
%  'Alpha'  -       elastic net parameter to passed on to lassoglm
%  'print'  -       Boolean, to print or not to print messages
%
%  OUTPUTS
%  selProb  -       100xP matrix of selection probabilities
%  maxProb  -       Px1 vector of maximum selection probabilities
%  numSel   -       100x1 vector, the average number of variables selected
%  Lambda   -       100x1 vector of regularisation parameter values
%
%  EXAMPLE
%  a = [1:-0.1:0.1 zeros(1,40)];
%  Y = randn(100,1);
%  X = normrnd(Y*a,0.2);
%  selProb = stabilityPaths(X,Y);
%  plotStabilityPaths(selProb,1:10)

%  REFERENCES
%  Meinshausen, Nicolai, and Peter Bühlmann. "Stability selection." 
%   Journal of the Royal Statistical Society Series B: Statistical 
%   Methodology 72.4 (2010): 417-473.
%  Shah, Rajen D., and Richard J. Samworth. "Variable selection with error
%   control: another look at stability selection." Journal of the Royal
%   Statistical Society Series B: Statistical Methodology 75.1 (2013): 55-80.

alpha = 0;
rounds = 100;
print = 1;
if numel(unique(Y))<3
    dist = 'binomial';
else
    dist = 'normal';
end

if ~isempty(varargin)
    if rem(size(varargin, 2), 2) ~= 0
		error('Check optional inputs.');
    else
        for i = 1:2:size(varargin, 2)
            switch varargin{1, i}
                case 'distr'
					dist = varargin{1, i+1};
                case 'Alpha'
					alpha = varargin{1, i+1};
                otherwise
					error(['Could not recognise optional input names.' ...
                        '\nNo input named "%s"'],...
						varargin{1,i});
            end
        end
    end
end

if alpha>0
    [~,FI] = lassoglm(X,Y,dist,'Alpha',alpha);
else
    [~,FI] = lassoglm(X,Y,dist);
end
Lambda = FI.Lambda';

parts = false(size(X,1),rounds);
for i=1:2:rounds
    if isequal(dist,'binomial')
        part = crossvalind('HoldOut',Y,0.5);
    else
        part = crossvalind('HoldOut',numel(Y),0.5);
    end
    parts(:,i:i+1) = [part, ~part];
end

selProb = zeros(numel(Lambda),size(X,2));
numSel = zeros(numel(Lambda),1);

parfor np=1:rounds
    if print && (mod(np,10)==0)
        fprintf('\t Subsample %d of %d\n',np,rounds);
    end
    Xtmp = X(parts(:,np),:);
    Ytmp = Y(parts(:,np));
    if alpha>0
        B = lassoglm(Xtmp,Ytmp,dist,"Alpha",alpha,"Lambda",Lambda);
    else
        B = lassoglm(Xtmp,Ytmp,dist,"Lambda",Lambda);
    end
    sel = B'~=0;
    selProb = selProb + sel;
    numSel = numSel + sum(sel,2);
end

selProb = selProb/rounds; selProb = flipud(selProb);
maxProb = max(selProb,[],1)';
numSel = numSel/rounds; numSel = flip(numSel);
Lambda = flip(Lambda);





