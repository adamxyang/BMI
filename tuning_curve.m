data = load('monkeydata_training.mat')

win_len = 20
avg_fr = zeros(98;8)
for angle = 1:8
    for 
    end
end


X = ones(30000 * 8, 99);
y = ones(30000 * 8, 2);
start = 1;
win_len = 10;
    
for d = 1:8
    for t = 1:max(size(training_data))  
        for c = 1:98 
            t0 = data(t, d).spikes(c, 300-win_len:end-100);
            t0_ = zeros(1, length(t0));
            for i = win_len:length(t0)
                t0_(i) = mean(t0(1, i-win_len+1:i));
            end
            t0_ = t0_(win_len:end)';
%             X(start:start+length(t0_)-1, 1+c+c:2+c+c) = [t0_, t0_.*t0_*10];
            X(start:start+length(t0_)-1, 1+c) = t0_;
            a0 = data(t, d).handPos(1:2, 299:end-100)';
            a1 = data(t, d).handPos(1:2, 300:end-99)';
            y(start:start+length(t0_)-1, :) = a1 - a0;
%             target = data(t,d).r_theta(1:2,300:end-99)';
%             y(start:start+length(t0_)-1, :) = target;
        end
%         y(start:start+length(t0_)-1, :) = data.trial(t, d).r_theta();
        start = start + length(t0_);
    end
end
    X = X(1:start-1, :);
    y = y(1:start-1, :);