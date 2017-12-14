function firing_rate_dist = calculateFiringRateDistribution(idx,posx,mean_dt,binedges,...
    numShuffles,smoothWindow)
% Calculates a distribution of firing rates from shuffled spike times

% If this is producing a non-uniform set of firing rates, it could be
% because average VR frame lengths vary w.r.t. the track.
% If that's the case, try shuffling raw spike times instead of spike indices. 
% However, this was very slow when I tried it.
% MGC 4/7/2017

% Changed to within-trial shuffling
% MGC 4/7/2017

% Changed to not use "time_per_bin" input
% Instead just input mean_dt directly
% MGC 9/23/17

time_per_bin_uniform = histcounts(posx,binedges)*mean_dt; % assumes uniform time bin length (not true)


if(~exist('smoothWindow','var'))
    smoothWindow=3;
end

if(~exist('numShuffles','var'))
    numShuffles=1000;
end

% added 1/17/16
% changes smoothing so as to not taper ends
noTaper = 1;

nbins = numel(binedges)-1;
firing_rate_dist = nan(numShuffles,nbins);
% gaussian filter for smoothing
gauss_filter = fspecial('gaussian',[smoothWindow 1], 1);

% get trial information
trial = [1 ; cumsum(diff(posx)<-100)+1];
trial_idx = [1 ; find(diff(posx)<-100); numel(trial)];

for j = 1:numShuffles
    
    % shuffle spikes (assumes all bins have equal length... but not
    % actually the case)
    
    % whole-session shuffling 
    %idx_shuffle = mod(idx - randi(length(posx),1), length(posx)) + 1;

    % within-trial shuffling
    idx_shuffle = [];
    for k = 1:numel(trial_idx)-1
        idx_thisTrial = idx(trial(idx)==k);
        trialStartIdx = trial_idx(k)-1;
        trialNumBins = trial_idx(k+1)-trialStartIdx-1;
        idx_shuffle_thisTrial = mod(idx_thisTrial-trialStartIdx+randsample(trialNumBins,1),trialNumBins)+1+trialStartIdx;
        idx_shuffle = [idx_shuffle ; idx_shuffle_thisTrial];
    end
    idx_shuffle = sort(idx_shuffle);
    
    % compute shuffled firing rate
    firing_rate_shuffle = histcounts(posx(idx_shuffle),binedges)./time_per_bin_uniform;

    % smooth shuffled firing rate
    if noTaper
        firing_rate_dist(j,:) = conv([firing_rate_shuffle(1) firing_rate_shuffle firing_rate_shuffle(end)],gauss_filter,'valid');
    else
        firing_rate_dist(j,:) = conv(firing_rate_shuffle,gauss_filter,'same');
    end
end

end