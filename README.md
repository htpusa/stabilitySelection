# stabilitySelection

Perform stability selection using the MATLAB function lassoglm. The function `stabilityPaths` estimates the probability of a variable to be chosen in a sparse model by repeatedly subsampling the data, calculating the reguralisation path for each subsample, and counting how frequently the variable was chosen at each point in the path.

The resulting *stability paths* can be used to select or rank variables based on, for example, the maximum selection probability they achieved.

For more on the method, see Meinshausen & Bühlmann, 2010, and Shah & Samworth, 2013.

Meinshausen, Nicolai, and Peter Bühlmann. "Stability selection." 
   Journal of the Royal Statistical Society Series B: Statistical 
   Methodology 72.4 (2010): 417-473.
   
Shah, Rajen D., and Richard J. Samworth. "Variable selection with error
   control: another look at stability selection." Journal of the Royal
   Statistical Society Series B: Statistical Methodology 75.1 (2013): 55-80.

# Example

```
a = [1:-0.1:0.1 zeros(1,40)];
Y = randn(100,1);
X = normrnd(Y*a,0.2);
Y = Y>0;
[selProb maxProb numSel Lambda] = stabilityPaths(X,Y);
plotStabilityPaths(selProb,1:10);
```
