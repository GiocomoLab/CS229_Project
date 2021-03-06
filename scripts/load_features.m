

function [X, Y] = load_features(datafolder,class_fnames,feats)

X = []; Y = [];
for i = 1:length(class_fnames)
    
    for f = 1:length(class_fnames{i})
        X = [X; load_single_sub(fullfile(datafolder,class_fnames{i}{f}),feats)];
        Y = [Y;i-1];
    end
end


end
        
 



function x = load_single_sub(fname, feats)

if isempty(feats)
    feats = {'fr','mean_fr_ccorr','ccorr_peak','fr_dft_abs'};
end

load(fname);

% %%% hacky solution to get time warp features in without rewriting a bunch of stuff
% C = strsplit(fname,'Malcolms_VR_Data');
% cell_suffix = strsplit(fname,'FeatStruct_');
% 
% twPCAStr = fullfile(C{1},'Malcolms_VR_Data','twPCA_Mats',strcat('bc_ls_',cell_suffix{end}(1:end-4),'*'));
% files = dir(twPCAStr);
% twPCAMat = files(1).name;
% load(fullfile(C{1},'Malcolms_VR_Data','twPCA_Mats',twPCAMat));
% %%%

x=[];

if sum(strcmp(feats,'fr'))>0
    fr = featStruct.firing_rate;
    fr = (fr-min(fr))/(max(fr)-min(fr));
    x = [x fr];
end

if sum(strcmp(feats,'mean_fr_ccorr'))>0
    x = [x featStruct.mean_fr_ccorr];
end

if sum(strcmp(feats,'ccorr_peak'))>0
    x = [x featStruct.max_lag];
end

if sum(strcmp(feats,'fr_dft_abs'))>0
    fr = featStruct.firing_rate;
    fr_fft = abs(fft(fr));
    x = [x fr_fft(1:floor(length(fr_fft)/2))];
end

if sum(strcmp(feats,'mean_fr'))>0
    x = [x featStruct.mean_rate];
end

if sum(strcmp(feats,'cross_corr'))>0
    x = [x featStruct.cross_corr];
end

if sum(strcmp(feats,'cross_corr_gd'))>0
    x = [x featStruct.cross_corr_gd];
end

if sum(strcmp(feats,'cross_corr_gi'))>0
    x = [x featStruct.cross_corr_gi];
end

% if sum(strcmp(feats,'time_warp'))>0
%     x = [ x slope intercept r_value^2 p_value mean(d) var(d)];
% end

end

