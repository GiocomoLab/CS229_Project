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