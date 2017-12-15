%%% loop over model types and hyperparameter sets and run cross validation
% INPUTS:
%   X - feature matrices (samples x feature)
%   Y - class labels
%   fold_inds - cell array with indices of each fold
%   modelTypes - cell array of models to test
%   hyperParams - cell array with values of regularization parameters

%  OUTPUTS:
%   results - cellarray of structures containing all output from cross_val

function results = batch_classifiers(X,Y,feats,fold_inds,modelTypes,hyperParams)


for i = 1:length(modelTypes)

    fprintf('\t\tmodel type %d/%d\n\t\t\tfolds (x10): ',i,length(modelTypes));
    [Y_train,Y_test,Y_hat_train,Y_hat_test,theta] = cross_val(X,Y,fold_inds,...
        modelTypes{i},hyperParams{i});
    fprintf('\n');
    eval(['results.' modelTypes{i} '.Y_train = Y_train;']);
    eval(['results.' modelTypes{i} '.Y_test = Y_test;']);
    eval(['results.' modelTypes{i} '.Y_hat_train = Y_hat_train;']);
    eval(['results.' modelTypes{i} '.Y_hat_test = Y_hat_test;']);
    eval(['results.' modelTypes{i} '.theta = theta;']);
    eval(['results.' modelTypes{i} '.hyperparams = hyperParams{i};']);

    % save confusion matrices for each classification
    cmat_train = confusionmat(cell2mat(Y_train),cell2mat(Y_hat_train));
    cmat_test = confusionmat(cell2mat(Y_test),cell2mat(Y_hat_test));
    eval(['results.' modelTypes{i} '.cmat_train = cmat_train;']);
    eval(['results.' modelTypes{i} '.cmat_test = cmat_test;']);
    
    results.feats = feats;
    
end