% Author: Pieter Abbeel pabbeel@cs.berkeley.edu www.cs.berkeley.edu/~pabbeel
% 2009/11/07

function map = tetris_init_map(board_data)

% map0: matrix with 0's and 1's that stores which squares are filled/empty

BoxX = board_data.BoxX;
BoxY = board_data.BoxY;



map = ones(BoxY,BoxX);
map(2:BoxY,2:BoxX-1) = 0;

