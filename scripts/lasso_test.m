

get_data_folder;

% Get all grid cells  
load(fullfile(datafolder,'params.mat')); % includes cell array with filenames of grid cells

% Take a random subset of non-grid cells to match prevelance
% use fixed random seed for debugging
rng('default'); 

get_fnames;

% comparisons to run
tests = {{'gb','nongb'},{'grid','nongrid'}};
% forward search order
forward_search_order = { {'mean_fr','fr_dft_abs'},{'mean_fr','fr','fr_dft_abs'},...
    {'mean_fr','fr','mean_fr_ccorr','ccorr_peak','fr_dft_abs'}};
% which classifiers to run
modelTypes = {'linear_svm'};
% hyperparams for each calssifier
hyperParams = {{'lasso',1}};
results = cell(length(tests),length(forward_search_order));
for t = 1:length(tests)
    eval(['class0_fnames = ' tests{t}{1} '_fnames;']);
    eval(['class1_fnames = ' tests{t}{2} '_fnames_ds;']);
    m = length(class0_fnames) + length(class1_fnames);
    fold_inds = build_folds(m,m);
    
    for f = 1:length(forward_search_order)
        feats = forward_search_order{f};
        [X, Y] = load_features(datafolder,{class0_fnames,class1_fnames},feats);
        
        single_run_results = batch_run_cv(X,Y,feats,fold_inds,modelTypes,hyperParams);
        single_run_results.groups = tests{t};
        
        results{t,f} = single_run_results;
        
        
    end
    
end

train_acc = zeros(2,3); test_acc = zeros(2,3);
for i =  1:length(tests)
    for j = 1:length(forward_search_order)
        
        cmat_train = results{i,j}.linear_svm.cmat_train;
        cmat_test = results{i,j}.linear_svm.cmat_test;
        
        train_acc(i,j) = sum(diag(cmat_train))/sum(sum(cmat_train));
        test_acc(i,j) = sum(diag(cmat_test))/sum(sum(cmat_test));

        
        
    end
end

% save baseline_classifier_results.mat results fold_inds train_acc test_acc