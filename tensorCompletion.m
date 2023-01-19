function [rmse, fit, rmses, fits] = tensorCompletion(X, R, missing)
% number of runs
n = 5;
[subs, vals] = find(X);
totalNNZ = length(subs);
numMissing = ceil(missing * totalNNZ);
ind = randperm(totalNNZ, numMissing);
missInd = subs(ind, :);
Y = X;
P = tenones(size(X));
Y(missInd) = 0;
P(missInd) = 0;
% disp(nnz(X));
% disp(nnz(Y));
% disp(nnz(P));
fits = zeros(n, 1);
rmses = zeros(n, 1);
% [M, U, Output] = cp_wopt(Y, P, R, 'init', 'rand');
parfor i=1:n
[M, U, Output] = cp_wopt(Y, P, R);
fits(i,1) = relativeFit(X, tensor(M));
rmses(i,1) = calRMSE(X, tensor(M), missInd);
end
disp(rmses);
disp(fits);
[rmse, minInd] = min(rmses);
fit = fits(minInd);
end
