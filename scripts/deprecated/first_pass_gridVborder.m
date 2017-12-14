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
ngrids = length(grid_fnames); nborders = length(border_fnames);
% Take a random subset of non-grid cells to match prevelance
% use fixed random seed for debugging
rng('default'); 

%% load data

% load feature structures and concatenate into design matrix
X = []; Y = []; feats = {'mean_fr_ccorr','ccorr_peak'};

for i = 1:ngrids
    X = [X; load_features(fullfile(datafolder,grid_fnames{i}),feats)];
    Y = [Y;1];
end

for i = 1:nborders
    X = [X; load_features(fullfile(datafolder,border_fnames{i}),feats)];
    Y = [Y;0];
        
end


%% train and test

cvsvm = fitclinear(X,Y,'Kfold',ngrids+nborders,'Regularization','ridge','Lambda',1e3,...
            'Learner','svm');
Yhat = kfoldPredict(cvsvm);
confusionmat(Y,Yhat)
accuracy = mean(Y==Yhat);

% % for each fold
% train_acc = zeros(k,1); test_acc = zeros(k,1);
% for fold = 1:k
%      fold_bool = zeros(k,1); fold_bool(k) = 1; fold_bool = bool(fold_bool);
%      X_train = X(cell2mat(fold_inds(~fold_bool)),:); 
%      Y_train = Y(cell2mat(fold_inds(~fold_bool)),:);
%      
%      X_test = X(cell2mat(fold_inds(fold_bool)),:);
%      Y_test = Y(cell2mat(fold_inds(fold_bool)),:);
% 
%     % set hyperparameters
%      lambda = 1e3;
% 
%     % train classifier 
%     %  function call with switch case statement that includes different stuff
%     % for now just implementing ridge logistic regression
%     
%     
% end 

% get training error

%  test classifier 
%  save test error

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

function h = fit_model(train_data,model_type,hyperparameters)


end

