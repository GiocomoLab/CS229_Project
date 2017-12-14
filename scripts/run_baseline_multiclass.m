% run baseline multiclass classifiers

% get data folder and filenames
get_data_folder;
get_fnames;

% which features to use
feats = {'fr_dft_abs'};

% which models to run with associated hyperparameters
modelTypes={'mc_linear_svm','mc_svm'};
hyperParams = {{'ridge',1e2},{'rbf'}};

% choose LOOCV
m = length(grid_fnames) + length(border_fnames) + length(nongb_fnames_ds);
fold_inds = build_folds(m,m);

% load feature matrices
[X, Y] = load_features(datafolder,{grid_fnames,border_fnames, nongb_fnames_ds},feats);

% run desired classifiers
results = batch_classifiers(X,Y,feats,fold_inds,modelTypes,hyperParams);
