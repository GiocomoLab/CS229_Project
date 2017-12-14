function [c,ceq] = min_fr_lin_model(x)
% for fitting saturating exponential
% nonlinear constraint that firing rate >= 0 (linear model)
% (i.e. c <= 0)
% MGC 12/6/16
c = -min(x(1)+x(2)*(2:0.1:100));
ceq = [];
end