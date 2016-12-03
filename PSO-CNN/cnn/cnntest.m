function [mmy,er, bad] = cnntest(net, x, y,opts)
%  feedforward
disp(['mse=',num2str(net.result(end))]);
num=opts.sizepar+1;
net.par{num}=net.gbestpar;
    for num=1:30
        net.par{num}=net.pbestpar{num};
        net = cnnassign(net,num);
        net = cnnff(net,x,y,num); % ǰ�򴫲��õ����
        mmy = [];
        mmy =[mmy;net.fv];
        % [Y,I] = max(X) returns the indices of the maximum values in vector I
        [~, h] = max(net.o); % �ҵ����������Ӧ�ı�ǩ
        [~, a] = max(y); 	 % �ҵ��������������Ӧ������
        bad = find(h ~= a);  % �ҵ����ǲ���ͬ�ĸ�����Ҳ���Ǵ���Ĵ���

        er = numel(bad) / size(y, 2); % ���������
        disp([num2str(er*100) '% error']);
    end
end
