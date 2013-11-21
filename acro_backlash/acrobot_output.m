% woody hoburg
% nov 2009

%map the full 6 dimensional "real" acrobot state to an output vector
%to avoid for loops - pass in a matrix where columns are state readings

function output = acrobot_output(state, flag)

%note: state is: 
%[th1, th2, th1dot, th2dot, thmotor, thmotordot]

encoder_ticks_per_rev = 400;

if(strcmp(flag, 'real_state'))
    output = state;
elseif(strcmp(flag, 'perfect_encoder_state'))
    output = state([1 5 3 6], :);
elseif(strcmp(flag, 'real_encoder_position'))
    output = state([1 5], :) - mod(state([1 5], :), 2*pi/encoder_ticks_per_rev);
else
    error('unrecognized flag')
end