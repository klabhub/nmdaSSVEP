function createFigures
% This script created figures from the data generated in 'screenFiles.m'
% (figures 2 & 3), 'processData.m' (figure 4) & 'analyzeData.m' (figure 5)
%
% Companion code for:
%
% N-methyl d-aspartate receptor hypofunction reduces steady state visual
% evoked potentials (2024)
% Alexander Schielke & Bart Krekelberg
% Center for Molecular and Behavioral Neuroscience
% Rutgers University - Newark 

%where are data located and where should figures be saved
sourceFolder = strrep(pwd,'code','');
dataFolder = [sourceFolder 'data\processed\'];
targetFolder = [sourceFolder 'plots\'];

%do the outputFolders exist 
%(this should be the case once the code has been run a least once)
if ~exist(targetFolder,'dir')
    mkdir(targetFolder);
end 

%% Figure 2: Examples of eeg recordings (5th, 50th and 95th percentile)
plotName = 'figure2';

%load information about each recording site (e.g. whether to include or not)
useInfo = load([dataFolder 'useInfo']);
useInfo = useInfo.useInfo;

%load averaged EEG traces
averageSignal = load([dataFolder 'averageSignal']);
averageSignal = averageSignal.averageSignal;

%select electrodes based on onsetSNR
electrodeSelection = useInfo.doUse(:,1);

snrValues = useInfo.snr.saline(electrodeSelection,1);
%keep only signal from electrodes meeting inclusion criteria
averageSignal.saline = averageSignal.saline(:,:,electrodeSelection);
averageSignal.ketamine = averageSignal.ketamine(:,:,electrodeSelection);

%find representative electrodes for figure
[sortSNRVals, sortedOrder] = sort(snrValues);
prctileIdx5 = sortedOrder(knnsearch(sortSNRVals,prctile(snrValues,5)));
prctileIdx50 = sortedOrder(knnsearch(sortSNRVals,prctile(snrValues,50)));
prctileIdx95 = sortedOrder(knnsearch(sortSNRVals,prctile(snrValues,95)));
  

%plot figure 2
nrConditions = size(averageSignal.saline,2);

sp1 = cell(1,nrConditions);
sp2 = cell(1,nrConditions);
sp3 = cell(1,nrConditions);
time = -800:2600;
yRange = [-110 110];
 
fig = figure;
    set(fig,'color','w');
    fig.PaperUnits = 'centimeters';
    fig.Units = 'centimeters';
    fig.PaperPosition = [0 0 17.6 15];
    fig.PaperSize = [17.6 15];
    fig.Position = [.5 2 17.6 15];
    
    totalCntr = 0;
    for conditionCntr = 1:5
        totalCntr = totalCntr +1;
        sp1{conditionCntr} = subplot(6,3,totalCntr);

        % if conditionCntr == 1
            %add patches that indicate analysis windows
            if conditionCntr>1
                patch([-500 -50 -50 -500], [-90 -90 90 90], [0 0 0 0], 'FaceColor' ,[0.5 0.5 0.5],'EdgeColor','none');hold on;
            end
            patch([500 1500 1500 500], [-90 -90 90 90], [0 0 0 0], 'FaceColor' ,[0.9 0.9 0.9],'EdgeColor','none');hold on;

            plot(time,averageSignal.saline(:,conditionCntr,prctileIdx5)); hold on;
            plot(time,averageSignal.ketamine(:,conditionCntr,prctileIdx5)); hold on;
            
            totalCntr = totalCntr +1;
            ax = gca;
            ax.TickLength = [0.03, 0.01];
            ax.LineWidth = 1.5;
            
            if conditionCntr<5
                xticklabels([])
            else
                xticklabels({'0'; '1000'; '2000'});
                xticks([0,1000,2000]);
            end
            
            if conditionCntr==3
                yl = ylabel([char(181) 'V']);
            end
            
            xlim([-500 2500])
            ylim(yRange)
            yticks([-80,0,80]);
            yticklabels({'-80';'0';'80'});
            sp1{conditionCntr}.FontSize = 10;

           
            
       sp2{conditionCntr} = subplot(6,3,totalCntr);

            %add patches that indicate analysis windows
            if conditionCntr>1
                patch([-500 -50 -50 -500], [-90 -90 90 90], [0 0 0 0], 'FaceColor' ,[0.5 0.5 0.5],'EdgeColor','none');hold on;
            end
            patch([500 1500 1500 500], [-90 -90 90 90], [0 0 0 0], 'FaceColor' ,[0.9 0.9 0.9],'EdgeColor','none');hold on;


            plot(time,averageSignal.saline(:,conditionCntr,prctileIdx50)); hold on;
            plot(time,averageSignal.ketamine(:,conditionCntr,prctileIdx50)); hold on;
            ax = gca;
            ax.TickLength = [0.03, 0.01];
            ax.LineWidth = 1.5;
            
            totalCntr = totalCntr +1;
            if conditionCntr<5
                xticklabels([])
            else
                xticklabels({'0'; '1000'; '2000'});
                xticks([0,1000,2000]);
                xlabel('Time (ms)')
            end
            xlim([-500 2500])
            ylim(yRange)
            yticklabels('')
            sp2{conditionCntr}.FontSize = 10;
            
     	sp3{conditionCntr} = subplot(6,3,totalCntr);

            %add patches that indicate analysis windows
            if conditionCntr>1
                patch([-500 -50 -50 -500], [-90 -90 90 90], [0 0 0 0], 'FaceColor' ,[0.5 0.5 0.5],'EdgeColor','none');hold on;
            end
            patch([500 1500 1500 500], [-90 -90 90 90], [0 0 0 0], 'FaceColor' ,[0.9 0.9 0.9],'EdgeColor','none');hold on;
            
            plot(time,averageSignal.saline(:,conditionCntr,prctileIdx95)); hold on;
            plot(time,averageSignal.ketamine(:,conditionCntr,prctileIdx95)); hold on;
            %ylabel('micro Volts')
            ax = gca;
            ax.TickLength = [0.03, 0.01];
            ax.LineWidth = 1.5;
            
            
            if conditionCntr<5
                xticklabels([])
            else
                xticklabels({'0'; '1000'; '2000'});
                xticks([0,1000,2000]);
            end
            xlim([-500 2500])
            ylim(yRange)
            yticklabels('')
            sp3{conditionCntr}.FontSize = 10;
    end
    
    plotYSize = 0.16;
    plotXSize = 0.275;


    
    
    sp1{conditionCntr+1} = subplot(6,3,totalCntr+1);
    sp1{conditionCntr+1}.Position = [0.16 0.00 0.825 0.03];
    xlim([0 1])
    axis off
    
    
    xlLeft.FontSize = 10;
    xlLeft.Position(2) = -250;
    ylLeft{3}.Position(1) = -18;
    ylRight{3}.Position(1) = -18;
    
    
    yLevels = [0.8 0.63 0.46 0.29 0.12];
    
    for conditionCntr = 1:5
    
        sp1{conditionCntr}.Position = [0.16 yLevels(conditionCntr) plotXSize plotYSize];
        sp2{conditionCntr}.Position = [0.4415 yLevels(conditionCntr) plotXSize plotYSize];
        sp3{conditionCntr}.Position = [0.723 yLevels(conditionCntr) plotXSize plotYSize];
    end
    
    
    %adjust the yLabel
    yl.Position(1) = - 950;
    yl.FontSize = 12;
    
    
    
    
    
    
    % create the legend
    
    patch([0 1 1 0], [0 0 1 1], [0 0 0 0], 'FaceColor' ,'w','EdgeColor','none');hold on;
    patch([0 0.05 0.05 0.0], [0.4 0.4 0.6 0.6], [0 0 0 0], 'FaceColor' ,'b');hold on;
    text(0.1, 0.56,'Saline','FontWeight','bold','FontSize',10, 'HorizontalAlignment','center','units','normalized');
    
    patch([0.2 0.25 0.25 0.2], [0.4 0.4 0.6 0.6], [0 0 0 0], 'FaceColor' ,'r');hold on;
    text(0.265, 0.56,'Ketamine','FontWeight','bold','FontSize',10, 'HorizontalAlignment','left','units','normalized');
    
    patch([0.435 0.485 0.485 0.435], [0.1 0.1 0.9 0.9], [0 0 0 0], 'FaceColor' ,[0.5 0.5 0.5]);hold on;
    text(0.5, 0.56,'Baseline','FontWeight','bold','FontSize',10, 'HorizontalAlignment','left','units','normalized');
    
    patch([0.665 0.715 0.715 0.665], [0.1 0.1 0.9 0.9], [0 0 0 0], 'FaceColor' ,[0.9 0.9 0.9]);hold on;
    text(0.73, 0.56,'Analysis Window','FontWeight','bold','FontSize',10, 'HorizontalAlignment','left','units','normalized');
    

    
  	%add colum titles
        text(0.165, 33,'Site 1','FontWeight','bold','FontSize',12, 'HorizontalAlignment','center','units','normalized');
        text(0.505, 33,'Site 2','FontWeight','bold','FontSize',12, 'HorizontalAlignment','center','units','normalized');
        text(0.85, 33,'Site 3','FontWeight','bold','FontSize',12, 'HorizontalAlignment','center','units','normalized');
         
 	%add row titles
    	text(-0.11, 29.4, '0 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
        text(-0.11, 23.7, '5 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
        text(-0.11, 18.05,'10 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
        text(-0.11, 12.4,'20 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
        text(-0.11, 6.75,'40 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
     

%save figure
	savePath = [targetFolder plotName];
 	exportgraphics(fig,[savePath '.pdf'],'Resolution',1000)
    close(fig)




%% Figure 3: Z-scored population lfps
plotName = 'figure3';

%load data with zScored LFPs
zScoredSignal = load([dataFolder 'zScoredSignal']);
zScoredSignal = zScoredSignal.zScoredSignal;
salineSignal = zScoredSignal.saline(:,:,electrodeSelection);
ketamineSignal = zScoredSignal.ketamine(:,:,electrodeSelection);


%generate a blue to white to red colormat 
r = [zeros(1,25) linspace(0,1,100) ones(1,99) linspace(1,0.4,25)];
b = fliplr(r);
g = [zeros(1,25) r(26:125) fliplr(r(26:124)) zeros(1,25)];
individualColormap = [r; g; b]';


%plot
fig = figure;
    set(fig,'color','w');
    fig.PaperUnits = 'centimeters';
    fig.Units = 'centimeters';
    fig.PaperPosition = [0 0 17.6 14];
    fig.PaperSize = [17.6 14];
    fig.Position = [.5 2 17.6 14];
    
totalCntr = 0;
for conditionCntr = 1:5
    totalCntr = totalCntr+1;
    
    sp1{conditionCntr} = subplot(6,2,totalCntr);
        imagesc(time,1:numel(sortedOrder),squeeze(salineSignal(:,conditionCntr,sortedOrder))');hold on;
        clim([-10 10])
        
        ax = gca;
        ax.TickLength = [0.03, 0.01];
        ax.LineWidth = 1.5;
        sp1{conditionCntr}.FontSize = 10;

        if conditionCntr<5
            xticklabels([])
        else
            xlabel('Time (ms)')
        end
        
        colormap(individualColormap)
        set(gca,'YDir','normal')
        yticklabels({'50';'100';'150';'200'})
        yticks([50 100 150 200])
        if conditionCntr==3
            ylabel('Electrode Number')
        end

    sp2{conditionCntr} = subplot(6,2,totalCntr+1);
        imagesc(time,1:numel(sortedOrder),squeeze(ketamineSignal(:,conditionCntr,sortedOrder))');hold on;
        clim([-10 10])
        
        ax = gca;
        ax.TickLength = [0.03, 0.01];
        ax.LineWidth = 1.5;
        sp2{conditionCntr}.FontSize = 10;

        if conditionCntr<5
            xticklabels([])
        else
            xlabel('Time (ms)')
        end
        
        yticklabels('')
        yticks([])
        colormap(individualColormap)
        set(gca,'YDir','normal')
        
    totalCntr = totalCntr+1;
end

%add horizontal colorbar
    spX = subplot(6,2,12);
    colorPlot('colorMap',individualColormap,'colorRange',[-10 10],'nrTicks',7)

%adjust sizes of subplots    
    spX.Position = [0.185    0.025    0.8    0.03];
    plotYPositions =  [0.81 0.645 0.48 0.315 0.15];
    plotYSize = 0.155;
    plotXSize = 0.4;
    for conditionCntr = 1:5
        sp1{conditionCntr}.Position = [0.180 plotYPositions(conditionCntr) plotXSize plotYSize];
        sp2{conditionCntr}.Position = [0.595 plotYPositions(conditionCntr) plotXSize plotYSize];
    end

%add drug type (colum) and condition (row) titles
    text(0.26, 31.8,'Saline','FontWeight','bold','FontSize',12, 'HorizontalAlignment','center','units','normalized');
    text(0.775, 31.8,'Ketamine','FontWeight','bold','FontSize',12, 'HorizontalAlignment','center','units','normalized');

    %add row titles
    text(-0.14, 28.65, '0 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
    text(-0.14, 23.22, '5 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
    text(-0.14, 17.74,'10 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
    text(-0.14, 12.29,'20 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
    text(-0.14, 6.8,'40 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
    text(0.5, 1.6,'z-score','FontWeight','bold','FontSize',12, 'HorizontalAlignment','center','units','normalized');

%save figure
	savePath = [targetFolder plotName];
 	exportgraphics(fig,[savePath '.pdf'],'Resolution',1000)
    close(fig)

    
    
%% Figure 4: evoked and induced magnitude spectra
plotName = 'figure4';
% 
%load evoked and induced spectra
splitSpectrum = load([dataFolder 'splitSpectrum']);
splitSpectrum = splitSpectrum.splitSpectrum;

%frequencies from fft
maxSamplePoints = max(2.^nextpow2(sum(time>=501 & time<=1500)));
signalLength = sum(time>=501 & time<=1500);  %how long is the signal
frequency = maxSamplePoints /(signalLength/1000)*(0:(maxSamplePoints/2))/maxSamplePoints;
frequency(frequency>maxSamplePoints/2) = [];
maxFreq = 125;


spLeft = cell(1,nrConditions);
spRight = cell(1,nrConditions);
plotAxLeft = cell(1,nrConditions);
ylLeft = cell(1,nrConditions);
ylRight = cell(1,nrConditions);

fig = figure;
    set(fig,'color','w');
    fig.PaperUnits = 'centimeters';
    fig.Units = 'centimeters';
    fig.PaperPosition = [0 0 17.6 15];
    fig.PaperSize = [17.6 15];
    fig.Position = [.5 2 17.6 15];
    
    plotCntr = 0;
for conditionCntr = 1:5
    plotCntr = plotCntr+1;
    
    spLeft{conditionCntr} = subplot(6,2,plotCntr);
    
        fill(([frequency(frequency<=maxFreq) fliplr(frequency(frequency<=maxFreq))]), ([(splitSpectrum.evoked.condition(conditionCntr).saline.ci(frequency<=maxFreq,1))', fliplr(splitSpectrum.evoked.condition(conditionCntr).saline.ci(frequency<=maxFreq,2)')]), 0.9*[0 0 1], 'EdgeColor', 'none','facealpha',.8); hold on;
        fill(([frequency(frequency<=maxFreq) fliplr(frequency(frequency<=maxFreq))]), ([(splitSpectrum.evoked.condition(conditionCntr).ketamine.ci(frequency<=maxFreq,1))', fliplr(splitSpectrum.evoked.condition(conditionCntr).ketamine.ci(frequency<=maxFreq,2)')]), 0.9*[1 0 0], 'EdgeColor', 'none','facealpha',.8);
        fill(([frequency(frequency<=maxFreq) fliplr(frequency(frequency<=maxFreq))]), ([(splitSpectrum.evoked.condition(conditionCntr).difference.ci(frequency<=maxFreq,1))', fliplr(splitSpectrum.evoked.condition(conditionCntr).difference.ci(frequency<=maxFreq,2)')]), 0.3*[1 1 1], 'EdgeColor', 'none','facealpha',.8);
        line([0 maxFreq], [0 0],'color','k', 'LineStyle','--')
        plot(frequency(frequency<=maxFreq),splitSpectrum.evoked.condition(conditionCntr).saline.mean(frequency<=maxFreq),'color',[0 0 1]);
        plot(frequency(frequency<=maxFreq),splitSpectrum.evoked.condition(conditionCntr).ketamine.mean(frequency<=maxFreq),'color',[1 0 0]);
        xlim([0 maxFreq])
         
        ax = gca;
        ax.TickLength = [0.03, 0.01];
        ax.LineWidth = 1.25;
        spLeft{conditionCntr}.FontSize = 10;

        xticks(0:20:120)
        if conditionCntr<5
            xticklabels([])
        else
            xlLeft = xlabel('Frequency');
          	xlLeft.FontSize = 10;
        end
        colormap(individualColormap)
        set(gca,'YDir','normal')
        plotAxLeft{conditionCntr} = gca;
        
        if conditionCntr == 1
            ylim([-15 25])
            yticks([-10 0 10 20])
        elseif conditionCntr == 2
            ylim([-50 230])
     	elseif conditionCntr == 3
                ylLeft{conditionCntr} = ylabel(['Magnitude (' char(181) 'VHz)']);
      	elseif conditionCntr == 4
            ylim([-150 1150])
       	elseif conditionCntr == 5
            yticks([0 250 500])
        end
        plotCntr = plotCntr+1;
        
  	spRight{conditionCntr} = subplot(6,2,plotCntr);
    
      fill(([frequency(frequency<=maxFreq) fliplr(frequency(frequency<=maxFreq))]), ([(splitSpectrum.induced.condition(conditionCntr).saline.ci(frequency<=maxFreq,1))', fliplr(splitSpectrum.induced.condition(conditionCntr).saline.ci(frequency<=maxFreq,2)')]), 0.9*[0 0 1], 'EdgeColor', 'none','facealpha',.8); hold on;
      fill(([frequency(frequency<=maxFreq) fliplr(frequency(frequency<=maxFreq))]), ([(splitSpectrum.induced.condition(conditionCntr).ketamine.ci(frequency<=maxFreq,1))', fliplr(splitSpectrum.induced.condition(conditionCntr).ketamine.ci(frequency<=maxFreq,2)')]), 0.9*[1 0 0], 'EdgeColor', 'none','facealpha',.8);
      fill(([frequency(frequency<=maxFreq) fliplr(frequency(frequency<=maxFreq))]), ([(splitSpectrum.induced.condition(conditionCntr).difference.ci(frequency<=maxFreq,1))', fliplr(splitSpectrum.induced.condition(conditionCntr).difference.ci(frequency<=maxFreq,2)')]), 0.3*[1 1 1], 'EdgeColor', 'none','facealpha',.8);
        line([0 maxFreq], [0 0],'color','k', 'LineStyle','--')
        plot(frequency(frequency<=maxFreq),splitSpectrum.induced.condition(conditionCntr).saline.mean(frequency<=maxFreq),'color',[0 0 1]);
        plot(frequency(frequency<=maxFreq),splitSpectrum.induced.condition(conditionCntr).ketamine.mean(frequency<=maxFreq),'color',[1 0 0]);
      	xlim([0 maxFreq])
        
        ax = gca;
        ax.TickLength = [0.03, 0.01];
        ax.LineWidth = 1.25;
        spRight{conditionCntr}.FontSize = 10;
        
        xticks(0:20:120)
        yticks(0:40:80)
        if conditionCntr<5
            xticklabels([])
        else
            xlRight = xlabel('Frequency');
            xlRight.FontSize = 10;
        end
        colormap(individualColormap)
        set(gca,'YDir','normal')
       
        ylim([-20 100])
        if conditionCntr == 3
            ylim([-20 100])
          	ylRight{conditionCntr} = ylabel(['Magnitude (' char(181) 'VHz)']);
        end
end

spLeft{conditionCntr+1} = subplot(6,2,plotCntr+1);
axis off

xSizeRight = 0.37;
xLocationRight = 0.62;
ySizeRight = 0.16;

yPositions = [0.8  0.63 0.46 0.29 0.12];
for positionCntr = 1:length(spRight)
    spRight{positionCntr}.Position = [xLocationRight    yPositions(positionCntr)    xSizeRight    ySizeRight];
end

xlRight.FontSize = 10;
xlRight.Position(2) = -46;
xLocationLeft = 0.16;
yPositions = [0.8  0.63 0.46 0.29 0.12];
%yPositions = [0.785  0.605 0.43 0.25 0.07];

for positionCntr = 1:length(spLeft)-1
    spLeft{positionCntr}.Position = [xLocationLeft    yPositions(positionCntr)    xSizeRight    ySizeRight];
end

% create the legend
spLeft{positionCntr+1}.Position = [0.16 0.01 0.825 0.03];
patch([0 1 1 0], [0 0 1 1], [0 0 0 0], 'FaceColor' ,'w','EdgeColor','none');hold on;
patch([0 0.05 0.05 0], [0.4 0.4 0.6 0.6], [0 0 0 0], 'FaceColor' ,'b');hold on;
text(0.1, 0.56,'Saline','FontWeight','bold','FontSize',10, 'HorizontalAlignment','center','units','normalized');

patch([0.4 0.45 0.45 0.4], [0.4 0.4 0.6 0.6], [0 0 0 0], 'FaceColor' ,'r');hold on;
text(0.47, 0.56,'Ketamine','FontWeight','bold','FontSize',10, 'HorizontalAlignment','left','units','normalized');

patch([0.8 0.85 0.85 0.8], [0.4 0.4 0.6 0.6], [0 0 0 0], 'FaceColor' ,[0.5 0.5 0.5]);hold on;
text(0.865, 0.56,'Difference','FontWeight','bold','FontSize',10, 'HorizontalAlignment','left','units','normalized');

xlLeft.FontSize = 10;
xlLeft.Position(2) = -250;
ylLeft{3}.Position(1) = -18;
ylRight{3}.Position(1) = -18;


%add colum titles
    text(0.225, 32.5,'Evoked','FontWeight','bold','FontSize',12, 'HorizontalAlignment','center','units','normalized');
    text(0.785, 32.5,'Induced','FontWeight','bold','FontSize',12, 'HorizontalAlignment','center','units','normalized');

%add row titles
    text(-0.11, 29, '0 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
    text(-0.11, 23.5, '5 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
    text(-0.11, 17.5,'10 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
    text(-0.11, 12,'20 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');
    text(-0.11, 6.5,'40 Hz','FontWeight','bold','FontSize',12, 'HorizontalAlignment','right','units','normalized');


savePath = [targetFolder plotName];
exportgraphics(fig,[savePath '.pdf'],'Resolution',1000)
close(fig)





%% Figure 5: Results of the linear mixed effects model for evoked, induced and basline activity
plotName = 'figure5';

%load table with final lme results
evokedResults = load([sourceFolder 'data\results\' 'eyeControl_evoked_contrastTable']);
inducedResults = load([sourceFolder 'data\results\' 'eyeControl_induced_contrastTable']);
baselineResults = load([sourceFolder 'data\results\' 'eyeControl_baseline_contrastTable']);
evokedResults = evokedResults.eyeControl_evoked_contrastTable;
inducedResults = inducedResults.eyeControl_induced_contrastTable;
baselineResults = baselineResults.eyeControl_baseline_contrastTable;

conditionNames = {'5Hz';'10Hz';'20Hz';'40Hz'};
conditionNamesForLabel = {'5'; '10'; '20'; '40'};
tempPVals = nan(1,nrConditions-1);

%plot

fig = figure;
    set(fig,'color','w');
    fig.PaperUnits = 'centimeters';
    fig.Units = 'centimeters';
    fig.PaperPosition = [0 0 17.6 6];
    fig.PaperSize = [17.6 6];
    fig.Position = [.5 2 17.6 6];

    %evoked
    sp(1) = subplot(2,3,1);

    for conditionCntr = 1:length(conditionNames)
        tempMean = evokedResults.delta(contains(evokedResults.condition, conditionNames{conditionCntr}));
        tempLB = diff([tempMean evokedResults.CI(contains(evokedResults.condition, conditionNames{conditionCntr}),1)]);
        tempUB = diff([tempMean evokedResults.CI(contains(evokedResults.condition, conditionNames{conditionCntr}),2)]);

        errorbar(conditionCntr,tempMean,tempLB,tempUB,'color',[0 0 0],'LineWidth',2);hold on;

        plot(conditionCntr,tempMean,'o','color',[0 0 0],'LineWidth',2,'MarkerSize',2);

        tempPVals(conditionCntr) = evokedResults.pValue(contains(evokedResults.condition, conditionNames{conditionCntr}));
    end

    sigLevelComp = [-1 -1 -1 -1 ];
    survivedCorrection = tempPVals<=0.05;
    permResultsVector = survivedCorrection;

    sigLocations = [1 2 3 4];
    for sigLocationCntr = 1:numel(permResultsVector)
        if permResultsVector(sigLocationCntr)
            if tempPVals(sigLocationCntr) <=0.001
                text(sigLocations(sigLocationCntr), sigLevelComp(sigLocationCntr),'***','FontSize',16, 'HorizontalAlignment','center');
            elseif tempPVals(sigLocationCntr) <=0.005
                text(sigLocations(sigLocationCntr), sigLevelComp(sigLocationCntr),'**','FontSize',16, 'HorizontalAlignment','center');
            elseif tempPVals(sigLocationCntr) <=0.05
                text(sigLocations(sigLocationCntr), sigLevelComp(sigLocationCntr),'*','FontSize',16, 'HorizontalAlignment','center');
            end

        else
        end
    end            
    sp(1).XLim =[0 5];
    sp(1).YLim=([-15 1]);
    xlim([0 5])
    xticklabels(conditionNamesForLabel)
    xl1 = xlabel('Stimulus Frequency (Hz)','FontSize',10);
    yticks([-14 -12 -10 -8 -6 -4 -2 0]) 
    xticks([1 2 3 4])
    set(gca,'linewidth',1.5,'TickLength',[0.015, 0.01],'FontSize',10)

    ylabel(['Difference (' char(181) 'V)'],'FontSize',10);


    %induced
    sp(2) = subplot(2,3,2);

    for conditionCntr = 1:length(conditionNames)
        tempMean = inducedResults.delta(contains(inducedResults.condition, conditionNames{conditionCntr}));
        tempLB = diff([tempMean inducedResults.CI(contains(inducedResults.condition, conditionNames{conditionCntr}),1)]);
        tempUB = diff([tempMean inducedResults.CI(contains(inducedResults.condition, conditionNames{conditionCntr}),2)]);

        errorbar(conditionCntr,tempMean,tempLB,tempUB,'color',[0 0 0],'LineWidth',2);hold on;
        plot(conditionCntr,tempMean,'o','color',[0 0 0],'LineWidth',2,'MarkerSize',2);
        tempPVals(conditionCntr) = inducedResults.pValue(contains(evokedResults.condition, conditionNames{conditionCntr}));
    end

    sigLevelComp = [0.35 0.35 0.35 0.35];
    survivedCorrection = tempPVals<=0.05;
    permResultsVector = survivedCorrection;

    sigLocations = [1 2 3 4];
    for sigLocationCntr = 1:numel(permResultsVector)
        if permResultsVector(sigLocationCntr)
            if tempPVals(sigLocationCntr) <=0.001
                text(sigLocations(sigLocationCntr), sigLevelComp(sigLocationCntr),'***','FontSize',16, 'HorizontalAlignment','center');
            elseif tempPVals(sigLocationCntr) <=0.005
                text(sigLocations(sigLocationCntr), sigLevelComp(sigLocationCntr),'**','FontSize',16, 'HorizontalAlignment','center');
            elseif tempPVals(sigLocationCntr) <=0.05
                text(sigLocations(sigLocationCntr), sigLevelComp(sigLocationCntr),'*','FontSize',16, 'HorizontalAlignment','center');
            end

        else
        end
    end            
    sp(2).XLim =[0 5];
    sp(2).YLim =[-0.35 0.45];
    yticks([-0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4])
    xticks([1 2 3 4])
    xticklabels(conditionNamesForLabel)
    xl2 = xlabel('Stimulus Frequency (Hz)');
    set(gca,'linewidth',1.5,'TickLength',[0.015, 0.01],'FontSize',10)



%baseline
    sp(3) = subplot(2,3,3);

    for conditionCntr = 1:length(conditionNames)
        tempMean = baselineResults.delta(contains(baselineResults.condition, conditionNames{conditionCntr}));
        tempLB = diff([tempMean baselineResults.CI(contains(baselineResults.condition, conditionNames{conditionCntr}),1)]);
        tempUB = diff([tempMean baselineResults.CI(contains(baselineResults.condition, conditionNames{conditionCntr}),2)]);

        errorbar(conditionCntr,tempMean,tempLB,tempUB,'color',[0 0 0],'LineWidth',2);hold on;
        plot(conditionCntr,tempMean,'o','color',[0 0 0],'LineWidth',2,'MarkerSize',2);
        tempPVals(conditionCntr) = baselineResults.pValue(contains(evokedResults.condition, conditionNames{conditionCntr}));
    end

    sigLevelComp = [0.205 0.205 0.205 0.205];
    survivedCorrection = tempPVals<=0.05;
    permResultsVector = survivedCorrection;

    sigLocations = [1 2 3 4];
    for sigLocationCntr = 1:numel(permResultsVector)
        if permResultsVector(sigLocationCntr)
            if tempPVals(sigLocationCntr) <=0.001
                text(sigLocations(sigLocationCntr), sigLevelComp(sigLocationCntr),'***','FontSize',16, 'HorizontalAlignment','center');
            elseif tempPVals(sigLocationCntr) <=0.005
                text(sigLocations(sigLocationCntr), sigLevelComp(sigLocationCntr),'**','FontSize',16, 'HorizontalAlignment','center');
            elseif tempPVals(sigLocationCntr) <=0.05
                text(sigLocations(sigLocationCntr), sigLevelComp(sigLocationCntr),'*','FontSize',16, 'HorizontalAlignment','center');
            end

        else
        end
    end            
    sp(3).XLim =[0 5];
    sp(3).YLim =[-1.6 0.45];
  	yticks([-1.5 -1.2 -0.9 -0.6  -0.3  0  0.3])
    xticklabels(conditionNamesForLabel)
    xticks([1 2 3 4])
    xl3 = xlabel('Stimulus Frequency (Hz)');
    set(gca,'linewidth',1.5,'TickLength',[0.015, 0.01],'FontSize',10)
  
  
    %subplot sizes
    sp(1).Position = [0.075     0.2    0.25    0.7];
    sp(2).Position = [0.4       0.2   0.25    0.7];
    sp(3).Position = [0.725     0.2   0.25    0.7];


    text(-13.35, 0.6, 'A', 'FontSize',12, 'FontWeight', 'bold','HorizontalAlignment','center');
    text(-6.9, 0.6, 'B', 'FontSize',12, 'FontWeight', 'bold','HorizontalAlignment','center');
    text(-0.4, 0.6, 'C', 'FontSize',12, 'FontWeight', 'bold','HorizontalAlignment','center');
    

    set(sp(1),'FontSize',10)
    set(sp(2),'FontSize',10)
    set(sp(3),'FontSize',10)
    
    xl1.FontSize = 10;
    xl2.FontSize = 10;
    xl3.FontSize = 10;
    

%save plot   
savePath = [targetFolder plotName];
exportgraphics(fig,[savePath '.pdf'],'Resolution',1000)
close(fig)



%% Figure 6: results of the linear mixed effects model for spontaneous activity
plotName = 'figure6';

%load table with final lme results
spontaneousResults = load([sourceFolder 'data\results\' 'eyeControl_spontaneous_contrastTable']);

spontaneousResults = spontaneousResults.eyeControl_spontaneous_contrastTable;


conditionNames = {'delta';'theta';'alpha';'beta';'gamma'};
conditionNamesForLabel = {'delta';'theta';'alpha';'beta';'gamma'};
tempPVals = nan(1,nrConditions);

%plot

fig = figure;
    set(fig,'color','w');
    fig.PaperUnits = 'centimeters';
    fig.Units = 'centimeters';
    fig.PaperPosition = [0 0 6.5 6];
    fig.PaperSize = [6.5 6];
    fig.Position = [.5 2 6.5 6];


    for conditionCntr = 1:length(conditionNames)
        tempMean = spontaneousResults.delta(contains(spontaneousResults.condition, conditionNames{conditionCntr}));
        tempLB = diff([tempMean spontaneousResults.CI(contains(spontaneousResults.condition, conditionNames{conditionCntr}),1)]);
        tempUB = diff([tempMean spontaneousResults.CI(contains(spontaneousResults.condition, conditionNames{conditionCntr}),2)]);

        errorbar(conditionCntr,tempMean,tempLB,tempUB,'color',[0 0 0],'LineWidth',2);hold on;

        plot(conditionCntr,tempMean,'o','color',[0 0 0],'LineWidth',2,'MarkerSize',2);

        tempPVals(conditionCntr) = spontaneousResults.pValue(contains(spontaneousResults.condition, conditionNames{conditionCntr}));
    end

    sigLevelComp = [0.05 0.05 0.05 0.05 0.05];
    survivedCorrection = tempPVals<=0.05;
    permResultsVector = survivedCorrection;

    sigLocations = [1 2 3 4 5];
    for sigLocationCntr = 1:numel(permResultsVector)
        if permResultsVector(sigLocationCntr)
            if tempPVals(sigLocationCntr) <=0.001
                text(sigLocations(sigLocationCntr), sigLevelComp(sigLocationCntr),'***','FontSize',16, 'HorizontalAlignment','center');
            elseif tempPVals(sigLocationCntr) <=0.005
                text(sigLocations(sigLocationCntr), sigLevelComp(sigLocationCntr),'**','FontSize',16, 'HorizontalAlignment','center');
            elseif tempPVals(sigLocationCntr) <=0.05
                text(sigLocations(sigLocationCntr), sigLevelComp(sigLocationCntr),'*','FontSize',16, 'HorizontalAlignment','center');
            end

        else
        end
    end            

    xlim([0 6])
    xticklabels(conditionNamesForLabel)
    xticks([1 2 3 4 5])
    ylim([-1.1 0.15])
    set(gca,'linewidth',1.5,'TickLength',[0.015, 0.01],'FontSize',10)

    ylabel(['Difference (' char(181) 'V)'],'FontSize',10);

    savePath = [targetFolder plotName];
    exportgraphics(fig,[savePath '.pdf'],'Resolution',1000)
    close(fig)


end