% script to run baseline classifiers
% MGC 12/5/2017

%% params

% whether or not to make plots
make_plots = 0;

% whether or not to save results
save_results = 1;

% get data folder
get_data_folder;
% datafolder = strcat(datafolder,'FeatureMats/gain_decrease_and_gain_increase');
datafolder = strcat(datafolder,'FeatureMats/gain_decrease');
sessions = 'gain_decrease';

% get file names for all cell classes
get_fnames_gainmanip;

% comparisons to run
tests = {{'grid', 'border'}};
% features to use (forward search)
% forward_search_order = {{'cross_corr_gd'},{'cross_corr_gi'},{'cross_corr_gd','cross_corr_gi'}};
forward_search_order = {{'cross_corr'}};
% which classifiers to run
modelTypes = {'logistic','linear_svm','svm','gda'};
% hyperparams for each classifier
hyperParams = {{'ridge',0.1},{'ridge',0.1},{'rbf'},{}};

%% train classifiers

results = cell(length(tests),length(forward_search_order));
fold_inds_save = cell(length(tests),1);
for t = 1:length(tests)
    fprintf('test %d/%d\n',t,length(tests));
    eval(['class0_fnames = ' tests{t}{1} '_fnames;']);
    eval(['class1_fnames = ' tests{t}{2} '_fnames;']);
    m = length(class0_fnames) + length(class1_fnames);
    fold_inds = build_folds(m,m);

    fold_inds_vector = nan(size(fold_inds));
    for i = 1:size(fold_inds,1)
        fold_inds_vector(i) = fold_inds{i};
    end
    fold_inds_save{t} = fold_inds_vector;

    for f = 1:length(forward_search_order)
        fprintf('\tforward search %d/%d\n',f,length(forward_search_order));
        feats = forward_search_order{f}
        [X, Y] = load_features(datafolder,{class0_fnames,class1_fnames},feats);

        single_run_results = batch_run_cv(X,Y,feats,fold_inds,modelTypes,hyperParams);
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
    save(sprintf('baseline_classifier_%s_results.mat', sessions),'results','fold_inds','train_acc','test_acc')
end

%% make plots

if make_plots
    % Sanity check: look at correctly and incorrectly classified cells
    fold_inds_save = fold_inds_save{1};
    [~,sort_idx]=sort(fold_inds_save);
    true_label = nan(size(fold_inds_save));
    classifier_label = nan(size(fold_inds_save));
    for i = 1:size(fold_inds_save,1)
        true_label(i) = results{1,1}.svm.Y_test{i};
        classifier_label(i) = results{1,1}.svm.Y_hat_test{i};
    end
    true_label = true_label(sort_idx);
    classifier_label = classifier_label(sort_idx);
    for i = 1:size(fold_inds_save,1)
        h = figure('Visible','off');
        plot(1:2:399,X(i,1:200));
        title(sprintf('true label=%d, classifier label=%d',true_label(i),classifier_label(i)));
        saveas(h,sprintf('sanity_check_plots/%d.png',i),'png')
    end
end
