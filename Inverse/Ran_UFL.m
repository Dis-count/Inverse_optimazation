% This function is used to get excel to show the specific data result.
function Ran_UFL(m,n,k)   
% (m,n) �����ģ  k Ϊ���ú������� Ĭ�� k=50;

theresult=zeros(k,2);

for j = 2:10 

    for i=1:k
    
        [a,b] =Random_UFL(m,n,j);  % �ظ�����
        theresult(i,:) = [a,b];
    end


filename = ['F:\Program Files\Matlab files\',num2str(m),'by',num2str(n),'-',num2str(j),'.xlsx'];

xlswrite(filename,theresult);

end
