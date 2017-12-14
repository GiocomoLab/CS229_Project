function speed = calcSpeed(posx,post,smoothingSigma)
% function to calculate speed from position and time data
% Malcolm Campbell 5/21/15
%
% Modified to make smoothing use the gauss_smoothing function
% Third argument is now smoothing sigma, not smoothing window size
% MGC 2/25/17
    
    if ~exist('smoothingSigma','var')
        smoothingSigma = 0;
    end
    
    dift = diff(post);
    difx = diff(posx);
    speed = difx./dift;
    speed(speed > 150) = NaN;
    speed(speed<-5) = NaN;
    speed(isnan(speed)) = interp1(find(~isnan(speed)), speed(~isnan(speed)), find(isnan(speed)), 'pchip'); % interpolate NaNs
    speed = [0;speed];
    if smoothingSigma>0
        speed = gauss_smoothing(speed,smoothingSigma);
    end

end