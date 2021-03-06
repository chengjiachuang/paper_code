function [new_net, new_tr] = cnn_train_rprop(net, x, d, tr)
% CNN_TRAIN_RPROP Train a CNN using Resilient Backpropagation method
%
% SYNTAX
%      [new_net, new_tr] = cnn_train_rprop(net, x, d, tr)
%
% PARAMETERS
%     net: CNN structure
%     x:   inputs         (3-D array H x W x K)
%     d:   desired output (2-D array NL x K)
%     tr:  existing training records
%
%     new_tr:  updated training records
%     new_net: trained net
%
% EXAMPLE
%     c = {cnn_cm('full', 1, 4), cnn_cm('1-to-1', 4), ...
%          cnn_cm('1-to-2 2-to-1', 4), cnn_cm('1-to-1', 14), ...
%          cnn_cm('1-to-1', 14), cnn_cm('full', 14, 2)};
%     net = cnn_new([36 32], c, [5 5; 2 2; 3 3; 2 2; 0 0; 0 0], ...
%           repmat({'tansig'}, 1, length(c)), 'rprop');
%     K = 5; x = randn(36, 32, K); d = randn(2,K);
%     [new_net, new_tr] = cnn_train_rprop(net, x, d);
%
% NOTES
% Son Lam Phung, started 12-Jan-2006.

%% Process input parameters................................................
if nargin < 4
    tr = cnn_get_init_tr;
end

if (ischar(tr) || isempty(tr))
    tr = cnn_get_init_tr;
end

start_time = clock;
new_net = net;    % New net
new_tr = tr;      % New training record

%% Store record fields for speed...........................................
tr_mse = [];  
tr_time = [];
tr_epoch = [];
tr_output_eval = [];
tr_gradient_eval = [];

train_method = upper(new_net.train.method);
etap = new_net.train.rprop.etap;
etam = new_net.train.rprop.etam;
delta_init = new_net.train.rprop.delta_init;

%% Retrieve previous training trends.......................................
if isfield(new_net.train.rprop, 'dEdw_prev')
    dEdw_prev=  new_net.train.rprop.dEdw_prev;
else
    dEdw_prev = zeros(new_net.P, 1);
end

dEdw_curr = zeros(new_net.P, 1);

if isfield(new_net.train.rprop, 'delta_w')
    delta_w =  new_net.train.rprop.delta_w;
else
    delta_w = delta_init * ones(new_net.P,1);
end

%% ............................. Training .............................. %%
output_eval_count = 0;
gradient_eval_count = 0;

for epoch_count = 1:new_net.train.epochs
    % Compute network output
    output_eval_count = output_eval_count + 1;
    [y, s] = cnn_sim_verbose(new_net, x);
    
    % Compute mean square error
    e = y{end} - d; % error
    E = mse(e);     % MSE

    if ((rem(epoch_count, new_net.train.show) == 0) || ...
        (epoch_count == 1))   
        tr_epoch         = [tr_epoch         epoch_count];
        tr_output_eval   = [tr_output_eval   output_eval_count];
        tr_gradient_eval = [tr_gradient_eval gradient_eval_count];
        tr_mse           = [tr_mse           E];
        tr_time          = [tr_time          etime(clock, start_time)];
        fprintf('\n%s: epoch %g, mse = %3.8g', ...
                train_method, epoch_count, E);
    end   

    % Exit training if goal is achieved
    if (E <= new_net.train.goal)
        fprintf('\nTraining goal is achieved.\n');
        break;
    end
    
    % Compute gradient
    gradient_eval_count = gradient_eval_count + 1;
    [dw, db] = cnn_compute_gradient(new_net, x, e, y, s);
    dEdw_curr = cnn_vectorize_wb(new_net, dw, db);
    
    % Update weight steps
    sign_w  = sign(dEdw_prev)  .* sign(dEdw_curr);
    delta_w = delta_w .* ((sign_w ==  1) * etap + ...
                          (sign_w == -1) * etam + ...
                          (sign_w ==  0)); 

    % Compute new weights
    w = cnn_vectorize_wb(new_net, new_net.w, new_net.b);
    w = w - sign(dEdw_curr)  .* delta_w;
    [new_w, new_b] = cnn_devectorize_wb(new_net, w);
    new_net.w = new_w; new_net.b = new_b;
    
    dEdw_prev = dEdw_curr; % Store gradient                    
end
new_net.train.rprop.delta_w = delta_w;
new_net.train.rprop.dEdw_prev = dEdw_curr;

%% Store progress of last epoch............................................
if (rem(epoch_count, new_net.train.show) ~= 0)
    tr_epoch         = [tr_epoch         epoch_count];
    tr_output_eval   = [tr_output_eval   output_eval_count];
    tr_gradient_eval = [tr_gradient_eval gradient_eval_count];
    tr_mse           = [tr_mse           E];
    tr_time          = [tr_time          etime(clock, start_time)];
    fprintf('\n%s: epoch %g, mse = %3.8g ...', ...
            train_method, epoch_count, E);
end

%% Add to existing training record.........................................
if (~isempty(tr.time))
    tr_time = tr_time + tr.time(end);
end

if (~isempty(tr.epoch))
    tr_epoch = tr_epoch + tr.epoch(end);
end

if (~isempty(tr.output_eval))
    tr_output_eval = tr_output_eval + tr.output_eval(end);
end

if (~isempty(tr.gradient_eval))
    tr_gradient_eval = tr_gradient_eval + tr.gradient_eval(end);
end

%% Update training record..................................................
new_tr.time = [tr.time tr_time];
new_tr.mse = [tr.mse tr_mse];
new_tr.epoch = [tr.epoch tr_epoch];
new_tr.output_eval = [tr.output_eval tr_output_eval];
new_tr.gradient_eval = [tr.gradient_eval tr_gradient_eval];
fprintf('\n');