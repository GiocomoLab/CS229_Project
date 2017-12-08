% Script to augment our dataset by rotating firing rate maps
% (199 rotations per cell)
% MGC 12/6/2017

%% load data
% get data folder
get_data_folder;
datafolder = strcat(datafolder,'/FeatureMats/');

% get FeatureMat files
files = dir(fullfile(datafolder,'FeatStruct_*.mat'));
files = {files(:).name}';

% get params
load(fullfile(datafolder,'params.mat')); % includes cell array with filenames of grid cells

%% save new grid/border filenames
files_aug = files;
for i = 1:numel(files_aug)
    temp_str = strsplit(files_aug{i},'.');
    temp_str = temp_str{1};
    files_aug{i} = strcat(temp_str,'_aug.mat');
end

grid_fnames_aug = grid_fnames;
for i = 1:numel(grid_fnames_aug)
    temp_str = strsplit(grid_fnames_aug{i},'.');
    temp_str = temp_str{1};
    grid_fnames_aug{i} = strcat(temp_str,'_aug.mat');
end

border_fnames_aug = border_fnames;
for i = 1:numel(border_fnames_aug)
    temp_str = strsplit(border_fnames_aug{i},'.');
    temp_str = temp_str{1};
    border_fnames_aug{i} = strcat(temp_str,'_aug.mat');
end

save(strcat(datafolder,'data_augmentation/params.mat'),'thresh','grid_fnames_aug','border_fnames_aug');

%% augment data
rotate_matrix = repmat(1:200,200,1);
for i = 1:200
    rotate_matrix(i,:) = circshift(rotate_matrix(i,:),i-1);
end
for i = 1:numel(files)
    fprintf('file %d/%d: %s\n',i,numel(files),files{i});
    load(strcat(datafolder,files{i}));
    featStruct.firing_rate_aug = featStruct.firing_rate(rotate_matrix);
    save(strcat(datafolder,'data_augmentation/',files_aug{i}),'featStruct');
end