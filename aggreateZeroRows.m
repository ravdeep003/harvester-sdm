function W = aggreateZeroRows(Ctilde)

[K, ~] = size(Ctilde);
lookUp = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
row_is_zero = all(Ctilde==0,2);

rowNum = 1;
i = 1;
j = 2;
if row_is_zero(i) == 1
    while j <= K
        if row_is_zero(j) == 0
            j = j + 1;
            break;
        else
            j = j + 1;
        end
    end
end
% disp(j);
while j <= K
    if row_is_zero(j) == 0
       lookUp(rowNum) = [i, j-1];
       rowNum = rowNum + 1;
       i = j;
       j = j + 1;
    else
       j = j + 1;
    end
end
if i ~= j
   lookUp(rowNum) = [i, j-1];
end
W = findW(lookUp, K);

% Cnew = unique(Ctilde(~row_is_zero, :), 'rows');
%     Ynew = tensor(ktensor({A, B, Cnew}));

end
