% Time spent on straight or corner paths of the maze
function [straight, corner, totTime] = summaryPath(position, controlPol, indx, unity_struct, pickuplocs)

    %Defining Paths by target to target (y = mx + b)
    x = [position(1,1); pickuplocs(:,1)];
    y = [position(1,2); pickuplocs(:,2)];
    m = zeros(size(x));
    b = zeros(size(m));
    for i=1:length(m)-1
       m(i) = (y(i+1) - y(i))/( x(i+1) - x(i) );
       if( m(i) == Inf) 
           m(i) = 0;
       end
       b(i) = y(i) - (m(i)*x(i));
    end
%%
    % %double check slope equation, note: last row should = 0
    y == m.*x + b;
%%
    corner_targets = [ 5; 6;8;9; 10];
    corner = 0; %total time spent in corner
    iscorner = false;
    start = 2;
%     stop = 0;
%     figure; plot(position(:,1), position(:,2),'b-')
%     hold on
    for i = 1: length(indx)  %epoch
        if ( ismember(indx(i), corner_targets) ) 
            if (~iscorner)
                start = i;
                iscorner = true;
            end
%             plot(position(i,1), position(i,2),'ro-')
%             hold on
        end
        if (~ismember(indx(i), corner_targets) && iscorner)
%             stop = i;
            iscorner = false;
            corner = corner + (unity_struct.clock(i) - unity_struct.clock(start) );
        end
    %     if (indx(i) == 0)
    end

    totTime = unity_struct.clock(end) - unity_struct.clock(2);
    straight = totTime - corner;
%%
    %Calculate wall-smacking behavior
    wall = 0; %total time spent wall-smacking
    positionPol = nan(size(position));
    [positionPol(:, 1), positionPol(:, 2)] = ...
                                  cart2pol(position(:, 1), position(:, 2));
    

%%




end