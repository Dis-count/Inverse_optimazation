% ������������������ϡ��� �� UFL���Ż� ������

% ��������ϡ��� ������� trans-cost ���󣨼���������ÿһ�ж�������һ����ΪM��ֵ����һ������˼������

% ������֮ǰ���еĳ���д��һ�� ��Ϊ һ������

%  ������˼·�� ���� ÿһ���������� ʹ��һ����������ʾ  

for m = 10:10:70
    myfun(m,2*m,50);
end

% This function is used to get excel to show the specific data result.
function myfun(m,n,k)   
% (m,n) �����ģ  k Ϊ���ú������� Ĭ�� k=50;

theresult=zeros(k+1,3);

for j = 2:10   % j is multiplier

    for i=1:k 
    
        [a,b] = fun1(m,n,j);  % �ظ�����  b Ϊ����ֵ
        theresult(i,:) = [a,b,(a-0)/b];  % gap  ����  ��ֵ
         
    end
theresult(k+1,:) = [mean(theresult(1:k,1)),mean(theresult(1:k,2)),mean(theresult(1:k,3))];

filename = ['F:\Program Files\Matlab files\',num2str(m),'by',num2str(n),'-',num2str(j),'.xlsx'];

xlswrite(filename,theresult);

end

end




function [gap,opt1] = fun1(m,n,mul)  % ����ԭUFL������ֵ �� �� LP ����õ��� gap
% ���� Facility ���� m  Player ���� n 

% mul Ϊ ��ʩ�ɱ�����

% ��Ӧ������������ Ϊ ��2mn+2m+2����  �����У�5mn+3m+n) ��

fi = round(rand(1,m)*10*mul)';    % ���Ե��� fi �� rik ֮��ı��� �鿴gap�仯 
% rik = round(rand(1,m*n)*10)'; % ע����������  �����1-10,1-100,1-1000��
rik = fun3(m,n,round(m*n*0.25));


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

end


function r = fun3(m,n,t)  % tΪϡ���
    x = ceil(rand(1,t)*m);    % ���� t �� 1-m ������  ��Ϊ�����������
    yy = 1:n;
    
    M = 100;     
    
    for i = 1:20
        y = ceil(rand(1,t)*n);  % ���� t �� 1-n ������  ��Ϊ�����������
        if sum(ismember(yy,y))== n  % �ж����������Ƿ���ϱ�׼
        
            break
        else
            disp(i);    
        end
    end
    
    v = ceil(rand(1,t)*10);   % ���� t �� ��� ����ֵ
        
    r = full(sparse(x,y,v,m,n));
    s = sum(sum(r~=0));   % �ж� ������ �Ƿ�����ϡ���
    if  s < t
        a = find(r==0); % �ҵ�Ԫ��Ϊ 0 ��λ��
            
        for i = 1:t-s
            b = unidrnd(length(a));     % ���ȡ�� a ��һ����ֵ
            r(a(b)) = ceil(rand(1,1)*10);    
            a(b) =[];   % ɾ������ӵ�Ԫ��  ע������ a �����Ѿ��� 1 ��
        end
    end
    r(r(:)==0) = M;    % ��ϡ�������Ϊ 0ֵ�ĵط� ȫ��Ϊ M
    r = reshape(r,m*n,1);
end


function [opt1,opt2] = fun2(fi,rik)   % fi rik Ϊ������  ��� UFL������ֵ�Լ�����
% ���� Facility ���� m  Player ���� n    

% ��Ӧ������������ Ϊ ��mn+m����  �����У�mn+m) ��

m = length(fi) ;
n = length(rik)/m ;


% disp(fi');

%fprintf('Facility Costs: %g\n', fi);

% disp(rik');

%fprintf('Trans Costs: %f\n', rik);

% fi  = [10; 10; 10; 10];   

% M = 100;    % define M= a bigger integer.

% ע������Ӧ��ʹ��ѭ������������ ������Ϊ�˼���򵥵����ӣ�n=4)������ֱ���ֶ���ӱ�����


% rik  = [ 3; 3; M; 2;
%          M; 1; 4; M;
%          3; M; 3; 4;
%          M; 2; M; 1;];


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