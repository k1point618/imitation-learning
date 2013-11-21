% Author: Pieter Abbeel pabbeel@cs.berkeley.edu www.cs.berkeley.edu/~pabbeel
% 2009/11/07

function phi = tetris_standard_22_features(map)

phi = zeros(22,1);

%for i=1:10
%    phi(i) = (max(find(map(:,i+1)>0))-1); % height of each column
%end

phi(1) = (max(find(map(:,1+1)>0))-1); % height of each column
phi(2) = (max(find(map(:,2+1)>0))-1); % height of each column
phi(3) = (max(find(map(:,3+1)>0))-1); % height of each column
phi(4) = (max(find(map(:,4+1)>0))-1); % height of each column
phi(5) = (max(find(map(:,5+1)>0))-1); % height of each column
phi(6) = (max(find(map(:,6+1)>0))-1); % height of each column
phi(7) = (max(find(map(:,7+1)>0))-1); % height of each column
phi(8) = (max(find(map(:,8+1)>0))-1); % height of each column
phi(9) = (max(find(map(:,9+1)>0))-1); % height of each column
phi(10) = (max(find(map(:,10+1)>0))-1); % height of each column



phi(11:19) = (abs(phi(1:9)-phi(2:10))); % absolute value of height differential for neighbors

phi(20) = (max(phi(1:10))); % max height

phi(21) = sum(phi(1:10)) - sum(sum(map(2:end,2:end-1)));%%number of holes i/t board;

phi(22) = 1; % always 1 feature



