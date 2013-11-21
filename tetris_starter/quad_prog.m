function [ t, weight ] = quad_prog(exp_feat, all_feat)

% i = size(all_feat, 2)
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
% %f = -2 * all_feat' * exp_feat;
% 
% % get H
% H = zeros(i);
% for j=1:i
%     for k=1:i
%         H(j, k) = all_feat(:,j)' * all_feat(:, k);
%     end % inner for
% end % end for
% 
% %H = all_feat' * all_feat;
% 
% % Testing quadprog function: 
% % H = [1 -1; -1 2]; 
% % f = [-2; -6];
% % A = [1 1; -1 2; 2 1];
% % b = [2; 2; 3];
% % lb = zeros(2,1);
% % quadprog(H,f,A,b,[],[],lb,[])
% lambda = quadprog(H, f', [], [], Aeq, beq, lb, []);
% 
% % use optimal lambda to find mu
% % mus = arrayfun(@(idx) lambda(idx) * all_feat{idx}, 1:i, 'UniformOutput', false);
% % mu = lambda' * all_feat{i};
% 
% mu = all_feat * lambda;
% 
% % use mu to update t, and w
% t = norm(exp_feat - mu, 2);
% weight = (exp_feat - mu)/t;


%-----------------------------
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

