function [pvalue,param_lin,param_exp,speed,fr] = LLH_model_comparison_VR(spike_t,speed,post,nonNegativeFiringRate)
% The boolean variable nonNegativeFiringRate indicates whether or not to
% include the restraint that the model's firing rate be non-negative
% MGC 12/6/2016
%
% updated 7/13/17 for new data format

if ~exist('nonNegativeFiringRate','var')
    nonNegativeFiringRate = 1;
end

% threshold for speed and other options
speedThreshold = 2;

% get vector of spike counts in each bin
spikeCounts = hist(spike_t,post);
spikeCounts = reshape(spikeCounts,size(post));
dt = diff(post); 
dt = [dt; mean(dt)];
fr = spikeCounts./dt; % change to units of Hz
fr = gauss_smoothing(fr,20);  % smooth with gaussian kernel (sigma=20)

% throw out bins with speeds below threshold
select = speed > speedThreshold; 
speed = reshape(speed,size(post));
speed = speed(select);
fr = fr(select);
spikeCounts = spikeCounts(select);
dt = dt(select);

data{1} = speed;
data{2} = spikeCounts;
data{3} = dt;

meanRate = sum(spikeCounts)/max(post);
init1 = [meanRate 0];
keep1 = speed>prctile(speed,90); keep2 = speed<prctile(speed,5);
a1 = sum(spikeCounts(keep1))/sum(dt(keep1));
a2 = a1-sum(spikeCounts(keep2))/sum(dt(keep2));
a3 = log(2)/mean(speed(spikeCounts==median(spikeCounts)));
init2 = [a1 a2 a3];
opts_fminunc = optimoptions('fminunc','Gradobj','on','Hessian','off','Display','off','Algorithm','trust-region');
opts_fmincon = optimoptions('fmincon','GradObj','on','Hessian','off','Display','off');
if nonNegativeFiringRate
    % use fmincon with a constraint that the minimum firing rate
    % over speed = 2:0.1:100 be non-negative (for saturating fit only - 
    % this constraint on linear fits led to issues)
    A = []; b = []; Aeq = []; beq = []; ub = []; lb = [0 0 0];
    nonlincon = @min_fr_exp_model;
    
    param_exp = fmincon(@(param) poiss_negLLH(param,data,'exp'),init2,A,b,Aeq,beq,lb,ub,nonlincon,opts_fmincon);
else
    % no constraints
    param_exp = fminunc(@(param) poiss_negLLH(param,data,'exp'),init2,opts_fminunc);
end
% no constraints on linear fit (led to issues)
param_lin = fminunc(@(param) poiss_negLLH(param,data,'lin'),init1,opts_fminunc);

D = 2 * (poiss_negLLH(param_lin,data,'lin') - ... 
	poiss_negLLH(param_exp,data,'exp'));

pvalue = 1-chi2cdf(D,1);

end