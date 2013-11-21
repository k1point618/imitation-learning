% Author: Pieter Abbeel pabbeel@cs.berkeley.edu www.cs.berkeley.edu/~pabbeel
% 2009/11/07

function [HMAP,HFIG] = tetris_init_draw(board_data)

BoxX = board_data.BoxX;
BoxY = board_data.BoxY;
PatX = board_data.PatX;
PatY = board_data.PatY;
bg_color = board_data.bg_color;
fill_color = board_data.fill_color;

% initialize figure window

HFIG = figure('Name','MTetris','Numbertitle','off','Menubar','none',...
    'Color', bg_color,'Resize','off','DoubleBuffer','on',...
    'Position',[150,150,220,400]);
axes('Units','normalized','Position', [.05 .06 .9 .93],'Visible','off',...
    'DrawMode','fast','NextPlot','replace','XLim',[1,BoxX-1],'YLim',[1,BoxY]);
set(line([1,BoxX-1,BoxX-1,1,1],[1,1,BoxY,BoxY,1]),'Color',[0,0,0]);

set(HFIG,'Position',[150,150,220,400]);
for x=2:BoxX-1
    for y=2:BoxY
        HMAP(y,x) = patch(PatX + x , PatY + y, bg_color);
    end
end
