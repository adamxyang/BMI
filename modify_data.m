function [data] = modify_data(orig_data)
data = orig_data;
[m,n] = size(data);
for i = 1:m
    for j = 1:n
        pos_matrix = data(i,j).handPos(1:2,:);

        x = pos_matrix(1,:);
        y = pos_matrix(2,:);

%         x_diff = x(300:end)-x(299:end-1);
%         y_diff = y(300:end)-y(299:end-1);

        r = vecnorm([x;y]);
        theta = atan(y./x);

        thres = 2;
        for t = 2:length(theta)
            if theta(t)-theta(t-1) > thres
                theta(t:end) = theta(t:end) - pi;
            else if theta(t) - theta(t-1) < -thres
                    theta(t:end) = theta(t:end) + pi;
                end
            end

        end
        data(i,j).r_theta = [r;theta];
    end
end

end



