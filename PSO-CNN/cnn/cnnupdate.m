function net=cnnupdate(net,opts)
%% ���弫ֵ��ȫ�弫ֵ�ĸ���

for num=1:opts.sizepar
    %���弫ֵ����
    if net.fitness(num)<net.fitnesspbest(num)
        net.fitnesspbest(num)=net.fitness(num);
        net.pbestpar{num}=net.par{num};
    end
    %Ⱥ�弫ֵ����
    if net.fitness(num)<net.fitnessgbest
        net.fitnessgbest=net.fitness(num);
        net.gbestpar=net.par{num};
    end
end

%��ȫ���������Ӹ�����31������
net.par{opts.sizepar+1}=net.gbestpar;

%% �������ӵ��ٶ�λ��

for num=1:opts.sizepar
    %�ٶȸ���
    net.vel{num}=opts.w*net.vel{num}+opts.c1*rand*(net.pbestpar{num}-net.par{num})+opts.c2*rand*(net.gbestpar-net.par{num})+net.sumgd;
    %��Ҫ����vel�����ֵ
    net.vel{num}(net.vel{num}>opts.velmax)=opts.velmax;
    net.vel{num}(net.vel{num}<opts.velmin)=opts.velmin;
    
    %����λ�ø���
    net.par{num}=net.par{num}+net.vel{num};
    %ʹ���������ڽ�ռ�
    net.par{num}(net.par{num}>opts.parmax)=opts.parmax;
    net.par{num}(net.par{num}<opts.parmin)=opts.parmin;
    % ����Ӧ���죬��Ҫ����λ�õ����ֵ
    total=numel(net.par{num});
    pos=unidrnd(total,1,floor(total/21));
    if rand>0.95
        net.par{num}(pos)=5*rands(1);
    end
    
end
