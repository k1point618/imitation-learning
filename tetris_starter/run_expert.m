mex tetris_place_block.c
mex tetris_standard_22_features.c
mex tetris_2_features.c

global options_map_log chosen_map_log map_idx best_theta % global variables recording tetris board situations, see above for details

% Initializing board data. 
board_data = init_board_data();
map = tetris_init_map(board_data);
[hmap, hfig] = tetris_init_draw(board_data); %inits drawing, we don't use hfig actually
game_over = 0;

for i=1:length(chosen_map_log)
    hmap = tetris_draw_now(hmap, chosen_map_log{i}, board_data); 
    
%     translation_action = ceil(rand*10); %choose from 1 to 10
%     rotation_action = ceil(rand*4)-1; % choose from 0 to 3
%     [map,game_over] = tetris_place_block(map, block_idx, translation_action, rotation_action, board_data);
%     hmap = tetris_draw_now(hmap, map, board_data); %draws the current map; will slow things down, obviously
    
    %note: occasionally the "tetris_draw_now" fails and complains about an
    %invalide handle; not sure what the deal is; if you find out, let me
    %know; in the meantime, it really should not prevent you from cracking
    %you entire PS b/c most of the time you would not want to draw anyway
    %(b/c it takes time)
    
    if(game_over)
        break;
    end
    pause(.1); % allows us to watch it play (current policy is not all that clever and interesting to watch though!)
end
fprintf(1,['\n\nthe computer managed to place ' num2str(i) ' blocks onto the board\n\n']);



