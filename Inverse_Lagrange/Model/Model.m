function  Model(min_step_size, max_iter)
%   次梯度方法求解拉格朗日dual
  best_ub = 1e4;

  best_lb = -2;

%   max_iter = 100;
%   min_step_size = 0.01;
  x0 = [2;2.5];  % The given solution

  c = [5;4];

  n_row = length(c); % dimension of variable

  iter = 1;

  non_improve = 0;

  max_non_improve = 3;

  % 松弛约束条件   A x_0 < b
  A = [-1,1;
        6,4;];

  b = [1;24];

  relax_con = [A,b];

  % relax_con = [-1,1,2 ;
  %               3,2,18;];

  % con = [1,2,8;]; %  A'\lambda > c

  sum_relax = length(relax_con(:,1)); % the length of column

%  lambda = ones(sum_relax,1);
  lambda = 0.5;   % 步长

%  subgradient = zeros(sum_relax,1);

  step_size = 1;

%  mu = zeros(sum_relax,1);   % 初始化拉格朗日multiplier plus one

   mu = Min_sub(A,b,c);

%  mu(1:sum_relax) = mu0;

while iter < max_iter

  [opt_x,A0,adjustment] = Model_sub(x0,A,b,c,mu);
  % if  sp.solve() == false
  %
  %   disp('solve wrong!');
  %
  % end

  A0 = reshape(A0,sum_relax,n_row)';

    % 更新下界
  if adjustment > best_lb

    best_lb = adjustment;

    non_improve = 0;

  else

    non_improve = non_improve + 1;

  end

% Notice here that the subgradient is a vector.

    subgradient = [A0*x0-b];
%    subgradient = (mu(1:end-1)'*b-c'*x0);

%    mu = Min_sub(A0,b,c);

    mu = max(0, mu - step_size * subgradient);

%    mu(1:end-1) = max(0.1, (mu(1:end-1) + step_size * subgradient(1:end-1)));

% 满足原问题约束的可行解可以作为原问题的lower bound
opt_x
A0
% (mu'*b-c'*x0)

  if all(subgradient <= 0)   % 如果 subgradient <0 说明满足原problem satisfy all constraints

    current_ub = sum(opt_x);

    if current_ub < best_ub

      best_ub = current_ub;

    end

  end

  fprintf('iter: %d\n', iter);

  fprintf('best lb: %f ', best_lb);

  fprintf('best ub: %f\n ', best_ub);

  mu
%  fprintf('mu: %f %f\n\n', mu);

% 上界未更新达到一定次��?

  if non_improve >= max_non_improve

    lambda = lambda/2;

    non_improve = 0;

  end

  mydist = norm(subgradient);    % Obtain the norm of subgradient

  % 迭代停止条件2,3

  if (any(mydist) <= 0.00001)||(best_lb >= best_ub-0.00001)

    break;

  end

  step_size = lambda * (best_ub - best_lb)/mydist;

  % 迭代停止条件4

  if any(step_size) < min_step_size

    break;

  end

iter = iter + 1;

end

end

function [opt_x,A0,obj] = Model_sub(x0,A,b,c,mu)
  % min (ei+fi) + \mu *(Ax-b)
  % c = [5;4];
  % relax_con = [-1,1,1 ;
  %               6,4,24;];

    model.modelname = 'Model_sub';

    model.modelsense = 'min';

    nrow = length(A(:,1));

    ncol = length(A(1,:))*4;

    model.lb = zeros(ncol,1);

   model.ub = ones(ncol,1)*10;

    coff = kron(mu(1:end),x0);  %(mu1x1,mu1x2,mu2x1,mu2x2);


    model.obj = ones(ncol,1) + [coff;-coff];

    model.vtype = repmat('C',ncol,1);

    AA = kron(mu(1:end)',eye(length(A(:,1))));

    AA = [AA,-AA];

  %  AA1 = kron(eye(length(A(1,:))),x0');

  %  AA1 = [-AA1,AA1];
% model.A = AA;

   model.A = sparse(nrow,ncol);

    % for i = 1: length(A(:,1))
    %
    %   model.A(i,:) = AA(i,:);
    %
    % end

    % for i = 1: length(A(1,:))
    %
    %   model.A(length(A(:,1))+i,:) = AA1(i,:);
    %
    % end


%    rhs1 = c - A'*mu(1:end);

  %  rhs2 = -(b-A*x0);

%    model.rhs = rhs1;

%    model.sense = repmat('>', nrow, 1);

    gurobi_write(model,'model.lp');

    params.outputflag = 0;

    result = gurobi(model, params);

  %  result = gurobi(model)

    opt_x = result.x;  % adjustment

    A0 = opt_x(1:end/2) - opt_x(end/2+1:end) + reshape(A',ncol/2,1);

    obj = result.objval + mu'*(A*x0-b);

% mu(end)*(mu(1:end-1)'*b-c'*x0)
end


function mu = Min_sub(A,b,c)
  % min bTy
  % c = [5;4];
  %  y > 0
  %  ATy > c
  % Obtain the dual

    model.modelname = 'Min_sub';

    model.modelsense = 'min';

    nrow = length(A(1,:));

    ncol = length(A(:,1));

    model.lb = zeros(ncol,1);

    model.ub = ones(ncol,1);

    model.obj = b;

    model.vtype = repmat('C',ncol,1);

    model.A = sparse(nrow,ncol);

    for i = 1: nrow

      model.A(i,:) = A(:,i);

    end

    model.rhs = c;

    model.sense = repmat('>', nrow, 1);

    gurobi_write(model,'min.lp');

    params.outputflag = 0;

    result = gurobi(model, params);

  %  result = gurobi(model)

    mu = result.x;

end
