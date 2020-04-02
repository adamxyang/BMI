% Test Script to give to the students, March 2015
%% Continuous Position Estimator Test Script
% This function first calls the function "positionEstimatorTraining" to get
% the relevant modelParameters, and then calls the function
% "positionEstimator" to decode the trajectory. 
function RMSE = testFunction_for_students_MTb(scale,thres, win_len)   % teamName

load monkeydata_training.mat

% Set random number generator
rng(2013);
ix = randperm(length(trial));

% addpath(teamName);

% Select training and testing data (you can choose to split your data in a different way if you wish)
trainingData = trial(ix(1:90),:);
testData = trial(ix(91:end),:);

fprintf('Testing the continuous position estimator...')

meanSqError = 0;
n_predictions = 0;  

figure
hold on
axis square
grid



% Train Model
modelParameters = positionEstimatorTraining(trainingData, scale, thres, win_len);

for tr=1:size(testData,1)
    display(['Decoding block ',num2str(tr),' out of ',num2str(size(testData,1))]);
    pause(0.001)
    tic;
    for direc=randperm(8) 
        decodedHandPos = [];
%         direc = angle;
        times=320:20:size(testData(tr,direc).spikes,2);
        
        for t=times
            %disp(t)
            past_current_trial.trialId = testData(tr,direc).trialId;
            past_current_trial.spikes = testData(tr,direc).spikes(:,1:t); 
            past_current_trial.decodedHandPos = decodedHandPos;

            past_current_trial.startHandPos = testData(tr,direc).handPos(1:2,1); 
            
            if nargout('positionEstimator') == 3
                [decodedPosX, decodedPosY, newParameters] = positionEstimator(past_current_trial, modelParameters, win_len);
                modelParameters = newParameters;
            elseif nargout('positionEstimator') == 2
                [decodedPosX, decodedPosY] = positionEstimator(past_current_trial, modelParameters, win_len);
            end
            
            decodedPos = [decodedPosX; decodedPosY];
            decodedHandPos = [decodedHandPos decodedPos];
            %decodedHandPos = decodedPos;
            
            
            %disp(size(testData(tr,direc).handPos(1:2,1:t)))
            %disp(size( decodedHandPos ))
            meanSqError = meanSqError + norm(testData(tr,direc).handPos(1:2,t) - decodedPos)^2;
            
        end
        n_predictions = n_predictions+length(times);
        hold on
        scatter(decodedHandPos(1,:),decodedHandPos(2,:),'.','r');
        scatter(testData(tr,direc).handPos(1,times),testData(tr,direc).handPos(2,times),'.','b')
        %scatter(decodedHandPos(1,:),decodedHandPos(2,:), '.','r');
        %scatter(testData(tr,direc).handPos(1,times),testData(tr,direc).handPos(2,times),'.','b')
%     end
        toc
end

% legend('Decoded Position', 'Actual Position')

RMSE = sqrt(meanSqError/n_predictions) 

% rmpath(genpath(teamName))

end
