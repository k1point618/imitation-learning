function [ theta_opt ] = alp(reward_weights, states, board_data, gamma)

num_actions = 40;
num_blocks = 7;

% Begin Linear Programming
cvx_begin
variable theta(22)
minimize (min_fun(theta, states))
subject to 
for i=1:length(states)
    
    s = states{i};
    
    for j=1:num_actions
        
        a = j;
        
        %Assume for now, there is only 1 block
        %for k=1:num_blocks
        block_idx = ceil(rand*num_blocks);
        
        [s_prime, game_over] = tetris_place_block(s, block_idx, ...
        floor(a/4) + 1, mod(a, 4), board_data);
    
        phi = tetris_standard_22_features(s);
        phi_prime = tetris_standard_22_features(s_prime);
        if game_over
            reward = -1 *  100000;
        else
            reward = reward_weights' * phi_prime;
        end
        0 >= (reward + gamma * theta' * phi_prime) - theta' * phi;
        
        %end
        
    end
    
end
cvx_end

theta_opt = theta;

end

function [value] = min_fun(theta, states)
% return SUM over s (theta' * phi(s))
% Where to get a set of sampling states?
    value = 0;
    for i=1:length(states)
        value = value + theta' * tetris_standard_22_features(states{i});
    end

end

% 
% function [value] = func2(reward_weights, states, i, board_data, theta)
% 
%     gamma = 0.5;
%     
%     phi = tetris_standard_22_features(states{i});
%     sum_term = 0;
%     for block_idx=1:7
%         action = policy(states{i}, block_idx, board_data, theta);
%         [new_state, game_over] = tetris_place_block(states{i}, block_idx, ...
%             floor(action/4) + 1, mod(action, 4), board_data);
%         new_phi = tetris_standard_22_features(new_state);
%         sum_term = sum_term + theta' * new_phi;
%     end
%     
%     value = reward_weights' * phi + 1/7 * gamma * sum_term - theta' * phi;
% end