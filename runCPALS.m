%Ravdeep Pasricha , Ekta Gujral, Vagelis Papalexakis 2018
%Computer Science and Engineering, University of California, Riverside
function [Facts, maxfit] = runCPALS(X, R)
iter = 5;
Facts_cell = cell(iter, 1);
out = cell(iter,1);
out_fit = zeros(iter,1);
parfor i = 1:iter
  [Facts_cell{i}, ~, out{i}] = cp_als(X, R, 'tol',1.0e-7, 'maxiters', 1000, 'printitn', 0);
end
for i=1:iter
    out_fit(i) = out{i}.fit;
end
[maxfit, index] = max(out_fit);

Facts = Facts_cell{index};

end
