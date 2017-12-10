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

%% make firing rate and raster plots
meanrate = nan(N,1);
median_isi = nan(N,1);
burstiness = nan(N,1); % = 1/(meanrate * median_isi)
stability = nan(N,1);
trial_stability = nan(N,1);
for i = 1:N
    fprintf('cell %d/%d\n',i,N);
    
    % load cell data
    load(sprintf('%s%s_%s_%s.mat',datafolder,A.Mouse{i},A.SessionVR{i},A.Cell{i}));
    posx = celldata.bl.posx{1};
    trial = celldata.bl.trial{1};
    spike_idx = celldata.bl.spike_idx{1};
    
    % burstiness score
    meanrate(i) = numel(celldata.bl.spike_t{1})/max(celldata.bl.post{1});
    median_isi(i) = median(diff(celldata.bl.spike_t{1}));
    burstiness(i) = 1/(meanrate(i) * median_isi(i));
    stability(i) = celldata.bl.stability(1);
    
    if make_figures

        h = figure('Visible','off');
        plot(posx(spike_idx),trial(spike_idx),'r.','MarkerSize',10);
        xlim([params.TrackStart params.TrackEnd]);
        ylim([0 max(trial)+1]);
        title(sprintf('fr=%0.2f, b=%0.3f, isi=%0.2f\n, s=%0.3f, st=%0.3f, st/s=%0.3f\nfs=%0.3f',...
            celldata.bl.bursty_score));
        if save_figures
            saveas(h,sprintf('plots/all_cells/%s_%s_%s.png',A.UniqueID{i},A.SessionVR{i},A.Cell{i}),'png');
        end
    end
end