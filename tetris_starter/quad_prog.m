% Author: Keren Gu kgu@mit.edu
% 2013 Fall UROP
% Interactive Robotics Group, CSAIL
function [ t, weight, lambda ] = quad_prog(exp_feat, all_feat)

% To compute a new guess of the reward function, we solve the following 
% convex quadratic programming problem: 
% $$\min_{\lambda} ||\mu_E - \mu||_2$$
% $$s.t.\ \sum_{j=0}^{i-1} \lambda_j \mu^{(j)}=\mu,\ \lambda \geq 0,\ \sum_{j=0}^{i-1}\lambda_j=1$$

cvx_begin
variable lambda(size(all_feat, 2))
minimize norm(exp_feat - all_feat * lambda, 2)
subject to 
    lambda > 0
    sum(lambda) == 1
cvx_end

lambda

mu = all_feat * lambda;

% use mu to update t, and w
t = norm(exp_feat - mu, 2);
weight = (exp_feat - mu)/t;

end

% % Without using cxv: 
% % We writing our optimization in form of quadratic programming:
% 
% i = size(all_feat, 2);
% 
% lb = zeros(i, 1);
% ub = ones(i, 1);
% Aeq = ones(1, i);
% beq = 1;
% 
% % % get f
% f = zeros(i, 1);
% for j=1:i
%     f(j) = -2 * exp_feat' * all_feat(:,j);
% end % end for f
% 
% 
% % % get H
% H = zeros(i);
% for j=1:i
%     for k=1:i
%         H(j, k) = all_feat(:,j)' * all_feat(:, k);
%     end % inner for
% end % end for
% 
% % Or more compactly: 
% % H = all_feat' * all_feat;
% % f = -2 * all_feat' * exp_feat;
% 
% lambda = quadprog(H, f', [], [], Aeq, beq, lb, []);
% 
% % use optimal lambda to find mu
% mu = all_feat * lambda;
% 
% % use mu to update t, and w
% t = norm(exp_feat - mu, 2);
% weight = (exp_feat - mu)/t;


