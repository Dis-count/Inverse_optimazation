
[a,b] = fun1(100,100);

a

b


function [gap,opt1] = fun1(m,n)  % ����ԭUFL������ֵ �� �� LP ����õ��� gap
% ���� Facility ���� m  Player ���� n 

delimiterIn = ' ';
headerlinesIn = 4;
data = importdata('411Eucl.txt',delimiterIn,headerlinesIn);

% data211=importdata('211.txt');

% ��Ӧ������������ Ϊ ��2mn+2m+2����  �����У�5mn+3m+n) ��

fi =  ones(1,100)'*3000 ;    % ���Ե��� fi �� rik ֮��ı��� �鿴gap�仯 
% rik = round(rand(1,m*n)*10)'; % ע����������  �����1-10,1-100,1-1000��

rik = data.data(:,3);


[opt1,opt2] = fun2(fi,rik);  % V_UFL Ϊ UFL����ֵ 
V_UFL = opt1;

% fi  = [10; 10; 10; 10];  
% ������� facility cost 

% M = 30;    % define M= a bigger integer.


% ������� transportation cost
% rik  = [ 3; 3; M; 2;
%          M; 1; 4; M;
%          3; M; 3; 4;
%          M; 2; M; 1;];


vi = opt2(1:m); 

uik = opt2(m+1:end);

% ����һ�� ����Ϊ ��5mn+3m+n) ��������ÿһ���������� ���� һ��������    

% Build model
model.modelname = 'UFL';
model.modelsense = 'min';

% Set data for variables
ncol = 5*m*n + 3*m + n;

% �����Ա������������� 
model.lb    = zeros(ncol, 1);
model.ub    = inf(ncol, 1);
model.obj   = [zeros(n+m+3*m*n,1); ones(2*m + 2*m*n,1); ];

% Set data for constraints and matrix
nrow = 2*m*n+2*m+2;

model.A     = sparse(nrow, ncol);


model.rhs   = [V_UFL; zeros(m + m*n, 1); V_UFL; fi; rik];
model.sense = [repmat('>', 1, 1); repmat('=', 2*m*n + 2*m + 1, 1)];


model.A(1,1:n) = 1;  % ��һ��Լ��

for p = 1:m
    for w = 1:n
        model.A(p+1, n*p+w) = 1;
    end
    model.A(p+1, n+n*m+p) = -1;
%    model.constrnames{p} = sprintf('Capacity%d', p);
end

% �ڶ���Լ��

for p = 1:m
    for w = 1:n
        model.A((p-1)*n+w+m+1,[w,m*n+m+p*n+w]) = 1;
        
        model.A((p-1)*n+w+m+1,[p*n+w,2*m*n+m+p*n+w]) = -1;
    end
end   % ������Լ��

for p = 1:m
    for w = 1:n
    model.A(m*n+m+2,m+2*m*n+p*n+w) = uik((p-1)*n+w);

    end
    model.A(m*n+m+2,n+m*n+p) = vi(p);
%    model.constrnames{nPlants+w} = sprintf('Demand%d', w);
end   % ���ĸ�Լ��


for p = 1:m
    model.A(m*n+m+2+p,n+m+3*m*n+p) = -1;
    model.A(m*n+m+2+p,[n+m*n+p,n+2*m+3*m*n+p]) = 1;   % �����Ҳ�Լ��Ϊ����fi ��ͬ
end   % �����Լ��
    

for p = 1:m
    for w = 1:n
        model.A((p-1)*n+m*n+2*m+2+w, 3*m+3*m*n+p*n+w) = -1;
        
        model.A((p-1)*n+m*n+2*m+2+w, [m+2*m*n+p*n+w,3*m+4*m*n+p*n+w]) = 1;
    end
end  % ������Լ��

% Save model
% gurobi_write(model,'UFL.lp');

% Optimize 
res = gurobi(model);

gap = res.objval;

%  disp(gap);
%  disp(opt1);

end




function [opt1,opt2] = fun2(fi,rik)   % fi rik Ϊ������  ��� UFL������ֵ�Լ�����
% ���� Facility ���� m  Player ���� n    

% ��Ӧ������������ Ϊ ��mn+m����  �����У�mn+m) ��

m = length(fi) ;
n = length(rik)/m ;


% ����һ�� ����Ϊ ��mn+m) ��������ÿһ���������� ���� һ��������


% Build model
model.modelname = 'I_UFL';
model.modelsense = 'min';

% Set data for variables
ncol = m*n + m ;

model.vtype = 'B';

model.obj   = [fi; rik];


% Set data for constraints and matrix

nrow = m*n + n;

model.A     = sparse(nrow, ncol);

model.rhs   = [zeros(m*n, 1); ones(n,1)];

model.sense = [repmat('>', m*n , 1); repmat('=', n , 1)];


for w =1:m
    for p =1:n
        model.A(p+n*(w-1),w) = 1;         % ��һ��Լ��
        
        model.A(p+n*(w-1),m+p+(w-1)*n) = -1;
    end
end

for p = 1:n
    model.A(p+m*n, n*(0:(m-1))+m+p) = 1; % �ڶ���Լ��
end

% Save model
% gurobi_write(model,'I_UFL.lp');

% Optimize
% res = gurobi(model, params);
res = gurobi(model);
opt1 = res.objval;
opt2 = res.x;
% Print solution

end
