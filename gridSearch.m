% Grid Search method for Harvester 1

% function gridSearch(datasetPath, fileName, resultPath)

datasetPath = 'datasets/syntheticDatasets/ten_100X100X10_5_50/';
% fileName = 'ten_100X100X10_5_40_';
resultPath = 'results/syntheticDatasets/ten_100X100X10_5_50/';

alphas = [10^-4 10^-3 10^-2];
betas = [10^-2 10^-1 10^0, 10];
gammas = [10^-4 10^-3 10^-2];
% gammas = [10^-6 10^-5 10^-4 10^-3 10^-2 10^-1 10^0 10^1 10^2];

% alphas = [0];
% alphas = [0 10^-4 10^-3 10^-2 10^-1 10^0];
% betas = [ 10^-4 10^-3 10^-2 10^-1 10^0 10^1 10^2];
% gammas = [0 10^-4 10^-3 10^-2 10^-1 10^0];
% gammas = [0];


datasets = dir(fullfile(datasetPath,'*.mat'));
% numData = length(datasets);
numData = 1;
for data=1:numData
    % Generating FileNames and result paths 
    disp("Dataset");
    disp(data);
    fname = datasets(data).name;
    splitNames = split(fname, '.');
%     disp(splitNames);
    sName = splitNames{1};
    rPath = strcat(resultPath, sName);
    filePath = strcat(datasets(data).folder,'/', datasets(data).name);
    disp(filePath)
    disp(rPath);
    if ~exist(rPath, 'dir')
       mkdir(rPath)
    end
    % Setting up params for running Harvester
    a = load(filePath);
    X = a.X;
    X_og = a.X_og;
    Y1 = aggregateOnFixedInterval(X, 5);
    Y2 = aggregateOnFixedInterval(X, 10);
    R = a.R;
    disp(size(X));disp(size(Y1));disp(size(Y2));
    params.figPath = strcat(rPath, '/', sName);
    params.R = R;
    params.iters = 150;
    params.errortol = 1e-04;
    params.normThreshold = 0.15;

    [A, B, C1, C2, maxfit] = setUpProblem(X, R, Y1, Y2);
    
    totalIteration = length(alphas) * length(betas) * length(gammas);
%     totalIteration = length(alphas) * length(betas);
    tracker = cell(totalIteration, 1);
    points = zeros(totalIteration, 3);
    count = 1;
    for a=alphas
        for b=betas
            for g=gammas 
%                 disp(count);
%                 g = a;
                params.alpha = a; 
                params.beta = b; 
                params.gamma1 = g;
                params.gamma2 = g;
              
                result = sprintf(strcat(rPath, '/', sName, '_harvester_1_alpha=', num2str(a), '_beta=', num2str(b), '_gamma1=', num2str(g), '_gamma2=', num2str(g), '.mat'));
                tracker{count}.result = result;
                tracker{count}.params = params;
                count = count + 1;
            end
        end
    end

    disp("Starting Grid Search");
    parfor j=1:totalIteration
%         param = tracker{j}.params;
        [Wn, Ws, BigLam, Copt, P1, P2, Errors, iterations, sparseCount] = harvester1(X, C1, C2, tracker{j}.params);
        saveToFile(tracker{j}.result, Wn, Ws, BigLam, Copt, P1, P2, Errors, iterations, tracker{j}.params, sparseCount);
        
        tracker{j}.totalErr = Errors.totalError(iterations);
        tracker{j}.reconErr = Errors.reconError(iterations);
        tracker{j}.reconErrC1 = Errors.reconErrorC1(iterations);
        tracker{j}.reconErrC2 = Errors.reconErrorC2(iterations);
        tracker{j}.iterations = iterations;
        tracker{j}.sparseCount = sparseCount;
        points(j, :) = [Errors.totalError(iterations) Errors.reconError(iterations) sparseCount];
    end
    disp("Grid Search Ended")

    % Sparse Percentile set some reasonable value.
%     sparseThreshold = ceil(prctile(points(:,3), 25));
    sparseThreshold = ceil(size(X,3)/10);
    errThreshold = median(points(points(:,3)<=sparseThreshold, 1));

    minErr = intmax;
%     minReconErr = intmax;
    numSlices = size(X, 3);
    minErrIndex = -1;
%     reconErrIndex = -1;
    sparCountIndex = -1;
    
    for i=1:totalIteration
        currErr = points(i, 1);
%         reconErr = points(i, 2);
        sparCount = points(i, 3);
        if currErr < minErr && sparCount <= sparseThreshold
            minErr = currErr;
            minErrIndex = i;
        end
%         if reconErr < minReconErr && sparCount <= sparseThreshold
%             minReconErr = reconErr;
%             reconErrIndex = i;
%         end
        if  sparCount < numSlices && currErr < errThreshold
            numSlices = sparCount;
            sparCountIndex = i;
        end

%         scatter(i, currErr, 100, "blue", "filled");
%         scatter(tracker{i}.sparseCount, currErr, 100, "blue", "filled");
%         text(i, currErr+currErr, num2str(tracker{i}.sparseCount), 'Color', 'Black', 'FontSize', 40, 'FontWeight', 'bold');
    end
    minErrParams = tracker{minErrIndex}.params;
%     reconErrParams = tracker{reconErrIndex}.params;
    sparCountParams = tracker{sparCountIndex}.params;

    colors = zeros(totalIteration, 3);
    colors(:,3) = 1;
%     colors([minErrIndex reconErrIndex sparCountIndex], 3) = 0;
    colors([minErrIndex sparCountIndex], 3) = 0;
    
    figure(1)
    hold on;
    scatter(points(:, 3), points(:, 1), 350, colors, "filled");
    scatter(points(sparCountIndex, 3), points(sparCountIndex, 1), 350, 'k', "filled");
    scatter(points(minErrIndex, 3), points(minErrIndex, 1), 350, 'k', "filled");
    hxl = xline(sparseThreshold, '--', 'Sparse Threshold', 'LineWidth', 5);
    yxl = yline(errThreshold, '--', 'Error Threshold', 'LineWidth', 5 );
    hxl.FontSize = 50;
    yxl.FontSize = 50;
    set(gca,'yscale','log')
    title('Total Loss vs Sparseness count of diagonal of Lambda', 'FontSize', 50);
    xlabel('Sparse Count', 'FontSize', 50);
    ylabel('Total loss', 'FontSize', 50);
    set(gcf, 'Units','normalized','Position',[0 0 1 1]); %fullscreen
    ax = gca;
    ax.FontSize = 50;
    savefig = strcat(resultPath, sName, '_totalLoss');
    saveas(gcf, savefig, 'epsc');
    saveas(gcf, savefig, 'jpg');
    hold off;
    clf('reset');
    close;

    scatter(points(:, 3), points(:, 2), 100, colors, "filled");
    hold on;
    xline(sparseThreshold, '--');
    set(gca,'yscale','log')
    title('Reconstructed Loss of C_i vs Sparness count of diagonal of Lambda for various hyperparameter settings', 'FontSize', 30);
    xlabel('Sparse Count', 'FontSize', 40);
    ylabel('Reconstructed Loss', 'FontSize', 40);
    set(gcf, 'Units','normalized','Position',[0 0 1 1]); %fullscreen
    savefig = strcat(resultPath, sName, '_recon_loss');
    saveas(gcf, savefig, 'epsc');
    saveas(gcf, savefig, 'jpg');
    hold off;
    clf('reset');
    close;
    
    analysis = cell(5,1);
    %lookUp = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
    % Compute Corcondia 
    count = 1;
    tcMissing = 0.2;
%     for findex=[minErrIndex reconErrIndex sparCountIndex]
    for findex=[minErrIndex sparCountIndex]
        disp("Analysis");
        disp(count);
        gsFile = tracker{findex}.result;
        disp(gsFile);
        gsVar = load(gsFile);
        Wnorm = gsVar.Wn;
        Wspar = gsVar.Ws;
        Co = gsVar.Copt;
        Lam = gsVar.BigLam;

        Ctilde = Lam * Co;
        Cnorm = Wnorm * Ctilde;
        Cspar = Wspar * Ctilde;
        
        Yn = tensor(ktensor({A, B, Cnorm}));
        Ys = tensor(ktensor({A, B, Cspar}));

%         Yn = ttm(X, Wn, 3);
%         Ys = ttm(X, Ws, 3);
        % Corcondia
        [Fnorm, CorNorm] = getRnC(Yn, ceil(R/2));
        [Fspar, CorSpar] = getRnC(Ys, ceil(R/2));
        analysis{count}.Fnorm = Fnorm;
        analysis{count}.CorNorm = CorNorm;
        analysis{count}.Fspar = Fspar;
        analysis{count}.CorSpar = CorSpar;
        % Fit
        [factsNorm, fitNorm] = runCPNMU(Yn, Fnorm);
        [factsSpar, fitSpar] = runCPNMU(Ys, Fspar);
        analysis{count}.factsNorm = factsNorm;
        analysis{count}.fitNorm = fitNorm;
        analysis{count}.factsSpar = factsSpar;
        analysis{count}.fitSpar = fitSpar;
        % Tensor Completion 
        [rmseNorm, relFitNorm, rmsesNorm, relFitsNorm] = tensorCompletion(Yn, Fnorm, tcMissing);
        [rmseSpar, relFitSpar, rmsesSpar, relFitsSpar] = tensorCompletion(Ys, Fspar, tcMissing);
        analysis{count}.rmseNorm = rmseNorm;
        analysis{count}.relFitNorm = relFitNorm;
        analysis{count}.rmseSpar = rmseSpar;
        analysis{count}.relFitSpar = relFitSpar;

        analysis{count}.rmsesNorm = rmsesNorm;
        analysis{count}.relFitsNorm = relFitsNorm;
        analysis{count}.rmsesSpar = rmsesSpar;
        analysis{count}.relFitsSpar = relFitsSpar;

        % Saving the C matrices
        analysis{count}.Cnorm = Cnorm;
        analysis{count}.Cspar = Cspar;
        analysis{count}.sizeYn = size(Yn);
        analysis{count}.sizeYs = size(Ys);



        count = count + 1;
    end
    % Y1, Y2 and X_og analysis   
    [F1, Cor1] = getRnC(Y1, ceil(R/2));
    [facts1, fit1] = runCPNMU(Y1, F1);
    [rmse1, relFit1, rmses1, relFits1] = tensorCompletion(Y1, F1, tcMissing);
    analysis{count}.F1 = F1;
    analysis{count}.Cor1 = Cor1;
    analysis{count}.facts1 = facts1;
    analysis{count}.fit1 = fit1;
    analysis{count}.rmse1 = rmse1;
    analysis{count}.relFit1 = relFit1;
    analysis{count}.sizeY1 = size(Y1);
    analysis{count}.rmses1 = rmses1;
    analysis{count}.relFits1 = relFits1;
    
    count = count + 1;
    
    [F2, Cor2] = getRnC(Y2, ceil(R/2));
    [facts2, fit2] = runCPNMU(Y2, F2);
    [rmse2, relFit2, rmses2, relFits2] = tensorCompletion(Y2, F2, tcMissing);
    analysis{count}.F2 = F2;
    analysis{count}.Cor2 = Cor2;
    analysis{count}.facts2 = facts2;
    analysis{count}.fit2 = fit2;
    analysis{count}.rmse2 = rmse2;
    analysis{count}.relFit2 = relFit2;
    analysis{count}.sizeY2 = size(Y2);
    analysis{count}.rmses2 = rmses2;
    analysis{count}.relFits2 = relFits2;

    count = count + 1;
    
    [F_og, Cor_og] = getRnC(X_og, ceil(R/2));
    [facts_og, fit_og] = runCPNMU(X_og, F_og);
    [rmse_og, relFit_og, rmses_og, relFits_og] = tensorCompletion(X_og, F_og, tcMissing);
    analysis{count}.F_og = F_og;
    analysis{count}.Cor_og = Cor_og;
    analysis{count}.facts_og = facts_og;
    analysis{count}.fit_og = fit_og;
    analysis{count}.rmse_og = rmse_og;
    analysis{count}.relFit_og = relFit_og;
    analysis{count}.sizeXog = size(X_og);
    analysis{count}.rmses_og = rmses_og;
    analysis{count}.relFits_og = relFits_og;
    % Saving variables to the file
    
    savePath = strcat(resultPath, sName, '.mat');
%     save(savePath, "minErr", "minErrParams", "minReconErr", "reconErrParams", "numSlices", "sparCountParams", "A", "B", "C1", "C2", "Y1", "Y2", "maxfit", "tracker", "sparseThreshold", "analysis", "tcMissing", "points", "errThreshold");
    save(savePath, "minErr", "minErrParams", "numSlices", "sparCountParams", "A", "B", "C1", "C2", "Y1", "Y2", "maxfit", "tracker", "sparseThreshold", "analysis", "tcMissing", "points", "errThreshold");
    

end
    
function saveToFile(fname, Wn, Ws, BigLam, Copt, P1, P2, Errors, iterations, params, sparseCount)
save(fname, "Wn", "Ws", "BigLam", "Copt", "P1", "P2","Errors", "iterations", "params", "sparseCount");
end



% end



