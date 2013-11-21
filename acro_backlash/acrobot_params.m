% woody hoburg
% nov 2009

function paramsout = acrobot_params(params)

%default parameters
paramsout.g = 9.81;           %gravity        (m/s^2)
paramsout.L1 = .6;            %link 1 length  (m)
paramsout.m1 = .5;            %link 1 mass    (kg)
m1 = paramsout.m1;
L1 = paramsout.L1;
paramsout.I1 = 1/12*m1*L1^2;  %link 1 inertia (kg*m^2)
paramsout.l1 = L1/2;          %link 1 CG      (m)
paramsout.m2 = .7;            %link 2 mass    (kg)
paramsout.l2 = .51;           %link 2 CG      (m)
paramsout.I2 = .019;          %link 2 inertia (kg*m^2)
paramsout.b1 = 0;             %damping        (kg/s)
paramsout.b2 = 0;             %damping        (kg/s)

if(exist('params', 'var'))
    if(isfield(params, 'g')) paramsout.g = params.g; end
    if(isfield(params, 'L1')) paramsout.L1 = params.L1; end
    if(isfield(params, 'm1')) paramsout.m1 = params.m1; end
    if(isfield(params, 'I1')) paramsout.I1 = params.I1; end
    if(isfield(params, 'l1')) paramsout.l1 = params.l1; end
    if(isfield(params, 'm2')) paramsout.m2 = params.m2; end
    if(isfield(params, 'l2')) paramsout.l2 = params.l2; end
    if(isfield(params, 'I2')) paramsout.I2 = params.I2; end
    if(isfield(params, 'b1')) paramsout.b1 = params.b1; end
    if(isfield(params, 'b2')) paramsout.b2 = params.b2; end
end