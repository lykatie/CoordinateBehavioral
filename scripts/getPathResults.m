function results = getPathResults(error, rotation, epochs, unity_struct)
    %Returns the path, path t, and run per orientation
    %unity_struct.events(:,2) ----> zeros till eats a target
    results = cell(1,5); 

    %Column IDs

    str_col = 1;    % string of unique paths
    t_col = 2;      % accumulated time by path
    err_col = 3;    % accumulated cosine error by path
    rot_col = 4;    % rotation value 
    run_col = 5;    % run per orientation

    start = 0;           %start time
    results{end, 2} = 0; %initialize cell
    eaten_tar = [0];     %stores targets in the eaten order


    %Identifies path ID's and path time
    for i = 1: length(unity_struct.events(:,2)) %epoch-ing
        current_tar = unity_struct.events(i,2);

        if(current_tar ~= 0) %Identifies eaten target ---> path change
            if((current_tar == 1 && eaten_tar(end) == 12) ...
                                      || unity_struct.events(i,1) == 2000) %restarting run
                eaten_tar = [eaten_tar ; 0];
            end
            eaten_tar = [eaten_tar; current_tar];
            tar_path = strcat(num2str(eaten_tar(end-1)), '->', num2str(eaten_tar(end)));

            results{end, str_col} = tar_path;
            results{end, t_col} = i - start;

            start = i;
            results{end+1, t_col} = 0;

        end

    end

    %Fill cosine error column
    for i=1:length(epochs)
        errsum = sum(error.angle2(epochs(i,1):epochs(i,2)));
        results(i,err_col) = num2cell(errsum);
    end

    %Find rotation col
    results(1:end-1,rot_col) = num2cell(rotation(epochs(:,2)));
    
    %Fill run per orientation column
    results(:,run_col) = num2cell(zeros(1,length(results)));
    rots = unique([results{:,rot_col}]);
    for i=1:length(rots) %find rotation
        count=1;
        rot_mask = double( [results{:,rot_col}] == rots(i) );
        rot_mask = [rot_mask 0];
        for j=1:length(rot_mask)-1 %find where rotations occur
            if(rot_mask(j) == 1)
                rot_mask(j) = count;
                if(rot_mask(j+1) == 0)%when rotations end
                    count = count +1;
                end
            end
        end
        results(1:end-1,run_col) = num2cell( [results{1:end-1,run_col}] + rot_mask(1:end-1));
    end
    
    results = results(1:end-1,:);
end



    
