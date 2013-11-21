function [ features ] = feature_action( state, action)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

num_feat = 22;
num_action = 40;

features = zeros(num_feat * num_action, 1);

phi = tetris_standard_22_features(state);

start_idx = (action) * length(phi) + 1;
end_idx = (action + 1) * length(phi);
features(start_idx:end_idx) = phi;

end

