

function [Xtrain, Ytrain, Xtest,Ytest] = load_features_data_augmentation(datafolder,class_fnames,numFeats)

augSubsPerCell = 2*numFeats; %shifts and reflections
nCells = numel(cell2mat(class_fnames));
numAugSubs = augSubsPerCell*nCells; %shifts and reflections

Xtest = nan(nCells,200); Ytest = nan(nCells,1);
Xtrain = nan(numAugSubs,200); Ytrain = nan(numAugSubs,1);
for i = 1:length(class_fnames)
    
    if i == 0
        class_ind_shift = 0;
    else
        class_ind_shift = class_ind_shift+numel(class_fnames{i});
    end
    
    for f = 1:length(class_fnames{i})
        [Xreal,Xaug] = load_single_sub(fname);
        
        Xtrain(class_ind_shift+1:class_ind_shift+augSubsPerCell,:) = Xaug;
        Xtest(class_ind_shift+f,:) = Xreal;
%         X(class = [X; load_single_sub(fullfile(datafolder,class_fnames{i}{f}),feats)];
        Ytrain(class_ind_shift+1:class_ind_shift+augSubsPerCell) = i-1;
        Ytest(class_ind_shift+f) = i-1;
    end
end


end
        
 
function [xreal,xaug] = load_single_sub(fname)

load(fname);
xreal = featStruct.firing_rate;

xaug = [featStruct.firing_rate_aug; featStruct.firing_rate_aug(:,end:-1:1)];
end

% function x = load_single_sub(fname, feats)
% 
% if isempty(feats)
%     feats = {'fr','mean_fr_ccorr','ccorr_peak','fr_dft_abs'};
% end
% 
% load(fname);
% x=[];
% 
% if sum(strcmp(feats,'fr'))>0
%     fr = featStruct.firing_rate;
%     fr = (fr-min(fr))/(max(fr)-min(fr));
%     x = [x fr];
% end
% 
% if sum(strcmp(feats,'mean_fr_ccorr'))>0
%     x = [x featStruct.mean_fr_ccorr];
% end
% 
% if sum(strcmp(feats,'ccorr_peak'))>0
%     x = [x featStruct.max_lag];
% end
% 
% if sum(strcmp(feats,'fr_dft_abs'))>0
%     fr = featStruct.firing_rate;
%     fr_fft = abs(fft(fr));
%     x = [x fr_fft(1:floor(length(fr_fft)/2))];
% end
% 
% if sum(strcmp(feats,'mean_fr'))>0
%     x = [x featStruct.mean_rate];
% end
% 
% if sum(strcmp(feats,'cross_corr'))>0
%     x = [x featStruct.cross_corr];
% end
% 
% if sum(strcmp(feats,'cross_corr_gd'))>0
%     x = [x featStruct.cross_corr_gd];
% end
% 
% if sum(strcmp(feats,'cross_corr_gi'))>0
%     x = [x featStruct.cross_corr_gi];
% end
% 
% end
% 
