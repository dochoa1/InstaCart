library(tidyverse)

# Reading In The Data (currently using 20% of total data)
orders <- read_csv("../Source/orders_sample40.csv")
order_products <- read_csv("../Source/order_products_sample40.csv")


# Preparing the Data

"Cleaning the data by changing variable types"
orders$eval_set <- as.factor(orders$eval_set)

"We want to build our model only on the `prior` dataset."
orders_prior <- 
  orders %>%
  filter(eval_set == "prior")

order_products_prior <-
  order_products %>%
  inner_join(orders_prior, by="order_id")


"We are going to want the results of the `train` dataset for cross-validation later."
orders_train <- 
  orders %>%
  filter(eval_set == "train")

order_products_train <-
  order_products %>%
  inner_join(orders_train, by="order_id")

rm(order_products)


#Feature Engineering

"We are going to want data specific to each user, each product, and each user-product interaction.
The features that come in the vanilla datasets aren't quite telling enought so we are going to build some of our own."

## Feature Engineering: Products

prods <- order_products_prior %>%
  arrange(user_id, order_number, product_id) %>%
  group_by(user_id, product_id) %>%
  mutate(product.numTimes = row_number()) %>% #  Number of times this product has appeared so far for this user
  ungroup() %>%
  group_by(product_id) %>%
  summarise(product.orders = n(),
            product.reorders = sum(reordered),
            product.avgDaysSincePriorOrder = mean(days_since_prior_order, na.rm=TRUE),
            product.firstOrders = sum(product.numTimes == 1), # number of users that have ordered this product
            product.secondOrders = sum(product.numTimes == 2)) %>% # number of users that ordered this product more than once
  mutate(product.reorderProbability = product.secondOrders / product.firstOrders) %>%
  mutate(product.avgTimesOrdered = 1 + product.reorders / product.firstOrders) %>%
  mutate(product.reorderRatio = product.reorders / product.orders) %>%
  select(-product.reorders, -product.firstOrders, -product.secondOrders)


## Feature Engineering: Users

"Adding user specific features"

users <- orders_prior %>%
  group_by(user_id) %>%
  summarise(user.numOrders = max(order_number),
            user.useInterval = sum(days_since_prior_order, na.rm=TRUE))


"Some user specific features require data on the number of products they order"

user_products <- order_products_prior %>%
  group_by(user_id) %>%
  summarise(user.reorderRatio = sum(reordered == 1) / sum(order_number > 1))

users <- users %>%
  inner_join(user_products, by="user_id")

rm(user_products)


"Finally let's add the `test` and `train` orders for each user to the users table to be used 
later for predictions (days_since_prior_order) and in seperating of cross-validation and test prediction sets."

users_finalOrder <- orders %>%
  filter(eval_set != "prior") %>%
  select(user_id, order_id, days_since_prior_order, eval_set)

users <- users %>% 
  inner_join(users_finalOrder, by="user_id")

rm(users_finalOrder, orders)


## Feature Engineering: User-Product

### Order Streak Feature

"This feature is going to keep track of how many consecutive orders before the current order has a specific user
ordered a specific product. The intution behind this is that if a user has ordered a given product every order 
of their past n orders, than as n gets larger, we expect this user to order this product again with high likelihood."

user_product_streak <- order_products_prior %>%
  arrange(user_id, product_id, order_number) %>%
  select(user_id, order_number, product_id) %>%
  mutate(user_product.order_streak = if_else(lag(order_number) == order_number - 1 & lag(product_id) == product_id & lag(user_id) == user_id, 0, 1, 1)) %>%  # 1 when new 'streak group' begins, 0 when streak group continues
  group_by(cumsum(user_product.order_streak), user_id) %>% #Puts each member of streak group in same numeric group
  mutate(user_product.order_streak = row_number()) %>%  
  ungroup() %>%
  group_by(user_id, product_id) %>%
  filter(order_number == max(order_number)) %>% # Only want the latest order for each product
  ungroup() %>%
  group_by(user_id) %>%
  mutate(user_product.order_streak = if_else(order_number == max(order_number), as.numeric(user_product.order_streak), 0, 0)) %>% #streak is 0 if product latest order was not the users most recent order
  select(user_id, product_id, user_product.order_streak)


"Addings some other, more basic, User-Product features."
hour_train <- order_products_train %>%
  group_by(user_id,order_hour_of_day) %>%
  summarise()

user_products <- order_products_prior %>%
  group_by(user_id, product_id) %>% 
  summarise(
    user_product.orders = n(),
    user_product.firstOrder = min(order_number),
    user_product.lastOrder = max(order_number),
    user_product.avgDaysSincePriorOrder = mean(days_since_prior_order))%>%
  left_join(user_product_streak, by=c("user_id", "product_id"))%>%
  ungroup()%>%
  left_join(hour_train)%>%
  select(-order_hour_of_day)

rm(user_product_streak)
rm(hour_train)


# Data: Build Main Data Set

"Now we are going to join all of the feature tables and add some more features that are intertable dependent."
"TODO: Reorder table to be in a nicer format."
data <- user_products %>% 
  inner_join(prods, by = "product_id") %>%
  inner_join(users, by = "user_id") %>%
  mutate(user_product.ordersSinceLastOrdered = user.numOrders - user_product.lastOrder) %>%
  mutate(user_product.avgDaysSincePriorOrderDifference = abs(user_product.avgDaysSincePriorOrder - days_since_prior_order)) %>%
  mutate(product.avgDaysSincePriorOrderDifference = abs(product.avgDaysSincePriorOrder - days_since_prior_order)) %>%
  mutate(user_product.orderRate = user_product.orders / user.numOrders) %>%
  mutate(user_product.orderRateSinceFirstOrdered = user_product.orders / (user.numOrders - user_product.firstOrder + 1)) %>%
  select(-user_product.lastOrder, -user_product.avgDaysSincePriorOrder, -user_product.firstOrder, -product.avgDaysSincePriorOrder, -user.numOrders)

rm(prods, users, user_products)


"We join with train dataset reorders to train model in which products are reordered. 
(This means that we are currently only considering possible products that a user can order from the products they have already ordered.)"
data <- data %>% 
  left_join(order_products_train %>% select(user_id, product_id, reordered), 
            by = c("user_id", "product_id"))

# Data: Test and Train

train <- data %>%
  ungroup() %>%
  filter(eval_set == "train") %>%
  select(-eval_set)

train$reordered[is.na(train$reordered)] <- 0

test <- data %>%
  ungroup() %>%
  filter(eval_set == "test") %>%
  select(-eval_set, -reordered)

rm(data)

"Finally we write the training and testing data to /Source"
write_csv(train, "../Source/trainingData.csv")
write_csv(test, "../Source/testingData.csv")