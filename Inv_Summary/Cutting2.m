function x = Cutting(vi0,uij0,fi,rij)
% This one is used to obtain the lower bound by local search.

% vi0, uij0 表示给定 feasible solution [0,1]  row vector
% x 表示主问题给出的 (a,c,b,d)  2mn+2m
% c0 = (fi;rij) 为原设施成本  column vector
%  You must notice that the row and column vectors!!!!

s = 0; % 计数
opt2 = -0.5;
% 初始化限制集
I = [vi0;uij0]';

c0 = [fi;rij];

while opt2 < -0.00001
  x = Main(vi0,uij0,c0,I);

  [opt1,opt2] = Sub(x,fi,rij,vi0,uij0);

  opt1 = round(opt1);  % Rounding the fraction to integer.



  I = [I;opt1'];

  s = s + 1;

  if s > 80
    break
  end

end
s
% function end: 'myFunction'
end


function opt = Main(vi0,uij0,c0,I)
% I 表示 restricted set 每一行是给定 feasible solution  行数即可行解个数
% c0 为原设施成本  column vector
% vi0, uij0 表示给定feasible solution [0,1]  Row Vector

m = length(vi0) ;

n = length(uij0)/m ;

model.modelname = 'Main';

model.modelsense = 'min';

ncol = 2*m*n + 2*m ;

model.vtype = 'C';

model.obj   = ones(2*m + 2*m*n,1);

nrow = length(I(:,1));

delta = zeros(nrow,ncol/2);

model.A     = sparse(nrow, ncol);

for p = 1:nrow

    delta(p,:) = I(p,:) - [vi0;uij0]';

    model.A(p,:) = [delta(p,:), -delta(p,:)];

end

model.rhs   = -delta * c0;  % Matrix Multiply

model.sense = repmat('>', nrow , 1);


% Save model
% gurobi_write(model,'Main.lp');

% Set parameters
% params.method = 2;

% Optimize
% res = gurobi(model, params);
params.outputflag = 0;

res = gurobi(model,params);

opt = res.x;   %  给出 (a,c,b,d)

end


function [opt1,opt2] = Sub(x,fi,rij,vi0,uij0)
% I expresses restrict set. Every row is a feasible solution
% And the row numbers are the number of solutions
% x 表示主问题给出的 (a,c,b,d)  2mn+2m
% c0 = (fi;rij) 为原设施成本  Column vector

m = length(fi) ;

n = length(rij)/m ;

c = (x(1:m*n+m)-x(m*n+m+1:2*m*n+2*m)+[fi;rij]);  % m*n+m

model.modelname = 'Sub';

model.modelsense = 'min';

ncol = m*n + m ;

model.vtype = 'C';

model.obj   = c ;

nrow = m*n + n;

model.A     = sparse(nrow, ncol);

model.rhs   = [zeros(m*n, 1); ones(n,1)];

model.sense = [repmat('>', m*n , 1); repmat('=', n , 1)];

for w =1:m
    for p =1:n
        model.A(p+n*(w-1),w) = 1;

        model.A(p+n*(w-1),m+p+(w-1)*n) = -1;

    end
end

for p = 1:n

    model.A(p+m*n, n*(0:(m-1))+m+p) = 1;

end
% Save model
% gurobi_write(model,'Sub.lp');

% Set parameters
% params.method = 2;

% Optimize
% res = gurobi(model, params);

params.outputflag = 0;

res = gurobi(model,params);

opt1 = res.x;   %  给出 (v*,u*)

opt2 = res.objval - dot(c,[vi0;uij0]);

end
