% Calculate d' for an mAFC task
%
% Hacker & Ratliff, 1979, Perception & Psychophysics, 26(2), 168-170.

% determines precision of ordinate and area of unit gaussian
prc = -100:100;

% d' lookups -- nVals
% nVals -- precision of lookup table
nVals = 500;
dPrime = linspace(-1,4,nVals);

% how many alternatives?
m = 10;

for tmp = 1:length(dPrime)
    p(tmp) = sum(normpdf(prc-dPrime(tmp)).*normcdf(prc).^(m-1));
end

pc2dPrime = [p' dPrime']