function [implicit_ratings_morning, stbs, channels] = compute_urm()

%
%% Init matrices: channels, set-top-boxes (stbs).
[stbs, channels] = init_matrices();


%% Compute Rating Matrix
[implicit_ratings_morning] = compute_ratings(stbs, channels, 'morning');
    
end


function [implicit_ratings] = compute_ratings(stbs, channels, period)

     %% Initialize Matrix
    
    % Number of elements of channels and set-top-boxes
    nr_stbs = length(stbs);
    nr_channels = length(channels);
    implicit_ratings = sparse(nr_stbs, nr_channels);
    
    % Make the connection with database
    conn = database('orcl', 'system', 'informatica','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@localhost:1521:orcl');
    setdbprefs('DataReturnFormat','cellarray');
    
    percentage_viewed = [];
    % For morning periods
    if (strcmp(period, 'morning')==1)
        percentage_viewed = fetch(conn,'select box_id, channel_id, sum(percentage_viewed) from iptv_morning group by box_id, channel_id');
    end
    close(conn);
    
    %% Fill Implicit Ratings
    n_elements = length(percentage_viewed);
    for i=1:n_elements
       stb_id = percentage_viewed{i,1};
       channel_id = percentage_viewed{i,2};
       
       index_stb = find(strcmp(stb_id,stbs) == 1);
       index_channel = find([channels{:,1}] == channel_id);
       
       implicit_ratings(index_stb, index_channel) = percentage_viewed{i,3}; 
    end
    

end

function [stbs, channels] = init_matrices()
    %% Initialize Matrix
    % Make the connection with database
    conn = database('orcl', 'system', 'informatica','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@localhost:1521:orcl');

    % Exec function to open a cursor and execute an SQL statement
    setdbprefs('DataReturnFormat','cellarray');
    stbs = fetch(conn,'select distinct(box_id) from iptv_processed');
    channels = fetch(conn,'select distinct(channel_id) from iptv_processed');
    close(conn);
end

