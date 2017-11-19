% 

function [Y_train,Y_test,Y_hat_train,Y_hat_test,theta] = run_cv(X,Y,fold_inds,model_type,hyperparameters)
   

% for each fold
k = length(fold_inds);  
Y_hat_train = cell(k,1); Y_hat_test = cell(k,1);
Y_train = cell(k,1); Y_test = cell(k,1);
theta = cell(k,1);
for fold = 1:k
     fold_bool = zeros(k,1); fold_bool(k) = 1; fold_bool = logical(fold_bool);
     X_train = X(cell2mat(fold_inds(~fold_bool)),:); 
     Y_train{fold} = Y(cell2mat(fold_inds(~fold_bool)),:);
     
     X_test = X(cell2mat(fold_inds(fold_bool)),:);
     Y_test{fold} = Y(cell2mat(fold_inds(fold_bool)),:);

    % build classifier based on inputs
%    and test classifiers
    switch model_type
        case 'linear_svm'
            mdl = fitclinear(X_train,Y_train{fold},'Regularization',...
                hyperparameters{1},'Lambda',hyperparameters{2},...
                'Learner','svm');
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
            theta{fold} = mdl.Beta;
        case 'logistic'
            mdl = fitclinear(X_train,Y_train{fold},'Regularization',...
                hyperparameters{1},'Lambda',hyperparameters{2},...
                'Learner','svm');
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
            theta{fold} = mdl.Beta;
        case 'svm'
            mdl = fitcsvm(X_train,Y_train{fold},'KernelFunction',...
                hyperparameters{1});
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
    end
             
    
end 


end