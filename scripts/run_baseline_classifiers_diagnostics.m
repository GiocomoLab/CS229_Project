% script to run baseline classifiers
% MGC 12/5/2017

%% params

% get data folder
get_data_folder;
datafolder = strcat(datafolder,'FeatureMats/gain_increase');

% get file names for all cell classes
get_fnames_gain_manip;

% comparisons to run
tests = {{'grid', 'border'}};
% features to use (forward search)
forward_search_order = {{'cross_corr'}};
% which classifiers to run
modelTypes = {'linear_svm'};
% hyperparams for each classifier
hyperParams = {{'ridge',0.1}};

%% accuracy and log loss over various training set sizes

% train classifier
% number of times to create learning curve by downsampling
num_runs = 10;
max_samples_per_category = 30;
increment = 2;
num_training_sets = max_samples_per_category/increment;
training_size = nan(num_runs,num_training_sets);
train_acc = nan(num_runs,num_training_sets);
test_acc = nan(num_runs,num_training_sets);
train_log_loss = nan(num_runs,num_training_sets);
test_log_loss= nan(num_runs,num_training_sets);
for k = 1:num_runs
    fprintf('run %d/%d\n',k,num_runs);
    
    % permute samples
    class0_fnames = grid_fnames(randperm(numel(grid_fnames)));
    class1_fnames = border_fnames(randperm(numel(border_fnames)));
    for j = 1:num_training_sets
        fprintf('\ttraining set %d/%d\n',j,num_training_sets);        
        
        % subsample
        class0_fnames_subset = class0_fnames(1:increment*j);
        class1_fnames_subset = class1_fnames(1:increment*j);
        m = length(class0_fnames_subset) + length(class1_fnames_subset);
        fold_inds = build_folds(m,m);

        % train model
        feats = forward_search_order{1};
        [X, Y] = load_features(datafolder,{class0_fnames_subset,class1_fnames_subset},feats);
        results = batch_run_cv(X,Y,feats,fold_inds,modelTypes,hyperParams);
        
        % compute accuracy
        cmat_train = results.linear_svm.cmat_train;
        cmat_test = results.linear_svm.cmat_test;
        train_acc(k,j) = sum(diag(cmat_train))/sum(sum(cmat_train));
        test_acc(k,j) = sum(diag(cmat_test))/sum(sum(cmat_test));
        training_size(k,j) = m;
    end
end

figure;
plot(mean(training_size),mean(test_acc),'b-')
hold on; plot(mean(training_size),mean(train_acc),'r-')
xlabel('training set size');
ylabel('accuracy');
legend({'train','test'});
title('grid vs border (linear svm)');