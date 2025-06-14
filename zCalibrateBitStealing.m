function calRec = zCalibrateBitStealing(rgbBackground);
%
% calRec = pbCalibrateBitStealing([rgbBackground]);
%

% Prevents MATLAB from reprinting the source code when the program runs.
echo off


% For an explanation of the try-catch block, see the section "Error
% Handling"
% at the end of this document.
try
    fprintf('\nBIT-STEALING CALIBRATION PROCEDURE\n');

    oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);
    whichScreen = max(Screen('Screens'));

   if (exist('rgbBackground','var')==0)
       fprintf('No rgb background provided. Will use [160,160,160] as default.\n');
       rgbBackground=[160 160 160];
   end;
    
    portNumber=1;
    reps=1;
    stimpix=512;
    alldone=0;
    docheck=1;
    getDCoffset=0;
    while (alldone==0)
        gotone=0;
        while (gotone==0)
            fprintf('\tCalibration Parameters:\n');
            fprintf('\t1... screen number = %i\n',whichScreen);
            fprintf('\t2... port number = %i\n',portNumber);
            fprintf('\t3... stimulus size (pixels) = %i\n',stimpix);
            if (docheck==1)
                fprintf('\t4... check & adjust calibration? YES\n');
            else
                fprintf('\t4... check & adjust calibration? NO\n');
            end;   
            fprintf('\t5... reps = %i\n',reps);
            if (getDCoffset==0)
                fprintf('\t6... assume DC offset is zero? YES\n');
            else
                fprintf('\t6... assume DC offset is zero? NO\n');
            end;   
            fprintf('\td... do calibration\n');
            fprintf('\tx... exit\n');
            theInput=lower(input(sprintf('\t>> '),'s'));
            gotone=ismember(theInput,'123456dx');
        end; % while(gotone)

        switch theInput
            case '1'
                tmp = input(sprintf('\t screen number >> '));
                if isnumeric(tmp)
                    whichScreen=round(abs(tmp));
                end;
            case '2'
                tmp = input(sprintf('\t port number >> '));
                if isnumeric(tmp)
                    portNumber=round(abs(tmp));
                end;
            case '3'
                tmp = input(sprintf('\t stimulus size (pixels) >> '));
                if isnumeric(tmp)
                    stimpix=round(abs(tmp));
                end;
            case '4'
                docheck=not(docheck);
            case '5'
                tmp = input(sprintf('\t number of repetitions >> '));
                if isnumeric(tmp)
                    reps=round(abs(tmp));
                end;
            case '6'
                getDCoffset=not(getDCoffset);
            case 'd'
                alldone=1;
            case 'x'
                fprintf('calibration procedure aborted by user\n');
                calRec=NaN;
                return;

        end; % switch theInput
    end; % while alldone




    WaitSecs(0.5); % wait a moment...
    fprintf('\n(calibration)$ please set the display to the desired spatial and temporal resolution\n')
    pbTestGrid(whichScreen,64);
    fprintf('measure dimensions of drawing area...\n');
    pbOutlineDrawingArea(whichScreen);
%     fprintf('(calibration)$ hit any key to continue...\n');
%     WaitSecs(0.25);
%     FlushEvents('keyDown');
%     KbWait(-1,3);

    fprintf('\n(calibration)$ turn on the photometer...\n');
    fprintf('(calibration)$ hit any key to continue...\n');
    WaitSecs(0.25);
    FlushEvents('keyDown');
    KbWait(-1,3);
    fprintf('initializing photometer...\n');
    retval = pr655init(portNumber);

    
    
	    
	% ---------- Window Setup ----------
	% Opens a window.
	screens=Screen('Screens');
	white=WhiteIndex(whichScreen);
	black=BlackIndex(whichScreen);
    gray=round((white+black)/2);
	if gray==white
		gray=black;
	end
	inc=white-gray;

	% Open a double buffered fullscreen window and draw a gray background 
	% to front and back buffers:
    WaitSecs(1);
	[w,wrect]=Screen('OpenWindow',whichScreen, 0,[],32,2);
    

    % get & record screen properties
    hz=Screen('NominalFrameRate', whichScreen);
    fprintf('>>> display frame rate (Hz) = %g\n',hz);
    pixelSize=Screen('PixelSize', whichScreen);
    fprintf('>>> pixel size = %g\n',pixelSize);

    [widthPixels, heightPixels]=Screen('WindowSize', whichScreen);
    fprintf('>>> display size (pixels)[width, height] = [%g,%g]\n',widthPixels,heightPixels);
    [widthcm,heightcm] = pbGetScreenDimensions(whichScreen);
    
    Screen('FillRect',w, rgbBackground);
	Screen('Flip', w);
	Screen('FillRect',w, rgbBackground);
	Screen('Flip', w);
    
    center = [wrect(3) wrect(4)]/2;	% coordinates of screen center (pixels)
    fps=Screen('FrameRate',w);      % frames per second
    if(fps==0)
        fps=67;
        fprintf('WARNING: using default frame rate of %i Hz\n',fps);
    end;
    ifi=Screen('GetFlipInterval', w);






	  

	% ---------- Image Setup ----------
	stimrect=SetRect(0,0,stimpix,stimpix);
	destRect=CenterRect(stimrect,wrect);
	Screen('FillRect',w,rgbBackground,destRect);
	Screen('FillOval',w,[0 0 0],destRect);			
	vbl=Screen('Flip', w,1);
    fprintf('\n\n>>> center photometer on stimulus area and hit a key to continue...\n');
    WaitSecs(0.5);
    FlushEvents('KeyDown');
    KbWait(-1,3);
%     while(KbCheck==0)
% 	end;
    Screen('CloseAll');
    Screen('Preference','SuppressAllWarnings',oldEnableFlag);    
    
    fprintf('taking measurements...\n');
    fprintf('HOLD DOWN ANY KEY TO ABORT...\n\n');
	
	waitframes = 2;
    
    if getDCoffset==1
        fprintf('\n>>> measuring DC offset...\n');
        [tmp,dcOffset,abortFlag]=pbGunMeasurements('red',stimpix,portNumber,[0 0 0],whichScreen,1,0); % DC offset
        if(abortFlag==1)
            calRec=NaN;
            Screen('CloseAll');
            ShowCursor;
            return;
        end;
    else
        dcOffset=0;
        fprintf('\n>>> setting DC offset to zero\n');
    end;
    fprintf('\n>>> measuring background offset...\n');
    [tmp,bkgrndOffset,abortFlag]=pbGunMeasurements('red',stimpix,portNumber,rgbBackground,whichScreen,3,0); % background Offset
    if(abortFlag==1)
        calRec=NaN;
        Screen('CloseAll');
        ShowCursor;
        return;
    end;
    
    iInc=50;
    fprintf('\n>>> measuring red gun...\n');
    [Nred,redData,abortFlag]=pbGunMeasurements('red',stimpix,portNumber,rgbBackground,whichScreen,reps,[10,30,50:iInc:250,255]); % red gun
    if(abortFlag==1)
        calRec=NaN;
        Screen('CloseAll');
        ShowCursor;
        return;
    end;
    fprintf('\n>>> measuring green gun...\n');
    [Ngreen,greenData,abortFlag]=pbGunMeasurements('green',stimpix,portNumber,rgbBackground,whichScreen,reps,[20,30,50:iInc:250,255]); % green
    if(abortFlag==1)
        calRec=NaN;
        Screen('CloseAll');
        ShowCursor;
        return;
    end;
    fprintf('\n>>> measuring blue gun...\n');
    [Nblue,blueData,abortFlag]=pbGunMeasurements('blue',stimpix,portNumber,rgbBackground,whichScreen,reps,[30,50:iInc:250,255]); % blue
    if(abortFlag==1)
        calRec=NaN;
        Screen('CloseAll');
        ShowCursor;
        return;
    end;
    
    fprintf('>>> saving measurements in temporary file gunDataTmpFile.mat\n');
    save gunDataTmpFile Nred redData Ngreen greenData Nblue blueData

    % convert data to Luminance
    redLum=[redData-dcOffset-bkgrndOffset]';
    redLum=max(redLum,0); % get rid of negative values
    % insert zero:
    redLum=[0;redLum];
    redLUT=[0,Nred]';
    % do the same for the green data:
    greenLum=[greenData-dcOffset-bkgrndOffset]';
    greenLum=max(greenLum,0);
    greenLum=[0;greenLum];
    greenLUT=[0,Ngreen]';
    % do the same for the blue data:
    blueLum=[blueData-dcOffset-bkgrndOffset]';
    blueLum=max(blueLum,0);
    blueLum=[0;blueLum];
    blueLUT=[0,Nblue]';
    
    % interpolate data to estimate luminance corresponding to all lut values from 0 to 255
    redNumber=0:255;
    redInterpolated=interp1(redLUT,redLum,redNumber,'pchip');
    greenNumber=0:255;
    greenInterpolated=interp1(greenLUT,greenLum,greenNumber,'pchip');
    blueNumber=0:255;
    blueInterpolated=interp1(blueLUT,blueLum,blueNumber,'pchip');
    



    rgbvalues=pbBitStealingArray; % create default bitstealing rgb values
    n=size(rgbvalues,1);
    Ltotal=zeros(n,1);

    fprintf('>>> building bit-stealing lookup table...\n')
    for kk=1:n
        ri=rgbvalues(kk,1);
        gi=rgbvalues(kk,2);
        bi=rgbvalues(kk,3);
        rL=interp1(redNumber,redInterpolated,ri);
        gL=interp1(greenNumber,greenInterpolated,gi);
        bL=interp1(blueNumber,blueInterpolated,bi);
        Ltotal(kk)=rL+gL+bL+bkgrndOffset;
    end;

    [LumSorted,ti]=sort(Ltotal);
    rgbSorted=rgbvalues(ti,:);
    n=size(rgbSorted,1);
    rgbNumbers=[1:n]';
    calData=[rgbSorted,rgbNumbers,LumSorted];

	

	% ---------- Window Cleanup ---------- 

	 
	% Restores the mouse cursor.
	ShowCursor;
	
	
    calRec.calType='BITSTEALING';
    calRec.date=datestr(now);
    calRec.stimsize = stimpix;
    calRec.displaypixels =  [widthPixels, heightPixels];
    calRec.framerate = hz;
    calRec.displaycm =  [widthcm, heightcm];
    calRec.pixelsize = pixelSize;    
    calRec.backgroundRGB = rgbBackground;
    bkgrndRGBnumber = pbRGB2Index(rgbBackground,rgbSorted);
    calRec.backgroundNumber = bkgrndRGBnumber;
    calRec.caldata=calData;
    calRec.lmaxminave=pbLookupScalar([pbMaxBITStealingIndex,1,bkgrndRGBnumber],LumSorted,rgbNumbers);
    
    
    calRec = pbCleanAndSortLuminanceTable(calRec);
%     fprintf('(calibration)$ eliminating non-unique values in luminance table\n');
%     L=calRec.caldata(:,5);
%     % now we make sure that every L value is unique; need to do so to make
%     % interp1 routine work; we make everything unique by adding very small
%     % random numbers:
%     k=1;
%     while(k==1)
%         dL=diff(L); % compute difference between adjacent elements in L
%         if(length(find(dL==0))>0) % look for zero differences
%             dL0=find(dL==0)+1; % find the indices and then add 1 to make locations compatible with L
%             iL=0.001*rand(size(dL0)); % random numbers between 0 and 0.001 cd/m^2 (i.e., >>SMALL<<)
%             L(dL0)=L(dL0)+iL;
%             k = 1;
%         else
%             k = 0;
%         end;
%     end; % while
%     L = sort(L);
%     calRec.caldata(:,5)=L; % sort and save

   
    fprintf('(calibration)$ saving raw uncorrected calibration file in curCalRecTmpFileRAW.mat\n');
    save 'curCalRecTmpFileRAW' calRec;
    
    if docheck==1
        setup.whichScreen=whichScreen;
        setup.portNumber=portNumber;
        setup.reps=reps;
        
        L=calRec.caldata(:,5);                
        B=calRec.caldata(:,4);
        dcNumber = calRec.backgroundNumber;
        avgLum = pbBitStealing2Lum(dcNumber,L,B);
        tmpContrast = -0.3:.05:0.3;
        tmpLum = avgLum.*(1+tmpContrast);
        tmpNumber = pbLum2BS(tmpLum,L,B);
%         rn=round([1,0.05*size(calRec.caldata,1),0.125*size(calRec.caldata,1),0.25*size(calRec.caldata,1),tmpNumber,0.5*size(calRec.caldata,1),0.9*size(calRec.caldata,1),0.95*size(calRec.caldata,1),size(calRec.caldata,1)] );
        rn=round([tmpNumber,[0.05:0.1:0.45]*size(calRec.caldata,1),[0.65:0.1:0.95]*size(calRec.caldata,1)]);
        rn = sort(rn);
        %         rn=round([1,[0.1:0.05:1].*size(calRec.caldata,1)] );
        fprintf('>>> measuring calibration errors...\n');
        errRec=pbCheckCalibration(calRec,rn,setup);
        fprintf('(calibration)$ adjusting lookup table...\n');
        calRec=pbCorrectCalibration(calRec,errRec);
        fprintf('(calibration)$ saving >>ADJUSTED<< calibration file in curCalRecTmpFileADJUSTED.mat\n');
        save 'curCalRecTmpFileADJUSTED' calRec;
        fprintf('>>> measuring errors in adjusted calibration...\n');
        errRec2=pbCheckCalibration(calRec,rn,setup);
    end;
        
        

catch
   
	% ---------- Error Handling ---------- 
	% If there is an error in our code, we will end up here.

	% The try-catch block ensures that Screen will restore the display and return us
	% to the MATLAB prompt even if there is an error in our code.  Without this try-catch
	% block, Screen could still have control of the display when MATLAB throws an error, in
	% which case the user will not see the MATLAB prompt.
	Screen('CloseAll');

	% Restores the mouse cursor.
	ShowCursor;
    
%     % Restore preferences
%     Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
%     Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);

	% We throw the error again so the user sees the error description.
	psychrethrow(psychlasterror);

end
%     function [qual,L,U,V] = getMeasurement(w,bkgrndRGB,rgb,destRect,reps)
%         Priority(MaxPriority(w));
%         Screen('FillRect',w,bkgrndRGB);
%         Screen('FillOval',w,rgb,destRect);
%         vbl=Screen('Flip', w,1);
%         WaitSecs(0.2);
%         Lm=zeros(reps,1);
%         Um=zeros(reps,1);
%         Vm=zeros(reps,1);
%         qualm=zeros(reps,1);
%         for kk=1:reps
%             WaitSecs(0.2);
%             [qualm(kk),Lm(kk),Um(kk),Vm(kk)]=pb650Measure;
%             if KbCheck
%                 break;
%             end;
%         end;
%         qual=min(qualm);
%         L=mean(Lm);
%         U=mean(Um);
%         V=mean(Vm);
%         finalprio = Priority(0);
%     end
% 
%     function calFitRecord=pbFitBitStealingData(calRecord)
% 
%         caldata=calRecord.caldata;
%         if (size(caldata,1)<2)
%             calFitRecord=calRecord;
%             calFitRecord.ABKG=NaN;
%             calFitRecord.calmatrix=NaN;
%             warning('Insufficient points to fit pelli function');
%         else
%             
%             bitsNumbers = caldata(:,8);
%             lumValues = caldata(:,5);
%             % initial parameters
%             alpha = min(min(caldata(:,5)));
%             beta = .01;
%             kappa = .01;
%             gamma = 2;
%             initcoeffs = [alpha beta kappa gamma];
% 
%             % fits
%             coeffs = pbPelliFit(bitsNumbers,lumValues,initcoeffs);
% 
%             bn = 1:pbMaxBITStealingIndex;
%             bn = bn';
%             rgb = pbBitStealing2RGB(bn);
%             L = pbPelliPower(coeffs,bn);
% 
%             % final calibration plot
%             plot(bn,L,'k-');
%             ylabel('Luminance (cd/m^2)');
%             xlabel('Index');
%             title('Look-Up Table');		
% 
%             drawnow;
% 
% 
%             calFitRecord=calRecord;
%             calFitRecord.ABKG=coeffs;
%             calFitRecord.calmatrix=[rgb,L,bn];
%         end;
% 
% 
%     end
% 
% 
% end
% 













