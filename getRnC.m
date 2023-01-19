%Ravdeep Pasricha , Ekta Gujral, Vagelis Papalexakis 2019
%Computer Science and Engineering, University of California, Riverside

function [F, cor]=getRnC(X, R)
    % Input: Tensor X and estimated rank R.
    % Output: Low rank of the tensor and corresponding corcondia score.
    sizeX = size(X);
    density = nnz(X)/(sizeX(1)*sizeX(2)*sizeX(3));
    disp(density);
    if density > 0.25
        X = tensor(X);
    else
        X = sptensor(X);
    end
    n = 10;
    maxRank = 2 * R;
    allRank = zeros(n,1);
    allCor = zeros(n,1);
    parfor i=1:n
        disp(i);
%         This version of autoten uses CP_NMU intead of CP_als
        [Fac ,c ,K] = AutoTen_NMU(X, maxRank, 1);
%         [Fac ,c ,K] = AutoTen(X, maxRank, 1);
        allRank(i,1) = K;
        allCor(i,1) = c;
    end
    disp(allRank);
    disp(allCor);
    F = mode(allRank(:,1));
    disp(F);
    inds = allRank(:,1)==F;
%     allCor = allRank(:,2);
    cor = max(allCor(inds));
   
end