% drift analysis
% MGC 11/12/17

%% params
datafolder = '/Users/malcolmcampbell/Dropbox/Work/Malcolms_VR_data/';
A = readtable('allCells.csv');
A = A(strcmp(A.SessionTypeVR,'gain_manip'),:);
params = readtable('UniversalParams.xlsx');
num_lags = 10; % for cross corr calculations

% thresholds
thresh.border = 0.523;
thresh.grid = 0.349;

% identify cell types
inter = A.MeanRateOF > 10;
grid = find(A.GridScore > thresh.grid & ~inter);
border = find(A.BorderScore > thresh.border & ~ inter);

%% analyze drift: grid cells
lag_grid = nan(size(grid));
uniqueID_grid = A.UniqueID(grid);
fprintf('\n\n\ngrid\n\n\n');
for j = 1:numel(grid)
    mouse = A.Mouse{grid(j)};
    session = A.SessionVR{grid(j)};
    cellname = A.Cell{grid(j)};
    load(sprintf('%s%s_%s_%s.mat',datafolder,mouse,session,cellname));
    fprintf('%d/%d %s %s %s\n',j,numel(grid),mouse,session,cellname);

    % position, time and trial data
    posx = celldata.vr_data.posx;
    post = celldata.vr_data.post;
    dt = diff(post);
    dt = [dt; mean(dt)];
    trial = celldata.vr_data.trial;
    spike_t = celldata.vr_data.spike_t;
    
    % only include A period
    maxtrial = find(diff(celldata.vr_data.manipulation_trial),1);
    if isempty(maxtrial)
        maxtrial = max(trial);
    else
        maxtrial = maxtrial+1;
    end
    posx = posx(trial<maxtrial);
    post = post(trial<maxtrial);
    dt = dt(trial<maxtrial);
    trial = trial(trial<maxtrial);
    spike_t = spike_t(spike_t<max(post));

    % get spike indices
    idx = nan(numel(spike_t),1);
    for i = 1:numel(idx)
        [~,idx(i)] = min(abs(post-spike_t(i)));
    end

    % compute firing rate
    firing_rate = calculateSmoothedFiringRate(idx,posx,dt,params);

    % compute single trial cross-correlations
    fr_corr = nan(max(trial)-1,num_lags*2+1);
    for i = 2:max(trial)
        % trial 1
        posx1 = posx(trial==i-1);
        dt1 = dt(trial==i-1);
        idx1 = idx(trial(idx)==i-1);
        idx1 = idx1 - sum(trial<i-1);
        fr1 = calculateSmoothedFiringRate(idx1,posx1,dt1,params);

        % trial 2
        posx2 = posx(trial==i);
        dt2 = dt(trial==i);
        idx2 = idx(trial(idx)==i);
        idx2 = idx2 - sum(trial<i);
        fr2 = calculateSmoothedFiringRate(idx2,posx2,dt2,params);

        % cross correlation
        fr_corr(i-1,:) = crosscorr(fr1,fr2,num_lags);
    end

    % get cross correlation peak
    x = -num_lags*params.BinSize:params.BinSize:num_lags*params.BinSize;
    [~,max_lag] = max(mean(fr_corr));
    lag_grid(j) = x(max_lag);
end
% average by unique ID
gridID = unique(uniqueID_grid);
numgrid = numel(gridID);
lag_grid_collapsed = nan(numgrid,1);
for i = 1:numgrid
    lag_grid_collapsed(i) = mean(lag_grid(strcmp(uniqueID_grid,gridID{i})));
end

%% analyze drift: border cells
lag_border = nan(size(border));
uniqueID_border = A.UniqueID(border);
fprintf('\n\n\nborder\n\n\n');
for j = 1:numel(border)
    mouse = A.Mouse{border(j)};
    session = A.SessionVR{border(j)};
    cellname = A.Cell{border(j)};
    load(sprintf('%scells/%s_%s_%s.mat',datafolder,mouse,session,cellname));
    fprintf('%d/%d %s %s %s\n',j,numel(border),mouse,session,cellname);

    % position, time and trial data
    posx = celldata.vr_data.posx;
    post = celldata.vr_data.post;
    dt = celldata.vr_data.dt;
    trial = celldata.vr_data.trial;
    spike_t = celldata.vr_data.spike_t;

    % throw out incomplete last trial
    posx = posx(trial<maxtrial);
    post = post(trial<maxtrial);
    dt = diff(post);
    dt = [dt; mean(dt)];
    trial = trial(trial<maxtrial);
    spike_t = spike_t(spike_t<max(post));

    % get spike indices
    idx = nan(numel(spike_t),1);
    for i = 1:numel(idx)
        [~,idx(i)] = min(abs(post-spike_t(i)));
    end

    % compute firing rate
    firing_rate = calculateSmoothedFiringRate(idx,posx,dt,params);

    % compute single trial cross-correlations
    fr_corr = nan(max(trial)-1,num_lags*2+1);
    for i = 2:max(trial)
        % trial 1
        posx1 = posx(trial==i-1);
        dt1 = dt(trial==i-1);
        idx1 = idx(trial(idx)==i-1);
        idx1 = idx1 - sum(trial<i-1);
        fr1 = calculateSmoothedFiringRate(idx1,posx1,dt1,params);

        % trial 2
        posx2 = posx(trial==i);
        dt2 = dt(trial==i);
        idx2 = idx(trial(idx)==i);
        idx2 = idx2 - sum(trial<i);
        fr2 = calculateSmoothedFiringRate(idx2,posx2,dt2,params);

        % cross correlation
        fr_corr(i-1,:) = crosscorr(fr1,fr2,num_lags);
    end

    % get cross correlation peak
    x = -num_lags*params.BinSize:params.BinSize:num_lags*params.BinSize;
    [~,max_lag] = max(mean(fr_corr));
    lag_border(j) = x(max_lag);
end
% average by unique ID
borderID = unique(uniqueID_border);
numborder = numel(borderID);
lag_border_collapsed = nan(numborder,1);
for i = 1:numborder
    lag_border_collapsed(i) = mean(lag_border(strcmp(uniqueID_border,borderID{i})));
end