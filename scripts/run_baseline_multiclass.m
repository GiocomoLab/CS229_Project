% run baseline multiclass classifiers


get_data_folder;
get_fnames;


feats = {'fr_dft_abs'};

modelTypes={'mc_linear_svm','mc_svm'}; %,'softmax'};
hyperParams = {{'ridge',1e2},{'rbf'}};

m = length(grid_fnames) + length(border_fnames) + length(nongb_fnames_ds);
fold_inds = build_folds(m,m);

[X, Y] = load_features(datafolder,{grid_fnames,border_fnames, nongb_fnames_ds},feats);
results = batch_run_cv(X,Y,feats,fold_inds,modelTypes,hyperParams);


save 'baseline_multiclass_classifiers.mat' results