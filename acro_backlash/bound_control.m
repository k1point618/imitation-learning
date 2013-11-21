% woody hoburg
% nov 2009

function bounded_input = bound_control(input, limit)

%assume scalar bound is positive and symmetric

bounded_input = max(input, -limit);
bounded_input = min(bounded_input, limit);