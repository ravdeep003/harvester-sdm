function W = normAggregation(Copt, threshold)
% [K, F] = size(Copt);
% norms = zeros(K,1);
% for i=1:K
%     norms(i) = norm(Copt(i,:));
% end
% normSorted = sort(norms, 'descend');
% %semilogy(normSorted);
% plot(normSorted);
% a = sum(normSorted);
% for j=1:K
% ratio = sum(normSorted(1:j))/a;
% if ratio > 0.5
% disp(j)
% break
% end
% end

%end
floatThreshold = 10^-6;
%threshold = 0.10;
[K, F] = size(Copt);
lookUp = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
rowNum = 1;
prev = Copt(1,:);
i = 1;
j = 2;
while j <=K
    
    if norm(Copt(j,:)) == 0
        j = j + 1;
        if j > K
            lookUp(rowNum) = [i, j-1];
        end
        continue;
        
    end
    
    current = sum(Copt(i:j,:), 1);
    prevNorm = norm(prev);
    currentNorm = norm(current);
    delta = (currentNorm - prevNorm)/prevNorm;
    
    if abs(delta) < floatThreshold
        delta = 0;
    end
    
    if isnan(delta)
        delta = 0;
    end
    if delta < threshold && delta ~=0
        lookUp(rowNum) = [i, j-1];
        i = j;
        j = j + 1;
        prev = Copt(i, :);
        rowNum = rowNum + 1;
    else
        prev = current;
        j = j+1;
        
    end
    if j > K
        lookUp(rowNum) = [i, j-1];
    end
    
    
end
W = findW(lookUp, K);
end