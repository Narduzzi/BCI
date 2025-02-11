
clear all;
close all;
clc

%%

load('data_simon1.mat')
downfactor = 8;
low=1;
high=40;
order=5;
Fs = header_down.SampleRate/downfactor;
signal_filtered = band_filter(low,high,order,Fs,signal_down);

%%
text = 'data_simon1_ses_1_condition.txt';
[easy,hard_assist,hard_noassist] = partitioning2(header_down,signal_filtered,text);

%%
%centered_electrodes = load('25_centered_electrodes.mat');
%[indices] = index_of_electrodes(centered_electrodes.label,header_down);
indices = 1:64;
%indices = [1, 19, 21, 23, 24, 27, 28, 29, 33, 35, 36, 49, 60, 63, 64, 18, 31, 32, 39, 40, 42, 43, 44, 47, 48, 50, 52, 55, 56, 57, 61 ];
%indices = [18, 27, 28, 29, 31, 32, 48, 49, 50, 56, 60, 61];
indices = sort(indices);

%%
window_size = 256;
step_size = window_size/2;
%features_extracted = features_extraction(easy(indices,:),hard_noassist(indices,:),hard_assist(indices,:),header,window_size,step_size);
features_extracted = features_extraction(easy(indices,:),hard_noassist(indices,:),-1,header_down,window_size,step_size);

%%
%discriminant_analysis(features_extracted,1000);
[TRAIN_ERROR, TEST_ERROR,SELECTED] = model_FFS(features_extracted);
%%
train_errors = [];

test_errors = [];
for traj = 0:4
    [train_labels,train_features,test_labels,test_features] = create_folds(features_extracted,traj);
    classifier_lda = fitcdiscr(train_features, train_labels, 'DiscrimTyp', 'Linear', 'Prior', 'uniform');
    
    yhat_lda = predict(classifier_lda, train_features); 
    [train_err] = classerror(train_labels, yhat_lda);
    yhat_lda = predict(classifier_lda, test_features);
    [test_err] = classerror(test_labels, yhat_lda); 
    
    fprintf('Train Error : %0.3f\t',train_err);
    fprintf('Test Error : %0.3f\n ',test_err);
    
    train_errors = horzcat(train_errors,train_err);
    test_errors = horzcat(test_errors,test_err);
end
disp('====Evaluation finished====');
fprintf('Mean Train Error : %0.3f\t',mean(train_errors));
fprintf('Mean Test Error : %0.3f\n',mean(test_errors));

%% 
[coeff, features_pca, variance] = pca(features_extracted(:,3:end));
features_selected = [features_extracted(:,1:2) features_pca(:,1:100)];
%features_selected = features_pca(:,1:876);

 
%%
train_features = features_extracted(:,3:end);
train_labels = features_extracted(:,1);

% [orderedInd, orderedPower] = rankfeat(train_features, train_labels, 'fisher');
% nb_features = 610;
% features_index = orderedInd(1:nb_features);
% %classifier = fitcdiscr(train_features(:,orderedInd(1:nb_features)), train_labels, 'DiscrimTyp', 'DiagLinear', 'Prior', 'uniform');
% classifier = fitcsvm(train_features(:,orderedInd(1:nb_features)),train_labels,'KernelFunction','rbf');
% yhat = predict(classifier, train_features(:,orderedInd(1:nb_features))); 

[orderedInd, orderedPower] = relieff(train_features, train_labels, 400);
nb_features = 251;
features_index = orderedInd(1:nb_features);
%classifier = fitcsvm(train_features(:,orderedInd(1:nb_features)),train_labels,'KernelFunction','linear');
classifier = fitcdiscr(train_features(:,orderedInd(1:nb_features)), train_labels, 'DiscrimTyp', 'DiagLinear', 'Prior', 'uniform');
yhat = predict(classifier, train_features(:,orderedInd(1:nb_features)));

% [coeff train_PCA variance] = pca(train_features);
% mean_t = mean(train_features,1);
% nb_features = 51;
% features_index = [];
% classifier = fitcdiscr(train_PCA(:,1:nb_features), train_labels, 'DiscrimTyp', 'DiagQuadratic', 'Prior', 'uniform');
% yhat = predict(classifier, train_PCA(:,1:nb_features)); 

training_error_final = classerror(train_labels, yhat)
model_simon.classifier = classifier;
model_simon.nb_features = nb_features;
model_simon.indices = features_index;
%model_simon.coeff = coeff;
%model_simon.mean = mean_t;
save('classifier_simon_relieff.mat', 'model_simon')

