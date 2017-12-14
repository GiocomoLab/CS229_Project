function [f,df] = poiss_negLLH(param,data,modelType)
% returns negative log likelihood of data given params 

v = data{1}; % speed
y = data{2}; % spike counts
dt = data{3}; % dt

if strcmp(modelType,'lin')
	rate = param(1)+param(2)*v;
elseif strcmp(modelType,'exp')
	rate = param(1)-param(2)*exp(-param(3)*v);
end

% negative log likelihood of observed firing rate given parameters
f = sum(rate.*dt-y.*log(rate.*dt));

% the gradient
if strcmp(modelType,'lin')
	df = [sum(dt-dt.*y./(rate.*dt)) sum(v.*(dt-dt.*y./(rate.*dt)))];
elseif strcmp(modelType,'exp') % fix this
	df = [sum(dt-dt.*y./(rate.*dt)) sum(-exp(-param(3)*v).*(dt-dt.*y./(rate.*dt))) sum(param(2)*v.*exp(-param(3)*v).*(dt-dt.*y./(rate.*dt)))];
end

end