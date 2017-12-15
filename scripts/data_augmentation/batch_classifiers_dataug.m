%%% loop over model types and hyperparameter sets and run cross validation
%   ***augmented data from a given test cell is not included in the training
%   set***
% 
%  INPUTS:
%   Xtrain - augmented feature matrices of entire data set (samples x features)
%   Xtest - original data from all cells
%   Ytrain - sample labels for augmented data (samples x 1) 
%   fold_inds - cell array with indices of each fold
%   modelTypes - cell array of models to test
%   hyperParams - cell array with values of regularization parameters
%  OUTPUTS:
%   results - cellarray of structures containing all output from cross_val

function results = batch_classifiers_dataug(Xtrain,Ytrain,Xtest,Ytest,fold_inds,modelTypes,hyperParams)

% for each model to test
for i = 1:length(modelTypes)

    fprintf('\t\tmodel type %d/%d\n\t\t\tfolds (x10): ',i,length(modelTypes));
    
    % run model
    [Y_train_folds,Y_test_folds,Y_hat_train_folds,Y_hat_test_folds,theta] = ...
        cross_val_dataug(Xtrain,Ytrain,Xtest,Ytest,...
        fold_inds,modelTypes{i},hyperParams{i});
    fprintf('\n');
    % save results
    eval(['results.' modelTypes{i} '.Y_train = Y_train_folds;']);
    eval(['results.' modelTypes{i} '.Y_test = Y_test_folds;']);
    eval(['results.' modelTypes{i} '.Y_hat_train = Y_hat_train_folds;']);
    eval(['results.' modelTypes{i} '.Y_hat_test = Y_hat_test_folds;']);
    eval(['results.' modelTypes{i} '.theta = theta;']);
    eval(['results.' modelTypes{i} '.hyperparams = hyperParams{i};']);
    
    % get confusion matrices 
    cmat_train = confusionmat(cell2mat(Y_train_folds),cell2mat(Y_hat_train_folds));
    cmat_test = confusionmat(cell2mat(Y_test_folds),cell2mat(Y_hat_test_folds));
    eval(['results.' modelTypes{i} '.cmat_train = cmat_train;']);
    eval(['results.' modelTypes{i} '.cmat_test = cmat_test;']);
    
    
end