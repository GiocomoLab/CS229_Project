%  run K fold cross-validation
%  INPUTS:
%   X - feature matrices of entire data set (samples x features)
%   Y - sample labels (samples x 1) 
%   fold_inds - cell array, each cell contains indices of fold
%   model_type - string indicating which model to run
%   hyperparameters - cell array containing regularization types and strengths

function [Y_train,Y_test,Y_hat_train,Y_hat_test,theta,model_output] = cross_val(X,Y,fold_inds,model_type,hyperparameters)
   
% allocate space
k = length(fold_inds); 
Y_hat_train = cell(k,1); Y_hat_test = cell(k,1);
Y_train = cell(k,1); Y_test = cell(k,1);
theta = cell(k,1);

%  for each fold of cross-validation
for fold = 1:k
%     print every 10 folds
     if mod(fold,10)==1 
         fprintf('.');
     end

     % use fold indices to set training and test sets
     inds_test = fold_inds{fold}; 
     if fold ==1
         inds_train = cell2mat(fold_inds(2:end));
     elseif fold == k
         inds_train = cell2mat(fold_inds(1:fold-1));
     else
         inds_train = cell2mat(fold_inds([1:fold-1 fold+1:end]));
     end
     
     % training data
     X_train = X(inds_train,:); 
     Y_train{fold} = Y(inds_train);
     
     % test data
     X_test = X(inds_test,:);
     Y_test{fold} = Y(inds_test);
    
        
    % build classifier objects, train, and test
    model_output = nan;
    switch model_type
        case 'linear_svm' % linear svm
            mdl = fitclinear(X_train,Y_train{fold},'Regularization',...
                hyperparameters{1},'Lambda',hyperparameters{2},...
                'Learner','svm');
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
            theta{fold} = mdl.Beta;
        case 'logistic' % regularized (flexible penalty) logistic regression 
            mdl = fitclinear(X_train,Y_train{fold},'Regularization',...
                hyperparameters{1},'Lambda',hyperparameters{2},...
                'Learner','logistic');
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
            model_output = 1/(1+exp(-(X_test * mdl.Beta + mdl.Bias)));
            theta{fold} = mdl.Beta;
        case 'svm' % kernel svm
            mdl = fitcsvm(X_train,Y_train{fold},'KernelFunction',...
                hyperparameters{1},'KernelScale','auto');
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
        case 'gda' % Gaussian discriminant analysis
            mdl = fitcdiscr(X_train,Y_train{fold});
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
            
        case 'qda' % quadratic discriminant analysis
            mdl = fitcdiscr(X_train,Y_train{fold},'DiscrimType','quadratic');
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
            
        case 'mc_linear_svm' % multi class svm
            t = templateLinear('Learner','svm',....
                'Regularization',hyperparameters{1},'Lambda',hyperparameters{2});
            
            mdl = fitcecoc(X_train,Y_train{fold},'Learners',t);
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
            
        case 'mc_svm' % multi class kernel svm
            t = templateSVM('Standardize',1,'KernelFunction',hyperparameters{1},...
                'KernelScale','auto');
            mdl = fitcecoc(X_train,Y_train{fold},'Learners',t);
            
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
            
           
        case 'softmax' % run softmax regression
            %only model that does not fit the intercept separately
            
            B = mnrfit([ones(size(X_train,1),1) X_train],Y_train{fold}+1);
            p_hat_train = mnrval(B,X_train);
            [~,Y_hat_train{fold}] = max(p_hat_train,[],2);
            Y_hat_train{fold} = Y_hat_train{fold}-1;
            p_hat_test = mnrval(B,[ones(size(X_test,1),1) X_test]);
            [~,Y_hat_test{fold}] = max(p_hat_test,[],2);
            Y_hat_test{fold} = Y_hat_test{fold}-1;
            
            
    end
             
    
end 


end


