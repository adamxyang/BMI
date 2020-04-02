rmse_old = inf;
for win_len = 1:1:20
    for scale = 0:10:100
        for thres = 0.0:0.01:0.2
            rmse = testFunction_for_students_MTb(scale,thres,win_len);
            if rmse < rmse_old
                best_params = {scale,thres,win_len}
            end
        end
    end
end
