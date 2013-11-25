% Author: Keren Gu kgu@mit.edu
% 2013 Fall UROP
% Interactive Robotics Group, CSAIL

function [ features ] = feature_action(state, action)

% Used for q_sarsa: The version of SARSA that expands the feature of a
% state into a combination of feature of state and action. 
% Since SARSA is not used, this function is also not used. 
num_feat = 22;
num_action = 40;

features = zeros(num_feat * num_action, 1);

phi = tetris_standard_22_features(state);

start_idx = (action) * length(phi) + 1;
end_idx = (action + 1) * length(phi);
features(start_idx:end_idx) = phi;

end

