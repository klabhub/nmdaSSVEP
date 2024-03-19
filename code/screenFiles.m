% This script performs quality checks to determine whether recording sites
% should be included and counts number trials that were included or
% excluded. Additionally, example signals for figures 2 and 3 are generated
%
% Companion code for:
%
% N-methyl d-aspartate receptor hypofunction reduces steady state visual
% evoked potentials (2024)
% Alexander Schielke & Bart Krekelberg
% Center for Molecular and Behavioral Neuroscience
% Rutgers University - Newark 

%where are data located and where should results be saved
sourceFolder = strrep(pwd,'code','data\combined\');
targetFolder = strrep(pwd,'code','data\processed\');
resultsFolder = strrep(pwd,'code','data\results\');

%do the outputFolders exist 
%(this should be the case once the code has been run a least once)
if ~exist(targetFolder,'dir')
    mkdir([targetFolder 'processed\']);
end 

if ~exist([resultsFolder 'results\'],'dir')
    mkdir([resultsFolder 'results\']);
end 

fileNames = dir(sourceFolder);
fileNames = {fileNames.name};
fileNames(1:2) = [];
time = -800:2600; %trial duration with stimulus onset at 0
%by file
totalElectrodeCntr = 0;
for fileCntr = 1:length(fileNames)

    tempFile = load([sourceFolder fileNames{fileCntr}]);
    tempFile = tempFile.data;
    uCond = unique(tempFile.lfp.trialInfo.conIdent{1});
    fileName = strrep(fileNames{fileCntr},'.mat','');
    fileName = str2double(fileName(5:end));


    for electrodeCntr = 1:size(tempFile.lfp.signal{1},3)
        totalElectrodeCntr = totalElectrodeCntr+1;

        %track trials excluded because of
        %   -blinks
        %   -missing data
        %   -artifacts
        %   -baseline artifacts
        eyeClosedSaline = tempFile.lfp.trialInfo.outlierInfo{1}.electrode(electrodeCntr).eyesClosed;
        nanTrialsSaline = tempFile.lfp.trialInfo.outlierInfo{1}.electrode(electrodeCntr).nanTrials;
        artifactsSaline = tempFile.lfp.trialInfo.outlierInfo{1}.electrode(electrodeCntr).artifact;
        baselineArtifactsSaline = detectOutliers(tempFile.lfp.signal{1}(time>=-800 & time<0,:,electrodeCntr),4)';

        eyeClosedKetamine = tempFile.lfp.trialInfo.outlierInfo{2}.electrode(electrodeCntr).eyesClosed;
        nanTrialsKetamine = tempFile.lfp.trialInfo.outlierInfo{2}.electrode(electrodeCntr).nanTrials;
        artifactsKetamine = tempFile.lfp.trialInfo.outlierInfo{2}.electrode(electrodeCntr).artifact;
        baselineArtifactsKetamine = detectOutliers(tempFile.lfp.signal{2}(time>=-800 & time<0,:,electrodeCntr),4)';

        uEyeClosedSaline = eyeClosedSaline;
        uNanTrialsSaline = nanTrialsSaline;
        uNanTrialsSaline(uEyeClosedSaline) = 0;
        uArtifactsSaline = (artifactsSaline + baselineArtifactsSaline)>0;
        uArtifactsSaline(uEyeClosedSaline | uNanTrialsSaline) = 0;
        uEyeClosedKetamine = eyeClosedKetamine;
        uNanTrialsKetamine = nanTrialsKetamine;
        uNanTrialsKetamine(uEyeClosedKetamine) = 0;
        uArtifactsKetamine = (artifactsKetamine + baselineArtifactsKetamine)>0;
        uArtifactsKetamine(uEyeClosedKetamine | uNanTrialsKetamine) = 0;

    	%trials that do not contains artifacts, nans or blinks 
        allIncludedTrialsSaline = ~((tempFile.lfp.trialInfo.outlierInfo{1}.electrode(electrodeCntr).eyesClosed + ...
                                tempFile.lfp.trialInfo.outlierInfo{1}.electrode(electrodeCntr).nanTrials + ...
                                tempFile.lfp.trialInfo.outlierInfo{1}.electrode(electrodeCntr).artifact)>0);

        allIncludedTrialsKetamine = ~((tempFile.lfp.trialInfo.outlierInfo{2}.electrode(electrodeCntr).eyesClosed + ...
                                tempFile.lfp.trialInfo.outlierInfo{2}.electrode(electrodeCntr).nanTrials + ...
                                tempFile.lfp.trialInfo.outlierInfo{2}.electrode(electrodeCntr).artifact)>0);

        %what are the conditions
        conditionsSaline = tempFile.lfp.trialInfo.conIdent{1};
        conditionsKetamine = tempFile.lfp.trialInfo.conIdent{2};

        %time after injection that a trial was completed
        sessionTimeSaline = tempFile.lfp.trialInfo.realTime{1};
        sessionTimeKetamine = tempFile.lfp.trialInfo.realTime{2};

        subselectionSaline = sessionTimeSaline<=60;
        subselectionKetamine = sessionTimeKetamine<=60;
        allIncludedTrialsSaline = allIncludedTrialsSaline & subselectionSaline;
        allIncludedTrialsKetamine= allIncludedTrialsKetamine & subselectionKetamine;
        useInfo.subject(totalElectrodeCntr,:) = tempFile.subject;
        useInfo.session(totalElectrodeCntr) = fileName;
        useInfo.electrode(totalElectrodeCntr) = electrodeCntr;

        
        useInfo.noEyeData.saline(totalElectrodeCntr) = size(tempFile.eye.signal{1},1)==1;
        useInfo.noEyeData.ketamine(totalElectrodeCntr) = size(tempFile.eye.signal{2},1)==1;

        useInfo.rejectedTrials.saline.nrFixationBreakTrials(totalElectrodeCntr,1) = sum(uEyeClosedSaline(subselectionSaline));
        useInfo.rejectedTrials.saline.nrNaNTrials(totalElectrodeCntr,1) = sum(uNanTrialsSaline(subselectionSaline));
        useInfo.rejectedTrials.saline.nrArtifactTrials(totalElectrodeCntr,1) = sum(uArtifactsSaline(subselectionSaline));
        useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(totalElectrodeCntr,1) = sum(uEyeClosedKetamine(subselectionKetamine));
        useInfo.rejectedTrials.ketamine.nrNaNTrials(totalElectrodeCntr,1) = sum(uNanTrialsKetamine(subselectionKetamine));
        useInfo.rejectedTrials.ketamine.nrArtifactTrials(totalElectrodeCntr,1) = sum(uArtifactsKetamine(subselectionKetamine));
        

        for conditionCntr = 1:numel(uCond)

            useInfo.rejectedTrials.saline.nrFixationBreakTrials(totalElectrodeCntr,conditionCntr+1) = sum(uEyeClosedSaline(subselectionSaline & conditionsSaline==uCond(conditionCntr)));
            useInfo.rejectedTrials.saline.nrNaNTrials(totalElectrodeCntr,conditionCntr+1) = sum(uNanTrialsSaline(subselectionSaline & conditionsSaline==uCond(conditionCntr)));
            useInfo.rejectedTrials.saline.nrArtifactTrials(totalElectrodeCntr,conditionCntr+1) = sum(uArtifactsSaline(subselectionSaline & conditionsSaline==uCond(conditionCntr)));
            useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(totalElectrodeCntr,conditionCntr+1) = sum(uEyeClosedKetamine(subselectionKetamine & conditionsKetamine==uCond(conditionCntr)));
            useInfo.rejectedTrials.ketamine.nrNaNTrials(totalElectrodeCntr,conditionCntr+1) = sum(uNanTrialsKetamine(subselectionKetamine & conditionsKetamine==uCond(conditionCntr)));
            useInfo.rejectedTrials.ketamine.nrArtifactTrials(totalElectrodeCntr,conditionCntr+1) = sum(uArtifactsKetamine(subselectionKetamine & conditionsKetamine==uCond(conditionCntr)));


            %include only trials of recordings that have at least 20 trials for that condition
            useInfo.trialSelection.saline{totalElectrodeCntr,conditionCntr+1} = allIncludedTrialsSaline & conditionsSaline==uCond(conditionCntr);
            useInfo.trialSelection.saline{totalElectrodeCntr,conditionCntr+1} = (useInfo.trialSelection.saline{totalElectrodeCntr,conditionCntr+1}) * sum(useInfo.trialSelection.saline{totalElectrodeCntr,conditionCntr+1})>=20;
            useInfo.trialSelection.ketamine{totalElectrodeCntr,conditionCntr+1} = allIncludedTrialsKetamine & conditionsKetamine==uCond(conditionCntr);
            useInfo.trialSelection.ketamine{totalElectrodeCntr,conditionCntr+1} = useInfo.trialSelection.ketamine{totalElectrodeCntr,conditionCntr+1} * sum(useInfo.trialSelection.ketamine{totalElectrodeCntr,conditionCntr+1})>=20;

            useInfo.rejectedTrials.saline.sufficientTrials(totalElectrodeCntr,conditionCntr) = sum(useInfo.trialSelection.saline{totalElectrodeCntr,conditionCntr+1})>=20;
            useInfo.rejectedTrials.ketamine.sufficientTrials(totalElectrodeCntr,conditionCntr) = sum(useInfo.trialSelection.ketamine{totalElectrodeCntr,conditionCntr+1})>=20;


            %calculate Onset Response Ratio (ORR) by using only first 60 minutes
            tempMeanSal = mean(tempFile.lfp.signal{1}(:,allIncludedTrialsSaline & conditionsSaline==uCond(conditionCntr),electrodeCntr),2,'omitnan');
            baselineStd = std(abs(tempMeanSal(time>=-500 & time<0)));
            onsetMean = mean(abs(tempMeanSal(time>=51 & time<=250)));
            onsetResponseRatio = (onsetMean)/baselineStd;
            useInfo.snr.saline(totalElectrodeCntr,conditionCntr) = onsetResponseRatio;
            averageSignal.saline(:,conditionCntr,totalElectrodeCntr) = tempMeanSal;

            tempMeanKet = mean(tempFile.lfp.signal{2}(:,allIncludedTrialsKetamine & conditionsKetamine==uCond(conditionCntr),electrodeCntr),2,'omitnan');
            baselineStd = std(abs(tempMeanKet(time>=-500 & time<0)));
            onsetMean = mean(abs(tempMeanKet(time>=51 & time<=250)));
            onsetResponseRatio = (onsetMean)/baselineStd;
            useInfo.snr.ketamine(totalElectrodeCntr,conditionCntr) = onsetResponseRatio;
            averageSignal.ketamine(:,conditionCntr,totalElectrodeCntr) = tempMeanKet;

            %use only first 60 minutes to calculate zScored signal
            combinedSignal = mean([tempFile.lfp.signal{1}(:,allIncludedTrialsSaline & conditionsSaline==uCond(conditionCntr),electrodeCntr) tempFile.lfp.signal{2}(:,allIncludedTrialsKetamine & conditionsKetamine==uCond(conditionCntr),electrodeCntr)],2);
            combinedSignalStd = std(combinedSignal(time>=-500 & time<0));
            signalSalZScored = tempMeanSal/combinedSignalStd;
            signalKetZScored = tempMeanKet/combinedSignalStd;

            zScoredSignal.saline(:,conditionCntr,totalElectrodeCntr) = signalSalZScored;
            zScoredSignal.ketamine(:,conditionCntr,totalElectrodeCntr) = signalKetZScored;

        end
    end
end



%% book keeping: create information about rejected electrodes and trials
%how many electrodes were rejected becaue of snr (we only use the 0 Hz
%condition to determine SNR
rejectInfo.snr.saline = useInfo.snr.saline(:,1)<2.5 & useInfo.snr.ketamine(:,1)>=2.5;   %only saline recording is bad
rejectInfo.snr.ketamine = useInfo.snr.ketamine(:,1)<2.5 & useInfo.snr.saline(:,1)>=2.5; %only ketamine recording is bad
rejectInfo.snr.both = useInfo.snr.ketamine(:,1)<2.5 & useInfo.snr.saline(:,1)<2.5; %both, saline and ketamine recording are bad

%how many electrodes that were not excluded so far were rejected because
%either the saline or ketamine recording had too few trials left
rejectInfo.insufficientTrials.saline = (useInfo.rejectedTrials.ketamine.sufficientTrials-useInfo.rejectedTrials.saline.sufficientTrials)==1;
rejectInfo.insufficientTrials.saline(useInfo.snr.saline(:,1)<2.5 | useInfo.snr.ketamine(:,1)<2.5,:) = 0;    %do not count electrodes that have already been excluded
rejectInfo.insufficientTrials.ketamine = (useInfo.rejectedTrials.ketamine.sufficientTrials-useInfo.rejectedTrials.saline.sufficientTrials)==-1;
rejectInfo.insufficientTrials.ketamine(useInfo.snr.saline(:,1)<2.5 | useInfo.snr.ketamine(:,1)<2.5,:) = 0;  %do not count electrodes that have already been excluded
rejectInfo.insufficientTrials.both = (useInfo.rejectedTrials.saline.sufficientTrials+ useInfo.rejectedTrials.ketamine.sufficientTrials)==0;
rejectInfo.insufficientTrials.both(useInfo.snr.saline(:,1)<2.5 & useInfo.snr.ketamine(:,1)<2.5,:) = 0;      %do not count electrodes that have already been excluded

%how many electrodes that were not excluded so far were rejected because we
%do not have pupil data available
rejectInfo.noEye = (useInfo.noEyeData.ketamine | useInfo.noEyeData.saline)'; %both are actually the same anyway
rejectInfo.noEye(useInfo.snr.saline(:,1)<2.5 | useInfo.snr.ketamine(:,1)<2.5) = 0;
rejectInfo.noEye = repmat(rejectInfo.noEye,[1,5]);

rejectInfo.noEye(rejectInfo.insufficientTrials.saline | rejectInfo.insufficientTrials.ketamine | rejectInfo.insufficientTrials.both) = 0;


%combining information about electrodes that had sufficients trials and a
%good ORR in the 0 Hz condition provides the  inclusion critereon we will 
% use for all further analyses for this study
useInfo.doUse = useInfo.snr.saline(:,1)>=2.5 & useInfo.snr.ketamine(:,1)>=2.5 & ...     %electrodes with an snr of at least 2.5
                useInfo.rejectedTrials.saline.sufficientTrials & useInfo.rejectedTrials.ketamine.sufficientTrials & ...
                ~rejectInfo.noEye;%electrodes with at least 20 trials are included


%of the included electrodes, what is the number trials that were rejected
    % -because the monkey lost fixation (e.g., due to blink) during a trial
    for conditionCntr = 2:size(useInfo.rejectedTrials.saline.nrFixationBreakTrials,2)
        rejectedTrials.saline.perCondition.blinks.mean(conditionCntr-1) = mean(useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr));
        rejectedTrials.saline.perCondition.blinks.std(conditionCntr-1) = std(useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr));
        rejectedTrials.saline.perCondition.blinks.range(conditionCntr-1,:) = [min(useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)) max(useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr))];
        rejectedTrials.ketamine.perCondition.blinks.mean(conditionCntr-1) = mean(useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr));
        rejectedTrials.ketamine.perCondition.blinks.std(conditionCntr-1) = std(useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr));
        rejectedTrials.ketamine.perCondition.blinks.range(conditionCntr-1,:) = [min(useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)) max(useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr))];
        rejectedTrials.combined.perCondition.blinks.mean(conditionCntr-1) = mean([useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr); useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)]);
        rejectedTrials.combined.perCondition.blinks.std(conditionCntr-1) = std([useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr); useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)]);
        rejectedTrials.combined.perCondition.blinks.range(conditionCntr-1,:) = [min([useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr); useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)]) max([useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr); useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)])];
    
    end
    rejectedTrials.saline.acrossConditions.blinks.mean = mean(useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse));
    rejectedTrials.saline.acrossConditions.blinks.std = std(useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse));
    rejectedTrials.saline.acrossConditions.blinks.range = [min(useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse)) max(useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse))];
   	rejectedTrials.ketamine.acrossConditions.blinks.mean = mean(useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse));
    rejectedTrials.ketamine.acrossConditions.blinks.std = std(useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse));
    rejectedTrials.ketamine.acrossConditions.blinks.range = [min(useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse)) max(useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse))];
    rejectedTrials.combined.acrossConditions.blinks.mean = mean([useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse); useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse)]);
    rejectedTrials.combined.acrossConditions.blinks.std = std([useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse); useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse)]);
    rejectedTrials.combined.acrossConditions.blinks.range = [min([useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse); useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse)]) max([useInfo.rejectedTrials.saline.nrFixationBreakTrials(useInfo.doUse); useInfo.rejectedTrials.ketamine.nrFixationBreakTrials(useInfo.doUse)])];
    
    % -because a trial had missing data in the recording of local field
    % potentials (this has apparently not happened)
  	for conditionCntr = 2:size(useInfo.rejectedTrials.saline.nrFixationBreakTrials,2)
        rejectedTrials.saline.perCondition.nans.mean(conditionCntr-1) = mean(useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr));
        rejectedTrials.saline.perCondition.nans.std(conditionCntr-1) = std(useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr));
        rejectedTrials.saline.perCondition.nans.range(conditionCntr-1,:) = [min(useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)) max(useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr))];
        rejectedTrials.ketamine.perCondition.nans.mean(conditionCntr-1) = mean(useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr));
        rejectedTrials.ketamine.perCondition.nans.std(conditionCntr-1) = std(useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr));
        rejectedTrials.ketamine.perCondition.nans.range(conditionCntr-1,:) = [min(useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)) max(useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr))];
        rejectedTrials.combined.perCondition.nans.mean(conditionCntr-1) = mean([useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr); useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)]);
        rejectedTrials.combined.perCondition.nans.std(conditionCntr-1) = std([useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr); useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)]);
        rejectedTrials.combined.perCondition.nans.range(conditionCntr-1,:) = [min([useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr); useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)]) max([useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr); useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)])];  
    end
    rejectedTrials.saline.acrossConditions.nans.mean = mean(useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse));
    rejectedTrials.saline.acrossConditions.nans.std = std(useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse));
    rejectedTrials.saline.acrossConditions.nans.range = [min(useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse)) max(useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse))];
   	rejectedTrials.ketamine.acrossConditions.nans.mean = mean(useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse));
    rejectedTrials.ketamine.acrossConditions.nans.std = std(useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse));
    rejectedTrials.ketamine.acrossConditions.nans.range = [min(useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse)) max(useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse))];
    rejectedTrials.combined.acrossConditions.nans.mean = mean([useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse); useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse)]);
    rejectedTrials.combined.acrossConditions.nans.std = std([useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse); useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse)]);
    rejectedTrials.combined.acrossConditions.nans.range = [min([useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse); useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse)]) max([useInfo.rejectedTrials.saline.nrNaNTrials(useInfo.doUse); useInfo.rejectedTrials.ketamine.nrNaNTrials(useInfo.doUse)])];
   


    % -because a trial had artifacts in the lfp recording (e.g., movement) 
  	for conditionCntr = 2:size(useInfo.rejectedTrials.saline.nrFixationBreakTrials,2)
        rejectedTrials.saline.perCondition.artifacts.mean(conditionCntr-1) = mean(useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr));
        rejectedTrials.saline.perCondition.artifacts.std(conditionCntr-1) = std(useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr));
        rejectedTrials.saline.perCondition.artifacts.range(conditionCntr-1,:) = [min(useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)) max(useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr))];
        rejectedTrials.ketamine.perCondition.artifacts.mean(conditionCntr-1) = mean(useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr));
        rejectedTrials.ketamine.perCondition.artifacts.std(conditionCntr-1) = std(useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr));
        rejectedTrials.ketamine.perCondition.artifacts.range(conditionCntr-1,:) = [min(useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)) max(useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr))];
        rejectedTrials.combined.perCondition.artifacts.mean(conditionCntr-1) = mean([useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr); useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)]);
        rejectedTrials.combined.perCondition.artifacts.std(conditionCntr-1) = std([useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr); useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)]);
        rejectedTrials.combined.perCondition.artifacts.range(conditionCntr-1,:) = [min([useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr); useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)]) max([useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr); useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse(:,conditionCntr-1),conditionCntr)])];  
    end
    rejectedTrials.saline.acrossConditions.artifacts.mean = mean(useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse));
    rejectedTrials.saline.acrossConditions.artifacts.std = std(useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse));
    rejectedTrials.saline.acrossConditions.artifacts.range = [min(useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse)) max(useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse))];
   	rejectedTrials.ketamine.acrossConditions.artifacts.mean = mean(useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse));
    rejectedTrials.ketamine.acrossConditions.artifacts.std = std(useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse));
    rejectedTrials.ketamine.acrossConditions.artifacts.range = [min(useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse)) max(useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse))];
    rejectedTrials.combined.acrossConditions.artifacts.mean = mean([useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse); useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse)]);
    rejectedTrials.combined.acrossConditions.artifacts.std = std([useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse); useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse)]);
    rejectedTrials.combined.acrossConditions.artifacts.range = [min([useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse); useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse)]) max([useInfo.rejectedTrials.saline.nrArtifactTrials(useInfo.doUse); useInfo.rejectedTrials.ketamine.nrArtifactTrials(useInfo.doUse)])];
   
    
%how many trials did each electrode we included supply
nrTrialsIncludedSaline = nan(size(useInfo.trialSelection.saline,1),size(useInfo.trialSelection.saline,1)-1);
nrTrialsIncludedKetamine = nan(size(useInfo.trialSelection.saline,1),size(useInfo.trialSelection.saline,1)-1);
for conditionCntr =  2:size(useInfo.trialSelection.saline,2)
    for electrodeCntr = 1:size(useInfo.trialSelection.saline,1)
        nrTrialsIncludedSaline(electrodeCntr,conditionCntr-1) = sum(useInfo.trialSelection.saline{electrodeCntr,conditionCntr});
        nrTrialsIncludedKetamine(electrodeCntr,conditionCntr-1) = sum(useInfo.trialSelection.ketamine{electrodeCntr,conditionCntr});
    end
end
   
nrTrialsIncludedSaline(~useInfo.doUse) = NaN;
nrTrialsIncludedKetamine(~useInfo.doUse) = NaN;
nrTrialsIncludedCombined = [nrTrialsIncludedSaline; nrTrialsIncludedKetamine];

includedTrials.saline.perCondition.mean = mean(nrTrialsIncludedSaline,'omitnan');
includedTrials.ketamine.perCondition.mean = mean(nrTrialsIncludedKetamine,'omitnan');
includedTrials.saline.perCondition.std = std(nrTrialsIncludedSaline,'omitnan');
includedTrials.ketamine.perCondition.std = std(nrTrialsIncludedKetamine,'omitnan');
includedTrials.saline.perCondition.range = [min(nrTrialsIncludedSaline)', max(nrTrialsIncludedSaline)'];
includedTrials.ketamine.perCondition.range = [min(nrTrialsIncludedKetamine)', max(nrTrialsIncludedKetamine)'];
includedTrials.combined.perCondition.mean = mean(nrTrialsIncludedCombined,'omitnan');
includedTrials.combined.perCondition.std = std(nrTrialsIncludedCombined,'omitnan');
includedTrials.combined.perCondition.range = [min(nrTrialsIncludedCombined)', max(nrTrialsIncludedCombined)'];

includedTrials.saline.acrossConditions.mean = mean(nrTrialsIncludedSaline(:),'omitnan');
includedTrials.ketamine.acrossConditions.mean = mean(nrTrialsIncludedKetamine(:),'omitnan');
includedTrials.saline.acrossConditions.std = std(nrTrialsIncludedSaline(:),'omitnan');
includedTrials.ketamine.acrossConditions.std = std(nrTrialsIncludedKetamine(:),'omitnan');
includedTrials.saline.acrossConditions.range = [min(nrTrialsIncludedSaline(:))', max(nrTrialsIncludedSaline(:))'];
includedTrials.ketamine.acrossConditions.range = [min(nrTrialsIncludedKetamine(:))', max(nrTrialsIncludedKetamine(:))'];
includedTrials.combined.acrossConditions.mean = mean(nrTrialsIncludedCombined(:),'omitnan');
includedTrials.combined.acrossConditions.std = std(nrTrialsIncludedCombined(:),'omitnan');
includedTrials.combined.acrossConditions.range = [min(nrTrialsIncludedCombined(:))', max(nrTrialsIncludedCombined(:))'];






%save the information we want to report in a readable format
    %electrodes removed for poor snr
    electrodesRemovedForLowSNR.saline = sum(rejectInfo.snr.saline); %because only saline snr was below 2.5
    electrodesRemovedForLowSNR.ketamine = sum(rejectInfo.snr.ketamine); %because only saline snr was below 2.5
    electrodesRemovedForLowSNR.both = sum(rejectInfo.snr.both); %because only saline snr was below 2.5
    electrodesRemovedForLowSNR.total = electrodesRemovedForLowSNR.saline + electrodesRemovedForLowSNR.ketamine + electrodesRemovedForLowSNR.both ; %because only saline snr was below 2.5
    
    %electrodes removed for too low nr trials
    electrodesRemovedForTrialCount.saline(:,1) = sum(rejectInfo.insufficientTrials.saline);
    electrodesRemovedForTrialCount.ketamine(:,1) = sum(rejectInfo.insufficientTrials.ketamine);
    electrodesRemovedForTrialCount.both(:,1) = sum(rejectInfo.insufficientTrials.both);
    electrodesRemovedForTrialCount.total(:,1) = electrodesRemovedForTrialCount.saline+electrodesRemovedForTrialCount.ketamine+electrodesRemovedForTrialCount.both;
    electrodesRemovedForTrialCount.unique(:,1) = [sum((sum(rejectInfo.insufficientTrials.saline,2) + sum(rejectInfo.insufficientTrials.ketamine,2))>0) NaN NaN NaN NaN];
    
    electrodesRemovedForNoEye.total = sum(rejectInfo.noEye)'; %both the same anyway


    %how many electrodes were ultimately included
    electrodesIncluded.totalIncluded(:,1) = sum(useInfo.doUse);
    electrodesIncluded.totalExcluded(:,1) = sum(~useInfo.doUse);
    electrodesIncluded.total(:,1) = electrodesIncluded.totalIncluded+electrodesIncluded.totalExcluded ;
    
%how many trials did we reject (on average) and for what reason
    conditionNames = {'0Hz'; '5Hz'; '10Hz'; '20Hz'; '40Hz'; 'all'};
    indexCntr = 0;
    for conditionCntr = 1:6
        indexCntr = indexCntr+1;
        if conditionCntr < 6
            reportRejectedTrials.blinks_saline_mean(indexCntr,:) = rejectedTrials.saline.perCondition.blinks.mean(conditionCntr);
            reportRejectedTrials.blinks_saline_std(indexCntr,:) = rejectedTrials.saline.perCondition.blinks.std(conditionCntr);
            reportRejectedTrials.blinks_saline_range(indexCntr,:) = rejectedTrials.saline.perCondition.blinks.range(conditionCntr,:);
            reportRejectedTrials.blinks_ketamine_mean(indexCntr,:) = rejectedTrials.ketamine.perCondition.blinks.mean(conditionCntr);
            reportRejectedTrials.blinks_ketamine_std(indexCntr,:) = rejectedTrials.ketamine.perCondition.blinks.std(conditionCntr);
            reportRejectedTrials.blinks_ketamine_range(indexCntr,:) = rejectedTrials.ketamine.perCondition.blinks.range(conditionCntr,:);
            reportRejectedTrials.blinks_combined_mean(indexCntr,:) = rejectedTrials.combined.perCondition.blinks.mean(conditionCntr);
            reportRejectedTrials.blinks_combined_std(indexCntr,:) = rejectedTrials.combined.perCondition.blinks.std(conditionCntr);
            reportRejectedTrials.blinks_combined_range(indexCntr,:) = rejectedTrials.combined.perCondition.blinks.range(conditionCntr,:);
            

            reportRejectedTrials.nans_saline_mean(indexCntr,:) = rejectedTrials.saline.perCondition.nans.mean(conditionCntr);
            reportRejectedTrials.nans_saline_std(indexCntr,:) = rejectedTrials.saline.perCondition.nans.std(conditionCntr);
            reportRejectedTrials.nans_saline_range(indexCntr,:) = rejectedTrials.saline.perCondition.nans.range(conditionCntr,:);
            reportRejectedTrials.nans_ketamine_mean(indexCntr,:) = rejectedTrials.ketamine.perCondition.nans.mean(conditionCntr);
            reportRejectedTrials.nans_ketamine_std(indexCntr,:) = rejectedTrials.ketamine.perCondition.nans.std(conditionCntr);
            reportRejectedTrials.nans_ketamine_range(indexCntr,:) = rejectedTrials.ketamine.perCondition.nans.range(conditionCntr,:);
          	reportRejectedTrials.nans_combined_mean(indexCntr,:) = rejectedTrials.combined.perCondition.nans.mean(conditionCntr);
            reportRejectedTrials.nans_combined_std(indexCntr,:) = rejectedTrials.combined.perCondition.nans.std(conditionCntr);
            reportRejectedTrials.nans_combined_range(indexCntr,:) = rejectedTrials.combined.perCondition.nans.range(conditionCntr,:);

            reportRejectedTrials.artifacts_saline_mean(indexCntr,:) = rejectedTrials.saline.perCondition.artifacts.mean(conditionCntr);
            reportRejectedTrials.artifacts_saline_std(indexCntr,:) = rejectedTrials.saline.perCondition.artifacts.std(conditionCntr);
            reportRejectedTrials.artifacts_saline_range(indexCntr,:) = rejectedTrials.saline.perCondition.artifacts.range(conditionCntr,:);
            reportRejectedTrials.artifacts_ketamine_mean(indexCntr,:) = rejectedTrials.ketamine.perCondition.artifacts.mean(conditionCntr);
            reportRejectedTrials.artifacts_ketamine_std(indexCntr,:) = rejectedTrials.ketamine.perCondition.artifacts.std(conditionCntr);
            reportRejectedTrials.artifacts_ketamine_range(indexCntr,:) = rejectedTrials.ketamine.perCondition.artifacts.range(conditionCntr,:);
         	reportRejectedTrials.artifacts_combined_mean(indexCntr,:) = rejectedTrials.combined.perCondition.artifacts.mean(conditionCntr);
            reportRejectedTrials.artifacts_combined_std(indexCntr,:) = rejectedTrials.combined.perCondition.artifacts.std(conditionCntr);
            reportRejectedTrials.artifacts_combined_range(indexCntr,:) = rejectedTrials.combined.perCondition.artifacts.range(conditionCntr,:);
        else
            reportRejectedTrials.blinks_saline_mean(indexCntr,:) = rejectedTrials.saline.acrossConditions.blinks.mean;
            reportRejectedTrials.blinks_saline_std(indexCntr,:) = rejectedTrials.saline.acrossConditions.blinks.std;
            reportRejectedTrials.blinks_saline_range(indexCntr,:) = rejectedTrials.saline.acrossConditions.blinks.range;
            reportRejectedTrials.blinks_ketamine_mean(indexCntr,:) = rejectedTrials.ketamine.acrossConditions.blinks.mean;
            reportRejectedTrials.blinks_ketamine_std(indexCntr,:) = rejectedTrials.ketamine.acrossConditions.blinks.std;
            reportRejectedTrials.blinks_ketamine_range(indexCntr,:) = rejectedTrials.ketamine.acrossConditions.blinks.range;    
          	reportRejectedTrials.blinks_combined_mean(indexCntr,:) = rejectedTrials.combined.acrossConditions.blinks.mean;
            reportRejectedTrials.blinks_combined_std(indexCntr,:) = rejectedTrials.combined.acrossConditions.blinks.std;
            reportRejectedTrials.blinks_combined_range(indexCntr,:) = rejectedTrials.combined.acrossConditions.blinks.range;    
            
        	reportRejectedTrials.nans_saline_mean(indexCntr,:) = rejectedTrials.saline.acrossConditions.nans.mean;
            reportRejectedTrials.nans_saline_std(indexCntr,:) = rejectedTrials.saline.acrossConditions.nans.std;
            reportRejectedTrials.nans_saline_range(indexCntr,:) = rejectedTrials.saline.acrossConditions.nans.range;
            reportRejectedTrials.nans_ketamine_mean(indexCntr,:) = rejectedTrials.ketamine.acrossConditions.nans.mean;
            reportRejectedTrials.nans_ketamine_std(indexCntr,:) = rejectedTrials.ketamine.acrossConditions.nans.std;
            reportRejectedTrials.nans_ketamine_range(indexCntr,:) = rejectedTrials.ketamine.acrossConditions.nans.range;
         	reportRejectedTrials.nans_combined_mean(indexCntr,:) = rejectedTrials.combined.acrossConditions.nans.mean;
            reportRejectedTrials.nans_combined_std(indexCntr,:) = rejectedTrials.combined.acrossConditions.nans.std;
            reportRejectedTrials.nans_combined_range(indexCntr,:) = rejectedTrials.combined.acrossConditions.nans.range;    
            
           	reportRejectedTrials.artifacts_saline_mean(indexCntr,:) = rejectedTrials.saline.acrossConditions.artifacts.mean;
            reportRejectedTrials.artifacts_saline_std(indexCntr,:) = rejectedTrials.saline.acrossConditions.artifacts.std;
            reportRejectedTrials.artifacts_saline_range(indexCntr,:) = rejectedTrials.saline.acrossConditions.artifacts.range;
            reportRejectedTrials.artifacts_ketamine_mean(indexCntr,:) = rejectedTrials.ketamine.acrossConditions.artifacts.mean;
            reportRejectedTrials.artifacts_ketamine_std(indexCntr,:) = rejectedTrials.ketamine.acrossConditions.artifacts.std;
            reportRejectedTrials.artifacts_ketamine_range(indexCntr,:) = rejectedTrials.ketamine.acrossConditions.artifacts.range; 
          	reportRejectedTrials.artifacts_combined_mean(indexCntr,:) = rejectedTrials.combined.acrossConditions.artifacts.mean;
            reportRejectedTrials.artifacts_combined_std(indexCntr,:) = rejectedTrials.combined.acrossConditions.artifacts.std;
            reportRejectedTrials.artifacts_combined_range(indexCntr,:) = rejectedTrials.combined.acrossConditions.artifacts.range;            
        end
    end
   
%how many trials were ultimately included
    for conditionCntr = 1:5
        reportIncludedTrials.saline_mean(conditionCntr,:) = includedTrials.saline.perCondition.mean(conditionCntr);
        reportIncludedTrials.saline_std(conditionCntr,:) = includedTrials.saline.perCondition.std(conditionCntr);
        reportIncludedTrials.saline_range(conditionCntr,:) = includedTrials.saline.perCondition.range(conditionCntr,:);
       	reportIncludedTrials.ketamine_mean(conditionCntr,:) = includedTrials.ketamine.perCondition.mean(conditionCntr);
        reportIncludedTrials.ketamine_std(conditionCntr,:) = includedTrials.ketamine.perCondition.std(conditionCntr);
        reportIncludedTrials.ketamine_range(conditionCntr,:) = includedTrials.ketamine.perCondition.range(conditionCntr,:);
      	reportIncludedTrials.combined_mean(conditionCntr,:) = includedTrials.combined.perCondition.mean(conditionCntr);
        reportIncludedTrials.combined_std(conditionCntr,:) = includedTrials.combined.perCondition.std(conditionCntr);
        reportIncludedTrials.combined_range(conditionCntr,:) = includedTrials.combined.perCondition.range(conditionCntr,:);
    end
   	reportIncludedTrials.saline_mean(conditionCntr+1,:) = includedTrials.saline.acrossConditions.mean;
    reportIncludedTrials.saline_std(conditionCntr+1,:) = includedTrials.saline.acrossConditions.std;
    reportIncludedTrials.saline_range(conditionCntr+1,:) = includedTrials.saline.acrossConditions.range;
    reportIncludedTrials.ketamine_mean(conditionCntr+1,:) = includedTrials.ketamine.acrossConditions.mean;
    reportIncludedTrials.ketamine_std(conditionCntr+1,:) = includedTrials.ketamine.acrossConditions.std;
    reportIncludedTrials.ketamine_range(conditionCntr+1,:) = includedTrials.ketamine.acrossConditions.range;
    reportIncludedTrials.combined_mean(conditionCntr+1,:) = includedTrials.combined.acrossConditions.mean;
    reportIncludedTrials.combined_std(conditionCntr+1,:) = includedTrials.combined.acrossConditions.std;
    reportIncludedTrials.combined_range(conditionCntr+1,:) = includedTrials.combined.acrossConditions.range;
    
    
%save information about rejected and included electrodes and trials

electrodesRemovedForLowSNR = struct2table(electrodesRemovedForLowSNR);
writetable(electrodesRemovedForLowSNR,[resultsFolder 'electrodesRemovedForLowSNR' '.csv'],'WriteRowNames',true);
electrodesRemovedForTrialCount = struct2table(electrodesRemovedForTrialCount);
electrodesRemovedForTrialCount.Properties.RowNames = conditionNames(1:5);
writetable(electrodesRemovedForTrialCount,[resultsFolder 'electrodesRemovedForTrialCount' '.csv'],'WriteRowNames',true);
electrodesRemovedForNoEye = struct2table(electrodesRemovedForNoEye);
electrodesRemovedForNoEye.Properties.RowNames = conditionNames(1:5);
writetable(electrodesRemovedForNoEye,[resultsFolder 'electrodesRemovedForNoEye' '.csv'],'WriteRowNames',true);

electrodesIncluded = struct2table(electrodesIncluded);
electrodesIncluded.Properties.RowNames = conditionNames(1:5);
writetable(electrodesIncluded,[resultsFolder 'electrodesIncluded' '.csv'],'WriteRowNames',true);
reportRejectedTrials = struct2table(reportRejectedTrials);
reportRejectedTrials.Properties.RowNames = conditionNames;
writetable(reportRejectedTrials,[resultsFolder 'reportRejectedTrials' '.csv'],'WriteRowNames',true);
reportIncludedTrials = struct2table(reportIncludedTrials);
reportIncludedTrials.Properties.RowNames = conditionNames;
writetable(reportIncludedTrials,[resultsFolder 'reportIncludedTrials' '.csv'],'WriteRowNames',true);

%compare if number trials included is different across conditions or drugs
 [~,P,CI] =ttest2(reportIncludedTrials.saline_mean(2:5),reportIncludedTrials.ketamine_mean);
 testNrTrialsIncluded.p = P;
 testNrTrialsIncluded.p = CI;
 testNrTrialsIncluded = struct2table(testNrTrialsIncluded);

writetable(testNrTrialsIncluded,[resultsFolder 'testNrTrialsIncluded' '.csv'],'WriteRowNames',true);
 


%save information about data quality and zscored signal
save([targetFolder 'useInfo'], 'useInfo','-v7.3');
save([targetFolder 'averageSignal'], 'averageSignal','-v7.3');
save([targetFolder 'zScoredSignal'], 'zScoredSignal','-v7.3');




function outliers = detectOutliers(inputSignal,threshold)


    outliers = nan(size(inputSignal,2),size(inputSignal,3));
    for electrodeCntr = 1:size(inputSignal,3)
        minMaxTrial =zeros(1,size(inputSignal,2));
        
        %find outliers
        workSet = squeeze(inputSignal(:,:,electrodeCntr));

        for trialCntr = 1:size(workSet,2)
            minMaxTrial(trialCntr) = diff([min(workSet(:,trialCntr)) max(workSet(:,trialCntr))]);
        end
    	lb = median(minMaxTrial)-threshold*iqr(minMaxTrial);
      	ub = median(minMaxTrial)+threshold*iqr(minMaxTrial);
        badTrialLB = minMaxTrial<lb;
        badTrialUB = minMaxTrial>ub;

        outliers(:,electrodeCntr) = (badTrialLB + badTrialUB) >0;
    end

end