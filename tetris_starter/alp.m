% Author: Keren Gu kgu@mit.edu
% 2013 Fall UROP
% Interactive Robotics Group, CSAIL
function [ theta_opt ] = alp(reward_weights, states, board_data, gamma)


% In ALP, we solve the following linear programming problem:
% $$\min_\theta c(s)\theta^T \phi(s)$$
% $$s.t.\ \theta^T \phi(s)\geq \sum_{s'}T(s, a, s')(R(s, a, s') + \gamma 
% \theta^T \phi(s')); \ \forall s \in S, \ \forall a$$. 
% In our implementation, we sample $s$ from the provided in states, and 
% consider all possible $a$ and $s'$ for a given $s$. 


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


%%%%%%%%%% Test ALP %%%%%%%%%%
% % The following tests the how ALP find the policy with a given reward
% % function.
% gammas = [1:10] * 0.1;
% results = [1:10];
% for i=1:length(gammas)
%     
%     states = chosen_map_log(1:10:length(chosen_map_log));
%     theta = alp(new_w, states, board_data, 0.9); %gammas(i));
%     max_j = 100;
%     map = tetris_init_map(board_data);
%     for j=1:max_j
%         block_idx = ceil(rand*7);
%         action = policy(map, block_idx, board_data, theta);
%         [map, game_over] = tetris_place_block(map, block_idx, ...
%             floor(action/4) + 1, mod(action, 4), board_data);
%         if(game_over)
%             break;
%         end
%     end
%     results(i) = j;
% end
% results
% plot(gammas, results)
%%%% Test shows that 0.9 gamma works the best. 
%%%% In terms of Reward function, @gamma=0.9, 0-1 reward landed ~150 blocks. 
