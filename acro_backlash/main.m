% woody hoburg
% nov 2009

%run one line at a time to understand how everything works

%deterministic acrobot dynamics -- simulate falling from top for 10s
params = [];
top = [pi; 0; 0; 0];
[tout, xout] = ode45(@(t,x)acrobot_dynamics(t,x,0,params), [0 10], top*1.005);
sim_traj(tout, xout, @(t,x)draw_acrobot(1,1,t,x), .03);
%swings like crazy.  try that again with some damping:
params = struct('b1', .01, 'b2', .01);
[tout, xout] = ode45(@(t,x)acrobot_dynamics(t,x,0,params), [0 20], top*1.005);
sim_traj(tout, xout, @(t,x)draw_acrobot(1,1,t,x), .03);
%that's more realistic.
%ok, now let's make sure we can build the LQR controller for the
%deterministic system:
[xdot, dfdt, dfdx, dfdu] = acrobot_dynamics(0, top, 0, params);
A = dfdx;
B = dfdu;   %linearization
Q = diag([1 1 .1 .1]);
R = .1;
K = lqr(A, B, Q, R);
[tout, xout] = ode45(@(t,x)acrobot_dynamics(t,x,-K*(x-top),params), [0 5], top*1.005);
sim_traj(tout, xout, @(t,x)draw_acrobot(1,1,t,x), .03);
%woohoo, success!

%%%%%%%%%%%%%%%%%%%%%%%
%now for the full "real" system!!!!

%to get a feel for it, excite things with a sinusoidal input.
outputfun = @(x)acrobot_output(x, 'real_encoder_position');
controlfun = @(t,x)sin(15*t);
[tout, xout, fullstate] = real_acrobot_sim(controlfun, outputfun, [0 10], [0;0;0;0]);
figure(1); clf(1); plot(tout, fullstate(:, 2)); %zoom in on this plot -- you can sure see the backlash!
figure(2); clf(2); plot(tout, fullstate(:, 2) - fullstate(:,5));    %this shows the motor shaft flopping back and forth
figure(3); clf(3); plot(tout, fullstate(:, 2)); hold on; plot(tout, fullstate(:, 5),'g');
