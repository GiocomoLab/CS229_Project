mouse = 'Aretha';
session = '0716_1';
cellname = 'T1C1';
params = readtable('UniversalParams.xlsx');
datafile = strcat('~/Dropbox/Malcolms_VR_data/',mouse,'_',session,'_',cellname,'.mat');
load(datafile);



posx = celldata.vr_data.posx;
post = celldata.vr_data.post;
dt = diff(celldata.vr_data.post);
dt = [dt; mean(dt)];
trial = celldata.vr_data.trial;
spike_t = celldata.vr_data.spike_t;
idx = nan(size(spike_t));
for i = 1:numel(spike_t)
    [~,idx(i)] = min(abs(post-spike_t(i)));
end
firing_rate = calculateSmoothedFiringRate(idx,posx,dt,params);

figure();
% firing rate
x = (params.TrackStart+params.BinSize/2):params.BinSize:(params.TrackEnd-params.BinSize/2);
subplot(2,1,1);
plot(x,firing_rate,'k-');
% raster plot
subplot(2,1,2);
plot(posx(idx),trial(idx),'k.');