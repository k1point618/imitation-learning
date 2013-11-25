% Author: Keren Gu kgu@mit.edu
% 2013 Fall UROP
% Interactive Robotics Group, CSAIL
function [action] = policy(state, block_idx, board_data, past_thetas, mixture)

% Returns the new map given the current map, and the new block that is
% presented. The policy computes the map by finding the action that
% maximizes the value function of the new map, as well as the feature form
% of the state. 

new_maps = arrayfun(@(i) tetris_place_block(state, block_idx, ...
    floor(i/4) + 1, mod(i, 4), board_data), 0:39, 'UniformOutput', false);

% Pick a theta with respect to given mixture distribution. (Make
% Stochastic)
r = rand;
index = min(find(r <= cumsum(mixture)));
theta = past_thetas(:, index);

new_map_values = arrayfun(@(map1) value_function(map1, theta), new_maps);
[best_val, action] = max(new_map_values);

action = action - 1;

end

function [value] = value_function(map1, theta)

phi0 = tetris_standard_22_features(map1{1});
value = theta' * phi0;

end