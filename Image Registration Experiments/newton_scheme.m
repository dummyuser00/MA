function [x_star, x_history] = ...
    newton_scheme(f, x0, tol1, maxIter, tol2)
% IN:
%   f           ~ function handle   target function, returns
%                                       - f(x)      ~ 1 x 1
%                                       - df/dx     ~ k x 1
%                                       - d2f/dx^2  ~ k x k
%   x0          ~ k x 1             starting point
%   tol1        ~ 1 x 1             tolerance for necessary condition
%   maxIter     ~ 1 x 1             max. number of iterations
%   tol2        ~ 1 x 1             tolerance for target decrease
% OUT:
%   x_star      ~ k x 1             minimizer of f / last iterate
%   x_history   ~ k x #iter         recording of all iterates of x

% set standard parameters if not provided
if nargin < 5, tol2 = 1e-2; end
if nargin < 4, maxIter = 100; end
if nargin < 3, tol1 = 1e-3; end

% iteration counter
i = 0;

% tracking of target fctn. values
f_history = zeros(maxIter + 1, 1);

% evaluate starting point
x_current = x0;
[f_cur, df_cur, d2f_cur] = f(x_current);
f_history(1) = f_cur;

% return all iterates of x (if requested)
if nargout == 2
    x_history = zeros(length(x0), maxIter + 1);
    x_history(:, 1) = x0;
end

% output some info
fprintf('\nNEWTON SCHEME ON %s\n\nSTOPPING CRITERIONS\n\n', ...
    func2str(f));
fprintf('\tTOLERANCE ||grad(f)(x)|| <= %.1e\n', tol1);
fprintf('\tMAXITER = %d\n', maxIter);
fprintf('\tDECREASE OVER 3 ITERATES <= %.1e\n\n', tol2);
fprintf('i \t ||grad(f)(x_i)|| \t f(x_i)/f(x_i-1)\n');
fprintf('------------------------------------------------\n');

% newton scheme iteration
while (norm(df_cur) > tol1) && ...
        (i < maxIter) && ...
        ((i < 3) || ((f_history(i + 1) / f_history(i - 2)) < (1 - tol2)))
    
    i = i + 1;
    
    % newton direction = (d2f)^(-1) * (-df)
    dir = d2f_cur \ (-df_cur);
    
    % make sure, that dir is a descent direction (or else switch to -dir)
    descent = (dir' * df_cur < 0);
    if ~descent, dir = -dir; end
    
    % Armijo line search for step size
    alpha = armijo(f, x_current, dir, 1, 1e-3, 0.5);
    
    % update current iterate
    x_current = x_current + alpha * dir;
    [f_cur, df_cur, d2f_cur] = f(x_current);
    f_history(i + 1) = f_cur;
    if nargout == 2
        x_history(:, i + 1) = x_current;
    end
    
    % output progress
    fprintf('%d \t %.2e \t\t %.4f\n', ...
        i, norm(df_cur), f_cur / f_history(i));
end

x_star = x_current;
if nargout == 2
    x_history(:, (i + 2) : end) = [];
end

% final output
fprintf('\nSTOPPING AT CRITERION\n\n');
if (i == maxIter)
    fprintf('\t#iter = maxIter = %d\n', maxIter);
elseif (norm(df_cur) <= tol1)
    fprintf('\t||grad(f)(x_i)|| = %.2e <= %.1e\n', norm(df_cur), tol1);
else
    fprintf('\tDECREASE OVER LAST 3 ITERATES = %.1e <= %.1e\n', ...
        (1 - (f_history(i + 1) / f_history(i - 4))), tol2);
end
fprintf('\nREMAINDER OF INITIAL TARGET\n\n');
fprintf('\tf(x_star)/f(x_0) = %.4e\n\n', ...
    (f_history(i + 1) / f_history(1)));

end