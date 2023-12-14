function plotStabilityPaths(selProb,varargin)

% plotStabilityPaths(selProb)
%  Plots the stability paths in selProb.
%  plotStabilityPaths(selProb,highlight) hightlights variables with indices
%  in highlight.

if nargin>1
    sel = varargin{1};
else
    sel = [];
end

hold on
remain = 1:size(selProb,2);
remain(sel) = [];
plot(1:size(selProb,1),selProb(:,remain),'k')
xticks([]);xlim([0.9 size(selProb,1)+0.1])
xlabel('\lambda')
ylim([0 1.01]);ylabel('selection probability');
if ~isempty(sel)
    plot(1:size(selProb,1),selProb(:,sel),'LineWidth',2)
end
hold off