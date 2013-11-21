function [ theta ] = sarsa( w, start_map, board_data)

num_episodes = 1;
max_steps = 10;
gamma = 0.9;
learn_rate = 0.3; 
%theta = old_theta;
theta = rand(22, 1);
num_blocks = 0;

for ep=1:num_episodes
   
    s = start_map;
    old_s = start_map;
    game_over = 0;
    action = 0;
    block_idx = 1;
    
    for step=1:max_steps
        
        [new_s, game_over] = tetris_place_block(s, block_idx, ...
            floor(action/4) + 1, mod(action, 4), board_data);

        % reward
        reward = w' * tetris_standard_22_features(new_s);

        % new best action
        new_block_idx = 1;%ceil(rand*7);
        new_action = policy(new_s, block_idx, board_data, theta);
        
        % transtion
        [new_new_s, game_over] = tetris_place_block(new_s, block_idx, ...
            floor(action/4) + 1, mod(action, 4), board_data);

        % new theta
        new_features = tetris_standard_22_features(new_new_s);
%         new_features = new_features / norm(new_features);
        old_features = tetris_standard_22_features(new_s);
%         old_features = old_features / norm(old_features);
        delta = reward + gamma * theta' * new_features ...
            - theta' * old_features;
        theta = theta + learn_rate * delta * tetris_standard_22_features(new_s);
%         delta = reward + gamma * theta' * tetris_standard_22_features(new_s) ...
%             - theta' * tetris_standard_22_features(s)
%         theta = theta + learn_rate * delta * tetris_standard_22_features(s)
        
        % update state
        old_s = s;
        s = new_s;
        action = new_action;
        block_idx = new_block_idx;
        num_blocks = num_blocks + 1;
    end
    
end


% for ep=1:num_episodes
%    
%     s = start_map;
%     old_s = start_map;
%     game_over = 0;
%     
%     while (not(game_over))
%         
%         % reward
%         reward = w' * tetris_standard_22_features(old_s);
% 
%         % new best action
%         block_idx = ceil(rand*7);
%         action = policy(s, block_idx, board_data, theta);
%         
%         % transtion
%         [new_s, game_over] = tetris_place_block(s, block_idx, ...
%             floor(action/4) + 1, mod(action, 4), board_data);
% 
%         % new theta
%         new_features = tetris_standard_22_features(new_s);
%         old_features = tetris_standard_22_features(s);
%         delta = reward + gamma * theta' * new_features ...
%             - theta' * old_features
%          theta = theta + learn_rate * delta * tetris_standard_22_features(s)
% %         delta = reward + gamma * theta' * tetris_standard_22_features(new_s) ...
% %             - theta' * tetris_standard_22_features(s)
% %         theta = theta + learn_rate * delta * tetris_standard_22_features(s)
%         
%         %theta = theta / norm(theta);
%         
%         % update state
%         old_s = s;
%         s = new_s;
%         num_blocks = num_blocks + 1;
%     end
%     
% end

end

