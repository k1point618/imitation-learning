% Author: Pieter Abbeel pabbeel@cs.berkeley.edu www.cs.berkeley.edu/~pabbeel
% 2009/11/07
% Editted by: Keren Gu kgu@mit.edu 2013/11
% Implemented the Inverse Reinforcement Algorithm within the Tetris
% environment provided by Prof. Abbeel pabbell@cs.berkely.edu www.cs.berkeley.edu/~pabbeel

% This file is not necessarily intended to be starter code for any of the questions.
% Its sole purpose is to illustrate some of the functions provided to you.
% In particular, this file illustrates 
% (a) how you can run an instantiation of
%     tetris for human play 
%   Controls (use numpad):
%    [4] Left  [5] Spin  [6] Right
%              [2] Drop
%    alternatively,
%    [Q] Left  [W] Spin  [E] Right
%              [S] Drop
%
%    [Ctrl+P] Pause/Unpause
% (b) the data you obtain stored in a set of global variables from human play: 
%        * chosen_map_log: a log containing all the board configurations that
%             were chosen during human play
%             chosen_map_log{k} will contain the k'th board configuration
%             encountered during play
%        * options_map_log: a log containing all the board configurations
%             that were available as a next state during human play
%             options_map_log{k}{i}: i indexes over all board situations
%             that were available to the player as next states; the one the
%             player chose is stored in chosen_map_log{k}
%         Note: the human player can choose actions not considered
%         available to the computer player.  I.e., the computer player is
%         supposed to choose a translatino and a rotation, and then simply
%         drop the block straight down.  As a consequence, it is possible
%         that the chosen_map_log{k} map is not equal to
%         options_map_log{k}{i} for any i.
%         Note2: when calling mtetris a 2nd, 3rd, etc. time, the new maps
%         will be appended to the back of the maps already stored in
%         options_map_log and chosen_map_log.
% (c) How you can have the computer play (currently playing randomly)
% start by running the following commands (it will ensure some calls will
% be executed as compiled c-code, rather than interpreted matlab code, this
% will speed up your runs)

mex tetris_place_block.c
mex tetris_standard_22_features.c
mex tetris_2_features.c

% play:
global options_map_log chosen_map_log map_idx % global variables recording tetris board situations, see above for details

mtetris
mtetris
mtetris% repeat as many games as you like
% now options_map_log and chosen_map_log will contain data

% let's compute the features for the chosen and options maps:
% [just to illustrate feature computation]
for i=1:length(chosen_map_log)
    chosen_phi_log{i} = tetris_standard_22_features(chosen_map_log{i});
    for j=1:size(options_map_log{i},2)
        options_phi_log{i}(:,j) = tetris_standard_22_features(options_map_log{i}{j});
    end
end
    
% Take the chosen_map_log and rrganize into per-demo-map_log
map_log_by_demo = [];
num_demo = 1;
index = 1;
for i=2:length(chosen_map_log)
    if (chosen_phi_log{i-1}(20) - chosen_phi_log{i}(20)) > 10
       num_demo = num_demo + 1;
       index = 1;
    end
    
    map_log_by_demo{num_demo}{index} = chosen_map_log{i};
    index = index + 1;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Outline of the IRL Algorithm
% 1. Compute Expert Feature Exp (mu_E) using map_log_by_demo
% For each iteration of the IRL:
%   2. Compute the Feature Expectation of the current policy (mu_pi).
% (recursively) (deterministic)
% 3. Quadratic Programming: find t, and max weights. 
% 4. Reinforcment Algorithm: Takes in w, and outputs a policy. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Initializing board data. 
board_data = init_board_data();
map = tetris_init_map(board_data);
game_over = 0;

% Initialize IRL values. 
MAX_ITERATIONS = 30;
FE_GAMMA = 0.9;
ALP_GAMMA = 0.9;
EPSILON = 0.15;

theta = rand(22, 1);
best_w = 0;
min_t = intmax;
Ts = ones(1,MAX_ITERATIONS);
past_feat_exp = zeros(22, 1);
past_thetas = zeros(22, 1);
states = chosen_map_log(1:10:length(chosen_map_log)); 
    % Survaying frequency. -- Should adjust depending on dataset. 
    % When the number of states to be survayved is too small, 
    % ALP may throw exception for some "matrix not positive definite" reason. 

% 1. Compute Expert Feature Exp using map_log_by_demo
exp_feat = expert_feature(FE_GAMMA, map_log_by_demo);

for i=1:MAX_ITERATIONS
    past_thetas(:, i) = theta;
    
    % 2. Compute the Feature Expectation of the current policy (mu_pi).
    mixture = ones(1, 1);
    thetas = [theta];
    feat_exp = feature_expectation(FE_GAMMA, map, board_data, thetas, mixture);
    past_feat_exp(:,i) = feat_exp;

    % 3. (quadratic programming, find weight^(i) given mu^(0, ..., i-1))
    [new_t, new_w, lambda] = quad_prog(exp_feat, past_feat_exp);
    Ts(i) = new_t/norm(exp_feat)
    
    if new_t/norm(exp_feat) < EPSILON
       break; 
    end

    % 4. (RL algo. Takes in w, returns theta)
    theta = alp(best_w, states, board_data, ALP_GAMMA);
    
end

% Modification: Mix the resulting policy.
Ts

feat_exp = feature_expectation(FE_GAMMA, map, board_data, past_thetas, lambda);
exp_feat;

NUM_DEMO = 5;
for i=1:NUM_DEMO
    run_policy(past_thetas, lambda)
end



