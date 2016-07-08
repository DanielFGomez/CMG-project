names=cellstr(['  Mean  Performance   ';...
               '  Performance Variance';...
               ' num Good Performances';...
               '  Worst Performance   ';...
               'First Good Performance']);

for j=1:5
    figure
    for i=1:10

        subplot(3,4,i)
        surf(Test(:,:,i,j))
        ylabel('\alpha')
        xlabel('\gamma')
        title(strcat('explore=', num2str((i-1)/10)));
    end
    suptitle(names(j));
end