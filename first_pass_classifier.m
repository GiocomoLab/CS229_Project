%% First pass grid cell classifier
% Mark Plitt - 11/15/17

% Trying balanced classes first


%% preliminaries

mp_prefix = '~/Dropbox/Malcolms_VR_Data/FeatureMats';
mc_prefix = '/Users/malcolmcampbell/Dropbox/Work/Malcolms_VR_data/FeatureMats';
if (exist(mc_prefix,'dir')>0)
    datafolder = mc_prefix;
elseif (exist(mp_prefix,'dir')>0)
    datafolder = mp_prefix;
end

% Get all grid cells  
load(fullfile(datafolder,'params.mat')); % includes cell array with filenames of grid cells

% Take a random subset of non-grid cells to match prevelance
% use fixed random seed for debugging
rng('default'); 

% get non-grid filenames
files = dir(fullfile(datafolder,'FeatStruct_*.mat'));
files = {files(:).name}';
grid_inds = zeros(size(files));
ngrids = length(grid_fnames);
for g = 1:length(grid_fnames)
    grid_inds = grid_inds + strcmp(files,grid_fnames{g});
end
nongrid_fnames = files(~grid_inds);
% downsample
nongrid_fnames_ds = nongrid_fnames(randperm(length(nongrid_fnames),ngrids));
% 


%% Cross Validation folds


%% load data

% load feature structures and concatenate into design matrix
X = []; Y = []; feats = {'fr','mean_fr_ccorr','ccorr_peak','fr_dft_abs'};

for i = 1:ngrids
    X = [X; load_features(fullfile(datafolder,grid_fnames{i}),feats)];
    Y = [Y;1];
    
    X = [X; load_features(fullfile(datafolder,nongrid_fnames{i}),feats)];
    Y = [Y;0];
        
end




%% train and test
fold_inds = build_folds(size(X,1),10); % LOO cross-validation
modelTypes = {'linear_svm','logistic', 'svm'};
hyperParams = {{'ridge',1e4},{'ridge',1e4},{'rbf'}};

for i = 1:length(modelTypes)

    [Y_train,Y_test,Y_hat_train,Y_hat_test,theta] = run_cv(X,Y,fold_inds,...
        modelTypes{i},hyperParams{i});
    eval(['results.' modelTypes{i} '.Y_train = Y_train;']);
    eval(['results.' modelTypes{i} '.Y_test = Y_test;']);
    eval(['results.' modelTypes{i} '.Y_hat_train = Y_hat_train;']);
    eval(['results.' modelTypes{i} '.Y_hat_test = Y_hat_test;']);
    
    cmat_train = confusionmat(cell2mat(Y_train),cell2mat(Y_hat_train));
    cmat_test = confusionmat(cell2mat(Y_test),cell2mat(Y_hat_test));
    eval(['results.' modelTypes{i} '.cmat_train = cmat_train;']);
    eval(['results.' modelTypes{i} '.cmat_test = cmat_test;']);
    
end


%% helper functions

function x = load_features(fname, feats)

if isempty(feats)
    feats = {'fr','mean_fr_ccorr','ccorr_peak','fr_dft_abs'};
end

load(fname);
x=[];

if sum(strcmp(feats,'fr'))>0
    fr = featStruct.firing_rate;
    fr = (fr-min(fr))/max(fr);
    x = [x fr];
end

if sum(strcmp(feats,'mean_fr_ccorr'))>0
    x = [x featStruct.mean_fr_ccorr];
end

if sum(strcmp(feats,'ccorr_peak'))>0
    x = [x featStruct.max_lag];
end

if sum(strcmp(feats,'fr_dft_abs'))>0
    fr = featStruct.firing_rate;
    x = [x abs(fft(fr))];
end

end

function fold_inds = build_folds(N,k)

%Make Folds for k-fold cross-validation
order = randperm(N);
% fill folds so that they are similar size
fold_inds = cell(k,1);
counter = 0;
while ~isempty(order)
    i = mod(counter,k)+1;
    fold_inds{i} = [fold_inds{i}; order(1)];
    order(1) = [];
    counter = counter+1;
end

end

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

