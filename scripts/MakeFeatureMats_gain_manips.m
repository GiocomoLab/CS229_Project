% feature structures for gain manip sessions
% MGC 12/6/17

%% params

% get data folder
get_data_folder;

% load table with recording information
A = readtable('../allCells.csv');
A = A(strcmp(A.SessionTypeVR,'gain_manip'),:);

% celltypes
celltypes = {'grid','border'};

% session types
sessiontype = {'gain_decrease', 'gain_increase', 'gain_decrease_and_gain_increase'};

% universal params
params = readtable('../UniversalParams.xlsx');
nbins = (params.TrackEnd-params.TrackStart)/params.BinSize;

% for cross corr calculations
num_lags = 50; 

% thresholds
thresh.border = 0.523; % border score
thresh.grid = 0.349; % grid score
thresh.inter = 10; % firing rate to identify interneurons
thresh.firingRate = 0.2; % cutoff for inclusion
thresh.stability_zscore = 1; % cutoff for inclusion

% identify cell types
inter = A.MeanRateOF > thresh.inter;
grid = A.GridScore > thresh.grid & ~inter;
border = A.BorderScore > thresh.border & ~ inter;

%% extract features from recordings

% values to compute: order is grid gd, border gd, grid gi, border gi
uniqueID_all = {[],[],[],[]};
uniqueID_all_including_unstable = {[],[],[],[]};
meanrate_all = {[],[],[],[]};
stab_zscore_all = {[],[],[],[]};
crosscorr_all = {[],[],[],[]};
autocorr_A_all = {[],[],[],[]};
autocorr_B_all = {[],[],[],[]};

for ii = 1:numel(celltypes)
    celltype = celltypes{ii};
    fprintf('\n\n%s\n\n',celltype);
    if strcmp(celltype,'grid')
        cellIdx = find(grid);
    elseif strcmp(celltype,'border')
        cellIdx = find(border);
    end
    crosscorr_gd = nan(200,nbins*2-1);
    autocorr_gd_A = nan(200,nbins*2-1);
    autocorr_gd_B = nan(200,nbins*2-1);
    crosscorr_gi = nan(200,nbins*2-1);
    autocorr_gi_A = nan(200,nbins*2-1);
    autocorr_gi_B = nan(200,nbins*2-1);
    stab_zscore_gd = nan(numel(cellIdx),2);
    stab_zscore_gi = nan(numel(cellIdx),2);
    meanrate_gd = nan(numel(cellIdx),2);
    meanrate_gi = nan(numel(cellIdx),2);
    uniqueID_gd = {};
    uniqueID_gd_including_unstable = {};
    uniqueID_gi = {}; 
    uniqueID_gi_including_unstable = {};
    counter_gd = 1;
    counter_gi = 1;
    counter_gd2 = 1;
    counter_gi2 = 1;
    for i = 1:numel(cellIdx)

        mouse = A.Mouse{cellIdx(i)};
        session = A.SessionVR{cellIdx(i)};
        cell = A.Cell{cellIdx(i)};
        uniqueID = A.UniqueID{cellIdx(i)};

        datafile = strcat(datafolder,'/',mouse,'_',session,'_',cell,'.mat');
        fprintf('%s %s %s\n',mouse,session,cell);
        load(datafile);
        blockdata = celldata.bl;

        for j = 2:2:celldata.numblocks      

            % get A period data
            posxA = blockdata.posx_filt{j-1};
            postA = blockdata.post_filt{j-1};
            dtA = blockdata.dt_filt{j-1};
            idxA = blockdata.spike_idx_filt{j-1};
            trialA = blockdata.trial_filt{j-1};
            spike_t_A = blockdata.spike_t_filt{j-1};  
            stabA_zscore = blockdata.stability_zscore_lastNtrials(j-1);
            
            % get B period data
            posxB = blockdata.posx_filt{j};
            postB = blockdata.post_filt{j};
            dtB = blockdata.dt_filt{j};
            idxB = blockdata.spike_idx_filt{j};
            trialB = blockdata.trial_filt{j};      
            meanrateB = numel(idxB)/sum(dtB);
            gainvalue = blockdata.blockgain(j);
            frB = calculateSmoothedFiringRate(idxB,posxB,dtB,params);     
            stabB_zscore = blockdata.stability_zscore_lastNtrials(j);
            
            % keep only last n trials where n = num manip trials
            posxA = posxA(trialA > max(trialA)-max(trialB));
            postA = postA(trialA > max(trialA)-max(trialB));
            dtA = dtA(trialA > max(trialA)-max(trialB));
            trialA = trialA(trialA > max(trialA)-max(trialB)) - (max(trialA)-max(trialB));       
            spike_t_A = spike_t_A(spike_t_A > min(postA)) - min(postA);
            postA = postA - min(postA);
            idxA = nan(numel(spike_t_A),1);
            for k = 1:numel(idxA)
                [~,idxA(k)] = min(abs(postA-spike_t_A(k)));
            end 
            meanrateA = numel(spike_t_A)/sum(dtA);
            frA = calculateSmoothedFiringRate(idxA,posxA,dtA,params);

            % firing rate threshold
            if meanrateA>thresh.firingRate && meanrateB>thresh.firingRate && mean(frA)>0 && mean(frB)>0
                
                if gainvalue == 0.5
                    uniqueID_gd_including_unstable{counter_gd2} = uniqueID;
                    stab_zscore_gd(counter_gd2,1) = stabA_zscore;
                    stab_zscore_gd(counter_gd2,2) = stabB_zscore;
                    counter_gd2 = counter_gd2+1;
                elseif gainvalue == 1.5
                    uniqueID_gi_including_unstable{counter_gi2} = uniqueID;
                    stab_zscore_gi(counter_gi2,1) = stabA_zscore;
                    stab_zscore_gi(counter_gi2,2) = stabB_zscore;
                    counter_gi2 = counter_gi2+1;
                end
                
                % stability threshold
                if stabA_zscore>thresh.stability_zscore && stabB_zscore>thresh.stability_zscore
                    fprintf('\t passed all thresholds\n');
                    if gainvalue == 0.5
                        uniqueID_gd{counter_gd} = uniqueID;
                        crosscorr_gd(counter_gd,:) = xcorr(frB-mean(frB),frA-mean(frA),'coeff');
                        autocorr_gd_A(counter_gd,:) = xcorr(frA-mean(frA),frA-mean(frA),'coeff');
                        autocorr_gd_B(counter_gd,:) = xcorr(frB-mean(frB),frB-mean(frB),'coeff');
                        meanrate_gd(counter_gd,1) = meanrateA;
                        meanrate_gd(counter_gd,2) = meanrateB;
                        counter_gd = counter_gd + 1;
                    elseif gainvalue == 1.5
                        uniqueID_gi{counter_gi} = uniqueID;
                        crosscorr_gi(counter_gi,:,:) = xcorr(frB-mean(frB),frA-mean(frA),'coeff');
                        autocorr_gi_A(counter_gi,:) = xcorr(frA-mean(frA),frA-mean(frA),'coeff');
                        autocorr_gi_B(counter_gi,:) = xcorr(frB-mean(frB),frB-mean(frB),'coeff');
                        meanrate_gi(counter_gi,1) = meanrateA;
                        meanrate_gi(counter_gi,2) = meanrateB;
                        counter_gi = counter_gi + 1;
                    end
                else
                    fprintf('\t\tdid not pass stability threshold\n');
                end
            else
                fprintf('\t\tdid not pass firing rate threshold\n')
            end

        end
    end
    % average together all cells that have the same unique ID
    crosscorr_gd = crosscorr_gd(~isnan(crosscorr_gd(:,1)),:); 
    autocorr_gd_A = autocorr_gd_A(~isnan(autocorr_gd_A(:,1)),:);
    autocorr_gd_B = autocorr_gd_B(~isnan(autocorr_gd_B(:,1)),:);   
    crosscorr_gi = crosscorr_gi(~isnan(crosscorr_gi(:,1)),:);
    autocorr_gi_A = autocorr_gi_A(~isnan(autocorr_gi_A(:,1)),:);
    autocorr_gi_B = autocorr_gi_B(~isnan(autocorr_gi_B(:,1)),:);    
    meanrate_gd = meanrate_gd(~isnan(meanrate_gd(:,1)),:);
    meanrate_gi = meanrate_gi(~isnan(meanrate_gi(:,1)),:);
    group1 = unique(uniqueID_gd);
    group2 = unique(uniqueID_gi);
    n_gd = numel(group1);
    n_gi = numel(group2);
    crosscorr_gd_collapsed = nan(n_gd,nbins*2-1);
    autocorr_gd_A_collapsed = nan(n_gd,nbins*2-1);
    autocorr_gd_B_collapsed = nan(n_gd,nbins*2-1);    
    crosscorr_gi_collapsed = nan(n_gi,nbins*2-1);
    autocorr_gi_A_collapsed = nan(n_gi,nbins*2-1);
    autocorr_gi_B_collapsed = nan(n_gi,nbins*2-1);  
    meanrate_gd_collapsed = nan(n_gd,2);
    meanrate_gi_collapsed = nan(n_gi,2);
    for i = 1:n_gd
        crosscorr_gd_collapsed(i,:) = mean(crosscorr_gd(strcmp(uniqueID_gd,group1{i}),:),1);
        autocorr_gd_A_collapsed(i,:) = mean(autocorr_gd_A(strcmp(uniqueID_gd,group1{i}),:),1);
        autocorr_gd_B_collapsed(i,:) = mean(autocorr_gd_B(strcmp(uniqueID_gd,group1{i}),:),1);
        meanrate_gd_collapsed(i,:) = mean(meanrate_gd(strcmp(uniqueID_gd,group1{i}),:),1);
        
    end
    for i = 1:n_gi
        crosscorr_gi_collapsed(i,:) = mean(crosscorr_gi(strcmp(uniqueID_gi,group2{i}),:),1);
        autocorr_gi_A_collapsed(i,:) = mean(autocorr_gi_A(strcmp(uniqueID_gi,group2{i}),:),1);
        autocorr_gi_B_collapsed(i,:) = mean(autocorr_gi_B(strcmp(uniqueID_gi,group2{i}),:),1);        
        meanrate_gi_collapsed(i,:) = mean(meanrate_gi(strcmp(uniqueID_gi,group2{i}),:),1);
    end
    
    % average stability scores by cell
    group1 = unique(uniqueID_gd_including_unstable);
    group2 = unique(uniqueID_gi_including_unstable);
    n_gd = numel(group1);
    n_gi = numel(group2);
    stab_zscore_gd = stab_zscore_gd(~isnan(stab_zscore_gd(:,1)),:);
    stab_zscore_gi = stab_zscore_gi(~isnan(stab_zscore_gi(:,1)),:);  
    stab_zscore_gd_collapsed = nan(n_gd,2);
    stab_zscore_gi_collapsed = nan(n_gi,2);
    for i = 1:n_gd
        stab_zscore_gd_collapsed(i,:) = mean(stab_zscore_gd(strcmp(uniqueID_gd_including_unstable,group1{i}),:),1);
    end
    for i = 1:n_gi
        stab_zscore_gi_collapsed(i,:) = mean(stab_zscore_gi(strcmp(uniqueID_gi_including_unstable,group2{i}),:),1);
    end
    
    % add to full data list
    uniqueID_all{ii} = uniqueID_gd;
    uniqueID_all{ii+2} = uniqueID_gi;
    uniqueID_all_including_unstable{ii} = uniqueID_gd_including_unstable;
    uniqueID_all_including_unstable{ii+2} = uniqueID_gi_including_unstable;
    meanrate_all{ii} = meanrate_gd_collapsed;
    meanrate_all{ii+2} = meanrate_gi_collapsed;
    stab_zscore_all{ii} = stab_zscore_gd_collapsed;
    stab_zscore_all{ii+2} = stab_zscore_gi_collapsed;
    crosscorr_all{ii} = crosscorr_gd_collapsed;
    crosscorr_all{ii+2} = crosscorr_gi_collapsed;
    autocorr_A_all{ii} = autocorr_gd_A_collapsed;
    autocorr_B_all{ii} = autocorr_gd_B_collapsed;
    autocorr_A_all{ii+2} = autocorr_gi_A_collapsed;
    autocorr_B_all{ii+2} = autocorr_gi_B_collapsed;  
    
end

% only keep second half of autocorr
for j = 1:4
    autocorr_A_all{j} = autocorr_A_all{j}(:,nbins:end);
    autocorr_B_all{j} = autocorr_B_all{j}(:,nbins:end);
end

%% create feature matrices
% 1: gain decrease
% 2: gain increase
% 3: gain decrease and gain increase

% file names
grid_fnames_all = {[],[]};
border_fnames_all = {[],[]};
grid_fnames_all{1} = strcat('FeatStruct_',unique(uniqueID_all{1}),'.mat');
grid_fnames_all{2} = strcat('FeatStruct_',unique(uniqueID_all{3}),'.mat');
border_fnames_all{1} = strcat('FeatStruct_',unique(uniqueID_all{2}),'.mat');
border_fnames_all{2} = strcat('FeatStruct_',unique(uniqueID_all{4}),'.mat');


% only keep cells that were not both grid and border cells
keep_grid = {[],[]};
keep_border = {[],[]};
grid_fnames_all_filt = {[],[],[]};
border_fnames_all_filt = {[],[],[]};
for i = 1:2
    keep_grid{i} = ~ismember(grid_fnames_all{i},border_fnames_all{i});
    keep_border{i} = ~ismember(border_fnames_all{i},grid_fnames_all{i});
    grid_fnames_all_filt{i} = grid_fnames_all{i}(keep_grid{i});
    border_fnames_all_filt{i} = border_fnames_all{i}(keep_border{i});
end

% get gain decrease and gain increase cross corrs
crosscorr_grid_filt{1} = crosscorr_all{1}(keep_grid{1},:);
crosscorr_border_filt{1} = crosscorr_all{2}(keep_border{1},:);
crosscorr_grid_filt{2} = crosscorr_all{3}(keep_grid{2},:);
crosscorr_border_filt{2} = crosscorr_all{4}(keep_border{2},:);

% get cells that had both gain increases and gain decreases
has_both_border1 = ismember(border_fnames_all_filt{1},border_fnames_all_filt{2});
has_both_border2 = ismember(border_fnames_all_filt{2},border_fnames_all_filt{1});
border_fnames_all_filt{3} = border_fnames_all_filt{1}(has_both_border1);
has_both_grid1 = ismember(grid_fnames_all_filt{1},grid_fnames_all_filt{2});
has_both_grid2 = ismember(grid_fnames_all_filt{2},grid_fnames_all_filt{1});
grid_fnames_all_filt{3} = grid_fnames_all_filt{1}(has_both_grid1);

% get cross corrs for cells that have both gain increases and gain
% decreases
crosscorr_grid_filt{3}{1} = crosscorr_grid_filt{1}(has_both_grid1,:);
crosscorr_grid_filt{3}{2} = crosscorr_grid_filt{2}(has_both_grid2,:);
crosscorr_border_filt{3}{1} = crosscorr_border_filt{1}(has_both_border1,:);
crosscorr_border_filt{3}{2} = crosscorr_border_filt{2}(has_both_border2,:);

% create and save feature matrices
for i = 1:3
    % grids
    n = numel(grid_fnames_all_filt{i});
    for j = 1:n
        if i==1 || i==2
            featStruct.cross_corr = crosscorr_grid_filt{i}(j,nbins-num_lags:nbins+num_lags);
            featStruct.cross_corr_gd = [];
            featStruct.cross_corr_gi = [];
        else
            featStruct.cross_corr = [];
            featStruct.cross_corr_gd = crosscorr_grid_filt{i}{1}(j,nbins-num_lags:nbins+num_lags);
            featStruct.cross_corr_gi = crosscorr_grid_filt{i}{2}(j,nbins-num_lags:nbins+num_lags);
        end
        save(strcat(datafolder,'FeatureMats/',sessiontype{i},'/',grid_fnames_all_filt{i}{j}), 'featStruct');
    end   
    
    % borders
    n = numel(border_fnames_all_filt{i});
    for j = 1:n
        if i==1 || i==2
            featStruct.cross_corr = crosscorr_border_filt{i}(j,nbins-num_lags:nbins+num_lags);
            featStruct.cross_corr_gd = [];
            featStruct.cross_corr_gi = [];
        else
            featStruct.cross_corr = [];
            featStruct.cross_corr_gd = crosscorr_border_filt{i}{1}(j,nbins-num_lags:nbins+num_lags);
            featStruct.cross_corr_gi = crosscorr_border_filt{i}{2}(j,nbins-num_lags:nbins+num_lags);
        end
        save(strcat(datafolder,'FeatureMats/',sessiontype{i},'/',border_fnames_all_filt{i}{j}), 'featStruct');
    end
end

% save params
for i = 1:3
    grid_fnames = grid_fnames_all_filt{i};
    border_fnames = border_fnames_all_filt{i};
    save(strcat(datafolder,'FeatureMats/',sessiontype{i},'/params.mat'),'thresh','grid_fnames','border_fnames');
end