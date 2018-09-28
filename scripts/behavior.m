function [ position, controlVel, controlPol, error, rotation, runnum, epochs, unity_struct, tdt_clock ] ...
                  = behavior( behaviorcells, pickuplocs, butndata, butnfs )
%BEHAVIOR Summary of this function goes here
%   Gets user's playing behavior for all runs 
%COMPUTE_BUTNALIGN Summary of this function goes here
%   ??

    if(~exist('butndata', 'var'))
        butndata = [];
    end
    col.time = 1;
    col.pos = [2 4];    %Avatar position
    col.vel = [5 6];    %Mouse/trackpad/control velocity
    col.button = 10;    %key that performs maze rotation
    col.pickup = 11;    %

    unity_struct = unitycsvextract(behaviorcells, col); %Gets pre-synced unity events
    position = cell2mat(behaviorcells(:, col.pos));
    controlVel = cell2mat(behaviorcells(:, col.vel));

    %Get button events
    rotationraw = unity_struct.events(:, 1);
    
    %Identifies run's orientation
    rotation = rotationraw;
    rotation(rotation >= 2000 | rotation < 1000) = 0;
    rotation = rotation - 1000;
    rotation(1) = 0;
    
    %total runs
    runnum = zeros(size(rotationraw));
    runnum(1) = 1;
    
    %Target IDs
    target = ones(size(unity_struct.events(:, 2))); 

    %Set target IDs by current maze orientation/pickup events
    for i = 2:length(rotationraw)
        if(rotation(i) == -1000)
            rotation(i) = rotation(i-1);
        end
        if(rotationraw(i) == 2000)
            runnum(i) = runnum(i-1)+1;
            target(i) = 1;
        else
            runnum(i) = runnum(i-1);
        end
        if(unity_struct.events(i, 2) ~= 0)
            target(i) = unity_struct.events(i, 2)+1;
            if(target(i) > 12)
                target(i) = 0;
            end
        else
            target(i) = target(i-1);
        end
    end
    


    %convert velocity cartesian into polar coordinates (theta, r)
    controlPol = nan(size(controlVel));
    [controlPol(:, 1), controlPol(:, 2)] = ...
        cart2pol(controlVel(:, 1), controlVel(:, 2));
    
    %resets targetID by mouse and target proximity
    tlocs = repmat(pickuplocs, 1, 1, length(position)); %replicated target locs for each target
    tlocs = permute(tlocs, [3 2 1]);    %[35528 x 2 x 12]
    
    % for lop here to run through unity_struct.events(:, 2)
    % as each event happens (whenever unity_struct.events(:, 2) ~= 0
    % that number j is used in distcoord(:, :, j) and set them to [999999,
    % 999999]
    % when unity_struct.events(:,1) == 2000, reset all the distcoord using
    % pickuplocs again    
    eaten_targets = unity_struct.events(:,2);
    track_targets = []; %tracks eaten targets per run 
    for i = 1:length(eaten_targets)
        if(length(track_targets) == 12 || unity_struct.events(i,1) == 2000) %reset
            track_targets = [];
        end
%             tlocs = abs(tlocs - repmat(position, 1, 1, 12));
        if(eaten_targets(i) ~=0)
                track_targets = [track_targets; eaten_targets(i)];
        end
        if(~isempty(track_targets))
            tlocs(i,:,track_targets) = repmat([99999,99999],1,1,length(track_targets));
        end
    end
    
    distcoord = abs(tlocs - repmat(position, 1, 1, 12));
    %Calculating distance between current avatar location and all targets
    dist = sqrt(squeeze(sum(distcoord.^2,2)));
    [min_val, indx] = min(dist,[],2); %indx = new target IDs
    difference = diff(indx);
    for i =1:length(difference)
%         difference = abs(indx(i+1) - indx(i)); 
%         if( diff == 4 || diff == 5)
        if( difference(i) >= 3 && difference(i) <= 6 && unity_struct.events(i,1) ~= 2000)
            indx(i+1) = indx(i); % resist change
        end
    end
    
       %Calculates angle error wrt target pickup
    error = struct();
    error.angle = zeros(size(rotationraw));
    for i = 1:length(rotationraw)
        if(controlPol(i, 2) > 0 && target(i) > 0)
            targetcoord = pickuplocs(target(i), :);
            error.angle(i) = ...
                acos(dot(targetcoord-position(i, :), controlVel(i, :)) / ...
                (norm(targetcoord-position(i, :)) * norm(controlVel(i, :))));
        end
    end 
        %Calculates angle error wrt target pickup (by closest target)
%     error = struct();
    error.angle2 = zeros(size(rotationraw));
    for i = 1:length(rotationraw)
        if(controlPol(i, 2) > 0 && indx(i) > 0)
            targetcoord = pickuplocs(indx(i), :);
            error.angle2(i) = ...
                acos(dot(targetcoord-position(i, :), controlVel(i, :)) / ...
                (norm(targetcoord-position(i, :)) * norm(controlVel(i, :))));
        end
    end
    
    %Define path epochs
    stop = find(unity_struct.events(:,2) ~= 0);
    start = [1; stop+1];
    epochs = [start [stop ;0]];
    epochs = epochs(1:end-1,:);
    

    
    %??
    tdt_clock = zeros(length(butndata)-1);
    if(~isempty(butndata))
        [~, butnlocs] = findpeaks(abs(butndata), 'MinPeakProminence', 0.5, 'MinPeakDistance', butnfs*0.036);
        unitylocs = unity_struct.clock(find(unity_struct.events(:, 1)));
        usenum = min(length(butnlocs), length(unitylocs(2:end)));
        offset = mean(butnlocs(end-usenum+1:end)/butnfs - unitylocs(end-usenum+1:end) + 0.0539);
        %0.0539 = button and audio delay
        
        unity_correct_clock = unity_struct.clock + offset;
        tdt_clock = (0:length(butndata)-1)'/butnfs; %time for each display update
        
        position = interp1(unity_correct_clock, position, tdt_clock, 'linear', 'extrap');
        controlVel = interp1(unity_correct_clock, controlVel, tdt_clock, 'linear', 'extrap');
        controlPol = interp1(unity_correct_clock, controlPol, tdt_clock, 'linear', 'extrap');
        error.angle = interp1(unity_correct_clock, error.angle, tdt_clock, 'linear', 'extrap');
        rotation = interp1(unity_correct_clock, rotation, tdt_clock, 'nearest', 'extrap');
    end
    
    
end

