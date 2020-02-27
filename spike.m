clear all; clc; close all;
addpath(genpath('.'))

%% 
data = load('monkeydata_training.mat');

for i = 1:100
    for j = 1:8
        pos_matrix = data.trial(i,j).handPos(1:2,:);
        r = vecnorm(pos_matrix);
        theta = atan(pos_matrix(1,:)./pos_matrix(2,:));
        x_diff = pos_matrix(1,2:end)-pos_matrix(1,1:end-1);
        y_diff = pos_matrix(2,2:end)-pos_matrix(2,1:end-1);

        data.trial(i,j).r_theta = [r;theta];
        data.trial(i,j).diff = [x_diff;y_diff];
    end
end

save('modified_data', 'data')

%% sliding window



