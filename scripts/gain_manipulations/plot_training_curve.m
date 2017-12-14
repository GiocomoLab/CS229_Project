% pick train size and test size

get_data_folder;
get_fnames;
load baseline_classifier_results.mat
TrainSizes = linspace(10,size(Y,1));
% plot learning curve to show we're not overfitting on the linear
% classifiers

