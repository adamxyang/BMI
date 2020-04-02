function [modelParameters] = positionEstimatorTraining(training_data, scale, thres, win_len)  
    data = training_data;
    selected_neurons = tuning_curve(data, scale, thres, win_len);  % neuron*angle

    % data = modify_data(training_data);

    win_len = 20;    
    modelParameters = {};
    
    for angle = 1:8
        
        speed = NaN;
        relative_sin = NaN;
        relative_cos = NaN;
        spike_angle = zeros(1,1);
        
        selected_angle = selected_neurons(:,angle);
        indices = find(selected_angle==1.);        %when to ask for it
        window_accu_length = 0;

        for trial = 1:max(size(training_data))
            
            timelength = length(data(trial, angle).spikes(1, 300-win_len:end-100));
            windows = ceil(timelength./win_len);
            window_start_timestep = 300-win_len;      

            for window = 1: windows    
                for idx = 1:length(indices)    
                    neuron = indices(idx);
                    t_start = window_start_timestep;
                    if window_start_timestep + win_len < timelength
                        t_end = window_start_timestep + win_len;
                    else
                        t_end = timelength;
                    end
                    
                    spike_sum = sum(data(trial,angle).spikes(neuron,t_start:t_end));
                    spike_angle(window_accu_length+window, idx) = spike_sum;
                end

                distanceX= data(trial, angle).handPos(1,window_start_timestep + win_len)- data(trial, angle).handPos(1,window_start_timestep);
                distanceY = data(trial, angle).handPos(2,window_start_timestep + win_len)- data(trial, angle).handPos(2,window_start_timestep);
                
                speed(window_accu_length+window) = sqrt(distanceX^2 + distanceY^2);
                relative_sin(window_accu_length+window) = distanceY/speed(window_accu_length+window);
                relative_cos(window_accu_length+window) = distanceX/speed(window_accu_length+window);
                
                window_start_timestep = window_start_timestep + win_len;
            end
            window_accu_length = window_accu_length+windows; %goto another trial
        end

        tic;
        model1 = fitrlinear(spike_angle, speed);
%         model1 = fitrkernel(spike_angle, speed);
        toc

        tic;
        model2 = fitrlinear(spike_angle,relative_sin);
%         model2 = fitrkernel(spike_angle, relative_sin);
        toc

        tic;
        model3 = fitrlinear(spike_angle,relative_cos);
%         model3 = fitrkernel(spike_angle, relative_cos);
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
%                 spike_num = 0;
%                 for t=1:tmax
%                     if training_data(n,k).spikes(i,t) == 1
%                         spike_num = spike_num + 1;
%                     end
%                 end
            spike_sum = sum(data(n,k).spikes(i,1:tmax));
            spike_count(count,i)= spike_sum;
            response_2(count) = k;
            count = count +1;
        end
    end
end
tic;
classifier = fitcecoc(spike_count, response_2);
% classifier = fitcknn(spike_count,response_2,'NumNeighbors',10,'NSMethod','exhaustive','Distance','cosine');
modelParameters{end+1} = classifier;
toc
end