%Main: Visuomotor Behavior Quantification Analysis 
%Extracts and stores data from all partcipants
%Analyzes user's quality performance w/ following quantification methods:
%   -Target execution by target angle error 
%   -Playing duration (total and each run)
%   -Straight vs corner path performance ( angle error and time?)
%   --------------add other methods----------

% List all available data, one .csv per session*subject
filelist = dir('data_processed/*.csv');
% Load the canonical list of where the targets are
load('pickuplocs.mat');
% Start an empty struct: this is where the results of the data processing
% go, into errorresult
% errorresult.
errorresult = struct();
pathSummary = struct();

%% attempt to load brain & sync data
% for i = 1:numel(filelist)
%     neuraldataname = ['data_neural/' filelist(1).name '.mat']
%     loadsynchronizedbrain(neuraldataname, tactdata(:, 1))
% end

%% attempt to load behavioral data
for i = 1:numel(filelist)
    errorresult(i).name = filelist(i).name;
    pathSummary(i).name = filelist(i).name;
    filename = ['data_processed/' filelist(i).name];
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, '%f%f%f%f%f%f%f%f%f%s%s%[^\n\r]', 'Delimiter', ',', 'EmptyValue' ,NaN, 'ReturnOnError', false);
    fclose(fileID);
    
    %Convert the 2-layer cell type from textscan into a one-layer cell and
    %trim the last column. Still cells but note that columns 10 and 11 are
    %NOT continuous - most are empty
    dataArray([1, 2, 3, 4, 5, 6, 7, 8, 9]) = cellfun(@(x) num2cell(x), dataArray([1, 2, 3, 4, 5, 6, 7, 8, 9]), 'UniformOutput', false);
    behaviordat = [dataArray{1:end-1}];
    
%     unity_struct = unitycsvextract( behaviorcells, col );

    
    %Extracts user's total playing behavior(sync to tdt axes)
    [position, controlVel, controlPol, error, rotation, runnum, epochs, unity_struct, tdtclock] = behavior(behaviordat, pickuplocs);
    
    %Quantification Methods
    [~, ~, errorresult(i).runerror, errorresult(i).meanerror, errorresult(i).sderror] = summaryerror(error, rotation, runnum);
%     [errorresult(i).straight, errorresult(i).corner, errorresult(i).tot_time] = summaryPath(position, controlPol, indx, unity_struct, pickuplocs);
%     pathSummary(i).results = getPathResults(error, rotation, unity_struct);
    results = getPathResults(error, rotation, epochs, unity_struct);
    T = table(epochs(:,1),epochs(:,2), results(:,1), results(:,2), results(:,3), results(:,4), results(:,5), ...
        'VariableNames', {'start','stop', 'path', 'execution_time', 'cum_cosine_error', 'rotation', 'run_per_rot'} );
    save([filename '_table.mat'], 'T')
    
end
% clearvars filename fileID dataArray ans;
% save('T113318behav', 'T113318behav');

%%
%Store total runerror sum 
orientation = [0 45 90 180];
for i = 1:numel(filelist)
    total = zeros(length(orientation), 3); %4x3 matrix
    for j =1:numel(orientation)
        mask = logical(zeros(length(errorresult(i).runerror),1));
        mask = errorresult(i).runerror(:,3) == orientation(j);
        total(j, 1) = sum(errorresult(i).runerror(mask,1));
        total(j, 2) = sum(errorresult(i).runerror(mask,2));
        total(:,3) = orientation;
    end
    errorresult(i).runerror_total = total;
end



%stores all errorangle sums for each orientation and each file
% [25(files), 2(error angles), 4(orientations)]
file_sum = zeros(numel(filelist),2,length(orientation)); 
for i=1:size(file_sum,1)
    for j=1:size(file_sum, 2)
        for k=1:size(file_sum,3)
            file_sum(i,j,k) = errorresult(i).runerror_total(k,j);
        end
    end
end

%mean/stdev of all files by orientation
errmean = zeros(length(orientation), 3);
errstdev = zeros(size(errmean));
for i=1:size(errmean,1)
    for j=1:size(errmean,2)-1
        errmean(i,j) = mean(file_sum(:,j,i));
        errstdev(i,j) = std(file_sum(:,j,i)) / sqrt(length(file_sum)); %divide by sqrt(number of elements)
    end
end

%%
%plot angle error
figure;
errorbar(orientation, errmean(:,1), errstdev(:,1), 'o-')
hold on
errorbar(orientation, errmean(:,2), errstdev(:,2), 'ro-')

    
%%
%Plot straight vs corner behavior error
s_vals = zeros(length(errorresult),1);
c_vals = s_vals;
for i=1:length(errorresult)
    s_vals(i) = errorresult(i).straight;
    c_vals(i) = errorresult(i).corner; 
end

figure;
errorbar([1], mean(s_vals), std(s_vals)/ sqrt(numel(s_vals)), 'o-')
hold on
errorbar([2], mean(c_vals), std(c_vals)/ sqrt(numel(c_vals)), 'ro-')
%%

% figure; 
% 
% for i=1:length(position)
%     plot(pickuplocs(:,1), pickuplocs(:,2), 'rx-','LineWidth', 3, 'MarkerSize', 3)
%     plot(position(i,1), position(i,2),'bo')
%     xlim([-10 10])
%     ylim([-10 10])
%     hold on
%     pause(0.0001)
% end

%%
%plot path behavior by each consecutive target path
% tar_paths = cell(0,0);
% for i=1:length(pathSummary)
%         tar_paths= horzcat(tar_path,pathSummary(i).results(1,:));
% end
% tar_paths = unique(tar_paths(2:end));
% 
% path_t = cell(1,length(tar_paths));
% for i=1:length(pathSummary)
%    for j=1:length(pathSummary(1).results)
%        loc = find(cellfun(@(x) strcmp(x, pathSummary(i).results(1,j)), tar_paths));
%        path_t(loc) = pathSummary(i).results(2,j);
%    end
% end

% path_t = zeros(length(pathSummary), length(tars));
% for i=1:length(path_t)
%     path_t(i,:) = pathSummary(i).results;
% end
% figure; 
% for i=1:length(tars)
%     errorbar([tars(i)], mean(path_t(:,tars(i))), std(path_t(:,tars(i)))/ sqrt(numel(path_t(:,tars(i)))), 'o-')
%     hold on
% end



%%
%Plot path times with every unique target path across all
%participants/trials

tar_paths = cell(0,0);
for i=1:length(pathSummary)
        tar_paths= vertcat(tar_paths,pathSummary(i).results(:,2));
end
tar_paths = unique(tar_paths); %find all unique paths across all participants/trials

%contains # of path occurances(length of 1 cell) and path t for each instance
path_t = cell(length(tar_paths),1); 
for i=1:length(pathSummary)
   for j=1:length(pathSummary(i).results)
       loc = find(cellfun(@(x) strcmp(x, pathSummary(i).results(j,2)), tar_paths));
       temp = vertcat(path_t{loc},pathSummary(i).results(j,3));
                           %unload path_t cell at loc
       path_t(loc) = {temp};
   end
   path_t;
end

path_err = cell(length(tar_paths),1);
for i=1:length(pathSummary)
   for j=1:length(pathSummary(i).results)
       loc = find(cellfun(@(x) strcmp(x, pathSummary(i).results(j,2)), tar_paths));
                %index location of path in the list of all path instances(tar_paths)
       temp = vertcat(path_err{loc},pathSummary(i).results(j,4));
                           %unload path_t cell at loc
       path_err(loc) = {temp};
   end
end

%%

%Plots path frequency 
figure;
hold on;
pathcounts = arrayfun(@(i) length([path_t{i}{:}]), 1:length(path_t));
[sortpathcounts, sortidx] = sort(pathcounts, 'Descend');
bar(sortpathcounts)

title('path frequency')
xticklabels(tar_paths(sortidx))
xlim([0 length(path_t)])
xticks([1:1:length(path_t)])
xtickangle(90)
%%
%Plots mean accumulated path t
figure;
hold on;
for i=1:length(path_t)
    errorbar(i, mean([path_t{i}{:}]), std([path_t{i}{:}])/...
                                         sqrt(length([path_t{i}{:}])), 'o-') 
    hold on;
end
% title('avg path t')
xticklabels(tar_paths(sortidx))
xlim([0 length(path_t)])
xticks([1:1:length(path_t)])
xtickangle(90)

%%
%Plots accumulated time by path
figure;
hold on;
for i =1:length(path_t)
    bar(i, sum([path_t{i}{:}]))
    hold on;
end
title('accumulated time for each path')
xticklabels(tar_paths(sortidx))
xlim([0 length(path_t)])
xticks([1:1:length(path_t)])
xtickangle(90)

%Plots accumulated cosine error by path
figure;
for i=1:length(path_err)
    bar(i, sum([path_err{i}{:}]))
    hold on;
end
title('accumulated cosine error by path')
xticklabels(tar_paths(sortidx))
xlim([0 length(path_t)])
xticks([1:1:length(path_t)])
xtickangle(90)

%%
