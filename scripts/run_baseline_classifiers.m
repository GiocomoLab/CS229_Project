

get_data_folder;

% Get all grid cells  
load(fullfile(datafolder,'params.mat')); % includes cell array with filenames of grid cells

% Take a random subset of non-grid cells to match prevelance
% use fixed random seed for debugging
rng('default'); 

<<<<<<< HEAD
get_fnames;
=======
% get all files names
files = dir(fullfile(datafolder,'FeatStruct_*.mat'));
files = {files(:).name}';

% find grid cells
grid_inds = zeros(size(files));
ngrids = length(grid_fnames);
for g = 1:length(grid_fnames)
    grid_inds = grid_inds + strcmp(files,grid_fnames{g});
end

% find border cells
border_inds = zeros(size(files));
nborders = length(border_fnames);
for b = 1:length(border_fnames)
    border_inds = border_inds + strcmp(files,border_fnames{b});
end

% get unique IDs
uniqueID_grid = cell(numel(grid_fnames),1);
for i = 1:numel(grid_fnames)
    split = strsplit(grid_fnames{i},'_');
    uniqueID_grid{i} = split{2};
end
uniqueID_border = cell(numel(border_fnames),1);
for i = 1:numel(border_fnames)
    split = strsplit(border_fnames{i},'_');
    uniqueID_border{i} = split{2};
end
uniqueID_all = cell(numel(files),1);
for i = 1:numel(files)
    split = strsplit(files{i},'_');
    uniqueID_all{i} = split{2};
end


% non grid cells
nongrid_fnames = files(~endsWith(uniqueID_all,uniqueID_grid));

% non border cells 
nonborder_fnames = files(~endsWith(uniqueID_all,uniqueID_border));

% get all grid | border cells
gb_inds = logical(grid_inds+border_inds);
gb_fnames = files(gb_inds);

% non grid | border cells
nongb_fnames = files(~endsWith(uniqueID_all,uniqueID_grid) & ~endsWith(uniqueID_all,uniqueID_border));

% downsample non-functional cell types

nongrid_fnames_ds = nongrid_fnames(randperm(length(nongrid_fnames),length(grid_fnames)));
nonborder_fnames_ds = nonborder_fnames(randperm(length(nonborder_fnames),length(border_fnames)));
nongb_fnames_ds = nongb_fnames(randperm(length(nongb_fnames),length(gb_fnames)));

>>>>>>> MalcolmBranch

% comparisons to run
tests = {{'grid','nongrid'}};
% forward search order
<<<<<<< HEAD
forward_search_order = {{'mean_fr','fr_dft_abs'},...
    {'mean_fr','fr','fr_dft_abs'},{'mean_fr','mean_fr_ccorr','ccorr_peak','fr_dft_abs'},...
    {'mean_fr','fr','fr_dft_abs','ccorr_peak','fr_dft_abs'}};
% which classifiers to run
modelTypes = {'linear_svm','logistic', 'svm','gda'};
% hyperparams for each calssifier
hyperParams = {{'ridge',1e4},{'ridge',1e4},{'rbf'},{},{}};
=======
% forward_search_order = {{'fr'},{'fr','fr_dft_abs'}, {'fr','fr_dft_abs','ccorr_peak'},....
%    {'fr','fr_dft_abs','ccorr_peak','mean_fr_ccorr'}};
forward_search_order = {{'fr','fr_dft_abs'}};
% which classifiers to run
% modelTypes = {'linear_svm','logistic', 'svm'};
modelTypes = {'svm'};
% hyperparams for each classifier
%hyperParams = {{'ridge',1e4},{'ridge',1e4},{'rbf'}};
hyperParams = {{'rbf'}};
>>>>>>> MalcolmBranch
results = cell(length(tests),length(forward_search_order));
fold_inds_save = cell(length(tests),1);
for t = 1:length(tests)
    eval(['class0_fnames = ' tests{t}{1} '_fnames;']);
    eval(['class1_fnames = ' tests{t}{2} '_fnames_ds;']);
    m = length(class0_fnames) + length(class1_fnames);
    fold_inds = build_folds(m,m);
    
    fold_inds_vector = nan(size(fold_inds));
    for i = 1:size(fold_inds,1)
        fold_inds_vector(i) = fold_inds{i};
    end
    fold_inds_save{t} = fold_inds_vector;
    
    for f = 1:length(forward_search_order)
        feats = forward_search_order{f};
        [X, Y] = load_features(datafolder,{class0_fnames,class1_fnames},feats);
        
        single_run_results = batch_run_cv(X,Y,feats,fold_inds,modelTypes,hyperParams);
        single_run_results.groups = tests{t};
        
        results{t,f} = single_run_results;
        
        
    end
    
end

<<<<<<< HEAD
train_acc = zeros(3,5,5); test_acc = zeros(3,5,5);
for i =  1:length(tests)
    for j = 1:length(forward_search_order)
        cmat_train = results{i,j}.logistic.cmat_train;
        cmat_test = results{i,j}.logistic.cmat_test;
        
        train_acc(i,j,1) = sum(diag(cmat_train))/sum(sum(cmat_train));
        test_acc(i,j,1) = sum(diag(cmat_test))/sum(sum(cmat_test));
            
        
        cmat_train = results{i,j}.linear_svm.cmat_train;
        cmat_test = results{i,j}.linear_svm.cmat_test;
        
        train_acc(i,j,2) = sum(diag(cmat_train))/sum(sum(cmat_train));
        test_acc(i,j,2) = sum(diag(cmat_test))/sum(sum(cmat_test));

        
        cmat_train = results{i,j}.svm.cmat_train;
        cmat_test = results{i,j}.svm.cmat_test;
        
        train_acc(i,j,3) = sum(diag(cmat_train))/sum(sum(cmat_train));
        test_acc(i,j,3) = sum(diag(cmat_test))/sum(sum(cmat_test));
        
        cmat_train = results{i,j}.gda.cmat_train;
        cmat_test = results{i,j}.gda.cmat_test;
        
        train_acc(i,j,4) = sum(diag(cmat_train))/sum(sum(cmat_train));
        test_acc(i,j,4) = sum(diag(cmat_test))/sum(sum(cmat_test));
        
%         cmat_train = results{i,j}.qda.cmat_train;
%         cmat_test = results{i,j}.qda.cmat_test;
%         
%         train_acc(i,j,5) = sum(diag(cmat_train))/sum(sum(cmat_train));
%         test_acc(i,j,5) = sum(diag(cmat_test))/sum(sum(cmat_test));
    end
end

save baseline_classifier_results.mat results fold_inds train_acc test_acc
=======


% Sanity check: look at correctly and incorrectly classified cells
fold_inds_save = fold_inds_save{1};
[~,sort_idx]=sort(fold_inds_save);
true_label = nan(size(fold_inds_save));
classifier_label = nan(size(fold_inds_save));
for i = 1:size(fold_inds_save,1)
    true_label(i) = results{1,1}.svm.Y_test{i};
    classifier_label(i) = results{1,1}.svm.Y_hat_test{i};
end
true_label = true_label(sort_idx);
classifier_label = classifier_label(sort_idx);
for i = 1:size(fold_inds_save,1)
    h = figure('Visible','off');
    plot(1:2:399,X(i,1:200));
    title(sprintf('true label=%d, classifier label=%d',true_label(i),classifier_label(i)));
    saveas(h,sprintf('sanity_check_plots/%d.png',i),'png')
end
>>>>>>> MalcolmBranch
