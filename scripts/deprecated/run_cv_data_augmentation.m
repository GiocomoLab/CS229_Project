%  run K fold cross-validation for data augmentation,
%   ***augmented data from a given test cell is not included in the training
%   set***
% 
%  INPUTS:
%   Xtrain - augmented feature matrices of entire data set (samples x features)
%   Xtest - original data from all cells
%   Ytrain - sample labels for augmented data (samples x 1) 
%   fold_inds - cell array, each cell contains indices of fold
%   model_type - string indicating which model to run
%   hyperparameters - cell array containing regularization types and strengths
%  OUTPUTS:
%   Y_train_folds - true class labels training data for each fold
%   Y_test_folds - true class labels fors test data for each fold
%   Y_hat_train_folds - predicted class labels on training data for each fold
%   Y_hat_test_folds - predicted class labels on test data for each fold
%   theta - model parameters for linear models
%   model_output - value of hypothesis function


function [Y_train_folds,Y_test_folds,Y_hat_train_folds,Y_hat_test_folds,theta,model_output] = cross_val_dataug...
    (Xtrain,Ytrain,Xtest,Ytest,fold_inds,model_type,hyperparameters)   

% number of data augmentations
rotation_offset = 10;
num_aug = size(Xtrain,2)/rotation_offset; % rotations

% outputs with entries for each fold
k = length(fold_inds); 
Y_hat_train_folds = cell(k,1);
Y_hat_test_folds = cell(k,1);
Y_train_folds = cell(k,1);
Y_test_folds = cell(k,1);
theta = cell(k,1);

% iterate over folds
for fold = 1:k
    if mod(fold,10)==1
     fprintf('.');
    end

    inds_test = fold_inds{fold}; 
    if fold ==1
     inds_train = cell2mat(fold_inds(2:end));
    elseif fold == k
     inds_train = cell2mat(fold_inds(1:fold-1));
    else
     inds_train = cell2mat(fold_inds([1:fold-1 fold+1:end]));
    end
    inds_train = (repmat(inds_train,1,num_aug)-1).*repmat(num_aug,numel(inds_train),num_aug)+...
        repmat(1:num_aug,numel(inds_train),1);
    inds_train = reshape(inds_train',numel(inds_train),1);
    
    % define train and test sets for this fold
    X_train_fold = Xtrain(inds_train,:); 
    Y_train_folds{fold} = Ytrain(inds_train);
    X_test_fold = Xtest(inds_test,:);
    Y_test_folds{fold} = Ytest(inds_test);
     
    % build classifier objects, train, and test
    model_output = nan;
    switch model_type
        case 'linear_svm' % linear SVM, can change regularization strength
            mdl = fitclinear(X_train_fold,Y_train_folds{fold},'Regularization',...
                hyperparameters{1},'Lambda',hyperparameters{2},...
                'Learner','svm');
            Y_hat_train_folds{fold} = predict(mdl,X_train_fold);
            Y_hat_test_folds{fold} = predict(mdl,X_test_fold);
            theta{fold} = mdl.Beta;
        case 'logistic' % regularized logistic regression
            mdl = fitclinear(X_train_fold,Y_train_folds{fold},'Regularization',...
                hyperparameters{1},'Lambda',hyperparameters{2},...
                'Learner','logistic');
            Y_hat_train_folds{fold} = predict(mdl,X_train_fold);
            Y_hat_test_folds{fold} = predict(mdl,X_test_fold);
            model_output = 1/(1+exp(-(X_test_fold * mdl.Beta + mdl.Bias)));
            theta{fold} = mdl.Beta;
        case 'svm' % kernel svm
            mdl = fitcsvm(X_train_fold,Y_train_folds{fold},'KernelFunction',...
                hyperparameters{1},'KernelScale','auto');
            Y_hat_train_folds{fold} = predict(mdl,X_train_fold);
            Y_hat_test_folds{fold} = predict(mdl,X_test_fold);
        case 'gda' % gaussian discriminant analysis
            mdl = fitcdiscr(X_train_fold,Y_train_folds{fold});
            Y_hat_train_folds{fold} = predict(mdl,X_train_fold);
            Y_hat_test_folds{fold} = predict(mdl,X_test_fold);           
        case 'qda' % quadratic discriminant analysis
            mdl = fitcdiscr(X_train_fold,Y_train_folds{fold},'DiscrimType','quadratic');
            Y_hat_train_folds{fold} = predict(mdl,X_train_fold);
            Y_hat_test_folds{fold} = predict(mdl,X_test_fold);            
        case 'mc_linear_svm' % multiclass linear svm
            t = templateLinear('Learner','svm',....
                'Regularization',hyperparameters{1},'Lambda',hyperparameters{2});           
            mdl = fitcecoc(X_train_fold,Y_train_folds{fold},'Learners',t);
            Y_hat_train_folds{fold} = predict(mdl,X_train_fold);
            Y_hat_test_folds{fold} = predict(mdl,X_test_fold);
            theta{fold} = mdl.Beta;            
        case 'mc_svm' % multiclass kernel svm
            t = templateSVM('Standardize',1,'KernelFunction',hyperparameters{1},...
                'KernelScale','auto');
            mdl = fitcecoc(X_train_fold,Y_train_folds{fold},'Learners',t);            
            Y_hat_train_folds{fold} = predict(mdl,X_train_fold);
            Y_hat_test_folds{fold} = predict(mdl,X_test_fold);           
        case 'softmax' % only model that does not fit the intercept separately            
            B = mnrfit([ones(size(X_train_fold,1),1) X_train_fold],Y_train_folds{fold}+1);
            p_hat_train = mnrval(B,X_train_fold);
            [~,Y_hat_train_folds{fold}] = max(p_hat_train,[],2);
            Y_hat_train_folds{fold} = Y_hat_train_folds{fold}-1;
            p_hat_test = mnrval(B,[ones(size(X_test_fold,1),1) X_test_fold]);
            [~,Y_hat_test_folds{fold}] = max(p_hat_test,[],2);
            Y_hat_test_folds{fold} = Y_hat_test_folds{fold}-1;            
    end    
end 

end

