

get_data_folder;

% Get all grid cells  
load(fullfile(datafolder,'params.mat')); % includes cell array with filenames of grid cells

% Take a random subset of non-grid cells to match prevelance
% use fixed random seed for debugging
rng('default'); 

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

% non grid cells
nongrid_fnames = files(~grid_inds);

% non border cells 
nonborder_fnames = files(~border_inds);

% get all grid | border cells
gb_inds = logical(grid_inds+border_inds);
gb_fnames = files(gb_inds);

% non grid | border cells
nongb_fnames = files(~gb_inds);

% downsample non-functional cell types

nongrid_fnames_ds = nongrid_fnames(randperm(length(nongrid_fnames),length(grid_fnames)));
nonborder_fnames_ds = nonborder_fnames(randperm(length(nonborder_fnames),length(border_fnames)));
nongb_fnames_ds = nongb_fnames(randperm(length(nongb_fnames),length(gb_fnames)));


% comparisons to run
tests = {{'gb','nongb'},{'grid','nongrid'},{'border','nonborder'}};
% forward search order
forward_search_order = {{'fr'},{'fr','fr_dft_abs'}, {'fr','fr_dft_abs','ccorr_peak'},....
    {'fr','mean_fr_ccorr','ccorr_peak','fr_dft_abs'}};
% which classifiers to run
modelTypes = {'linear_svm','logistic', 'svm'};
% hyperparams for each calssifier
hyperParams = {{'ridge',1e4},{'ridge',1e4},{'rbf'}};
results = cell(length(tests),length(forward_search_order));
for t = 1:length(tests)
    eval(['class0_fnames = ' tests{t}{1} '_fnames;']);
    eval(['class1_fnames = ' tests{t}{2} '_fnames_ds;']);
    m = length(class0_fnames) + length(class1_fnames);
    fold_inds = build_folds(m,m);
    
    for f = 1:length(forward_search_order)
        feats = forward_search_order{f};
        [X, Y] = load_features(datafolder,{class0_fnames,class1_fnames},feats);
        single_run_results = batch_run_cv(X,Y,feats,fold_inds,modelTypes,hyperParams);
        single_run_results.groups = tests{t};
        
        results{t,f} = single_run_results;
        
        
    end
    
end