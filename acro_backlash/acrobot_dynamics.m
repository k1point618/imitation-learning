%woody hoburg
%nov 4, 2009

function [statedot, dfdt, dfdx, dfdu] = acrobot_dynamics(t, state, u, params)
persistent g L1 m1 I1 l1 m2 l2 I2 b1 b2
if(isempty(g))
    disp('reading params')
    params = acrobot_params(params);
    g = params.g;
    L1 = params.L1;
    m1 = params.m1;
    I1 = params.I1;
    l1 = params.l1;
    m2 = params.m2;
    l2 = params.l2;
    I2 = params.I2;
    b1 = params.b1;
    b2 = params.b2;
end

%unpack state
th1 = state(1);
th2 = state(2);
th1dot = state(3);
th2dot = state(4);

%precalculate trig functions we will use a lot
s1 = sin(th1);
c1 = cos(th1);
s2 = sin(th2);
c2 = cos(th2);
s12 = sin(th1 + th2);

%the actual dynamics, in manipulator equation form:
H = zeros(2); C = zeros(2); G = zeros(2,1);
H(1,1) = m1*l1^2 + I1 + m2*(L1^2 + l2^2 + 2*L1*l2*c2);
H(1,2) = m2*(l2^2 + L1*l2*c2);
H(2,1) = H(1,2);
H(2,2) = m2*l2^2 + I2;
C(1,1) = -2*m2*L1*l2*th2dot*s2 + b1;
C(1,2) = -m2*L1*l2*th2dot*s2;
C(2,1) = m2*L1*l2*th1dot*s2;
C(2,2) = b2;
G(1,1) = g*((m1*l1 + m2*L1)*s1 + m2*l2*s12);
G(2,1) = m2*l2*g*s12;
B = [0; 1];

%solve for angular accelerations
Hinv = inv(H);
RHS = (B*u - C*[th1dot; th2dot] - G);
acc = Hinv*RHS;
%pack up state derivative
statedot = [th1dot; th2dot; acc];

%gradients, if asked for
if(nargout > 1) 
    %trivial stuff
    dfdt = zeros(4,1);
    dfdu = [0; 0; Hinv*B];
    dfdx = zeros(4);
    dfdx(1,3) = 1;
    dfdx(2,4) = 1;
    
    %non-trivial state gradients
    c12 = cos(th1 + th2);
    dHdth2 = -[2*m2*L1*l2*s2, m2*L1*l2*s2; m2*L1*l2*s2, 0];  %derivs of H wrt all other state vars are zero!
    dHinvdth2 = -Hinv*dHdth2*Hinv;
    dCdth2 = m2*L1*l2*[-2*th2dot*c2, -th2dot*c2; th1dot*c2, 0];   %and dCdth1 is all zeros
    dCdth1dot = [0, 0; m2*L1*l2*s2, 0];
    dCdth2dot = -m2*L1*l2*[2*s2, s2; 0, 0];
    dGdth1 = g*[(m1*l1 + m2*L1)*c1 + m2*l2*c12; m2*l2*c12];
    dGdth2 = g*[m2*l2*c12; m2*l2*c12];
    
    %pack em in -- look at manipulator eqns for trivial derivation
    dfdx(3:4,1) = -Hinv*dGdth1;
    dfdx(3:4,2) = dHinvdth2*RHS + Hinv*(-dCdth2*[th1dot; th2dot] - dGdth2);
    dfdx(3:4,3) = -Hinv*(dCdth1dot*[th1dot; th2dot] + C*[1;0]);
    dfdx(3:4,4) = -Hinv*(dCdth2dot*[th1dot; th2dot] + C*[0;1]);
    
    %sha-bam.
end
end %function