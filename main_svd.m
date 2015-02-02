% userId::movieId::rating::timestamp

clear all;
clc;

% Ratings matrix
n_users = 5;
n_products = 5;
a = rand(n_users,n_products)>0.8;
b = rand(n_users,n_products)>0.8;
c = rand(n_users,n_products)>0.8;
ratings = a + 2*b + 3*c;

rk = 5;

users = ones(n_users, rk)*0.1;
products = ones(n_products, rk)*0.1;

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
           for p = 1:n_products
               for u = 1:n_users

                   % Only the non-zero ratings count
                   if (ratings(u,p) == 0)
                       continue;
                   end

                   % Compute the predict rating
                   predictions(u,p) = users(u,:) * products(p,:)';

                   % Compute the corresponding error
                   err = ratings(u,p) - predictions(u,p) ;

                   % Compute the next value of the current feature for both
                   % user and product
                   users(u,k) = users(u,k) + lrate * ( err * products(p,k) - lambda * users(u,k));
                   products(p,k) = products(p,k) + lrate * ( err * users(u,k) - lambda * products(p,k));
               end
           end
       end

   end

   % RMSE computation
   rmse = 0;
   n = 0;
   for p = 1:n_products
       for u = 1:n_users
           % Only the non-zero ratings count
           if (ratings(u,p) == 0)
               continue;
           end
           rmse = rmse + (ratings(u,p) - predictions(u,p))^2;
           n = n + 1;
       end
   end
   rmse = rmse / n;
   hist_rmse = [hist_rmse rmse];
end

% Plot the training error
semilogy(1:100,hist_rmse)

% Inspection: see the predictions matrix and its rounded values
predictions
round(predictions)

% Compare it to the ratings matrix: it should be the same
ratings - round(predictions)

error = sum(sum(ratings - round(predictions)))

% The product of the two matrices will give us the predicted ratings
round(products*users')'