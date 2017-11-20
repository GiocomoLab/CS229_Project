%%% loop over model types and hyperparameter sets and run cross validation
function results = batch_run_cv(X,Y,feats,fold_inds,modelTypes,hyperParams)


for i = 1:length(modelTypes)

    [Y_train,Y_test,Y_hat_train,Y_hat_test,theta] = run_cv(X,Y,fold_inds,...
        modelTypes{i},hyperParams{i});
    eval(['results.' modelTypes{i} '.Y_train = Y_train;']);
    eval(['results.' modelTypes{i} '.Y_test = Y_test;']);
    eval(['results.' modelTypes{i} '.Y_hat_train = Y_hat_train;']);
    eval(['results.' modelTypes{i} '.Y_hat_test = Y_hat_test;']);
    eval(['results.' modelTypes{i} '.theta = theta;']);

%     size(cell2mat(Y_test))
%     Y_hat_test
    
    cmat_train = confusionmat(cell2mat(Y_train),cell2mat(Y_hat_train));
    cmat_test = confusionmat(cell2mat(Y_test),cell2mat(Y_hat_test));
    eval(['results.' modelTypes{i} '.cmat_train = cmat_train;']);
    eval(['results.' modelTypes{i} '.cmat_test = cmat_test;']);
    
    results.feats = feats;
    
end