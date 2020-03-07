function [modelParameters] = positionEstimatorTraining(training_data, scale, thres, win_len)  
    data = training_data;
    selected_neurons = tuning_curve(data, scale, thres, win_len);  % neuron*angle

    % data = modify_data(training_data);

    win_len = 20;    
    X_all = ones(300000*8, 98);  % for classification
    y_all = ones(300000*8,1);
    total_length = 1;
    modelParameters = {};
    
    for angle = 1:8
        
        distanceX = NaN;
        distanceY = NaN;
        spike_angle = zeros(1,1);
        
        start = 1;
        
        selected_angle = selected_neurons(:,angle);
        indices = find(selected_angle==1.);        %when to ask for it

        X = ones(30000 * 8, 98);
        y = ones(30000 * 8, 2);
        window_accu_length = 0;

        for trial = 1:max(size(training_data))
            
            timelength = length(data(trial, angle).spikes(1, 300-win_len:end-100))-80;
            windows = ceil(timelength./win_len);
            window_start_timestep = 300-win_len;      

            for window = 1: windows    
                for neuron = 1:length(indices)
                    spike_sum = 0;
                    for t = window_start_timestep -80 : window_start_timestep + win_len -80
                        if t < timelength-80
                            if data(trial, angle).spikes(neuron, t)
                                spike_sum = spike_sum + 1; 
                            end
                        end
                    end 
                    spike_angle(window_accu_length+window, neuron) = spike_sum;
                end

                distanceX(window_accu_length+window) = data(trial, angle).handPos(1,window_start_timestep + win_len)- data(trial, angle).handPos(1,window_start_timestep);
                distanceY(window_accu_length+window) = data(trial, angle).handPos(2,window_start_timestep + win_len)- data(trial, angle).handPos(2,window_start_timestep);
                window_start_timestep = window_start_timestep + win_len;
            end
            window_accu_length = window_accu_length+windows;
        end
        
        disp('training model 1')
        tic;
        model1 = fitrkernel(spike_angle, distanceX);
        toc
        %disp('complete')
        
        disp('training model 2')
        tic;
        model2 = fitrkernel(spike_angle,distanceY);
        toc
        disp('complete')

        modelParameters{angle} = {model1, model2, selected_neurons};
       
    end
    
spike_count = NaN;

response_2 = NaN;

    for i = 1:98
        count =1;
        for k=1:8        
            for n=1:length(training_data)  
                tmax = 320;
                spike_num = 0;
                for t=1:tmax
                    if training_data(n,k).spikes(i,t) == 1
                        spike_num = spike_num + 1;
                    end
                end
                spike_count(count,i)= spike_num;
                response_2(count) = k;
                count = count +1;
            end
        end
    end
    classifier = fitcknn(spike_count,response_2,'NumNeighbors',10,'NSMethod','exhaustive','Distance','cosine');
    modelParameters{end+1} = classifier;
    toc
end
