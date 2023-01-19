function fit = relativeFit(Xoriginal, Xcomputed)
    a = norm(Xoriginal-Xcomputed);
    b = norm(Xoriginal);
    fit = 1 - a/b;
end


