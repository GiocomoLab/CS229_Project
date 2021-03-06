% script to run baseline classifiers
% with data augmentation
% MGC 12/6/2017

%% params

% number of features
numFeats = 200;

% use fixed random seed for debugging
rng('default');

% get data folder
get_data_folder;
datafolder = strcat(datafolder,'FeatureMats/data_augmentation');

% get file names for all cell classes
% Get all grid cells  
load(fullfile(datafolder,'params.mat')); % includes cell array with filenames of grid cells
get_fnames_aug;

% get all files names
files = dir(fullfile(datafolder,'FeatStruct_*.mat'));
files = {files(:).name}';

% find grid cells
grid_inds = zeros(size(files));
ngrids = length(grid_fnames_aug);
for g = 1:length(grid_fnames_aug)
    grid_inds = grid_inds + strcmp(files,grid_fnames_aug{g});
end

% find border cells
border_inds = zeros(size(files));
nborders = length(border_fnames_aug);
for b = 1:length(border_fnames_aug)
    border_inds = border_inds + strcmp(files,border_fnames_aug{b});
end

% comparisons to run
tests = {{'grid','border'},{'gb', 'nongb_ds'},{'grid','nongrid_ds'},{'border','nonborder_ds'}};
% features to use (forward search)
forward_search_order = {{'firing_rate'}};
% which classifiers to run
modelTypes = {'logistic','linear_svm','svm','gda'};
% hyperparams for each classifier
hyperParams = {{'ridge',1e2},{'ridge',1e2},{'rbf'},{}};

%% train classifiers

results = cell(length(tests),length(forward_search_order));
fold_inds_save = cell(length(tests),1);
for t = 1:length(tests)
    fprintf('test %d/%d\n',t,length(tests));
    eval(['class0_fnames = ' tests{t}{1} '_fnames_aug;']);
    eval(['class1_fnames = ' tests{t}{2} '_fnames_aug;']);
    m = length(class0_fnames) + length(class1_fnames);
    fold_inds = build_folds(m,m);

    fold_inds_vector = nan(size(fold_inds));
    for i = 1:size(fold_inds,1)
        fold_inds_vector(i) = fold_inds{i};
    end
    fold_inds_save{t} = fold_inds_vector;

    for f = 1:length(forward_search_order)
        fprintf('\tforward search %d/%d\n',f,length(forward_search_order));
        feats = forward_search_order{f};
        [Xtrain, Ytrain, Xtest, Ytest] = load_features_data_augmentation(datafolder,{class0_fnames,class1_fnames},numFeats);
        single_run_results = batch_run_cv_data_augmentation(Xtrain,Ytrain,Xtest,Ytest,feats,fold_inds,modelTypes,hyperParams);
        single_run_results.groups = tests{t};
        results{t,f} = single_run_results;
    end
end

%% evaluate classifiers

% training and test accuracy
train_acc = zeros(numel(tests),numel(forward_search_order),numel(modelTypes));
test_acc = zeros(numel(tests),numel(forward_search_order),numel(modelTypes));
for i =  1:length(tests)
    for j = 1:length(forward_search_order)
        % logistic
        cmat_train = results{i,j}.logistic.cmat_train;
        cmat_test = results{i,j}.logistic.cmat_test;
        train_acc(i,j,1) = sum(diag(cmat_train))/sum(sum(cmat_train));
        test_acc(i,j,1) = sum(diag(cmat_test))/sum(sum(cmat_test));

        % linear svm
        cmat_train = results{i,j}.linear_svm.cmat_train;
        cmat_test = results{i,j}.linear_svm.cmat_test;
        train_acc(i,j,2) = sum(diag(cmat_train))/sum(sum(cmat_train));
        test_acc(i,j,2) = sum(diag(cmat_test))/sum(sum(cmat_test));

        % svm
        cmat_train = results{i,j}.svm.cmat_train;
        cmat_test = results{i,j}.svm.cmat_test;
        train_acc(i,j,3) = sum(diag(cmat_train))/sum(sum(cmat_train));
        test_acc(i,j,3) = sum(diag(cmat_test))/sum(sum(cmat_test));
        
        % gda 
        cmat_train = results{i,j}.gda.cmat_train;
        cmat_test = results{i,j}.gda.cmat_test;
        train_acc(i,j,4) = sum(diag(cmat_train))/sum(sum(cmat_train));
        test_acc(i,j,4) = sum(diag(cmat_test))/sum(sum(cmat_test));
    end
end