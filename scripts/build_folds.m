function fold_inds = build_folds(N,k)

%Make Folds for k-fold cross-validation
order = randperm(N);
% fill folds so that they are similar size
fold_inds = cell(k,1);
counter = 0;
while ~isempty(order)
    i = mod(counter,k)+1;
    fold_inds{i} = [fold_inds{i}; order(1)];
    order(1) = [];
    counter = counter+1;
end

end