function err = calRMSE(Xog, X, subs)
a = Xog(subs) - X(subs);
b = a.^2;
meanErr = sum(b)/length(b);
err = sqrt(meanErr);
end
