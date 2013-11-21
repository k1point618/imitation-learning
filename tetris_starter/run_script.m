
NUM_TRIALS = 10;
result_Ts = zeros(20, NUM_TRIALS);
result_thetas = zeros(22, NUM_TRIALS);

for temp_j=1:NUM_TRIALS
    evalc('main_play_and_collect_data_and_computer_play;');
    result_Ts(:, temp_j) = Ts;
    result_thetas(:, temp_j) = best_theta;
    clearvars best_theta exp_feat feat_exp;
    
end