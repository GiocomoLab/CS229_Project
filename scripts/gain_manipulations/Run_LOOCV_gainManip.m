% script to run baseline classifiers


%% params
addpath ../


% get data folder
get_data_folder;

%%%%%%%% edit the variables below to control which models and cell groups
%%%%%%%% are tested %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sessions = 'gain_decrease';
datafolder = strcat(datafolder,'FeatureMats/',sessions);

% get file names for all cell classes
get_fnames_gainmanip;

% comparisons to run
tests = {{'grid', 'border'}};
% features to use (forward search)
forward_search_order = {{'cross_corr'}};
% which classifiers to run
modelTypes = {'logistic','linear_svm','svm','gda'};
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
    fold_inds_save{t} = fold_inds{t};

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
        % calculate accuracy from confusion matrices
        
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

