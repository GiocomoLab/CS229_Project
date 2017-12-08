function firing_rate = calculateSmoothedFiringRate(idx,posx,dt,p,binedges,smoothWindow)
% calculates smoothed firing rate from spike index and pos data
% Malcolm Campbell 5/21/15

% edited 4/7/2017 MGC
% No longer assumes that average frame length is the same in each position
% bin; instead takes an input, dt, which is the length of each time bin.
% Average frame length is computed in each position bin separately.
% Also made firing rate computed by fixed bin edges rather than number of
% bins.
    
    noTaper = 1; % smooths to avoid taper at ends
    if ~exist('p','var')
        p = readtable('UniversalParams.xlsx');   
    end
    if ~exist('binedges','var')
        binedges = p.TrackStart:p.BinSize:p.TrackEnd;
    end
    if(~exist('smoothWindow','var'))
        smoothWindow=round(3*5/p.BinSize);
        if mod(smoothWindow,2)==0
            smoothWindow = smoothWindow+1;
        end
    end
    
    % calculate firing rate
    nbins = numel(binedges)-1;
    if isempty(idx)
        firing_rate = zeros(1,nbins);
    else        
        [~,bin] = histc(posx, binedges);
        time_per_bin = nan(nbins,1);
        for i = 1:nbins
            time_per_bin(i) = sum(dt(bin==i));
        end
        firing_rate = histc(posx(idx), binedges);
        firing_rate = reshape(firing_rate(1:nbins),size(time_per_bin))./time_per_bin;   
        firing_rate(time_per_bin==0) = 0;

        % smooth firing rate
        gauss_filter = fspecial('gaussian',[smoothWindow 1], 1);
        if noTaper
            firing_rate = conv([repmat(firing_rate(1),floor(smoothWindow/2),1); firing_rate; ...
                repmat(firing_rate(end),floor(smoothWindow/2),1)],gauss_filter,'valid');
        else
            firing_rate = conv(firing_rate,gauss_filter,'same');
        end

        firing_rate = firing_rate';
    end
end