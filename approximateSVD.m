ratings = implicit_ratings_morning;

% Factor of dimensionality reduction
rk = 5;

nr_stbs = length(stbs);
nr_channels = length(channels);
    
stbs = ones(nr_stbs, rk)*0.1;
channels = ones(nr_channels, rk)*0.1;

predictions = zeros(size(ratings));
lrate = 0.001;
lambda = 0.02;
hist_rmse = [];

% Compute several steps of the coordinate descent
for steps=1:100

   % Descend one coordinate at a time
   % This corresponds to the computation of an individual feature
   for k =1:rk
 
       % Iterate several times through the ratings matrix
       % Each iteration correspondes to an lrate increment along the
       % current coordinate axis
       for it=1:100

           % Iterate through the ratings matrix
           for s = 1:nr_stbs
               for c = 1:nr_channels
                   
                   implicit_rating = full(ratings(s,c));
                   
                   % Only the non-zero ratings count
                   if (implicit_rating == 0)
                       continue;
                   end
                                   
                   % Compute the predict rating
                   predictions(s,c) = stbs(s,:) * channels(c,:)';

                   % Compute the corresponding error
                   err = implicit_rating - predictions(s,c) ;
                    
                   % Compute the next value of the current feature for both
                   % user and product
                   stbs(s,k) = stbs(s,k) + lrate * ( err * channels(c,k) - lambda * stbs(s,k));
                   channels(c,k) = channels(c,k) + lrate * ( err * stbs(s,k) - lambda * channels(c,k));
               end
           end
          
       end

   end

   % RMSE computation
   rmse = 0;
   n = 0;
   for s = 1:nr_stbs
       for c = 1:nr_channels
           
           implicit_rating = full(ratings(s,c));
           
           % Only the non-zero ratings count
           if (implicit_rating == 0)
               continue;
           end
           
           rmse = rmse + (ratings(s,c) - predictions(s,c))^2;
           n = n + 1;
       end
   end
   rmse = rmse / n
   hist_rmse = [hist_rmse rmse];
end

% Plot the training error
%semilogy(1:100,hist_rmse)

% Inspection: see the predictions matrix and its rounded values
%predictions;
%round(predictions);

% Compare it to the ratings matrix: it should be the same
%ratings - round(predictions);

%error = sum(sum(ratings - round(predictions)));

% The product of the two matrices will give us the predicted ratings
%round(stb*channels')'