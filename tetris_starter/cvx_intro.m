% Author: Pieter Abbeel pabbeel@cs.berkeley.edu www.cs.berkeley.edu/~pabbeel
% 2009/11/07

%cvx_intro.m
% This file is intended to provide a quick intro to CVX. 
% CVX is a convex optimization frontend which can be run within matlab.
% CVX will parse a so-called "disciplined" convex optimization problem (a
% subset of all convex optimization problems) and then feed it into a
% solver (which comes along with the CVX install, SDPT3 is the solver at
% time of this writing).
% CVX's power comes from being able to very conveniently write down the
% convex optimization problem, i.e., at a relatively high level of
% abstraction


% To obtain CVX: follow the download and install instructions:
% http://www.stanford.edu/~boyd/cvx/

% There are numerous examples on the above website.  Let's consider just a
% few here to give you a concrete starting point.


% Solve a least squares problem Ax=b with CVX
m = 20; n = 10;
A = randn(m,n); b = randn(m,1);
% in matlab, we can simply solve this by the following line of code:
x1 = A\b;
% using CVX we have:
cvx_begin
    variable x2(n)
    minimize( norm( A * x2 - b, 2 ) )
cvx_end

% if cvx is properly installed the above code will be parsed by CVX when
% inserted at the matlab command prompt, and after running the variable x2
% should contain the same value as the variable x1 (upto some numerical
% precision)


% CVX can do more than least squares though!
% For example:
%  minimize the 1-norm of A*x-b:
cvx_begin
variable x3(n)
minimize (norm(A*x3 - b, 1))
cvx_end

% or minimize the infinity norm:
cvx_begin
variable x4(n)
minimize (norm(A*x4 - b, inf))
cvx_end

% we can also minimize the infinity norm in a more elaborate way:
cvx_begin
variable x4(n)
variable t
minimize t
subject to
for i=1:m
    t >=   A(i,:)*x4 - b(i);
    t >= -(A(i,:)*x4 - b(i));
end
cvx_end

% or even:
cvx_begin
variable x4(n)
variable t
minimize t
subject to
for i=1:m
    t >= max(A(i,:)*x4 - b(i),-(A(i,:)*x4 - b(i)));
end
cvx_end

% or even in another way:
cvx_begin
variable x4(n)
variable t
minimize t
subject to
for i=1:m
    t >= abs(A(i,:)*x4 - b(i));
end
cvx_end


% we can also incorporate constraints
p = 4; q=3;
C = randn(p,n); d=randn(p,1);
E = randn(q,n); f=randn(q,1);
cvx_begin
variable x5(n)
minimize (norm(A*x5 - b, 1))
subject to
C * x5 == d
E * x5 <= f
cvx_end

% another example: the standard hard-margin SVM problem:
X = randn(m,n); y=1-2*round(rand(m,1));
% rows of X are the feature vectors
% rows of y are the labels (-1 or +1)
% find the minimum norm w such that the feature vectors with positive label are separated by
% a margin greater than or equal to 2 from the feature vectors with negative label
cvx_begin
variable w(n)
variable b
minimize pow_pos(norm(w,2),2)
subject to
for i=1:m
    (X(i,:)*w+b)*y(i) >= 1
end
cvx_end

% note there is really little incentive to square the norm in the above
% expression, the following will provide the same solution: 
cvx_begin
variable w(n)
variable b
minimize norm(w,2)
subject to
for i=1:m
    (X(i,:)*w+b)*y(i) >= 1
end
cvx_end

% for most random X and y, the above problem will be infeasible!! CVX will show this in
% its status

% --> let's go to soft margin version:
C = 1;
cvx_begin
variable w(n)
variable b(1)
variable xi(m)
minimize (pow_pos(norm(w,2),2) + C * sum(xi))
subject to
for i=1:m
    (X(i,:)*w+b)*y(i) >= 1 - xi(i)
end
xi >= 0
cvx_end

% Ok, now it has a solution!


