function [m,c] = zLocalSlope(srcIm)
% function [m,c] = zLocalSlope(srcIm)

        srcFFT=fft2(srcIm); % amplitude spectrum of source image
        imSize=size(srcIm);
        sigma=[64 16 8 4 2]; % list of standard deviations for gaussian derivative filters
        theta=[0 45 90 135]; % list of orientations - NB take as value, so orientation >180 sign ignored
        nSigmas=length(sigma); % how many filters altgether
        nOris=length(theta);

        respAmp=zeros(imSize(1),imSize(2), nSigmas); % store response amplitude for all filters at each pixel
        respPhz=zeros(imSize(1),imSize(2), nSigmas);

        x=ones(imSize(1),imSize(2), nSigmas); % record of log spatial frequency for regression

        for sigIndex=1:nSigmas; % work through list of spatial scales
            x(:,:,sigIndex)=x(:,:,sigIndex)*log2(imSize(1)/sigma(sigIndex)); % log frequency for regression
            dOneGauss=hilbert(diff(Gaussian2D(sigma(sigIndex), imSize/2, [imSize(1)+1 imSize(2)]))); % quadrature filter 

            for ori=1:nOris; %  work through list of steering filter orientations
                filtFFT=fft2(imrotate(dOneGauss,theta(ori),'crop')); % rotate filter
                ifftTemp = fftshift(ifft2(srcFFT.*filtFFT)); % convolve imge with filter 
                fftOUT=abs(ifftTemp);         % take abs amplitude
                fftPHZ=angle(ifftTemp);       % get phase
                respAmp(:,:,sigIndex)=respAmp(:,:,sigIndex)+fftOUT;  % response amplitude at each pixel
                respPhz(:,:,sigIndex)=respPhz(:,:,sigIndex)+fftPHZ;  % response amplitude at each pixel                                
            end
        end

        % linear regression of log amplitude and log frequency at all pixel locations
        y=log2(respAmp); % log amplitude for all SFs
        Sxy=x.*y; % variance of log frequency with log amplitude
        covXY=(sum(Sxy,3)-(sum(x,3).*sum(y,3))/length(sigma))/length(sigma); % covariance of log frequency with log amplitude
        %r=covXY/(std(x,0,3).*std(y,0,3)); % correlation coefficient, if wanted
        m=covXY./var(x,0,3); % slope at each pixel location
        c=mean(y,3)-(m.*mean(x,3)); % intercept? at each pixel location
return;
