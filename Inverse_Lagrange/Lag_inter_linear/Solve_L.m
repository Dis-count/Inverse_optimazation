function  Solve_L(min_step_size, max_iter)
%   次梯度方法求解拉格朗日对��?
  best_ub = 1e7;

  best_lb = -2;

%   max_iter = 100;
%   min_step_size = 0.01;

  obj = [5;4];

  iter = 1;

  non_improve = 0;

  max_non_improve = 3;

  lambda = 0.8;

  step_size = 1;

  mu = 0;   % 初始化拉格朗日乘��?

 % 松弛第一个约束条��?

  relax_con = [6,4,24;];

  con = [-1,1,1;
          1,2,8;];

while iter < max_iter

  [opt_x,opt_cost] = Sub_L(obj,relax_con,con,mu);
  opt_x
  % if  sp.solve() == false
  %
  %   disp('solve wrong!');
  %
  % end

% 更新上界
  if opt_cost < best_ub

    best_ub = opt_cost;

    non_improve = 0;

  else

    non_improve = non_improve + 1;

  end


  subgradient = dot(opt_x,relax_con(1:end-1)) - relax_con(end);

  mu = max(0, mu + step_size * subgradient);

% 满足原问题约束的可行解可以作为原问题的下��?

  if subgradient <= 0

    current_lb = dot(opt_x,obj);

    if current_lb > best_lb

      best_lb = current_lb;

    end

  end

  fprintf('iter: %d\n', iter);

  fprintf('best lb: %f ', best_lb);

  fprintf('best ub: %f ', best_ub);

  fprintf('mu: %f\n\n', mu);
% 上界未更新达到一定次��?

  if non_improve >= max_non_improve

    lambda = lambda/2;

    non_improve = 0;

  end

  mydist = subgradient^2;

  % 迭代停止条件2��?3

  if (mydist <= 0)||(best_lb >= best_ub-0.000001)

    break;

  end

  step_size = lambda * (opt_cost - best_lb)/mydist;

  % 迭代停止条件4

  if step_size < min_step_size

    break;

  end

iter = iter + 1;

end
