%woody hoburg
%nov 4, 2009

function [tout, xout, fullstate] = real_acrobot_sim(controlfun, outputfun, tspan, x0, params)

%note: state is: 
%[th1, th2, th1dot, th2dot, thmotor, thmotordot]

%controlfun -- should take in arguments (t,x) and return control action u
%dimension of x depends on which output is used -- see acrobot_output.m

%outputfun -- function that takes full state to state measurements -
%depending on 'flag' -- see acrobot_output.m

%tspan -- something like [0 20] <-- that would be 20 sec sim

%x0 -- initial state (ok to be 4 dimensional, not 6 -- last two get overwritten or appended)
%params - struct containing params to pass to acrobot_dynamics.

x0(5) = x0(2);  %motor shaft angle -- same as th2 for starters
x0(6) = x0(4);  %motor shaft velocity

%default params for backlash stuff
backlash_travel = 0.02; %in radians -- corresponds to 0.2mm slop in a 1cm radius gear
Imotor = 5e-6;  %inertia of motor, shaft, etc -- everything that gets 'backlashed'

%set up parameters to pass to acrobot_dynamics
if(~exist('params', 'var'))
    params = struct();
end
params = acrobot_params(params);
heavy_params = params;
heavy_params.I2 = Imotor + params.I2;
L1 = params.L1;
m1 = params.m1;
I1 = params.I1;
l1 = params.l1;
m2 = params.m2;
l2 = params.l2;
I2 = params.I2;

%initialize output stuff
tout = tspan(1);
fullstate = x0';
ic = x0;
contact = false;    %whether gears are engaged -- we set them not so above

while(tout(end) < tspan(2))
    if(contact)
        options = odeset('events', @(t,x)force0_event(t,x,controlfun(t,outputfun(x))));
        [to, xo, te, xe, ie] = ode45(@(t,x)comb_dyn(t,x,controlfun(t,outputfun(x))), [tout(end) tspan(2)], ic, options);
        contact = false;
        ic = xo(end,:);
    else
        options = odeset('events', @(t,x)impact_event(t,x));
        [to, xo, te, xe, ie] = ode45(@(t,x)sep_dyn(t,x,controlfun(t,outputfun(x))), [tout(end) tspan(2)], ic, options);
        contact = true;
        ic = collision(xo(end,:));  %BAM!!  inelastic collision.
    end
    tout = [tout; to(2:end)];       % Events at tstart are never reported.
    fullstate = [fullstate; xo(2:end,:)];
    
end

%finally, compute the output
xout = outputfun(fullstate')';  

    %%%%% functions %%%%%%%%

    function statedot = comb_dyn(t, state, u)
        statedot(1:4,1) = acrobot_dynamics(t,state,u,heavy_params);
        statedot(5,1) = state(6);   
        statedot(6,1) = statedot(4);%motor shaft does same thing as joint 2
    end

    function statedot = sep_dyn(t, state, u)
        statedot(1:4, 1) = acrobot_dynamics(t,state,0,params);  %acrobot with no action
        statedot(5,1) = state(6);
        statedot(6,1) = u/Imotor;   %motor acts on shaft alone
    end

    function [value, isterminal, direction] = impact_event(t, state)
        %check to see if gears have contacted
        value = [state(2)-state(5)-backlash_travel/2; state(5)-state(2)-backlash_travel/2];
        isterminal = [1;1];     
        direction = [1;1];
    end

    function [value, isterminal, direction] = force0_event(t, state, u)
        acc = sep_dyn(t, state, u);
        value = acc(4) - acc(6);        %check to see if force on gears has gone to 0
        isterminal = 1;
        direction = 0;
    end

    function stateout = collision(state)
        %we have params from call to acrobot_params (waaay earlier)
        %unpack state
        th2 = state(2);
        th1dot = state(3);
        th2dot = state(4);
        thmdot = state(6);
        c2 = cos(th2);
        
        %conserve angular momentum through impact -- derived separately
        th2dotout = (Imotor*thmdot + th2dot*(I2 + m2*l2^2))/(Imotor + I2 + m2*l2^2);
        angmomCG2 = m2*(th1dot*L1^2 + L1*l2*(2*th1dot+th2dot)*c2 + l2^2*(th1dot+th2dot));
        angmombefore = th1dot*(m1*l1^2 + I1) + thmdot*Imotor + I2*th2dot + angmomCG2;
        th1dotout = (angmombefore-th2dotout*(I2+Imotor+m2*L1*l2*c2+m2*l2^2))/(m1*l1^2 + I1 + m2*(L1^2 + 2*L1*l2*c2 + l2^2));

        stateout = state;
        stateout(3) = th1dotout;   
        stateout(4) = th2dotout;
        stateout(6) = th2dotout;    %set motor shaft velocity to joint 2 vel
    end

end