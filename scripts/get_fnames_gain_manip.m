% Script to load file names for feature matrices
% MGC 12/5/2017

% use fixed random seed for debugging

rng('default');

% Get all grid cells  
load(fullfile(datafolder,'params.mat')); % includes cell array with filenames of grid cells

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

% get all grid | border cells
gb_inds = logical(grid_inds+border_inds);
gb_fnames = files(gb_inds);