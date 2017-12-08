%%% loop over model types and hyperparameter sets and run cross validation
function results = batch_run_cv_data_augmentation(Xtrain,Ytrain,Xtest,Ytest,feats,fold_inds,modelTypes,hyperParams)

for i = 1:length(modelTypes)

    fprintf('\t\tmodel type %d/%d\n\t\t\tfolds (x10): ',i,length(modelTypes));
    %%%%% still neeed to edit run_cv to take these arguments
    %%%% Xtrain is 2*200*numcells x 200 
    %%% can use fold_inds and this info to grab the correct rows from
    %%% Xtrain and Xtest as well as Ytrain and Ytest
    [Y_train_folds,Y_test_folds,Y_hat_train_folds,Y_hat_test_folds,theta] = ...
        run_cv_data_augmentation(Xtrain,Ytrain,Xtest,Ytest,...
        fold_inds,modelTypes{i},hyperParams{i});
    fprintf('\n');
    eval(['results.' modelTypes{i} '.Y_train = Y_train_folds;']);
    eval(['results.' modelTypes{i} '.Y_test = Y_test_folds;']);
    eval(['results.' modelTypes{i} '.Y_hat_train = Y_hat_train_folds;']);
    eval(['results.' modelTypes{i} '.Y_hat_test = Y_hat_test_folds;']);
    eval(['results.' modelTypes{i} '.theta = theta;']);
    eval(['results.' modelTypes{i} '.hyperparams = hyperParams{i};']);

    cmat_train = confusionmat(cell2mat(Y_train_folds),cell2mat(Y_hat_train_folds));
    cmat_test = confusionmat(cell2mat(Y_test_folds),cell2mat(Y_hat_test_folds));
    eval(['results.' modelTypes{i} '.cmat_train = cmat_train;']);
    eval(['results.' modelTypes{i} '.cmat_test = cmat_test;']);
    
    results.feats = feats;
    
end