/*
% Author: Pieter Abbeel pabbeel@cs.berkeley.edu www.cs.berkeley.edu/~pabbeel
% 2009/11/07
%
% Adapted from Pascal Getreuer's mtetris.m
*/

/*
// function [map1, game_over] = tetris_place_block(map0, block_idx, translation, rotation)
*/

/*
// % map0: 19x12 matrix with 0's and 1's that stores which squares are filled/empty
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
// %
// % block_idx: index from 1 to 7, indicating which block we are currently
// % placing
// %
// % translation: from 1 to 10, where we would like to place the block
// % horizontally
// % 
// % rotation: from 0 to 3, number of 90 degree rotations to apply to the block
// % 
// % map1: resulting map
// % 
// % game_over: set to 1 if end of game is reached
// %
*/

/*
//%global BoxX BOXY
*/
#define BoxX  12
#define BoxY  19

#include "mex.h"
#include <math.h>
#include <string.h>

const int blocks[7][4][2] = { {  {-1, 0}, {0, 0}, {0, 1}, {1, 0} },
{  {-1, 0}, {0, 0}, {1, 0}, {2, 0} },
{  {-1, 1}, {0, 1}, {0, 0}, {1, 0} },
{  {-1, 0}, {0, 0}, {0, 1}, {1, 1} },
{  { 0, 0}, {0, 1}, {1, 0}, {1, 1} },
{  {-1, 0}, {0, 0}, {1, 0}, {1, 1} },
{  {-1, 1}, {-1,0}, {0, 0}, {1, 0} } };


/*
// const int block2[4][2] = {  {-1, 0}, {0, 0}, {1, 0}, {2, 0} };
// const int block3[4][2] = {  {-1, 1}, {0, 1}, {0, 0}, {1, 0} };
// const int block4[4][2] = {  {-1, 0}, {0, 0}, {0, 1}, {1, 1} };
// const int block5[4][2] = {  { 0, 0}, {0, 1}, {1, 0}, {1, 1} };
// const int block6[4][2] = {  {-1, 0}, {0, 0}, {1, 0}, {1, 1} };
// const int block7[4][2] = {  {-1, 1}, {-1,0}, {0, 0}, {1, 0} };
*/

void rotate_block(int block[4][2])
{
    /*GEO = [0,1;-1,0]*block.GEO;*/
    int i, tmp;
    for (i=0; i<4; ++i){
        tmp = block[i][0];
        block[i][0] = block[i][1];
        block[i][1] = -tmp;
    }
}

void copy_map(double* dest, double* src){
    memcpy(dest, src, sizeof(double)*19*12);
}

void build_2D_map(double* map0, int map_2D[19][12])
{
    int i,j;
    
    for (i=0; i<19; ++i){
        for (j=0; j<12; ++j){
            map_2D[i][j] = (int) map0[i + j*19];
        }
    }
}

void write_2D_map_to_1D(int map_2D[19][12], double* map1)
{
    int i, j;
    for (i=0; i<19; ++i){
        for (j=0; j<12; ++j){
            map1[i+j*19] = map_2D[i][j];
        }
    }
}

int collision(int map_2D[19][12], int block_pos[2], int block[4][2]){
    int i;
    for (i=0; i<4;++i){
        if (map_2D[block_pos[1] + block[i][1]][block_pos[0]+ block[i][0]]){
            return 1;
        }
    }
    return 0;
}

void place_block_in_map(int map_2D[19][12], int block_pos[2], int block[4][2])
{
    int i;
    for (i=0; i<4; ++i){
        map_2D[block_pos[1] + block[i][1]][block_pos[0] + block[i][0]]=1;
    }
}
    
int row_full(int map_2D[19][12], int row)
{
    int i;
    for (i=0; i<10; ++i)
        if(map_2D[row][1+i] == 0)
            return 0;
    return 1;
}

void clear_row(int map_2D[19][12], int row)
{
    int i, curr_row;
    for (curr_row = row; curr_row < 19-1; ++curr_row){
        for (i=0; i<10; ++i){
            map_2D[curr_row][1+i] = map_2D[curr_row+1][1+i];
        }
    }
    for (i=0; i<10; ++i){
        map_2D[18][1+i] = 0;
    }
}

void check_map_for_filled_rows(int map_2D[19][12])
{
    int i;
    for (i=BoxY-1; i>0; --i){
        if(row_full(map_2D, i)){       
            clear_row(map_2D, i);
        }
    }
}

void copy_block(const int src[4][2], int dest[4][2])
{
    memcpy(dest[0], src[0], sizeof(int)*2);
    memcpy(dest[1], src[1], sizeof(int)*2);
    memcpy(dest[2], src[2], sizeof(int)*2);
    memcpy(dest[3], src[3], sizeof(int)*2);
}

void print_2D_map(int map_2D[19][12])
{
    int i,j;
    for (i=0; i<19; ++i){
        for (j=0; j<12; ++j){
            printf("%d\t", map_2D[i][j]);
        }
        printf("\n");
    }
}
           
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    int block_idx = (int) (mxGetScalar(prhs[1]));
    int translation = (int) (mxGetScalar(prhs[2]));
    int rotation = (int) (mxGetScalar(prhs[3]));
    double* map0 = mxGetPr(prhs[0]);
    int block[4][2];
    int block_pos[2];
    int new_block_pos[2];
    int map_2D[19][12];
    
    double* game_over;
    double* map1;
    
    int i;
    
    plhs[0] =mxCreateDoubleMatrix(19,12, mxREAL); /*resulting board*/
    plhs[1] =mxCreateDoubleMatrix(1,1, mxREAL); /*game over or not*/
    
    map1 = mxGetPr(plhs[0]);
    game_over = mxGetPr(plhs[1]);
    
    // default outcomes:
    game_over[0] = 1;
    copy_map(map1, map0);
    
        
    if(block_idx <1 || block_idx > 7){
        printf("illegal block_idx: %d\n", block_idx);
        return;
    }
    
    if(translation > 10 || translation < 1){
        if(translation>10)
            translation = 10;
        if(translation < 1)
            translation = 1;
    }
    
    if(rotation < 0 || rotation > 3){
        while(rotation < 0)
            rotation+=4;
        while(rotation > 3)
            rotation -= 4;
    }
    
    build_2D_map(map0, map_2D);

//    printf("printing before block placement\n");
//    print_2D_map(map_2D);

    copy_block(blocks[block_idx-1], block);
        
    game_over[0] = 0;
    
    block_pos[1] = BoxY-3;
    block_pos[0] = (int) (floor(BoxX/2));
    
    /*% rotate action*/
    for (i=1; i<=rotation; ++i){
        rotate_block(block);
    }
    
    
    /* check if game over*/
    if(collision(map_2D, block_pos, block)){
        copy_map(map1, map0);
        game_over[0] = 1;
        return;
    }

    

    
    /*% translate action*/
    while( translation < block_pos[0]){
        new_block_pos[0] = block_pos[0]-1;
        new_block_pos[1] = block_pos[1];
        
        if (!collision(map_2D, new_block_pos, block)){
            block_pos[0] = new_block_pos[0];
        } else {
            break;
        }
    }
    
    while( translation > block_pos[0]){
        new_block_pos[0] = block_pos[0]+1;
        new_block_pos[1] = block_pos[1];
        
        if (!collision(map_2D, new_block_pos, block)){
            block_pos[0] = new_block_pos[0];
        } else {
            break;
        }
    }
    
    /*%drop shape:*/
    new_block_pos[0] = block_pos[0];
    new_block_pos[1] = block_pos[1];
    while(!collision(map_2D, new_block_pos, block)){
        new_block_pos[1] = new_block_pos[1] - 1;
    }
    block_pos[1] = new_block_pos[1]+1;
    
    
    
    place_block_in_map(map_2D, block_pos, block);
//    printf("printing after block placement\n");
//    print_2D_map(map_2D);
        
    /* % check for filled rows */
    check_map_for_filled_rows(map_2D);
    
//    printf("printing after row clearing\n");    
//    print_2D_map(map_2D);
    
    write_2D_map_to_1D(map_2D, map1);

    game_over[0] = 0;
}




