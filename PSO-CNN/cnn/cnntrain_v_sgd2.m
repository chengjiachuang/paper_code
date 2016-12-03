function net = cnntrain_v_sgd2(net, x, y, opts)
m = size(x, 3); % m ������� ѵ����������
numbatches = m / opts.batchsize;

net.rL = [];
% err = [];
result=[];



for i = 1 : opts.numepochs
    % disp(X) ��ӡ����Ԫ�ء����X�Ǹ��ַ������Ǿʹ�ӡ����ַ���
    disp(['epoch ' num2str(i) '/' num2str(opts.numepochs)]);
    % tic �� toc ��������ʱ�ģ��������������֮�����ĵ�ʱ��
    tic;
    
    
    %���Ӹ���
    for num=1:opts.sizepar
        %��ֵ��������cnnff�ֿ�
        net = cnnassign(net,num);
        % �ڵ�ǰ������Ȩֵ�����������¼�����������
        net = cnnff(net,x,y,num); % Feedforward
        
    end
    %����������Ƚ�һ��ѡ����������
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
    % �õ���������������ͨ����Ӧ��������ǩ��bp�㷨���õ���������Ȩֵ
    % (Ҳ������Щ����˵�Ԫ�أ��ĵ���
    % ����������һ��ѵ������Ȩֵ�ŵ�����ʮһ��������,���ֳ���ļ�����
    num=opts.sizepar+1;
    net.sumgd=zeros(size(net.par{1,1})); %һ��sgd���ݶ�֮�ͣ������ٶȹ�ʽ��
    net = cnnassign(net,num);
    
    %��Ҫ��cnnffǰ�����һ�Σ�����cnnbp��Ҫ��net.o���Ƕ�Ӧgebestpar�ģ�������һ��pso�����һ��������������net.o
    %ͬʱѭ������ʱ��BP��һ�λ���BP�����Ƕ�Ӧ����һ�θ���������ӽ��м�����Ӧ�ȡ�
    
    % P = randperm(N) ����[1, N]֮������������һ����������У�����
    % randperm(6) ���ܻ᷵�� [2 4 5 6 1 3]
    % �������൱�ڰ�ԭ�����������д��ң�������һЩ������ѵ��
    kk = randperm(m);
    
    for l = 1 : numbatches
        % ȡ������˳����batchsize�������Ͷ�Ӧ�ı�ǩ
        batch_x = x(:, :, kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));
        batch_y = y(:,    kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));
        
        % �ڵ�ǰ������Ȩֵ�����������¼�����������
        net = cnnff(net, batch_x,batch_y,num); % Feedforward
        
        
        %         net = cnnbp(net, y); % Backpropagation
        net = cnnbp(net,opts,batch_y);
        % �õ�����Ȩֵ�ĵ����󣬾�ͨ��Ȩֵ���·���ȥ����Ȩֵ
        %         net = cnnapplygrads(net, opts,num);
        net = cnnapplygrads_original(net, opts,num);
        
    end
    %��Ӧ�ȸ���,���弫ֵ��ȫ�弫ֵ���£��ٶȺ�λ�ø���
    net = cnnupdate(net,opts);
    %         net = cnnupdate_clpso(net,opts);
    toc;
    
    %��ÿ�ε�������Ӧ��ֵ����result
    if isempty(result)
        result=net.fitnessgbest;
    else
        result(end+1)=net.fitnessgbest;
    end
end
net.result=result;

figure('Name','����ʮ����ʵ��');
title('��Ӧ������');
xlabel('������Ӧ�ȴ���');ylabel('��Ӧ��');
saveas(figure(1),'����ʮ����ʵ��');

end
