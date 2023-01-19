%Ravdeep Pasricha , Ekta Gujral, Vagelis Papalexakis 2019
%Computer Science and Engineering, University of California, Riverside

function Y = aggregateOnFixedInterval(X, interval)
% Input: 3-mode tensor and aggregation interval
% Output: Aggregated tensor Y
start = 1;
last = interval;
sz = size(X);
newK = ceil(sz(3)/interval);
Y = sptensor([],[],[sz(1) sz(2) newK]);
for m=1:newK
    % to handle the case if last interval had only one slice and start &
    % last index the same
    if start == last
      Y(:,:,m) = X(:,:,start);
      break
    end
    Y(:,:,m) = collapse(X(:,:,start:last),3);
    start = last + 1;
    last = last + interval;
    if last > sz(3)
        last = sz(3);
    end

end
end