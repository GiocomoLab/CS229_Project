
load baseline_classifier_results

% plot example confusion matrices

% gb vs non gb
cmat = results{1,1}.gda.cmat_test;
cmat = cmat/sum(sum(cmat));
figure(1); imagesc(cmat);
text(.9,1,sprintf('%.2f',cmat(1,1)),'FontSize',14);
text(.9,2,sprintf('%.2f',cmat(2,1)),'FontSize',14);
text(1.9,1,sprintf('%.2f',cmat(1,2)),'FontSize',14);
text(1.9,2,sprintf('%.2f',cmat(2,2)),'FontSize',14);
xlabel('Predicted Labels'); ylabel('True Labels');
set(gca,'XTick',[1,2],'XTickLabel',{'0','1'},'YTick',[1 2],'YTickLabel',{'0','1'});



% grid v non grid
cmat = results{2,1}.gda.cmat_test;
cmat = cmat/sum(sum(cmat));
figure(2); imagesc(cmat);
text(.9,1,sprintf('%.2f',cmat(1,1)),'FontSize',14);
text(.9,2,sprintf('%.2f',cmat(2,1)),'FontSize',14);
text(1.9,1,sprintf('%.2f',cmat(1,2)),'FontSize',14);
text(1.9,2,sprintf('%.2f',cmat(2,2)),'FontSize',14);
xlabel('Predicted Labels'); ylabel('True Labels');
set(gca,'XTick',[1,2],'XTickLabel',{'0','1'},'YTick',[1 2],'YTickLabel',{'0','1'});


% border v non-border
cmat = results{3,1}.gda.cmat_test;
cmat = cmat/sum(sum(cmat));
figure(3); imagesc(cmat);
text(.9,1,sprintf('%.2f',cmat(1,1)),'FontSize',14);
text(.9,2,sprintf('%.2f',cmat(2,1)),'FontSize',14);
text(1.9,1,sprintf('%.2f',cmat(1,2)),'FontSize',14);
text(1.9,2,sprintf('%.2f',cmat(2,2)),'FontSize',14);
xlabel('Predicted Labels'); ylabel('True Labels');
set(gca,'XTick',[1,2],'XTickLabel',{'0','1'},'YTick',[1 2],'YTickLabel',{'0','1'});

