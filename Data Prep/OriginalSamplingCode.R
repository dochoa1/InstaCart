# This file is used to create reproducable random sampling of the orders and order_product datasets. Should be used
# if working on those whole datasets is too computationally strenuous.

library(tidyverse)

# Reading in the original data
orders <- read_csv("../Source/orders.csv") %>%
  mutate(order_dow = as.character(recode(order_dow, `0`="Sunday", `1`="Monday", `2`="Tuesday",
                                         `3`="Wednesday", `4`="Thurday", `5`="Friday", `6`="Saturday")))

order_products_prior <- read_csv("../Source/order_products__prior.csv")
order_products_train <- read_csv("../Source/order_products__train.csv")
order_products <- rbind(order_products_prior, order_products_train)

# Randomly sampling the data
set.seed(42)  # Allows for reproducable sample results
random_users <- sample(unique(orders$user_id), 40000)  #40000 users are randomly chosen (~20% sample)
orders_sample40 <-
  subset(orders, user_id %in% random_users)

order_products_sample40 <-
  subset(order_products, order_id %in% unique(orders_sample40$order_id))

# Before sampling:
#   orders - 3.4 million rows  
#   order_products - 32.4 million rows

#After sampling:
#   orders - 660 thousand rows
#   order_products - 6.23 million rows

write.csv(orders_sample40, "../Source/orders_sample40.csv")
write.csv(order_products_sample40, "../Source/order_products_sample40.csv")