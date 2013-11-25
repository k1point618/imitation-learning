% Author Pieter Abbeel pabbeel@cs.berkeley.edu www.cs.berkeley.edu/~pabbeel
% 2009/11/07
% Editted by: Keren Gu kgu@mit.edu

% Make sure that the actions are loaded into chosen_map_log
% This script will simply demonstrate how the expert log look like.
% Used to compare with resulting policy. 

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



