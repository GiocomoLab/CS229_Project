function rho = calculateSpatialStability(idx,posx,post,dt,p)
% function to calculate spatial stability by correlating firing rate in
% first half of trial with second half
%
% modified 6/27/17 to work with newer firing rate function
    
    if ~exist('p','var')
        p = readtable('UniversalParams.xlsx');
    end
    
    recording_length = max(post);
    idx1 = idx(post(idx)<recording_length/2);
    idx2 = idx(post(idx)>=recording_length/2)-sum(post<recording_length/2);
    posx1 = posx(post<recording_length/2);
    posx2 = posx(post>=recording_length/2);
    dt1 = dt(post<recording_length/2);
    dt2 = dt(post>=recording_length/2);
    
    fr1 = calculateSmoothedFiringRate(idx1,posx1,dt1,p);
    fr2 = calculateSmoothedFiringRate(idx2,posx2,dt2,p);
    
    rho = corr(fr1',fr2');

end