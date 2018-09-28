function geterrbarplot(data, labels, orderindx, graph_title)
    figure;
    hold on;
    for i=1:length(data)
        errorbar(i, mean([data{i}{:}]), std([data{i}{:}])/...
                                             sqrt(length([data{i}{:}])), 'o-') 
        hold on;
    end
    title(graph_title)
    xticklabels(labels(orderindx))
    xlim([0 length(data)])
    xticks([1:1:length(data)])
    xtickangle(90)

end