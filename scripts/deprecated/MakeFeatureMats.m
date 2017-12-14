% feature structures
% MGC 11/12/17

%% params

% get data folder
get_data_folder;

% load table with recording information
A = readtable('../allCells.csv');
A = A(strcmp(A.SessionTypeVR,'gain_manip'),:);

% which gain manipulation to use
gain_value = 0.5;

% universal params
params = readtable('../UniversalParams.xlsx');

% for cross corr calculations
num_lags = 10; 

% thresholds
thresh.border = 0.523; % border score
thresh.grid = 0.349; % grid score
thresh.inter = 10; % firing rate to identify interneurons

% shift matrix for data augmentation
numFeats = 200; % number of spatial bins
rotation_offset = 10; % "center" of data shifts
rotations = rotation_offset*(0:(numFeats/rotation_offset-1));
rotate_matrix = repmat(1:numFeats,numel(rotations),1);
for i = 1:numel(rotations)
    rotate_matrix(i,:) = circshift(rotate_matrix(i,:),rotations(i));
end

%% identify cell types
inter = A.MeanRateOF > thresh.inter;
grid = find(A.GridScore > thresh.grid & ~inter);
border = find(A.BorderScore > thresh.border & ~ inter);

% take one recording from each unique grid and border cell.
% might want to make it so that it's not always the first recording from
% each cell, but let's do this for now.
[~,uniq_idx_grid] = unique(A.UniqueID(grid));
[~,uniq_idx_border] = unique(A.UniqueID(border));
grid = grid(uniq_idx_grid);
border = border(uniq_idx_border);

grid_fnames = cell(numel(grid),1);
for g = 1:numel(grid)
    uniqueID = A.UniqueID{grid(g)};
    session = A.SessionVR{grid(g)};
    cellname = A.Cell{grid(g)};
    grid_fnames{g} = sprintf('FeatStruct_%s_%s_%s.mat',uniqueID,session,cellname);
end

border_fnames = cell(numel(border),1);
for b = 1:numel(border)
    uniqueID = A.UniqueID{border(b)};
    session = A.SessionVR{border(b)};
    cellname = A.Cell{border(b)};
    border_fnames{b} = sprintf('FeatStruct_%s_%s_%s.mat',uniqueID,session,cellname);
end

save(strcat(datafolder,'/params.mat'),'thresh','border_fnames','grid_fnames');
%% extract features and save




lag = nan(numel(A.UniqueID),1);
for j = 1:numel(A.UniqueID)

%     featStruct = struct([]);
    featStruct.id = A.UniqueID(j);
    featStruct.grid = double(A.GridScore(j)>thresh.grid & A.MeanRateOF < thresh.inter);
    featStruct.border = double(A.BorderScore(j) > thresh.border & A.MeanRateOF < thresh.inter);
    featStruct.mean_rate = A.MeanRateOF(j);

    uniqueID = A.UniqueID{j};
    mouse = A.Mouse{j};
    session = A.SessionVR{j};
    cellname = A.Cell{j};
    fname = sprintf('%s_%s_%s.mat',uniqueID,session,cellname);
    load(sprintf('%s%s_%s_%s.mat',datafolder,mouse,session,cellname));




    % position, time and trial data
    % only include A period
    posx = celldata.bl.posx{1};
    post = celldata.bl.post{1};
    dt = celldata.bl.dt{1};
    trial = celldata.bl.trial{1};
    spike_t = celldata.bl.spike_t{1};

    % throw out last trial (incomplete for some data)
    posx = posx(trial<max(trial));
    post = post(trial<max(trial));
    dt = dt(trial<max(trial));
    trial = trial(trial<max(trial));
    spike_t = spike_t(spike_t<max(post));

    % get spike indices
    idx = nan(numel(spike_t),1);
    for i = 1:numel(idx)
        [~,idx(i)] = min(abs(post-spike_t(i)));
    end

    % compute firing rate
    firing_rate = calculateSmoothedFiringRate(idx,posx,dt,params);
    featStruct.firing_rate = firing_rate;
    
    % augment firing rate maps 
    featStruct.firing_rate_aug = featStruct.firing_rate(rotate_matrix);

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

    featStruct.max_lag = x(max_lag);
    featStruct.mean_fr_ccorr = nanmean(fr_corr);


    save(strcat(datafolder,'/FeatStruct_' ,fname), 'featStruct');

    fprintf('%d/%d %s %s %s\n',j,numel(A.UniqueID),mouse,session,cellname);
end
