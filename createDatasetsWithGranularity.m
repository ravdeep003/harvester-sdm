function Z = createDatasetsWithGranularity(X, numOfBucketsPerSlice)
% X: is a 3 mode tensor
s = size(X);
I = s(1); J = s(2); K = s(3);
% Sanity Check
% if nnz(X) <= numOfBuckets
%     error('Dataset does not have enough entries to create dataset with minute granularities ')
% end
subs = [];
values = [];
last = 0;
for m = 1:K
    fSlice = X(:,:,m);
    numOfNZ = nnz(fSlice);
    % disp(numOfNZ);
    if numOfNZ == 0
        last = last + numOfBucketsPerSlice;
        continue
    end
    [indexs, value] = find(fSlice);
    zs = randi(numOfBucketsPerSlice, numOfNZ, 1);
%     disp(zs);
    zs = zs + last;
   
%     disp(last);
    subs = [subs; indexs zs];
    values = [values; value];
    last = last + numOfBucketsPerSlice;
%     disp(subs);
end
% disp(last);
if last ~= K*numOfBucketsPerSlice
    error('Number of Slices are not accounted for!')
end
Z = sptensor(subs, values, [I, J, last]);
disp(size(Z));
end