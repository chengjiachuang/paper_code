function [mmy,er, bad] = cnntest(net, x, y,opts)
    %  feedforward
    num=opts.sizepar+1;
    net.par{num}=net.gbestpar;
    net = cnnassign(net,num);
    net = cnnff(net,x,y,num); % ǰ�򴫲��õ����
    mmy = [];
    mmy =[mmy;net.fv];
	% [Y,I] = max(X) returns the indices of the maximum values in vector I
    [~, h] = max(net.o); % �ҵ����������Ӧ�ı�ǩ
    [~, a] = max(y); 	 % �ҵ��������������Ӧ������
    bad = find(h ~= a);  % �ҵ����ǲ���ͬ�ĸ�����Ҳ���Ǵ���Ĵ���

    er = numel(bad) / size(y, 2); % ���������
end