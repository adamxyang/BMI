function [x, y] = positionEstimator(test_data, modelParameters, win_len)

  % **********************************************************
  %
  % You can also use the following function header to keep your state
  % from the last iteration
  %
  % function [x, y, newModelParameters] = positionEstimator(test_data, modelParameters)
  %                 ^^^^^^^^^^^^^^^^^^
  % Please note that this is optional. You can still use the old function
  % declaration without returning new model parameters. 
  %
  % *********************************************************

  % - test_data:
  %     test_data(m).trialID
  %         unique trial ID
  %     test_data(m).startHandPos
  %         2x1 vector giving the [x y] position of the hand at the start
  %         of the trial
  %     test_data(m).decodedHandPos
  %         [2xN] vector giving the hand position estimated by your
  %         algorithm during the previous iterations. In this case, N is 
  %         the number of times your function has been called previously on
  %         the same data sequence.
  %     test_data(m).spikes(i,t) (m = trial id, i = neuron id, t = time)
  %     in this case, t goes from 1 to the current time in steps of 20
  %     Example:
  %         Iteration 1 (t = 320):
  %             test_data.trialID = 1;
  %             test_data.startHandPos = [0; 0]
  %             test_data.decodedHandPos = []
  %             test_data.spikes = 98x320 matrix of spiking activity
  %         Iteration 2 (t = 340):
  %             test_data.trialID = 1;
  %             test_data.startHandPos = [0; 0]
  %             test_data.decodedHandPos = [2.3; 1.5]
  %             test_data.spikes = 98x340 matrix of spiking activity
  % ... compute position at the given timestep.
  % Return Value:
  % - [x, y]:
  %     current position of the hand
    data = test_data;
    
    win_len = win_len;
    smooth_fr = zeros(98, length(data.spikes));
    for neuron = 1:98
        spike_train = data.spikes(neuron, :);
        for i = 1:win_len
            smooth_fr(neuron, i) = sum(spike_train(1, 1:i)) / win_len;
        end
        for i = win_len+1:length(spike_train)
            smooth_fr(neuron, i) = mean(spike_train(1, i-win_len:i));
        end
    end
    
    classifier = modelParameters{end};
    angle = classifier.predict(smooth_fr');
    disp('predicted angle')
    disp(angle)

    selected_neurons = modelParameters{angle}{3};
    selected_angle = selected_neurons(:,angle);
    indices = [find(selected_angle==1.)];
    
%     x = cumsum(modelParameters{angle}{1}' * smooth_fr);
%     y = cumsum(modelParameters{angle}{2}' * smooth_fr);
    
    x = cumsum(modelParameters{angle}{1}.predict(smooth_fr'))';
    y = cumsum(modelParameters{angle}{2}.predict(smooth_fr'))';

%     x = modelParameters{1}.predict(smooth_fr')';
%     y = modelParameters{2}.predict(smooth_fr')';
    

end
