function Method_c(m,n,k)
  result = zeros(k+1,8);

  for i = 1:k
% k is the number of iteration
    fi = randi([100,200],m,1);
    rij = randi([100,200],m*n,1);

%  rij = randi([1,100],m*n,1);
    ini_sol = feasible_v(m,n);  % Random a feasible solution
%   [opt1,ini_sol] = UFL(fi,rij);  % give the optimal solution
%  s1 s2 s3 are the number of iteration.
    tic
    [a,s1] = Cutting(fi,rij,ini_sol);   % The optimal solution
    t1 = toc;
    
    tic
    b = Cutting1(fi,rij,ini_sol);  % The UB
    t2 = toc;
    
    tic
    c = Cutting2(fi,rij,ini_sol);  % The LB
    t3 = toc;
    
    result(i,:) = [a,b,c,t1,t2,t3,(b-a)/a,(c-a)/a];

  end

result(k+1,:) = [mean(result(1:k,1)),mean(result(1:k,2)),mean(result(1:k,3)),mean(result(1:k,4)),mean(result(1:k,5)),mean(result(1:k,6)),mean(result(1:k,7)),mean(result(1:k,8))];

filename = ['F:\Program Files\Matlab files\',num2str(m),'by2',num2str(n),'.xlsx'];

xlswrite(filename,result);

end
