function [ feat_exp ] = feature_expectation( gamma, state_0, board_data, theta)
% feature_expectation: Computes the mu(pi) function
% Given a policy defined by @theta, we find the expected value of
% sum of discounted feature in each game.

feat_exp = 0;
num_trials = 10;

for i=1:num_trials
    
    feat_exp_i = 0;
    t = 0;
    cur_map= state_0;
    game_over = 0;
    
    while (not(game_over))
        block_idx = ceil(rand*7);
        action = policy(cur_map, block_idx, board_data, theta);
        [new_map, game_over] = tetris_place_block(cur_map, block_idx, ...
            floor(action/4) + 1, mod(action, 4), board_data);
        feat_exp_i = feat_exp_i + gamma^t * tetris_standard_22_features(new_map);
        cur_map = new_map;
        t = t + 1;
    end % end while
    
    feat_exp = feat_exp + feat_exp_i/num_trials;
    
end % end for

%return feat_exp
end