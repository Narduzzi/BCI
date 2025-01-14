function [ index20, index30, index95 ] = electrode_variance(data)
% Function that givex indexes of rows of variable data which:
%   index20: have the 20 most high variances
%   index30: have the 30 most high variances
%   index95: have 95% of total variance

% Take 64 first rows (electrodes)
data = data(1:64,:);
% Normalization by rows (electrodes)
data = normr(data);
% Compute variance of each row
var_electrode = var(data,0,2);

% Sort and take 20 first and 30 first rows with most variances
var_sorted = sort(var_electrode, 'descend');
index20 = var_electrode >= var_sorted(20);
index30 = var_electrode >= var_sorted(30);

% Take rows with 95% variance
cum_var = cumsum(var_sorted)/sum(var_sorted);
var95 = cum_var <= 0.95;
id0 = find(var95 == 0);
id0 = id0(1);
index95 = var_electrode >= var_sorted(id0);




end

