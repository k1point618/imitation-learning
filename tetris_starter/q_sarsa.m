function [ theta ] = q_sarsa( w, start_map, board_data, old_theta )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

num_episodes = 1;
max_steps = 5;
gamma = 0.9;
learn_rate = 0.5; 
theta = old_theta; % Initialize theta arbitrarily

for ep=1:num_episodes
   
    s = start_map;
    game_over = 0;
    action = 0;
    block_idx = 1;
    
    for step=1:max_steps

        [new_s, game_over] = tetris_place_block(s, block_idx, ...
            floor(action/4) + 1, mod(action, 4), board_data);

        % reward
        reward = w' * tetris_standard_22_features(new_s)

        % new best action
        new_block_idx = ceil(rand*7);
        new_action = q_policy(new_s, new_block_idx, board_data, theta);
        
        % transtion
        % Page 35 algo does not have this
        % [new_new_s, game_over] = tetris_place_block(new_s, block_idx, ...
        %     floor(new_action/4) + 1, mod(new_action, 4), board_data);

        % new theta
        new_features = feature_action(new_s, new_action); %phi(s', a')
        old_features = feature_action(s, action); %phi(s, a)
        delta = reward ... 
              + gamma * theta' * new_features ...
              - theta' * old_features
        theta = theta + learn_rate * delta * new_features
        
        % update state
        s = new_s;
        action = new_action;
        block_idx = new_block_idx;
    end
    
end

end

function [action] = q_policy(state, block_idx, board_data, theta)

new_maps = arrayfun(@(i) tetris_place_block(state, block_idx, ...
    floor(i/4) + 1, mod(i, 4), board_data), 0:39, 'UniformOutput', false);

actions = 0:39;
new_map_values = arrayfun(@(map1, a) q_value_function(map1, theta, a), new_maps, actions);
[best_val, action] = max(new_map_values);

action = action - 1;

end

function [value] = q_value_function(map1, theta, action)

phi0 = feature_action(map1{1}, action);
value = theta' * phi0;

end