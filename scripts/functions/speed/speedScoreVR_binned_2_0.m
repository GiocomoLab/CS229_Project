function [speedScore, speedSlope] = speedScoreVR_binned_2_0(spike_t,speed,post,posx,trackstart,trackend,binsize)
% function that returns speed score and speed slope for a VR normal session
% bins track into 8 50 cm bins and computes speed score and slope in each
% bin
% returns average over bins, weighted by number of spikes in bin
% MGC 5/30/16

% modified 4/25/17 to match new data format

% threshold for speed
speedThreshold = 2;

if ~exist('binsize','var')
    binsize = 50;
end


% estimate instantaneous firing rate by smoothing spike count histogram
h = hist(spike_t,post);
dt = diff(post); 
dt = [dt; mean(dt)];
fr = reshape(h,numel(post),1);
fr = fr./dt; % change to units of Hz
fr = gauss_smoothing(fr,20);  % smooth with gaussian kernel (sigma=20)

% throw out bins with speeds below threshold
select = speed > speedThreshold; 
speed = reshape(speed,numel(post),1);
speedFilt = speed(select);
frFilt = fr(select);
posxFilt = posx(select);

% bin by position and look at speed score in each position bin
[~,posBin] = histc(posxFilt,trackstart:binsize:trackend);

speedScores = nan(max(posBin),1);
speedSlopes = nan(max(posBin),2);
for i = 1:max(posBin)
    speedScores(i) = corr(speedFilt(posBin==i),frFilt(posBin==i));
    speedSlopes(i,:) = [ones(sum(posBin==i),1) speedFilt(posBin==i)]\frFilt(posBin==i);
end

% take weighted average across bins, weighted by number of spikes per bin
spikesPerBin = nan(max(posBin),1);
hFilt = h(select);
for i = 1:max(posBin)
    spikesPerBin(i) = sum(hFilt(posBin==i));
end
weights = spikesPerBin/sum(spikesPerBin);

speedScore = nansum(speedScores.*weights);
speedSlope = nansum(speedSlopes(:,2).*weights);


end