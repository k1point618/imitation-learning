% Author: Pieter Abbeel pabbeel@cs.berkeley.edu www.cs.berkeley.edu/~pabbeel
% 2009/11/07
%
% Adapted from Pascal Getreuer's mtetris.m

function [map1, game_over] = tetris_place_block(map0, block_idx, translation, rotation, board_data)

% map0: 19x12 matrix with 0's and 1's that stores which squares are filled/empty
%  The tetris board is only 10 wide and 18 high; for coding convenience the
%  board is represented by a 19x12 matrix; the first row is always all
%  ones, the first and last column are both always all ones (i.e., the
%  surrounding wall is included in the map)
%
%  map0(1+i, 1+j) = 1 if the square in the i'th row (from the bottom!) and
%  the j'th column (from the left) is filled;
%  Note the "1+" as per the explanations above.
%  Note: this indexing schemes means that if you type "map0" at the command
%  prompt you will see an up/down flipped version of how you are used to
%  seeing the tetris board.
%
% block_idx: index from 1 to 7, indicating which block we are currently
% placing
%
% translation: from 1 to 10, where we would like to place the block
% horizontally
% 
% rotation: from 0 to 3, number of 90 degree rotations to apply to the block
% 
% map1: resulting map
% 
% game_over: set to 1 if end of game is reached
%

if(translation > 10 | translation < 1)
    error('illegal translation');
    return;
end

if(block_idx <1 | block_idx > 7)
    error('illegal block_idx');
    return;
end

if(rotation < 0 | rotation > 3)
    error('illegal rotation');
    return;
end


%global BoxX BOXY
BoxX = board_data.BoxX;
BOXY = board_data.BoxY;

BOXOFF = [BOXY,1];
% shapes data
Shapes = reshape([-1 0 0 0 0 1 1 0 -1 0 0 0 1 0 2 0 -1 1 0 1 0 0 1 0 ...
    -1 0 0 0 0 1 1 1 0 0 0 1 1 0 1 1 -1 0 0 0 1 0 1 1 -1 1 -1 0 0 0 1 0],2,4,7);

game_over = 0;


% properties of block with index "block_idx"
block.SHAPEIND = block_idx;
block.GEO = Shapes(:,:,block.SHAPEIND);
block.POS = [ceil(BoxX/2);BOXY-2];

% rotate action
for i=1:rotation
    block.GEO = [0,1;-1,0]*block.GEO;
end

% check if game over
if any(map0(BOXOFF*block.POS + BOXOFF*block.GEO - BOXY))	 % game over
    game_over = 1;
    map1=map0;
    return;
end

% translate action
while( translation+1 < block.POS(1))
    if ~any(map0(BOXOFF*block.POS + BOXOFF*block.GEO - BOXY*2))
        block.POS = block.POS + [-1;0];
    else
        break;
    end
end

while( translation+1 > block.POS(1))
    if ~any(map0(BOXOFF*block.POS + BOXOFF*block.GEO))
        block.POS = block.POS + [1;0];
    else
        break;
    end
end

%drop shape:
NewInd = BOXOFF*block.POS + BOXOFF*block.GEO - BOXY - 1;
if ~any(map0(NewInd))
    while ~any(map0(NewInd))
        NewInd = NewInd - 1;
        block.POS = block.POS + [0;-1];
    end
end

if any(map0(BOXOFF*block.POS + BOXOFF*block.GEO - BOXY - 1))		% check if shape is blocked
    % add current shape into arrays
    map0(BOXOFF*block.POS + BOXOFF*block.GEO - BOXY) = 1;
    
    % check for filled rows
    %tmp = flipud(find(sum(map0(2:BOXY,:),2) == BoxX)) + 1;
    tmp = (find(sum(map0(2:BOXY,:),2) == BoxX)) + 1;
    
    if ~isempty(tmp)
        % clear rows and drop above rows
        for i = length(tmp):-1:1 %1:length(tmp)
            map0 = [map0([1:tmp(i)-1,tmp(i)+1:BOXY],:);1,zeros(1,BoxX-2),1];
        end
    end
end


map1=map0;
