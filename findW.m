function W = findW(lookup, n)
% Takes lookup Map(or dictionary) which has k keys (aggreated
% dimensions) & indexes for aggregating slices and n.
% Return aggregated W matrix
k = lookup.Count;
indi = zeros(n, 1);
indj = zeros(n, 1);
i = 1;
j = 0;
for m = 1:k
    val = lookup(m);
    list = val(1):val(2);
    len = length(list);
    j = j + len;
    indi(i:j) = m;
    indj(i:j) = list;
    i = j + 1;
end
W = sparse(indi, indj, 1);

end