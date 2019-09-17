function Inv_UFL3(fixed,v_i,u_ij,FC,TC)    % Inv_UFL1 ��������ѭ������Ҫ��һ���Ż� 
% �ú��� ���� �������� m,n ���Եõ�UFL�� ���Ż����
% �������Ҫ n ��ѭ��������
%  x_0 Ϊ������������Լ��Ƿ��� Facility  v_0 Ϊԭ��������ֵ  fixed ΪĿ��ֵ

% fixed = 29;   % ��������ֵ  ԭ��������ֵΪ29����� fixed = 29 ʱ���õ����Ž���� 0
 
% v_i = [0;0;1;1];
% ����һ�����н�
% u_ij = [0;0;0;0;
%         0;0;0;0;
%         1;0;1;0;
%         0;1;0;1;];

x_0 = [v_i;u_ij];

x0 =[x_0;x_0*(-1)];   % double the matrix    

% define primitive data
m = length(v_i);  
n = length(u_ij)/m; 

% ����ԭ�����C_0

% FC  = [10; 10; 10; 10];

% M = 30;
% TC  = [ 3; 3; M; 2;
%          M; 1; 4; M;
%          3; M; 3; 4;
%          M; 2; M; 1;];
Costs =[FC;TC];    % Cost Ϊ����

V_0 = x_0'*Costs;    %  ԭ���Ž� 


% Index helper function
% flowidx = @(w, p) nPlants * w + p;

% Build model
model.modelname = 'Inv_facility';
model.modelsense = 'min';

% Set data for variables
ncol = (m + m * n)*2 ;
model.lb    = zeros(ncol, 1);
model.ub    = [inf(ncol, 1)];
obj = [ones(m+m*n,1)];  

model.obj = [obj; obj];   % norm-1 c-Costs  ��Ϊ��

% model.vtype = [repmat('B', nPlants, 1); repmat('C', nPlants * nplayers, 1)];

% Set data for constraints and matrix
nrow = m^n + 1;
model.A     = sparse(nrow, ncol);

model.sense = [repmat('=', 1, 1); repmat('>', m^n, 1)];

% Production constraints   ע������������Ҫ����  ��һ��ǳ�����


model.A(1,:) = x0;

model.rhs(1) = fixed- V_0;

a = eye(m);

% f = zeros(m^n,m+m*n);

s = 2;  


% varRange������ȡֵ��˳�����С�
% ѭ��������������������(�����Ǳ������֣����ߵ����ַ��ȣ����ɣ���ô��Ҫ�û�������������

% varRange = {1:4, 1:4, 1:4 , 1:4}; % Ϊ��˳���ѭ����������

b = repmat(1:m,1,n);   % nΪplayer  ��ѭ������

varRange = mat2cell(b, [1], [repmat(m,1,n)]);

nloop = length(varRange);   % forѭ���������༴ѭ����������

var = cell(nloop,1);    % ��ʼ��ѭ������

maxIter = cellfun(@length,varRange(:));

subs = arrayfun(@(x)1:x,maxIter,'un',0);

iter = cell(nloop,1);

[iter{end:-1:1}] = ndgrid(subs{end:-1:1});

temp = cellfun(@(x)x(:),iter,'un',0);

iter = num2cell(cat(2,temp{:}));    % ѭ���������� 

for k = 1:size(iter,1)  % һ��ѭ�����Ƕ��
    
    var = cellfun(@(x,y)x(y),varRange,iter(k,:),'un',0);
    
    sca = cell2mat(var);
    
    c = [a(:, sca)];   % ����cell�õ��������Ӷ���������ȡ��������������
                    
    f = reshape(c',m*m,1); % ע������reshape�ǰ���  ��������Ҫ�ı���˳���ǰ�����Ϊ��cת�� ����������
                
    % d = all(x<0)
    d = zeros(m,1);
    
    for j = 1:m            
        d(j) = 1-all(c(j,:)==0);   % ����ȫΪ���򷵻�0
    end
    
    e = [d;f];   % ������
        
    ee = [e;e*(-1)];  % ����Ϊ������
        
    model.A(s,:) = ee;
                    
    model.rhs(s) = fixed - e'* Costs;
        
    % f(s,:) = e;        
        
    s = s+1;
    
end


gurobi_write(model,'Inv_UFL3.lp');

% Guess at the starting point: close the plant with the highest fixed
% costs; open all others first open all plants
% model.start = [ones(nPlants, 1); inf(nPlants * nplayers, 1)];
% [~, idx] = max(FC);
% model.start(idx) = 0;



% Optimize
res = gurobi(model);

end