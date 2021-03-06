% 

function [Y_train,Y_test,Y_hat_train,Y_hat_test,theta,model_output] = run_cv(X,Y,fold_inds,model_type,hyperparameters)
   

% for each fold
k = length(fold_inds); 
Y_hat_train = cell(k,1); Y_hat_test = cell(k,1);
Y_train = cell(k,1); Y_test = cell(k,1);
theta = cell(k,1);
for fold = 1:k
     if mod(fold,10)==1
         fprintf('.');
     end
%      fold_bool = zeros(k,1); fold_bool(k) = 1; fold_bool = logical(fold_bool);
     inds_test = fold_inds{fold}; 
     if fold ==1
         inds_train = cell2mat(fold_inds(2:end));
     elseif fold == k
         inds_train = cell2mat(fold_inds(1:fold-1));
     else
         inds_train = cell2mat(fold_inds([1:fold-1 fold+1:end]));
     end
     
     X_train = X(inds_train,:); 
%      mu = mean(X_train,1);
%      sigma = std(X_train,[],1);
%      X_train = (X_train-repmat(mu,[size(X_train,1),1]))./repmat(sigma,[size(X_train,1),1]);
     Y_train{fold} = Y(inds_train);
     
     X_test = X(inds_test,:);
%      X_test = X_test-repmat(mu,[size(X_test,1),1])./repmat(sigma,[size(X_test,1),1]);
     
     Y_test{fold} = Y(inds_test);
    
        
    % build classifier based on inputs
%    and test classifiers
    model_output = nan;
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
                'Learner','logistic');
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
            model_output = 1/(1+exp(-(X_test * mdl.Beta + mdl.Bias)));
            theta{fold} = mdl.Beta;
        case 'svm'
            mdl = fitcsvm(X_train,Y_train{fold},'KernelFunction',...
                hyperparameters{1},'KernelScale','auto');
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
        case 'gda'
            mdl = fitcdiscr(X_train,Y_train{fold});
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
            
        case 'qda'
            mdl = fitcdiscr(X_train,Y_train{fold},'DiscrimType','quadratic');
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
            
        case 'mc_linear_svm'
            t = templateLinear('Learner','svm',....
                'Regularization',hyperparameters{1},'Lambda',hyperparameters{2});
            
            mdl = fitcecoc(X_train,Y_train{fold},'Learners',t);
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
%             theta{fold} = mdl.Beta;
            
        case 'mc_svm'
            t = templateSVM('Standardize',1,'KernelFunction',hyperparameters{1},...
                'KernelScale','auto');
            mdl = fitcecoc(X_train,Y_train{fold},'Learners',t);
            
            Y_hat_train{fold} = predict(mdl,X_train);
            Y_hat_test{fold} = predict(mdl,X_test);
            
           
        case 'softmax' % only model that does not fit the intercept separately
            
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


function T = Y2T(Y)

numClasses = max(Y);

T = zeros(numClasses,length(Y));
for c = 1:numClasses
    T(c,:) = double(Y==c);
end
end

function Y = T2Y(T)

numClasses = size(T,1);
dummyY = [];
for c = 1:numClasses
    dummyY = [dummyY; (c-1)*ones(size(T,2),1)];
end

Y = squeeze(dummyY(logical(T)))';
end

