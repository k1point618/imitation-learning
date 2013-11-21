% Author: Pieter Abbeel pabbeel@cs.berkeley.edu www.cs.berkeley.edu/~pabbeel
% 2009/11/07

function hmap = tetris_draw_now(hmap, map, board_data)



for x=2:board_data.BoxX-1
    for y=2:board_data.BoxY
        if(map(y,x)==1)
            set(hmap(y,x),'FaceColor',board_data.fill_color);
        else
            set(hmap(y,x),'FaceColor',board_data.bg_color);
        end
    end
end

