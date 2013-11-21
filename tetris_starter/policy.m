function [action] = policy(state, block_idx, board_data, theta)
% Returns the new map given the current map, and the new block that is
% presented. The policy computes the map by finding the action that
% maximizes the value function of the new map, as well as the feature form
% of the state. 

new_maps = arrayfun(@(i) tetris_place_block(state, block_idx, ...
    floor(i/4) + 1, mod(i, 4), board_data), 0:39, 'UniformOutput', false);

new_map_values = arrayfun(@(map1) value_function(map1, theta), new_maps);
[best_val, action] = max(new_map_values);

% action = 0;
% best_val = 0;
% for i=1:length(new_maps)
%     new_val = value_function(new_maps(i), theta);
%     best_val = max(new_val, best_val);
%     
% end

%[best_val, action] = max(new_vals);
action = action - 1;

end

function [value] = value_function(map1, theta)

phi0 = tetris_standard_22_features(map1{1});
% theta = [0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 0 0];
% theta = theta * -1;
value = theta' * phi0;

end