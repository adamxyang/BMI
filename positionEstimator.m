function [x, y] = positionEstimator(test_data, modelParameters)

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
    win_len = 20;
    t_all = ones(99, length(data.spikes));
    for c = 1:98 
        t0 = data.spikes(c, :);
        for i = 1:win_len
            t_all(1+c, i) = sum(t0(1, 1:i)) / win_len;
        end
        for i = win_len+1:length(t0)
            t_all(1+c, i) = mean(t0(1, i-win_len:i));
        end
    end
    
%     x = cumsum(modelParameters{1}.predict(t_all'))';
%     y = cumsum(modelParameters{2}.predict(t_all'))';
    
    x = cumsum(modelParameters(:, 1)' * t_all);
    y = cumsum(modelParameters(:, 2)' * t_all);

%     r = modelParameters(:, 1)' * t_all;
%     theta = modelParameters(:, 2)' * t_all;
    
%     x = cos(theta).*r;
%     y = sin(theta).*r;
end
