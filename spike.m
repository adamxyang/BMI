clear all; clc; close all;
addpath(genpath('.'))
 
data = load('monkeydata_training.mat');

for i = 1:100
    for j = 1:8
        pos_matrix = data.trial(i,j).handPos(1:2,:);
        
        x = pos_matrix(1,:);
        y = pos_matrix(2,:);
  
        x_diff = x(300:end)-x(299:end-1);
        y_diff = y(300:end)-y(299:end-1);

        r = vecnorm([x_diff;y_diff]);
        theta = atan(y_diff./x_diff);
        
        thres = 2;
        for t = 2:length(theta)
            if theta(t)-theta(t-1) > thres
                theta(t:end) = theta(t:end) - pi;
            else if theta(t) - theta(t-1) < -thres
                    theta(t:end) = theta(t:end) + pi;
                end
            end
            
        end
       
        data.trial(i,j).r_theta = [r;theta];
        data.trial(i,j).diff = [x_diff;y_diff];
    end
end

save('modified_data', 'data')

%%
i = 1;
j = 6;
r = [];
for i = 1:100
    for j = 1:8
        r_theta = data.trial(i,j).r_theta;
        r = [r,r_theta(2,:)];
        plot(r_theta(2,:));
        hold on;
    end
end

% r_theta = data.trial(i,j).r_theta;
% plot(r);

% hold on;
% plot(y_diff);
% 
% hold on;
% plot(x_diff);
% legend('theta', 'y diff' ,'x diff');



