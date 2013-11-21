/*
% Author: Pieter Abbeel pabbeel@cs.berkeley.edu www.cs.berkeley.edu/~pabbeel
% 2009/11/07
*/
/*
// % map: 19x12 matrix with 0's and 1's that stores which squares are filled/empty
// %  The tetris board is only 10 wide and 18 high; for coding convenience the
// %  board is represented by a 19x12 matrix; the first row is always all
// %  ones, the first and last column are both always all ones (i.e., the
// %  surrounding wall is included in the map)
// %
// %  map0(1+i, 1+j) = 1 if the square in the i'th row (from the bottom!) and
// %  the j'th column (from the left) is filled;
// %  Note the "1+" as per the explanations above.
// %  Note: this indexing schemes means that if you type "map0" at the command
// %  prompt you will see an up/down flipped version of how you are used to
// %  seeing the tetris board.
*/
#include "mex.h"
#include <math.h>

#define MAP_HEIGHT 19
#define MAP_WIDTH 12

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
/*
//function phi = tetris_standard_22_features(map)
*/

double* phi;
double* map = mxGetPr(prhs[0]);
int i,h;
double num_filled_squares;
double sum_of_heights;

plhs[0] =mxCreateDoubleMatrix(22, 1, mxREAL);
phi = mxGetPr(plhs[0]);

/*
// %for i=1:10
// %    phi(i) = (max(find(map(:,i+1)>0))-1); % height of each column
// %end
//phi(20) = (max(phi(1:10))); % max height
*/

phi[19] = 0; // max height

num_filled_squares = 0;

for(i=0; i<10; ++i){
    phi[i] = 0;
    for(h=1; h<MAP_HEIGHT; ++h){
        if(map[h + (1+i)*MAP_HEIGHT]!=0){
            phi[i] = h;
            ++num_filled_squares;
        } 
    }
}

for (i=0; i<9; ++i){
    phi[10+i] = fabs(phi[i]-phi[i+1]);
}

sum_of_heights = 0;
for (i=0; i<10; ++i){
    sum_of_heights += phi[i];
    if(phi[i] > phi[19]){
        phi[19] = phi[i];
    }
}

/*
//%phi(21) = sum(phi(1:10)) - sum(sum(map(2:end,2:end-1)));%%number of holes i/t board;
*/

phi[20] = sum_of_heights - num_filled_squares;

/*
//phi(22) = 1; % always 1 feature
*/
phi[21] = 1;

}

