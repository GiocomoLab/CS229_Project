% script to run baseline classifiers


%% params

% whether or not to make plots
make_plots = 0;

% whether or not to save results
save_results = 0;
file_prefix = 'baseline';

% get data folder
get_data_folder;
datafolder = strcat(datafolder,'FeatureMats'); 

% get file names for all cell classes
% and downsample more prevalent class to match 
get_fnames;


%%%%%%%% edit the variables below to control which models and cell groups
%%%%%%%% are tested %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% comparisons to run 
tests = {{'gb','nongb_ds'},{'grid','nongrid_ds'},{'grid','border'}};
% features to use (forward search)
forward_search_order = {{'fr_dft_abs'},{'fr_dft_abs', 'ccorr_peak'}, ...
    {'fr_dft_abs','ccor_peak','mean_fr'},...
    {'fr','mean_fr','mean_fr_ccorr','ccorr_peak','fr_dft_abs'}};
% which classifiers to run
modelTypes = {'logistic','linear_svm','svm','gda',};
% hyperparams for each classifier
hyperParams = {{'ridge',0.1},{'ridge',0.1},{'rbf'},{}};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% train classifiers

results = cell(length(tests),length(forward_search_order));
fold_inds_save = cell(length(tests),1);
for t = 1:length(tests)
    fprintf('test %d/%d\n',t,length(tests));
    eval(['class0_fnames = ' tests{t}{1} '_fnames;']);
    eval(['class1_fnames = ' tests{t}{2} '_fnames;']);
    m = length(class0_fnames) + length(class1_fnames);
    fold_inds = build_folds(m,m);    
    fold_inds_save{t} = fold_inds;

    for f = 1:length(forward_search_order)
        fprintf('\tforward search %d/%d\n',f,length(forward_search_order));
        feats = forward_search_order{f};
        [X, Y] = load_features(datafolder,{class0_fnames,class1_fnames},feats);

        single_run_results = batch_classifiers(X,Y,feats,fold_inds,modelTypes,hyperParams);
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

%% save results

if save_results
    save(fprintf('%s_classifier_results.mat',file_prefix),'results',...
        'fold_inds_save','train_acc','test_acc');
end

