% varRange������ȡֵ��˳�����С�
% ѭ��������������������(�����Ǳ������֣����ߵ����ַ��ȣ����ɣ���ô��Ҫ�û�������������
varRange = {1:10, {[3 2], -6}, 'abc',{'China','UK'}}; % ѭ���������ϣ�ע��ӻ����źͲ��ӻ����������������
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
    % do something
    dispvar(k,nloop,var)
end



% �����dispvar��һ��������ʾѭ������ȡֵ�ĺ���

function dispvar(k,nloop,var)
% k - ��ǰѭ������
% nloop - Ƕ��ѭ���ܲ���
% var - ��ǰѭ������ȡֵ���
% δ����ϸ�Ĳ�����飬�ڷǳ������������¿��ܻ���bug

fprintf(['ѭ�������������%' num2str(fix(log10(k))+1) 'd:??('],k)
for s = 1:nloop
    if ~iscell(var{s})
        if isnumeric(var{s})
            fprintf('%g??',var{s})
        elseif ischar(var{s})
            fprintf('%c??',var{s})
        end
    else
        if isnumeric(var{s}{:}) && ~isscalar(var{s}{:})
            fprintf('[%0.f-by-%0.f %s] ',size(var{s}{:}),class(var{s}{:}));
        elseif isnumeric(var{s}{:}) && isscalar(var{s}{:})
            fprintf('%g ',var{s}{:});
        elseif ischar(var{s}{:})
            fprintf('%s??',var{s}{:})
        end
    end
end
fprintf(')\n')