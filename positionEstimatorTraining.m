function [modelParameters] = positionEstimatorTraining(training_data, scale, thres, win_len)  
    data = training_data;
    selected_neurons = tuning_curve(data, scale, thres, win_len);  % neuron*angle

    % data = modify_data(training_data);

%     win_len = win_len;    
    X_all = ones(300000*8, 98);  % for classification
    y_all = ones(300000*8,1);
    total_length = 1;
    modelParameters = {};
    
    for angle = 1:8
        
%         distanceX = NaN;
%         distanceY = NaN;
        speed = NaN;
        relative_sin = NaN;
        relative_cos = NaN;
        
        spike_angle = zeros(1,1);
        
        start = 1;
        
        selected_angle = selected_neurons(:,angle);
        indices = find(selected_angle==1.);        %when to ask for it
        indices = 97; 
        X = ones(30000 * 8, 98);
        y = ones(30000 * 8, 2);
        window_accu_length = 0;

        for trial = 1:max(size(training_data))
            
            timelength = length(data(trial, angle).spikes(1, 300-win_len:end-100))-80;
            num_windows = ceil(timelength./win_len);
            window_start_timestep = 300-win_len;      

            for window = 1:num_windows    
                for neuron = 1:length(indices)
%                     spike_sum = 0;
%                     for t = window_start_timestep -80 : window_start_timestep + win_len -80
%                         if t < timelength-80
%                             if data(trial, angle).spikes(neuron, t)
%                                 spike_sum = spike_sum + 1; 
%                             end
%                         end
%                     end 
%                     t_start = window_start_timestep - 80;
%                     if window_start_timestep - 80 < timelength - 80
%                         t_end = window_start_timestep + window*win_len - 80;
%                     else
%                         t_end = timelength - 80;
%                     end
                    
                    t_start = window_start_timestep;
                    if window_start_timestep < timelength
                        t_end = window_start_timestep + window*win_len;
                    else
                        t_end = timelength;
                    end
                    
                    spike_sum = sum(data(trial,angle).spikes(neuron,t_start:t_end));
                    spike_angle(window_accu_length+window, neuron) = spike_sum;
                end

                distanceX = data(trial, angle).handPos(1,window_start_timestep + win_len)- data(trial, angle).handPos(1,window_start_timestep);
                distanceY = data(trial, angle).handPos(2,window_start_timestep + win_len)- data(trial, angle).handPos(2,window_start_timestep);
                
                speed(window_accu_length+window) = sqrt(distanceX^2 + distanceY^2);
                relative_sin(window_accu_length+window) = distanceY/speed(window_accu_length+window);
                relative_cos(window_accu_length+window) = distanceX/speed(window_accu_length+window);
                
                window_start_timestep = window_start_timestep + win_len;
            end
            window_accu_length = window_accu_length+num_windows;
        end
        
        disp('angle')
        disp(angle)
        disp('number of selected neurons')
        disp(length(indices))
        
        disp('training model 1')
        tic;
%         model1 = fitlm(spike_angle, distanceX);
        model1 = fitrlinear(spike_angle,speed);
%         model1 = fitrkernel(spike_angle, distanceX);
%         model1 = fitrgp(spike_angle, distanceX);
        toc
        
        disp('training model 2')
        tic;
%         model2 = fitlm(spike_angle,distanceY);
        model2 = fitrlinear(spike_angle,relative_sin);
%         model2 = fitrkernel(spike_angle,distanceY);
%         model2 = fitrgp(spike_angle,distanceY);
        toc
        
        disp('training model 3')
        tic;
%         model2 = fitlm(spike_angle,distanceY);
        model3 = fitrlinear(spike_angle,relative_cos);
%         model2 = fitrkernel(spike_angle,distanceY);
%         model2 = fitrgp(spike_angle,distanceY);
        toc

        modelParameters{angle} = {model1, model2, model3, selected_neurons};
       
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
    tic;
    classifier = fitcecoc(spike_count, response_2);
%     classifier = fitcknn(spike_count,response_2,'NumNeighbors',10,'NSMethod','exhaustive','Distance','cosine');
    modelParameters{end+1} = classifier;
    toc
end
