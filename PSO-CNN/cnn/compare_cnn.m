function compare=compare_cnn(net,opts)
%�Ƚ�30�����Ӽ�Ĳ�ͬ������٣��ٶȲ���٣�pbest�����
%����ֵԽ�󣬶�Ӧ�ı���Խ����
compare.par=zeros(opts.sizepar);compare.vel=zeros(opts.sizepar);compare.pbestpar=zeros(opts.sizepar);
compare.par_pbestpar=zeros(1,opts.sizepar);
for i=1:opts.sizepar
    for j=1:opts.sizepar
        compare.par(i,j)=numel(find(abs(net.par{1,i}-net.par{1,j})<0.01))/numel(net.par{1,i});
        compare.vel(i,j)=numel(find(abs(net.vel{1,i}-net.vel{1,j})<0.01))/numel(net.par{1,i});
        compare.pbestpar(i,j)=numel(find(abs(net.pbestpar{1,i}-net.pbestpar{1,j})<0.01))/numel(net.par{1,i});
    end
    compare.par_pbestpar(i)=numel(find(abs(net.par{1,i}-net.pbestpar{1,i})<0.01))/numel(net.par{1,i});
end
