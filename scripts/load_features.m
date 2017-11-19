

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
x=[];

if sum(strcmp(feats,'fr'))>0
    fr = featStruct.firing_rate;
    fr = (fr-min(fr))/max(fr);
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
    x = [x abs(fft(fr))];
end

end
