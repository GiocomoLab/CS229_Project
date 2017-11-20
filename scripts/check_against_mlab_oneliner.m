get_data_folder;

% Get all grid cells  
load(fullfile(datafolder,'params.mat')); % includes cell array with filenames of grid cells

% Take a random subset of non-grid cells to match prevelance
% use fixed random seed for debugging
rng('default'); 

get_fnames;


% comparisons to run
tests = {{'gb','nongb'},{'grid','nongrid'},{'border','nonborder'}};
% forward search order
forward_search_order = {{'fr'},{'fr','fr_dft_abs'}, {'fr','fr_dft_abs','ccorr_peak'},....
    {'fr','mean_fr_ccorr','ccorr_peak','fr_dft_abs'}};
% which classifiers to run
modelTypes = {'svm'} ; %{'linear_svm','logistic', 'svm'};
% hyperparams for each calssifier
hyperParams = {{'rbf'}}; %{{'ridge',1e4},{'ridge',1e4},{'rbf'}};
results_mlabfunc = cell(length(tests),length(forward_search_order));
for t = 1:length(tests)
    eval(['class0_fnames = ' tests{t}{1} '_fnames;']);
    eval(['class1_fnames = ' tests{t}{2} '_fnames_ds;']);
    m = length(class0_fnames) + length(class1_fnames);
    fold_inds = build_folds(m,m);
    t
    for f = 1:length(forward_search_order)
        feats = forward_search_order{f};
        [X, Y] = load_features(datafolder,{class0_fnames,class1_fnames},feats);
        
        mdl = fitcsvm(X,Y,'KernelFunction','rbf','KernelScale','auto',...
            'Standardize',true);
        cv_mdl = crossval(mdl,'KFold',m);
        [Y_hat,score] = kfoldPredict(cv_mdl);
        c_mat = confusionmat(Y,Y_hat);
        results_mlabfunc{t,f} = c_mat;
    end
end
        