data = load('monkeydata_training.mat');

trial = 1;
angle = 1;
y = data.trial(trial,angle).handPos;
scatter(y(1,:),y(2,:),'b')
hold on
scatter(y(1,300:end-100), y(2,300:end-100), 'r')