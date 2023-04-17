function analyzeData
% This script uses linear mixed effects models to test the hypothesis that
% ketamine reduces SSVEPs while testing and controling for the effect of
% ketamine on eye movements
%
% Companion code for:
%
% N-methyl d-aspartate receptor hypofunction reduces steady state visual
% evoked potentials (2023)

%where are data located and where should results be saved
sourceFolder = strrep(pwd,'code','data\');
dataFolder = [sourceFolder 'processed\'];
targetFolder = [sourceFolder 'results\'];

%does the outputFolder exist 
%(this should be the case for anybody the data are shared with)
if ~exist(targetFolder,'dir')
    mkdir(targetFolder);
end 


%% use linear mixed effects models to test if ketamine changed (i.e. reduced evoked power) ssveps

%load useInfo
useInfo = load([dataFolder 'useInfo']);
useInfo = useInfo.useInfo;
useSelection = useInfo.doUse;


%load dividedData
dividedSignal = load([dataFolder 'dividedSignal']);
dividedSignal = dividedSignal.dividedSignal;
%load eyeData
eyeData = load([dataFolder 'eyeData']);
eyeData = eyeData.eyeData;


%put together a struct as input to a linear mixed effects model
time = -800:2600;
targetHz = [1 5 10 20 40];  %stimulus frequencies (1 is just the lowest frequency  we can pick)

%frequencies based on fft performed in 'processData.m'
maxSamplePoints = max(2.^nextpow2(sum(time>=501 & time<=1500)));
signalLength = sum(time>=501 & time<=1500);  %use center 1000 ms of stimulus presentation
frequency = maxSamplePoints /(signalLength/1000)*(0:(maxSamplePoints/2))/maxSamplePoints; %frequency vector
frequency(frequency>maxSamplePoints/2) = [];

%frequencies based on multi-taper based frequency analysis performed in 'processData.m'
mtFreq = 0:(5/3):125;

%% Evoked

    clearvars responseTable
    drugType = {'saline';'ketamine'};
    startCntr = 1;
    for drugCntr = 1:length(drugType)
        for conditionCntr = 2:numel(targetHz)
            tempResponse = squeeze(dividedSignal.(drugType{drugCntr}).evoked(frequency==targetHz(conditionCntr),conditionCntr,useSelection(:,conditionCntr)));             
            stopCntr = startCntr +numel(tempResponse) -1;
            responseTable.response(startCntr:stopCntr,1) = tempResponse;
            responseTable.drug(startCntr:stopCntr,:) = drugCntr;
            responseTable.condition(startCntr:stopCntr,1) = conditionCntr;
            responseTable.subject(startCntr:stopCntr,:) = string(useInfo.subject(useSelection(:,conditionCntr),:));
            responseTable.electrode(startCntr:stopCntr,:) = useInfo.electrode(useSelection(:,conditionCntr))';

            %add eyeData
            responseTable.fixInaccuracy(startCntr:stopCntr,:) = eyeData.fixInaccuracy.(drugType{drugCntr})(useSelection(:,conditionCntr),conditionCntr);
            responseTable.fixInstability(startCntr:stopCntr,:) = eyeData.fixInstability.(drugType{drugCntr})(useSelection(:,conditionCntr),conditionCntr);

            startCntr = stopCntr+1;
        end
    end

    responseTable = struct2table(responseTable);
    responseTable.condition = categorical(responseTable.condition);
    responseTable.drug = categorical(responseTable.drug);
    responseTable.observationNr = [1:size(responseTable,1)/2 1:size(responseTable,1)/2]';
    responseTable.subject = categorical(responseTable.subject);


    %edf files with eye data from 4 sessions (2 saline, and their 2
    %respective ketamine recordings) are missing, so we exclude lfp
    %recordings from those days, leaving us with 20 out of 24 sessions
    responseTableSub = responseTable(~(isnan(responseTable.fixInaccuracy)),:);
      
    
    %1. test if ketamine affects eye movements (independent of measure,
    %i.e. evoked, induced, baseline)
    [drug_predicts_fixInstability_lmeTable, drug_predicts_fixInstability_anovaTable, drug_predicts_fixInstability_anovaText] = doStats(responseTableSub,'fixInstability ~1+drug +(1|subject)','evoked');
    [drug_predicts_fixInaccuracy_lmeTable, drug_predicts_fixInaccuracy_anovaTable, drug_predicts_fixInaccuracy_anovaText] = doStats(responseTableSub,'fixInaccuracy ~1+drug +(1|subject)','evoked');
    
    
   	%2. test if eye movements and stability affect magnitude of SSVEPs regardless of drug
    [eyeMovements_predict_evoked_lmeTable, eyeMovements_predict_evoked_anovaTable, eyeMovements_predict_evoked_anovaText] = doStats(responseTableSub,'response~1+fixInaccuracy  +fixInstability +(1|subject)','evoked');

    %3. test if ketamine reduces SSVEPs while accounting for fixation instability and fixation inaccuracy
    [eyeControl_evoked_lmeTable, eyeControl_evoked_anovaTable, eyeControl_evoked_anovaText, eyeControl_evoked_contrastTable, eyeControl_evoked_contrastText] = doStats(responseTableSub,'response~1+condition*drug +fixInaccuracy +fixInstability  +(1|subject)','evoked');

    
    %save tables and variables
    %1.1
        writetable(drug_predicts_fixInstability_lmeTable,[targetFolder 'drug_predicts_fixInstability_lmeTable' '.csv'],'WriteRowNames',true);
        writetable(drug_predicts_fixInstability_anovaTable,[targetFolder 'drug_predicts_fixInstability_anovaTable' '.csv'],'WriteRowNames',true);
        writematrix(drug_predicts_fixInstability_anovaText,[targetFolder 'drug_predicts_fixInstability_anovaText.txt'])

    %1.2
        writetable(drug_predicts_fixInaccuracy_lmeTable,[targetFolder 'drug_predicts_fixInaccuracy_lmeTable' '.csv'],'WriteRowNames',true);
        writetable(drug_predicts_fixInaccuracy_anovaTable,[targetFolder 'drug_predicts_fixInaccuracy_anovaTable' '.csv'],'WriteRowNames',true);
        writematrix(drug_predicts_fixInaccuracy_anovaText,[targetFolder 'drug_predicts_fixInaccuracy_anovaText.txt'])
        
    %2
        writetable(eyeMovements_predict_evoked_lmeTable,[targetFolder 'eyeMovements_predict_evoked_lmeTable' '.csv'],'WriteRowNames',true);
        writetable(eyeMovements_predict_evoked_anovaTable,[targetFolder 'eyeMovements_predict_evoked_anovaTable' '.csv'],'WriteRowNames',true);
        writematrix(eyeMovements_predict_evoked_anovaText,[targetFolder 'eyeMovements_predict_evoked_anovaText.txt'])
    %3
        writetable(eyeControl_evoked_lmeTable,[targetFolder 'eyeControl_evoked_lmeTable' '.csv'],'WriteRowNames',true);
        writetable(eyeControl_evoked_anovaTable,[targetFolder 'eyeControl_evoked_anovaTable' '.csv'],'WriteRowNames',true);
        writematrix(eyeControl_evoked_anovaText,[targetFolder 'eyeControl_evoked_anovaText.txt'])     
        
        save([targetFolder 'eyeControl_evoked_contrastTable' '.mat'],'eyeControl_evoked_contrastTable','-v7.3');
        writetable(eyeControl_evoked_contrastTable,[targetFolder 'eyeControl_evoked_contrastTable' '.csv'],'WriteRowNames',true);
        writematrix(eyeControl_evoked_contrastText,[targetFolder 'eyeControl_evoked_contrastText.txt'])

    
    
    
    
    
    
%% induced
    clearvars responseTable
    drugType = {'saline';'ketamine'};
    startCntr = 1;
    for drugCntr = 1:length(drugType)
        for conditionCntr = 2:numel(targetHz)
            tempResponse = squeeze(dividedSignal.(drugType{drugCntr}).induced(frequency==targetHz(conditionCntr),conditionCntr,useSelection(:,conditionCntr)));             
            stopCntr = startCntr +numel(tempResponse) -1;
            responseTable.response(startCntr:stopCntr,1) = tempResponse;
            responseTable.drug(startCntr:stopCntr,:) = drugCntr;
            responseTable.condition(startCntr:stopCntr,1) = conditionCntr;
            responseTable.subject(startCntr:stopCntr,:) = string(useInfo.subject(useSelection(:,conditionCntr),:));
            responseTable.electrode(startCntr:stopCntr,:) = useInfo.electrode(useSelection(:,conditionCntr))';

            %add eyeData
            responseTable.fixInaccuracy(startCntr:stopCntr,:) = eyeData.fixInaccuracy.(drugType{drugCntr})(useSelection(:,conditionCntr),conditionCntr);
            responseTable.fixInstability(startCntr:stopCntr,:) = eyeData.fixInstability.(drugType{drugCntr})(useSelection(:,conditionCntr),conditionCntr);

            startCntr = stopCntr+1;
        end
    end

    responseTable = struct2table(responseTable);
    responseTable.condition = categorical(responseTable.condition);
    responseTable.drug = categorical(responseTable.drug);
    responseTable.observationNr = [1:size(responseTable,1)/2 1:size(responseTable,1)/2]';
    responseTable.subject = categorical(responseTable.subject);


    %edf files with eye data from 4 sessions (2 saline, and their 2
    %respective ketamine recordings) are missing, so we exclude lfp
    %recordings from those days, leaving us with 20 out of 24 sessions
    responseTableSub = responseTable(~(isnan(responseTable.fixInaccuracy)),:);
      
 
   	%4. test if eye movements and stability affect magnitude of SSVEPs regardless of drug
    [eyeMovements_predict_induced_lmeTable, eyeMovements_predict_induced_anovaTable, eyeMovements_predict_induced_anovaText] = doStats(responseTableSub,'response~1+fixInaccuracy  +fixInstability +(1|subject)','induced');

    %5. test if ketamine reduces SSVEPs while accounting for fixation instability and fixation inaccuracy
    [eyeControl_induced_lmeTable, eyeControl_induced_anovaTable, eyeControl_induced_anovaText, eyeControl_induced_contrastTable, eyeControl_induced_contrastText] = doStats(responseTableSub,'response~1+condition*drug +fixInaccuracy +fixInstability  +(1|subject)','induced');

    
    %save tables and variables

    %4
        writetable(eyeMovements_predict_induced_lmeTable,[targetFolder 'eyeMovements_predict_induced_lmeTable' '.csv'],'WriteRowNames',true);
        writetable(eyeMovements_predict_induced_anovaTable,[targetFolder 'eyeMovements_predict_induced_anovaTable' '.csv'],'WriteRowNames',true);
        writematrix(eyeMovements_predict_induced_anovaText,[targetFolder 'eyeMovements_predict_induced_anovaText.txt'])

    %5
        writetable(eyeControl_induced_lmeTable,[targetFolder 'eyeControl_induced_lmeTable' '.csv'],'WriteRowNames',true);
        writetable(eyeControl_induced_anovaTable,[targetFolder 'eyeControl_induced_anovaTable' '.csv'],'WriteRowNames',true);
        writematrix(eyeControl_induced_anovaText,[targetFolder 'eyeControl_induced_anovaText.txt'])   
        
        save([targetFolder 'eyeControl_induced_contrastTable' '.mat'],'eyeControl_induced_contrastTable','-v7.3');
        writetable(eyeControl_induced_contrastTable,[targetFolder 'eyeControl_induced_contrastTable' '.csv'],'WriteRowNames',true);
        writematrix(eyeControl_induced_contrastText,[targetFolder 'eyeControl_induced_contrastText.txt'])

    
    

%% baseline
    clearvars responseTable
    drugType = {'saline';'ketamine'};
    startCntr = 1;
    for drugCntr = 1:length(drugType)
        for conditionCntr = 2:numel(targetHz)
            tempResponse = squeeze(dividedSignal.(drugType{drugCntr}).totalBaseline(mtFreq==targetHz(conditionCntr),conditionCntr,useSelection(:,conditionCntr)));             
            stopCntr = startCntr +numel(tempResponse) -1;
            responseTable.response(startCntr:stopCntr,1) = tempResponse;
            responseTable.drug(startCntr:stopCntr,:) = drugCntr;
            responseTable.condition(startCntr:stopCntr,1) = conditionCntr;
            responseTable.subject(startCntr:stopCntr,:) = string(useInfo.subject(useSelection(:,conditionCntr),:));
            responseTable.electrode(startCntr:stopCntr,:) = useInfo.electrode(useSelection(:,conditionCntr))';

            %add eyeData
            responseTable.fixInaccuracy(startCntr:stopCntr,:) = eyeData.fixInaccuracy.(drugType{drugCntr})(useSelection(:,conditionCntr),conditionCntr);
            responseTable.fixInstability(startCntr:stopCntr,:) = eyeData.fixInstability.(drugType{drugCntr})(useSelection(:,conditionCntr),conditionCntr);

            startCntr = stopCntr+1;
        end
    end

    responseTable = struct2table(responseTable);
    responseTable.condition = categorical(responseTable.condition);
    responseTable.drug = categorical(responseTable.drug);
    responseTable.observationNr = [1:size(responseTable,1)/2 1:size(responseTable,1)/2]';
    responseTable.subject = categorical(responseTable.subject);


    %edf files with eye data from 4 sessions (2 saline, and their 2
    %respective ketamine recordings) are missing, so we exclude lfp
    %recordings from those days, leaving us with 20 out of 24 sessions
    responseTableSub = responseTable(~(isnan(responseTable.fixInaccuracy)),:);
      
 
    
   	%6. test if eye movements and stability affect magnitude of SSVEPs regardless of drug
    [eyeMovements_predict_baseline_lmeTable, eyeMovements_predict_baseline_anovaTable, eyeMovements_predict_baseline_anovaText] = doStats(responseTableSub,'response~1+fixInaccuracy  +fixInstability +(1|subject)','baseline');

    %7. test if ketamine reduces SSVEPs while accounting for fixation instability and fixation inaccuracy
    [eyeControl_baseline_lmeTable, eyeControl_baseline_anovaTable, eyeControl_baseline_anovaText, eyeControl_baseline_contrastTable, eyeControl_baseline_contrastText] = doStats(responseTableSub,'response~1+condition*drug +fixInaccuracy +fixInstability  +(1|subject)','baseline');

    
    %save tables and variables

    %6
        writetable(eyeMovements_predict_baseline_lmeTable,[targetFolder 'eyeMovements_predict_baseline_lmeTable' '.csv'],'WriteRowNames',true);
        writetable(eyeMovements_predict_baseline_anovaTable,[targetFolder 'eyeMovements_predict_baseline_anovaTable' '.csv'],'WriteRowNames',true);
        writematrix(eyeMovements_predict_baseline_anovaText,[targetFolder 'eyeMovements_predict_baseline_anovaText.txt'])

 	%7
        writetable(eyeControl_baseline_lmeTable,[targetFolder 'eyeControl_baseline_lmeTable' '.csv'],'WriteRowNames',true);
        writetable(eyeControl_baseline_anovaTable,[targetFolder 'eyeControl_baseline_anovaTable' '.csv'],'WriteRowNames',true);
        writematrix(eyeControl_baseline_anovaText,[targetFolder 'eyeControl_baseline_anovaText.txt'])     
        
        save([targetFolder 'eyeControl_baseline_contrastTable' '.mat'],'eyeControl_baseline_contrastTable','-v7.3');
        writetable(eyeControl_baseline_contrastTable,[targetFolder 'eyeControl_baseline_contrastTable' '.csv'],'WriteRowNames',true);
        writematrix(eyeControl_baseline_contrastText,[targetFolder 'eyeControl_baseline_contrastText.txt'])

        
end