% Author: Keren Gu kgu@mit.edu
% 2013 Fall UROP
% Interactive Robotics Group, CSAIL
function [ expert_ft ] = expert_feature( gamma, map_log_by_demo )

% Compute the feature expectation of the expert by taking as input, 
% $m$ demonstrations of the game, and a discount factor $\gamma$, and compute
% $$\hat{\mu}_E = \frac 1 m \sum_{i=1}^m \sum_{t=0} \gamma^t \phi(s_t^{(i)})$$

m = length(map_log_by_demo);
expert_ft = 0;

for i=1:m
    map_log = map_log_by_demo{i};
    for j=1:length(map_log)
       expert_ft = expert_ft + gamma^j * tetris_standard_22_features(map_log{j});
    end
end

expert_ft = expert_ft * 1/m;

end

