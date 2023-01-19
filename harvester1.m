% Multiplicative Update: ||Ci - Pi*lambda*Copt||^2 + alpha*||Copt^T||^2 +
% beta*||lambda|| + gamma * ||Pi||^2 
function[Wn, Ws, BigLam, Copt, P1, P2, Errors, i, sparseCount] = harvester1(X, C1, C2, params)
alpha = params.alpha;
beta = params.beta;
gamma1 = params.gamma1;
gamma2 = params.gamma2;
R = params.R;
iters = params.iters;
errortol = params.errortol;
normThreshold = params.normThreshold;

totalErrFigPathEPS =  sprintf(strcat(params.figPath, '_totalError_harvester_1_aplha=', num2str(alpha), '_beta=', num2str(beta), '_gamma1=', num2str(gamma1), '_gamma2=', num2str(gamma2), '.eps'));
totalErrFigPathJPG =  sprintf(strcat(params.figPath, '_totalError_harvester_1_aplha=', num2str(alpha), '_beta=', num2str(beta), '_gamma1=', num2str(gamma1), '_gamma2=', num2str(gamma2), '.jpg'));
reconErrFigPathEPS =  sprintf(strcat(params.figPath, '_reconError_harvester_1_aplha=', num2str(alpha), '_beta=', num2str(beta), '_gamma1=', num2str(gamma1), '_gamma2=', num2str(gamma2), '.eps'));
reconErrFigPathJPG =  sprintf(strcat(params.figPath, '_reconError_harvester_1_aplha=', num2str(alpha), '_beta=', num2str(beta), '_gamma1=', num2str(gamma1), '_gamma2=', num2str(gamma2), '.jpg'));

% disp(totalErrFigPathEPS);
% disp(reconErrFigPathEPS);

% [A, B, C1, C2, maxfit] = setUpProblem(X, R, Y1, Y2);
% Initalize Copt, P1, P2
sizeX = size(X);
sizeC1 = size(C1);
sizeC2 = size(C2);
K = sizeX(3); K1 = sizeC1(1); K2 = sizeC2(1); 
Copt = rand(K, R);
BigLam = diag(rand(K, 1));
% BigLam = rand(K, K);
P1 = rand(K1, K);
P2 = rand(K2, K);
% Copt = zeros(K, R);
% P1 = zeros(K1, K);
% P2 = zeros(K2, K);

totalError = zeros(iters, 1);
reconError = zeros(iters, 1);
reconErrorC1 = zeros(iters, 1);
reconErrorC2 = zeros(iters, 1);

for i=1:iters
%     disp(i)
    temp = (BigLam' * (P1' * P1) * BigLam + BigLam' * (P2' * P2) * BigLam + alpha * eye(K, K)) * Copt; 
    update = (BigLam' * P1' * C1) + (BigLam' * P2' * C2);
    update = update ./ (temp + eps);
    Copt = Copt .* update;
    Copt = max(Copt,0);

    
    tempP = BigLam * (Copt * Copt') * BigLam';
    tempP1 = P1 * (tempP + gamma1 * eye(K,K));
    tempP2 = P2 * (tempP + gamma2 * eye(K,K));
    updateP1 = (C1 * Copt' * BigLam') ./(tempP1 + eps);
    updateP2 = (C2 * Copt' * BigLam') ./(tempP2 + eps);
    P1 = P1 .* updateP1;
    P2 = P2 .* updateP2;
    P1 = max(P1,0);
    P2 = max(P2,0);
    
    tempLam = (2 * (P1' * P1) + 2 * (P2' * P2)) *  BigLam * (Copt * Copt') + beta * ones(K,K);
    updateLam = (2 * P1' * C1 * Copt' + 2 * P2' * C2 * Copt')./ (tempLam + eps);
    BigLam = BigLam .* updateLam;
    BigLam = max(BigLam, 0);
    
    % Error
    temp1 = P1 * BigLam * Copt;
    temp2 = P2 * BigLam * Copt;
    norm1 = norm(C1 - temp1, 'fro')^2;
    norm2 = norm(C2 - temp2, 'fro')^2;
    error = norm1 + norm2 + alpha * norm(Copt, 'fro')^2 + gamma1 * norm(P1, 'fro')^2 + gamma2 * norm(P2, 'fro')^2 + beta * norm(BigLam,1);
%     disp(error);
    totalError(i) = error;
    reconErrorC1(i) = norm1/norm(C1,'fro')^2;
    reconErrorC2(i) = norm2/norm(C2,'fro')^2;
    reconError(i) = reconErrorC1(i) + reconErrorC2(i);
    if i > 2
        errorDiff = abs(error - totalError(i-1));
        if errorDiff < errortol
        break;
        end
    end
end

Ctilde = BigLam * Copt;
Wn = normAggregation(Ctilde, normThreshold);
Ws = aggreateZeroRows(Ctilde);

Errors.totalError = totalError;
Errors.reconError = reconError;
Errors.reconErrorC1 = reconErrorC1;
Errors.reconErrorC2 = reconErrorC2;

% Sparsity 
diagVector = diag(BigLam);
sparseCount = nnz(diagVector);
%%%%%% Plots %%%%%
% Comment the plot section for computing run time
ymini = min([min(reconErrorC1) min(reconErrorC2)]);
ymax = 10^(ceil(log10(max(totalError))));
ymin = 10^(floor(log10(ymini)))/10;
font = 30;
semilogy(1:i, totalError(1:i), 'LineWidth', 3);
hold on;
title('Total Loss per iteration', 'FontSize', font);
xlabel('Iteration', 'FontSize', font);
ylabel('Error', 'FontSize', font);
xticks(0:10:i);
xlim([0 i]);
ylim([ymin ymax]);
set(gcf, 'Units','normalized','Position',[0 0 1 1]); %fullscreen
saveas(gcf, totalErrFigPathEPS);
saveas(gcf, totalErrFigPathJPG);
hold off;
clf('reset');
close;

semilogy(1:i, reconError(1:i), 'LineWidth', 2);
hold on;
semilogy(1:i, reconErrorC1(1:i), 'LineWidth', 2);
semilogy(1:i, reconErrorC2(1:i), 'LineWidth', 2);
title('Reconstructed Loss per iteration for C1 and C2', 'FontSize', font);
xlabel('Iteration', 'FontSize', font);
ylabel('Error', 'FontSize', font);
xticks(0:10:i);
xlim([0 i]);
ylim([ymin ymax]);
legend({'Total Relative Error', 'Relative Error C1', 'Relative Error C2'}, 'FontSize', font);
set(gcf, 'Units','normalized','Position',[0 0 1 1]); %fullscreen
saveas(gcf, reconErrFigPathEPS);
saveas(gcf, reconErrFigPathJPG);
hold off;
clf('reset');
close;
%%% Comment till here if you are timing experiments.


end