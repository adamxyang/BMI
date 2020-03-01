function [modelParameters] = positionEstimatorTraining(training_data)
  % Arguments:
  
  % - training_data:
  %     training_data(n,k)              (n = trial id,  k = reaching angle)
  %     training_data(n,k).trialId      unique number of the trial
  %     training_data(n,k).spikes(i,t)  (i = neuron id, t = time)
  %     training_data(n,k).handPos(d,t) (d = dimension [1-3], t = time)
  
  % ... train your model
  
  % Return Value:
  
  % - modelParameters:
  %     single structure containing all the learned parameters of your
  %     model and which can be used by the "positionEstimator" function.
  
data = training_data;
selected_neurons = tuning_curve(data);  % neuron*angle

% data = modify_data(training_data);

X = ones(30000 * 8, 99);
y = ones(30000 * 8, 2);
start = 1;
win_len = 10;
    
% for angle = 1:8
angle = 1;
selected_angle = selected_neurons(:,1);
indices = find(selected_angle==1);
for trial = 1:max(size(training_data))
    for idx = 1:length(indices)
        neuron = indices(idx);
        spike_train = data(trial, angle).spikes(neuron, 300-win_len:end-100);
        smooth_fr = zeros(1, length(spike_train));
        for i = win_len:length(spike_train)
            smooth_fr(i) = mean(spike_train(1, i-win_len+1:i));
        end
        smooth_fr = smooth_fr(win_len:end)';
%             X(start:start+length(t0_)-1, 1+c+c:2+c+c) = [t0_, t0_.*t0_*10];
        X(start:start+length(smooth_fr)-1, 1+neuron) = smooth_fr;
        a0 = data(trial, angle).handPos(1:2, 299:end-100)';
        a1 = data(trial, angle).handPos(1:2, 300:end-99)';
        y(start:start+length(smooth_fr)-1, :) = a1 - a0;
%             target = data(t,d).r_theta(1:2,300:end-99)';
%             y(start:start+length(t0_)-1, :) = target;
    end
%         y(start:start+length(t0_)-1, :) = data.trial(t, d).r_theta();
    start = start + length(smooth_fr);
end
% end
    X = X(1:start-1, :);
    y = y(1:start-1, :);

%     [beta,Sigma,E,CovB,logL] = mvregress(y, X);
%     [b1,bint1,r1,rint1,stats1] = regress(y(:,1), X);
%     [b2,bint2,r2,rint2,stats2] = regress(y(:,2), X);

%     model1 = fitrkernel(X,y(:,1));
%     model2 = fitrkernel(X,y(:,2));

    disp('training model 1')
    model1 = fitrgp(X(:,90:end),y(:,1));
    disp('complete')
    
    disp('training model 2')
    model2 = fitrgp(X(:,90:end),y(:,2));
    disp('complete')
    
%     model1 = fitsrsvm(X,y(:,1),'KernelFunction','gaussian','KernelScale','auto',...
%     'Standardize',true);
%     model2 = fitrsvm(X,y(:,2),'KernelFunction','gaussian','KernelScale','auto',...
%     'Standardize',true);
    
% 	modelParameters = {model1, model2};
%     modelParameters = [b1,b2];
  
end
