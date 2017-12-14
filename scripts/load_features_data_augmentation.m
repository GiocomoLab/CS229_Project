function [Xtrain, Ytrain, Xtest, Ytest] = load_features_data_augmentation(datafolder,class_fnames,numFeats)

rotation_offset = 10;
augSubsPerCell = numFeats/rotation_offset; %shifts
nCells = numel(class_fnames{1}) + numel(class_fnames{2});
numAugSubs = augSubsPerCell*nCells; %shifts

Xtest = nan(nCells,200);
Ytest = nan(nCells,1);
Xtrain = nan(numAugSubs,200);
Ytrain = nan(numAugSubs,1);

for i = 1:length(class_fnames)
    
    if i == 1
        class_ind_shift = 0;
    else
        class_ind_shift = class_ind_shift+numel(class_fnames{i-1});
    end
    
    for f = 1:length(class_fnames{i})
        [Xreal,Xaug] = load_single_sub(fullfile(datafolder,class_fnames{i}{f}));
        Xtrain(class_ind_shift*augSubsPerCell+(f-1)*augSubsPerCell+1:class_ind_shift*augSubsPerCell+f*augSubsPerCell,:) = Xaug;
        Xtest(class_ind_shift+f,:) = Xreal;
        Ytrain(class_ind_shift+(f-1)*augSubsPerCell+1:class_ind_shift*augSubsPerCell+f*augSubsPerCell) = i-1;
        Ytest(class_ind_shift+f) = i-1;
    end
end

end
        
 
function [xreal,xaug] = load_single_sub(fname)

load(fname);
xreal = featStruct.firing_rate;
xaug = featStruct.firing_rate_aug;

end