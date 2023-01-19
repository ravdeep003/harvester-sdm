function Z = createDatasetWithGranularityCountData(X, numOfBucketsPerSlice)
% X: is a 3 mode tensor
s = size(X);
I = s(1); J = s(2); K = s(3);
% Sanity Check
% if nnz(X) <= numOfBuckets
%     error('Dataset does not have enough entries to create dataset with minute granularities ')
% end
% newK = K * numOfBucketsPerSlice;

subs = [];
% values = [];
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
    sumOfVal = sum(value);
    lenVal = length(value);
    inds = zeros(sumOfVal, 2);
%     vals = zeros(sumOfVal, 1);
    count = 1;
    for j=1:lenVal
        v = value(j);
        if v == 1
            inds(count,:) = indexs(j, :);
            count = count + 1;
        elseif v > 1
            inds(count:count+v-1, :) = repmat(indexs(j,:), v, 1);
            count = count + v;
        end
    end
    zs = randi(numOfBucketsPerSlice, sumOfVal, 1);
%     disp(zs);
    zs = zs + last;
   
%     disp(last);
    subs = [subs; inds zs];
%     values = [values; value];
    last = last + numOfBucketsPerSlice;
%     disp(subs);
end
disp(last);
if last ~= K*numOfBucketsPerSlice
    error('Number of Slices are not accounted for!')
end
Z = sptensor(subs, 1, [I, J, last]);
disp(size(Z));
end