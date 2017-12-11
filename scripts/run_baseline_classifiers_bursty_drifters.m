% script to run baseline classifiers
% on "bursty drifting spatial cells"
% MGC 12/10/2017

%% params

% get data
feats = readtable('labeled_dataset_large.xlsx');
X = table2array(feats(:,[3:6 8:10]));
Y = 1*(table2array(feats(:,11))>0);

% which classifiers to run
modelTypes = {'logistic','linear_svm','svm'};
% hyperparams for each classifier
hyperParams = {{'ridge',0.1},{'ridge',0.1},{'rbf'}};

%% train classifiers
m = size(X,1);
fold_inds = build_folds(m,m);
results = batch_run_cv(X,Y,[],fold_inds,modelTypes,hyperParams);

%% evaluate classifiers

% training and test accuracy
train_acc = nan(1,3);
test_acc = nan(1,3);

% logistic
cmat_train = results.logistic.cmat_train;
cmat_test = results.logistic.cmat_test;
train_acc(1) = sum(diag(cmat_train))/sum(sum(cmat_train));
test_acc(1) = sum(diag(cmat_test))/sum(sum(cmat_test));

% linear svm
cmat_train = results.linear_svm.cmat_train;
cmat_test = results.linear_svm.cmat_test;
train_acc(2) = sum(diag(cmat_train))/sum(sum(cmat_train));
test_acc(2) = sum(diag(cmat_test))/sum(sum(cmat_test));

% svm
cmat_train = results.svm.cmat_train;
cmat_test = results.svm.cmat_test;
train_acc(3) = sum(diag(cmat_train))/sum(sum(cmat_train));
test_acc(3) = sum(diag(cmat_test))/sum(sum(cmat_test));