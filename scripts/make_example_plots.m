% makes basic plots of A period of every recording
% MGC 12/9/2017

%% params

restoredefaultpath;
addpath(genpath('functions/'));
get_data_folder;

% figures
make_figures = 0;
save_figures = 0;

% mice with bursty, drifty spatial cells
mice = {'Barbara','Biggie','Christina','JLo','LilKim','Rihanna','Shakira','Winehouse'};

% get data
A = readtable('../allCells.csv');
A = A(~strcmp(A.SessionTypeVR,'optic_flow_track') & ismember(A.Mouse,mice),:);
N = size(A,1);

% load params
params = readtable('../UniversalParams.xlsx');
nbins = (params.TrackEnd-params.TrackStart)/params.BinSize;

% for trial-trial cross correlations
num_lags = 5;

% for field size definition
thresh.autocorr = 0.2;

%% make raster plots
counter = 1;
feat = table(); % feature matrix
feat.uniqueID = cell(N*5,1);
feat.meanrate = nan(N*5,1);
feat.median_isi = nan(N*5,1);
feat.burstiness = nan(N*5,1); % = 1/(meanrate * median_isi)
feat.stability = nan(N*5,1);
feat.stability_zscore = nan(N*5,1);
feat.trial_stability = nan(N*5,1);
feat.stability_ratio = nan(N*5,1); % trial stability / stability
feat.fieldsize = nan(N*5,1);
for i = 1:N
    fprintf('cell %d/%d\n',i,N);
    
    % load cell data
    load(sprintf('%s%s_%s_%s.mat',datafolder,A.Mouse{i},A.SessionVR{i},A.Cell{i}));
    
    for j = 1:2:numel(celldata.bl.blocktype)

        % load data for this block
        posx = celldata.bl.posx_filt{j};
        trial = celldata.bl.trial_filt{j};
        dt = celldata.bl.dt_filt{j};
        idx = celldata.bl.spike_idx_filt{j};
        
        % compute firing rate
        firing_rate = calculateSmoothedFiringRate(idx,posx,dt,params);
        
        % autocorrelation (for field size)
        firing_rate_autocorr = autocorr(firing_rate,nbins-1);

        % compute single trial cross-correlations
        fr_corr = nan(max(trial)-1,num_lags*2+1);
        for k = 2:max(trial)
            % trial 1
            posx1 = posx(trial==k-1);
            dt1 = dt(trial==k-1);
            idx1 = idx(trial(idx)==k-1);
            idx1 = idx1 - sum(trial<k-1);
            fr1 = calculateSmoothedFiringRate(idx1,posx1,dt1,params);

            % trial 2
            posx2 = posx(trial==k);
            dt2 = dt(trial==k);
            idx2 = idx(trial(idx)==k);
            idx2 = idx2 - sum(trial<k);
            fr2 = calculateSmoothedFiringRate(idx2,posx2,dt2,params);

            % cross correlation
            fr_corr(k-1,:) = crosscorr(fr1,fr2,num_lags);
        end    
        
        % get features
        feat.uniqueID{counter} = A.UniqueID{i};
        feat.meanrate(counter) = numel(celldata.bl.spike_t{j})/max(celldata.bl.post{j});
        feat.median_isi(counter) = median(diff(celldata.bl.spike_t{j}));
        feat.burstiness(counter) = 1/(feat.meanrate(counter)*feat.median_isi(counter));
        feat.stability(counter) = celldata.bl.stability(j);
        feat.stability_zscore(counter) = celldata.bl.stability_zscore(j);
        feat.trial_stability(counter) = mean(max(fr_corr,[],2));
        feat.stability_ratio(counter) = feat.trial_stability(counter)/feat.stability(counter);
        thresh.fieldsize(counter) = params.BinSize*(find(firing_rate_autocorr<thresh.autocorr,1)-1);
        counter = counter+1;

        if make_figures
            h = figure('Visible','off');           
            plot(posx(idx),trial(idx),'r.','MarkerSize',10);
            xlim([params.TrackStart params.TrackEnd]);
            ylim([0 max(trial)+1]);
            if save_figures
                saveas(h,sprintf('plots/all_cells/%s_%s_%s_%d.png',A.UniqueID{i},A.SessionVR{i},A.Cell{i},j),'png');
            end
        end
    end
end

% filter out nans
feat = feat(~isnan(feat.meanrate),:);

% close figures
close all