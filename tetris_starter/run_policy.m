% Author Pieter Abbeel pabbeel@cs.berkeley.edu www.cs.berkeley.edu/~pabbeel
% 2009/11/07
% Editted by: Keren Gu kgu@mit.edu

function [ ] = run_policy(past_thetas, lambda)
% Demonstrates a policy with a given theta. 

% Initializing board data. 
board_data = init_board_data();
map = tetris_init_map(board_data);
game_over = 0;

[hmap, hfig] = tetris_init_draw(board_data); %inits drawing, we don't use hfig actually
max_i=1000;%max number of blocks we will let the computer play for
for i=1:max_i
    block_idx = ceil(rand*7); %Pick the next random block.
    action = policy(map, block_idx, board_data, past_thetas, lambda);
    [map, game_over] = tetris_place_block(map, block_idx, ...
        floor(action/4) + 1, mod(action, 4), board_data);
    hmap = tetris_draw_now(hmap, map, board_data); 
        
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
