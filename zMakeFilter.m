function madeFilter = zMakeFilter(filtType, fPeak, bWdth, alpha, filtSize)
% function madeFilter = zMakeFilter(filtType, fPeak, bWdth, alpha, filtSize)
%
% filtType: 
%   1 -- isotropic log exponential
%   2 -- isotropic 1/f^-alpha
%   3 -- orientation filter
%   4 -- isotropic log Cosine - Nasanen et al 1998
%   5 -- log Gaussian  
%   6 -- Gaussian 
%
% fPeak:
%
% bWdth:
%
% alpha:
%
% filtSize
%
% CPT -- Jan-3-12 (edits, clean-up)

% Function to make a range of basic filters 
% filtType=5; filtSize=512; bWdth=10*pi/180; fPeak=64; alpha=1;
% update svn.
if length(filtSize)==1;
    filtSize(2)=filtSize(1);
end
filtRadius=round(filtSize/2);

[X,Y]=meshgrid(-filtRadius(2):-filtRadius(2)+filtSize(2)-1,-filtRadius(1):-filtRadius(1)+filtSize(1)-1);                      % 2D matrix of radial distances from centre
radDist=(X.^2+Y.^2).^0.5;                                                                                   % radial distance from centre
radDist(filtRadius(1),filtRadius(2))=0.5;                                                                         % avoid log or divide by zero

if      filtType == 1   madeFilter = exp(-((log(2)*(abs(log(radDist/fPeak))).^3)/((bWdth*log(2)).^3)));     % isotropic log exponential
elseif  filtType == 2   madeFilter = radDist.^-alpha;                                                       % isotropic 1/f^-alpha
elseif  filtType == 3   fPeak=fPeak*pi/180; bWdth=bWdth*pi/180;                                             % convert degrees to radians
                        angDist=atan2(-Y, X);                                                               % orientation filter - angular dist
                        sintheta = sin(angDist); 
                        costheta = cos(angDist);
                        ds = sintheta * cos(fPeak) - costheta * sin(fPeak);                                 % Difference in sine
                        dc = costheta * cos(fPeak) + sintheta * sin(fPeak);                                 % Difference in cosine
                        dtheta = abs(atan2(ds,dc));                                                         % Absolute angular distance
                        madeFilter = exp((-dtheta.^2) / (2 * bWdth^2));                                     % Calculate the angular filter component
 
                        fPeak=fPeak+pi;                                                                     % 180 deg offset in +ve TFs
                        ds = sintheta * cos(fPeak) - costheta * sin(fPeak);                                 % Difference in sine
                        dc = costheta * cos(fPeak) + sintheta * sin(fPeak);                                 % Difference in cosine
                        dtheta = abs(atan2(ds,dc));                                                         % Absolute angular distance
                        madeFilter = madeFilter+exp((-dtheta.^2) / (2 * bWdth^2));                          % Calculate the angular filter component

elseif  filtType == 4   radDist=log2(radDist);                                                             % isotropic log Cosine - Nasanen et al 1998
                        madeFilter = 0.5*(1+cos(pi*(radDist-log2(fPeak))));
                        madeFilter(radDist>(log2(fPeak)+1))=0;
                        madeFilter(radDist<=(log2(fPeak)-1))=0;
elseif  filtType == 5   madeFilter = exp(-((log2(radDist)-log2(fPeak)).^2)/(2*(bWdth))^2);                  % log Gaussian
elseif  filtType == 6   madeFilter = exp(-((radDist-fPeak).^2)/(2*bWdth^2));                                %  Gaussian
else                    if fPeak<0 madeFilter = radDist>=abs(fPeak);                                        % default: hat box, -ve cut off = high-pass,
                        else madeFilter = radDist<=fPeak;                                                    % +ve cut-off = low pass hat box
                        end
end
% subplot(2,1,1); imagesc(madeFilter);
% subplot(2,1,2); plot(madeFilter(filtRadius,:))
madeFilter=fftshift(madeFilter);                                                                            % shift FFT for compatability with FFT2 (0 cpi is top left etc.)
madeFilter(1,1)=0;