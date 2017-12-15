% load feature matrices and assign labels
% INPUTS:
%   datafolder - directory where all feature structures are saved
%   class_fnames - 2x1 cell array where each index is itself a cell array
%   of filenames for each class
%   feats - cell array of strings for each set of features to be included
% OUTPUTS:
%   Xtrain - augmented data matrix
%   Ytrain - augmented labels
%   Xtest - original data matrix
% ` Ytest - original class labels


function [Xtrain, Ytrain, Xtest, Ytest] = load_features_dataug(datafolder,class_fnames,numFeats)

rotation_offset = 10; % center of shifts
augSubsPerCell = 2*numFeats/rotation_offset; %shifts + rotations
nCells = numel(class_fnames{1}) + numel(class_fnames{2});
numAugSubs = augSubsPerCell*nCells; % (shifts+rotations)*number of cells

% allocate for space
Xtest = nan(nCells,200);
Ytest = nan(nCells,1);
Xtrain = nan(numAugSubs,200);
Ytrain = nan(numAugSubs,1);

% for each class
for i = 1:length(class_fnames)
    
    % deal with indexing shifts in augmented data
    if i == 1
        class_ind_shift = 0;
    else
        class_ind_shift = class_ind_shift+numel(class_fnames{i-1});
    end
    
    % for each cell
    for f = 1:length(class_fnames{i})
        load(fullfile(datafolder,class_fnames{i}{f}));
        
        Xtrain(class_ind_shift*augSubsPerCell+(f-1)*augSubsPerCell+...
            1:class_ind_shift*augSubsPerCell+f*augSubsPerCell,:) = featStruct.firing_rate_aug;
        Xtest(class_ind_shift+f,:) = featStruct.firing_rate;
        
        Ytrain(class_ind_shift+(f-1)*augSubsPerCell+1:class_ind_shift*augSubsPerCell+f*augSubsPerCell) = i-1;
        Ytest(class_ind_shift+f) = i-1;
    end
end

end
        