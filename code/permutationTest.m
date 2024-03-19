function permResult = permutationTest(group1,group2,varargin)

defaultSide = 'two';                 
sideOptions = {'two', 'left', 'right'};

defaultComparison = 'groups';                 
comparisonOptions = {'groups', 'differences'};


    p = inputParser;
    p.addParameter('nrIterations',10000);
  	p.addParameter('groupNames',{'group1'; 'group2'});
  	p.addParameter('ci',[2.5 97.5]);
  	p.addParameter('side',defaultSide, @(x) any(validatestring(upper(x),sideOptions)));
  	p.addParameter('comparison',defaultComparison, @(x) any(validatestring(upper(x),comparisonOptions)));
    p.addParameter('paired',false);
    p.parse(varargin{:});

    
    groupNames = p.Results.groupNames;
    nrIterations = p.Results.nrIterations;
    
    %how many trials should be picked from each group?
    switch lower(p.Results.comparison)
        
        case 'groups'
    
            nrTrials= [numel(group1) numel(group2)];

            permResult.side = p.Results.side;

            %create null model
            
            combinedGroup = cat(1,group1,group2);
            clearvars group1 group2
            
            permIdx = nan(sum(nrTrials),nrIterations);
            for iterationCntr = 1:nrIterations
                permIdx(:,iterationCntr) = randperm(sum(nrTrials),sum(nrTrials)); 
            end
            fakeGroup1 = combinedGroup(permIdx(1:nrTrials(1),:));
           	fakeGroup2 = combinedGroup(permIdx(nrTrials(1)+1:end,:));
            nullDistribution = squeeze(mean(fakeGroup1,'omitnan')-mean(fakeGroup2,'omitnan'));
            
            group1Difference = mean(combinedGroup(randi(nrTrials(1),nrTrials(1),nrIterations)),'omitnan');
            group2Difference = mean(combinedGroup(randi(nrTrials(2),nrTrials(2),nrIterations)+nrTrials(1)),'omitnan');
            
            %assign results to output
            permResult.(groupNames{1}).mean = mean(group1Difference,'omitnan');
            permResult.(groupNames{2}).mean = mean(group2Difference,'omitnan');
            permResult.(groupNames{1}).distribution = group1Difference;
           	permResult.(groupNames{2}).distribution = group2Difference;
            permResult.(groupNames{1}).ci = prctile(group1Difference, [p.Results.ci(1) p.Results.ci(2)]);
           	permResult.(groupNames{2}).ci = prctile(group2Difference, [p.Results.ci(1) p.Results.ci(2)]);
            
            if p.Results.paired
                if isequal(nrTrials(1),nrTrials(2))
                    combinedGroup = combinedGroup(1:nrTrials(1)) - combinedGroup(nrTrials(1)+1:end);
                    bootsIdx.group1 = randi(nrTrials(1),nrTrials(1),nrIterations);
                    realDifference = mean(combinedGroup(bootsIdx.group1));
                else 
                    error('Groups have unequal nr entries. Not possible to perform paaired test.')
                end
            else
                bootsIdx.group1 = randi(nrTrials(1),nrTrials(1),nrIterations);
                bootsIdx.group2 = randi(nrTrials(2),nrTrials(2),nrIterations);
                bootsIdx.group2 = bootsIdx.group2+nrTrials(1);
                realDifference = mean(combinedGroup(bootsIdx.group1),'omitnan') - mean(combinedGroup(bootsIdx.group2),'omitnan');
            end
            

          	%assign results to output
            permResult.difference = mean(realDifference,'omitnan');
            permResult.differenceDistribution = realDifference;
            permResult.nullModelStd = std(nullDistribution,'omitnan');
            permResult.zScore = permResult.difference/ permResult.nullModelStd;


            if any(isnan(nullDistribution))
                permResult.permPVal = NaN;
            else
                switch lower(p.Results.side)
                    case 'two'
                        permResult.permPVal = sum(abs(nullDistribution)>=abs(mean(realDifference,'omitnan')))/nrIterations;
                    case 'left'
                        permResult.permPVal = sum(nullDistribution<=(mean(realDifference,'omitnan')))/nrIterations;
                    case 'right'
                        permResult.permPVal = sum(nullDistribution>=(mean(realDifference,'omitnan')))/nrIterations;
                end      

            end
            permResult.ci = prctile(realDifference,[p.Results.ci(1) p.Results.ci(2)]);

        case 'differences'
            

          	nrTrials= [numel(group1{1}) numel(group1{2}) numel(group2{1}) numel(group2{2})];

            permResult.side = p.Results.side;

            if sum(nrTrials>1)==4

                %make sure the number of trials is divisable by 2
                nrTrialsPerIteration = floor(min(nrTrials*0.8));
                if ~isequal(rem(nrTrialsPerIteration,2),0)
                    nrTrialsPerIteration = nrTrialsPerIteration-1;
                end

                %create random selection of trials
                clearvars permIdx
                for iterationCntr = 1:nrIterations
                    permIdx.group1A(:,iterationCntr) = randperm(nrTrials(1),nrTrialsPerIteration);
                    permIdx.group1B(:,iterationCntr) = randperm(nrTrials(2),nrTrialsPerIteration);
                    permIdx.group2A(:,iterationCntr) = randperm(nrTrials(3),nrTrialsPerIteration);
                    permIdx.group2B(:,iterationCntr) = randperm(nrTrials(4),nrTrialsPerIteration);
                end

               
                bootsIdx.group1A = randi(nrTrials(1),nrTrialsPerIteration,nrIterations);
                bootsIdx.group1B = randi(nrTrials(2),nrTrialsPerIteration,nrIterations);
                bootsIdx.group2A = randi(nrTrials(3),nrTrialsPerIteration,nrIterations);
                bootsIdx.group2B = randi(nrTrials(4),nrTrialsPerIteration,nrIterations);
                
                group1Differences = (group1{1}(bootsIdx.group1A) - group1{2}(bootsIdx.group1B));
                group2Differences = (group2{1}(bootsIdx.group2A) - group2{2}(bootsIdx.group2B));

                
                fakeGroup1 = [group1Differences(1:nrTrialsPerIteration/2,:); group2Differences(nrTrialsPerIteration/2+1:end,:)];
                fakeGroup2 = [group2Differences(1:nrTrialsPerIteration/2,:); group1Differences(nrTrialsPerIteration/2+1:end,:)];

                
                realDifference = mean(mean(group1{1}(bootsIdx.group1A) - group1{2}(bootsIdx.group1B), 'omitnan') - mean(group2{1}(bootsIdx.group2A) - group2{2}(bootsIdx.group2B), 'omitnan'), 'omitnan');
                nullDistribution = squeeze(mean(fakeGroup1 - fakeGroup2), 'omitnan');

               	realAverage.group1 = mean(group1Differences);
                realAverage.group2 = mean(group2Differences);

                
            	%assign results to output
                permResult.(groupNames{1}).mean = mean(realAverage.group1,'omitnan');
                permResult.(groupNames{2}).mean = mean(realAverage.group2,'omitnan');
                permResult.(groupNames{1}).distribution = realAverage.group1;
                permResult.(groupNames{2}).distribution = realAverage.group2;
                permResult.(groupNames{1}).ci = prctile(realAverage.group1, [p.Results.ci(1) p.Results.ci(2)]);
                permResult.(groupNames{2}).ci = prctile(realAverage.group2, [p.Results.ci(1) p.Results.ci(2)]);

                permResult.difference = realDifference;
                permResult.differenceDistribution = realAverage.group1 - realAverage.group2;

                permResult.nullModelStd = std(nullDistribution,'omitnan');
                

                permResult.zScore = realDifference/ permResult.nullModelStd;
                if any(isnan(nullDistribution))
                    permResult.permPVal = NaN;
                else
                    switch lower(p.Results.side)
                        case 'two'
                            permResult.permPVal = sum(abs(nullDistribution)>=abs(realDifference))/nrIterations;
                        case 'left'
                            permResult.permPVal = sum(nullDistribution<=realDifference)/nrIterations;
                        case 'right'
                            permResult.permPVal = sum(nullDistribution>=realDifference)/nrIterations;
                    end      

                end
                permResult.ci = prctile(realAverage.group1 - realAverage.group2,[p.Results.ci(1) p.Results.ci(2)]);
                
            else

                %assign results to output
                permResult.(groupNames{1}).mean = NaN;
                permResult.(groupNames{2}).mean = NaN;
                permResult.(groupNames{1}).distribution = NaN;
                permResult.(groupNames{2}).distribution = NaN;
                permResult.(groupNames{1}).ci = [NaN NaN];
                permResult.(groupNames{2}).ci = [NaN NaN];

                permResult.difference = NaN;
                permResult.differenceDistribution = NaN;

                permResult.nullModelStd = NaN;
                permResult.zScore = NaN;
                permResult.permPVal = NaN;
                permResult.ci = [NaN NaN];
            end                
            
            
    end
    
   	permResult.nrIterations = nrIterations;

end
