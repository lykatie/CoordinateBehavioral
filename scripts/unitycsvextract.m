%Gets Unity events and sync event start times
function [unity_struct] = unitycsvextract( behaviorcells, col )

    %Unity Events of Interest
    % define columns with stuff in it
    col_time = col.time;        %Game start time
    col_button = col.button;    
    col_pickup = col.pickup;

    %Sync game start time 
    unity_struct = struct();
    % correct clock 40-second skips
    unity_rawclock = cell2mat(behaviorcells(:, col_time)); % read from column 1
    rawclock_diff = diff(unity_rawclock);
    rawclock_diff(rawclock_diff >= 40) = ... % subtract the nearest integer skip
        rawclock_diff(rawclock_diff >= 40) - fix(rawclock_diff(rawclock_diff >= 40));
    unity_struct.clock = cumsum([0; rawclock_diff]); % reconstruct the clock from 0 without integer skip
    
    % sanity check
    if(length(unity_struct.clock) ~= length(behaviorcells))
        error('clock processing broke');
    end
    

    unity_struct.events = zeros(length(unity_struct.clock), 2);
            % unity_struct.events(:, 1) is button events,
            % unity_struct.events(:, 2) is pickupnumber
                                            
    %%%%%% Convert button events into event timeline
    % unity_struct.events(:, 1) definitions:
    % 1000, 1045, 1090, 1180 = 0, 45, 90, 180 deg rotation
    % 2000 = Reset (game avatar position to beginning)
    % 2001 = Sync (no operation, sends sync pulse only)
    buttoncells = find(~cellfun(@isempty,strfind(behaviorcells(:, col_button), '!'))); % find all button events
    behaviorcells(buttoncells, col_button) = strrep(behaviorcells(buttoncells, col_button),' button',''); %remove
    behaviorcells(buttoncells, col_button) = strrep(behaviorcells(buttoncells, col_button),'!Position ',''); %remove
    behaviorcells(buttoncells, col_button) = strrep(behaviorcells(buttoncells, col_button),'!Reset','1000');
    behaviorcells(buttoncells, col_button) = strrep(behaviorcells(buttoncells, col_button),'!Sync','1001');
    trigcells = find(~cellfun(@isempty,strfind(behaviorcells(:, col_button), 'Trig')));
    behaviorcells(trigcells, col_button) = strrep(behaviorcells(trigcells, col_button),'Trig','');
    unity_struct.events(buttoncells, 1) = cellfun(@str2num, behaviorcells(buttoncells, col_button))+1000;
                                                                             % add 1000, so 1000 becomes 2000
    
    %%%%%% Convert trigger pickups into event timeline
    pickupcells = find(~cellfun(@isempty,strfind(behaviorcells(:, col_pickup), 'Pickup')));
    behaviorcells(pickupcells, col_pickup) = strrep(behaviorcells(pickupcells, col_pickup),'Pickup',''); %remove
    unity_struct.events(pickupcells, 2) = cellfun(@str2num, behaviorcells(pickupcells, col_pickup));
    
    %%% Sanity check
    if any((unity_struct.events(:, 1) == 0) ~= (cellfun(@isempty, behaviorcells(:, col_button))))
        error('button conversion failed')
    elseif any((unity_struct.events(:, 2) == 0) ~= ... 
            xor(cellfun(@isempty, behaviorcells(:, col_pickup)), unity_struct.events(:, 1)==2001))
        %!Sync events emits an extra (useless) column 11 depending on version,
        % which is xor'd against empty cells, which should compose all trigger
        % events
        error('pickup conversion failed')
    end
end