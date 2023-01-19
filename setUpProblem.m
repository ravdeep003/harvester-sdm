function [A, B, C1, C2, maxfit] = setUpProblem(X, R, Y1, Y2)
% Y1 = tttm(X, W1, 3);
% Y2 = ttm(X, W2, 3);
size1 = size(Y1);
size2 = size(Y2);

Z = tensor;
% Z = tenzeros(siz1(1), size1(2), size1(3) + size2(3))
Z(:,:,1:size1(3)) = Y1;
Z(:,:,size1(3)+1:size1(3)+size2(3)) = Y2;
[Facts, maxfit] = runCPNMU(Z, R);
% [Facts, maxfit] = runCPALS(Z, R);
A = Facts.U{1}; B = Facts.U{2}; C = Facts.U{3};
C1 = C(1:size1(3), :);
C2 = C(size1(3)+1:end, :);
% disp(min(C(:)));
% disp(size(C1));
% disp(size(C2));
% disp(maxfit)
end