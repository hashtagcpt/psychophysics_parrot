function [thresh,pdfinfo]=zest(response,params)
% thresh=zest(response,init)
%
% This routine generalizes the ZEST procedure. The first invocation should
% have a second parameter "params" (actually a structure) that specifies the
% various parameters to initialize the ZEST routine. In particular, params
% should have the following fields:
 %   zestA   PDF scale factor
 %   zestB   falling PDF slope
 %   zestC   rising PDF slope
 %   zestmaxrange    the maximum value for possible estimates (usually in
 %                   log units)
 %   zestminrange    the minimum value for possible estimates (usually in
 %                   log units)
 %   zestfa  False alarm rate estimate (0<= fa <=1)
 %   zestmiss    Miss rate estimate (0<= miss <=)
 %   zestbeta    Response function slope
 %   zesteta     "sweat factor" or response criterion parameter
 % If there is a passed structure params, then the value of "response" (though
 % necessary) is ignored.
 %
 % Otherwise, just response (=0 or 1) is passed to ZEST. Based on teh
 % current set of parameters, the routine returns the most probable mean
 % vlaue of the PDF that can either be used for the next trial OR as a final
 % threshold estimate.
 %
 % To be done: return the variance of the current PDF so one could stop at a
 % particular confidence interval rather than after so many trials.
 %
 % Note that this code is currently written with default values for a
 % modulation detection task.
 %
 % For details about the parameters, see Marvit, et al. (2003), JASA
 % 113(6):3348-3361.
 %
 % In the main code, we specify modulation depth as percentage, but it is
 % better expressed and manipulated in a dB scale. So: Convert modulation
 % depth, m, to delta L in dB
 %   DLdB=20*log10((1+m)./(1-m))
 
 % 01/27/06 Petr Janata
 % - isolated the initialization routine a bit more
 % - persistent variable that did not need to be persistent were removed
 % - changed beta to b to avoid overriding beta()
 
 % CHeck Default values. Currently for 2AFC
 persistent is_inited
 persistent T fa miss b eta q meanpdf convert use_log
 
 % Initialize
 if isempty(is_inited)
   fprintf('Initializing PDF ...\n');
   
   % Parameters for Initial PDF for ZEST
   if isfield(params,'zestA') A=params.zestA;, else, 
     A=1;    % Scale factor to start with unity pdf area
   end
   if isfield(params,'zestB') B=params.zestB;, else, 
     B=3.0;  % Falling slope
   end
   if isfield(params,'zestC') C=params.zestC;, else, 
     C=1.5;  % Rising slope
   end    
   if isfield(params,'zestmaxrange') maxrange=params.zestmaxrange;, else, 
     maxrange=-2.5;
   end
   if isfield(params,'zestminrange') minrange=params.zestminrange;, else, 
     minrange=2.5;
   end
   
   % Parameters for Response function (Weibull function) (P(yes) given stimulus)
   if isfield(params,'zestfa') fa=params.zestfa;, else, 
     fa=0.50;   %gamma in the text, false alarm rate (guess rate for 2AFC)
   end
   if isfield(params,'zestmiss') miss=params.zestmiss;, else, 
     miss=0.01; %delta in the text, miss rate (1/2 inattention rate for 2AFC)
   end
   if isfield(params,'zestbeta') b=params.zestbeta;, else, 
     b=.6;    %beta in the text, slope of response function
   end
   if isfield(params,'zesteta') eta=params.zesteta;, else, 
     eta=0;     %eta in the text, "sweat factor" or response criterion parameter
   end
   
   % If a vector of DLs has been provided, use it
   if isfield(params,'T')
     T = params.T;
   else
     % Create a discrete vector of the extent/range of possible DLs
     T=linspace(minrange,maxrange,1000); % Linear DL's can vary from .01 dB to 20 dB in .01 dB increments
   end
   
   % Starting params
   if isfield(params,'zestinit') 
     m=params.zestinit; 
   else 
     m=.5; % Initially, start with 50% AMdepth
   end
   
   % Are we doing everything on a logscale
   if isfield(params,'logscale')
     use_log = params.logscale;
   else
     use_log = 1; 
   end
   
   % But convert it to log(dB)
   if use_log
     % Use initial "guess" as midpoint of PDF
     init_t=log10(20*log10((1+m)/(1-m))); 
   else                     
     init_t = m;
   end
   
   % Finally, flag to know how to return the threshold
   % POssibilities include 'm' (AMdepth->(0,100)%), 'mdB', 'logmdB'

   % 01/27/06 PJ changed (incorrect) reference to params.convert to params.zestconvert
   if isfield(params,'zestconvert') convert=params.zestconvert; else,   
     convert='m';
   end
   
   % Calculate the initial PDF
   q=A./(B*exp(-C*(T-init_t)) + C*exp(B*(T-init_t)));
   
   % Normalize area under q to be 1
   q = q/sum(q);
   
   meanpdf=init_t;
 
   thresh = convert_thresh(meanpdf, convert, use_log);
 
   pdfinfo.q = q;
   pdfinfo.T = T;
   pdfinfo.meanpdf = meanpdf;
   
   is_inited = 1;
   return
 end % if isempty(is_inited)
 
 % If we just have a response, calculate the next thresh. The prior
 % thresh estimate (stimulus value) was meanpdf.
 
 %   Psychometric function (Weibull):p is  model prob of resp given log_lev_diff if true log_DL is T
 p=1-miss-((1-fa-miss)*exp(-10.^(b*(meanpdf-T+eta))));
 if response==0
   p=1-p;
 end
 
 % Compute the next q (the next pdf)
 q=p.*q;
 
 % Normalize q
 q = q/sum(q);
 
 meanpdf=sum(T.*q)/sum(q); % Calculate new midpoint
 
 % Make sure that the new midpoint falls on a location on our scale
 if isempty(find(T == meanpdf))
   tidx = max(find(T < meanpdf));
   if isempty(tidx)
     tidx = 1;
   end
   meanpdf = T(tidx);
 end
 
 thresh = convert_thresh(meanpdf, convert, use_log);
 
 pdfinfo.q = q;
 pdfinfo.T = T;
 pdfinfo.meanpdf = meanpdf;
 
 return
   
 function thresh=convert_thresh(meanpdf, convert_type, use_log)
   switch convert_type
     case 'm'
       if use_log
     % De-logify
     antimean=10^meanpdf;
     % Now, de-dBify
     thresh=((10^(antimean/20))-1)/((10^(antimean/20))+1);
       else
     thresh = meanpdf;
       end
     case 'mdB'
       if use_log
     % Just de-logify
     thresh=10^meanpdf;
       end
     otherwise
       thresh=meanpdf;
   end

