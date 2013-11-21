% Author: Pieter Abbeel pabbeel@cs.berkeley.edu www.cs.berkeley.edu/~pabbeel
% 2009/11/07

function board_data = init_board_data()

board_data.BoxX = 12;
board_data.BoxY = 19;
board_data.PatX = [0;-1;-1;0];						% coordinates for drawing patches
board_data.PatY = [0;0;-1;-1];
board_data.bg_color = [.8 .8 .8];
board_data.fill_color = [.1 .1 .9];
