clear all; clc; close all;
addpath(genpath('.'))

%% 
data = load('monkeydata_training.mat');

for i = 1:100
    for j = 1:8
        pos_matrix = data.trial(i,j).handPos(1:2,:);
        
        x = pos_matrix(1,:);
        y = pos_matrix(2,:);
  
        x_diff = x(2:end)-x(1:end-1);
        y_diff = y(2:end)-y(1:end-1);

        r = vecnorm(pos_matrix);
        theta = atan(y_diff./x_diff);
        
        thres = 0;
        for t = 1:length(theta)
            if theta(t) < thres
                theta(t:end) = theta(t:end) + pi;
                thres = thres + pi;
            end
        end
       
        data.trial(i,j).r_theta = [r;[0,theta]];
        data.trial(i,j).diff = [x_diff;y_diff];
    end
end

save('modified_data', 'data')

%% sliding window



