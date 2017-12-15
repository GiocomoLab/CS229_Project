% Script to load file names for feature matrices

% use fixed random seed for debugging
rng('default');

% Get all grid and border cells  
load(fullfile(datafolder,'params.mat')); 

% get all files names
files = dir(fullfile(datafolder,'FeatStruct_*.mat'));
files = {files(:).name}';

