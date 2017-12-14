function [speedScore,params,speedFilt,frFilt] = speedScoreVR_lin_2_0(spike_t,speed,post)
% function to calculate speed score in VR using linear fit
% based on Kropff et al 2015
% Malcolm Campbell, 3/30/16
%
% Version 2.0, 2/25/17:
% spike_t is vector of spike times
% speed is vector of animal's real speed
% params = [intercept, slope]

% threshold for speed (in cm/s)
speedThreshold = 2;

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

% compute speed score by correlating instantaneous firing rate and speed
speedScore =corr(speedFilt,frFilt);
params = [ones(sum(select),1) speedFilt]\frFilt;

end