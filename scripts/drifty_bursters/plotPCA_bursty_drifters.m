% Plot PCs of drifty bursters to see approximately how well we should do

% get data
feats = readtable('labeled_dataset_large.xlsx');
X = table2array(feats(:,[3:6 8:10]));
Y = 1*(table2array(feats(:,11))>0);

% do pca
X = zscore(X,[],1);
[COEFF, SCORE, LATENT] = pca(X);


% get projections
Xred = X*COEFF;

% plot classes in 2D and 3D
figure; hold on;
scatter(Xred(Y==0,1),Xred(Y==0,2),[],'rx')
scatter(Xred(Y==1,1),Xred(Y==1,2),[],'bo')
xlabel('PC1'); ylabel('PC2');
legend('Y=0','Y=1');



figure; hold on;
scatter3(Xred(Y==0,1),Xred(Y==0,2),Xred(Y==0,3),[],'rx')
scatter3(Xred(Y==1,1),Xred(Y==1,2),Xred(Y==1,3),[],'bo')
xlabel('PC1'); ylabel('PC2'); zlabel('PC3');