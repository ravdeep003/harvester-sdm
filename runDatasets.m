function runDatasets(I, J, K, R, numOfDatasets, sparsity, numOfBucketsPerSlice)
% numOfDatasets = 10;
% I=10; J=10; K=10;
% R = 5;
% numOfBuckets = 50;
% sparsity = 0.1;
folderName = sprintf('datasets/syntheticDatasets/ten_%dX%dX%d_%d_%d/', I, J, K, R, numOfBucketsPerSlice); 
if ~exist(folderName, 'dir')
       mkdir(folderName)
end
i = 1;
count = 0;
while i <= numOfDatasets
    count = count + 1;
% for i=1:numOfDatasets
    fname = sprintf('ten_%dX%dX%d_%d_%d_%d.mat', I, J, K, R, numOfBucketsPerSlice, i);
    fname = strcat(folderName, fname);
%     [A,B,C,initialRank] =  createDatasetGeneric(I, J, K, R, batch);
    A = sprand(I, R, sparsity);
    B = sprand(J, R, sparsity);
    C = sprand(K, R, sparsity);
    X_og = tensor(ktensor(ones(R,1), full(A), full(B), full(C)));
    X = createDatasetsWithGranularity(X_og, numOfBucketsPerSlice);
    size_X = size(X);
    sparisity_tensor_og = nnz(X_og)/(I*J*K);
    sparisity_tensor = nnz(X)/(I*J*size_X(3));
    disp(sparisity_tensor);
    disp(sparisity_tensor_og);
    save(fname, 'A', 'B', 'C', 'X_og', 'X', 'R', 'numOfBucketsPerSlice', 'sparsity', 'sparisity_tensor', 'sparisity_tensor_og');
    index = X.subs;
    uniq = unique(index(:, 3));
    disp(size(uniq));
%     if size(uniq, 1) ~= (K*numOfBucketsPerSlice)
    if size(uniq, 1) < 0.95*(K*numOfBucketsPerSlice)
        continue;
    else
        disp('Done!!!')
        i = i + 1;
    end
    
    % For tensor RL
%     Z = checkTensor(X);
%     Z = double(Z);
%     save(fname, 'A', 'B', 'C', 'X_og', 'X', 'R', 'Z', 'numOfBucketsPerSlice', 'sparsity', '-v7');
end
disp(count);
end