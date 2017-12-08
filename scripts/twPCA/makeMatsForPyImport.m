% Make matrices for each neuron that are trial x timepoint
% MGC 11/12/17

%% params
addpath('/Users/markplitt/repos/CS229_Project/scripts/');
% get data folder
mp_prefix = '~/Dropbox/Malcolms_VR_Data/';
mc_prefix1 = '/Users/malcg/Dropbox/Work/Malcolms_VR_data/';
mc_prefix2 = '/Users/malcolmcampbell/Dropbox/Work/Malcolms_VR_data/';
if (exist(mc_prefix1,'dir')>0)
    datafolder = mc_prefix1;
elseif (exist(mc_prefix2,'dir')>0)
    datafolder = mc_prefix2;
elseif (exist(mp_prefix,'dir')>0)
    datafolder = mp_prefix;
end



A = readtable('/Users/markplitt/repos/CS229_Project/allCells.csv');
params = readtable('/Users/markplitt/repos/CS229_Project/UniversalParams.xlsx');
A = A(~strcmp(A.SessionTypeVR,'optic_flow_track'),:);
num_lags = 10; % for cross corr calculations

% thresholds
thresh.border = 0.523; % border score
thresh.grid = 0.349; % grid score
thresh.inter = 10; % firing rate to identify interneurons

% identify cell types
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
    grid_fnames{g} = sprintf('twPCA_%s_%s_%s.mat',uniqueID,session,cellname);
end

border_fnames = cell(numel(border),1);
for b = 1:numel(border)
    uniqueID = A.UniqueID{border(b)};
    session = A.SessionVR{border(b)};
    cellname = A.Cell{border(b)};
    border_fnames{b} = sprintf('twPCA_%s_%s_%s.mat',uniqueID,session,cellname);
end

save(strcat(datafolder,'twPCA_Mats/params.mat'),'thresh','border_fnames','grid_fnames');

%% make matrices 

binedges = params.TrackStart:params.BinSize:params.TrackEnd;
nbins = numel(binedges)-1;

for j = 1:numel(A.UniqueID)
    
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

%     allocate matrix based on number of trials and longest trial
    numtrials = length(unique(trial));
    maxTrialLength = 0;
    for i = 1:numtrials
        triallength = sum(trial==i);
        if triallength>maxTrialLength
            maxTrialLength=triallength;
        end
    end
    timeSpikeMat = nan(numtrials,maxTrialLength);
    posMat = nan(numtrials,maxTrialLength);
        
    
    
    
    % get spike indices
    idx = nan(numel(spike_t),1);
    for i = 1:numel(idx)
        [~,idx(i)] = min(abs(post-spike_t(i)));
    end
    spike_vec = zeros(size(posx));
    spike_vec(idx) = 1;
    
    
    % fill spike and position matrices
    frTrialMat = nan(numtrials,nbins);
    frTrialMat_noSmooth =  nan(numtrials,nbins);
    for i = 1:max(trial)
        % trial 1
        trial_bool = trial==i;
        length_trial = sum(trial_bool);
        
        timeSpikeMat(i,1:length_trial) = spike_vec(trial_bool);
        posMat(i,1:length_trial) = posx(trial_bool);
        
        
        
    
        posx_i = posx(trial==i-1);
        dt_i = dt(trial==i-1);
        idx_i = idx(trial(idx)==i-1);
        idx_i = idx_i - sum(trial<i-1);
%         [smooth_firing_rate, firing_rate] = calculateFiringRate(idx_i,posx_i,dt_i,params);
        [frTrialMat(i,:),frTrialMat_noSmooth(i,:)]= calculateFiringRate(idx_i,posx_i,dt_i,params);
       
    end
   
    save(strcat(datafolder,'twPCA_Mats/twPCA_' ,fname), 'timeSpikeMat','posMat','frTrialMat','frTrialMat_noSmooth');
    
    fprintf('%d/%d %s %s %s\n',j,numel(A.UniqueID),mouse,session,cellname);
end
