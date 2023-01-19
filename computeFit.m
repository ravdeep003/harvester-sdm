function fit=computeFit(Xoriginal, Xcomputed)
% Xcomputed = ktensor(Xcomputed)
fit = 1 - norm(Xoriginal-Xcomputed)/norm(Xoriginal);
end 