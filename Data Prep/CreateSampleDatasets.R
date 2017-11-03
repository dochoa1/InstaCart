# This file is used to create reproducable random sampling of the orders and order_product datasets. Should be used
# if working on those whole datasets is too computationally strenuous.

library(tidyverse)


# Reading in the original data
prior <- read_csv("../Source/orders.csv") %>%
  filter(eval_set == "prior") 
order_products <- read_csv("../Source/order_products__prior.csv")
products <- read_csv("../Source/products.csv")
departments <- read_csv("../Source/departments.csv")
aisles <- read_csv("../Source/aisles.csv")



# Randomly sampling the data
set.seed(42)  # Allows for reproducable sample results
random_users <- sample(unique(prior$user_id), 40000)  #40000 users are randomly chosen (~20% sample)

prior_sample40 <-
  subset(prior, user_id %in% random_users)

order_products_sample40 <-
  subset(order_products, order_id %in% unique(prior_sample40$order_id))


orders_priorn <- 
  prior_sample40 %>%
  left_join(order_products_sample40, by = "order_id") %>%
  left_join(products, by = "product_id") %>%
  left_join(departments, by = "department_id") %>%
  left_join(aisles, by = "aisle_id") %>%
  select(order_dow, order_hour_of_day, 
         product_name, aisle, department, 
         user_id, order_id, order_number, 
         reordered, add_to_cart_order, days_since_prior_order) 

names(orders_priorn)
nrow(orders_priorn)

# Before sampling:
#   prior - 3.2 million rows  
#   order_products - 32.4 million rows

#After sampling:
#   orders - 620 thousand rows
#   order_products - 6.23 million rows

write.csv(prior_sample40, "../Source/prior_sample40.csv")
write.csv(orders_priorn, "../Source/orders_priorn.csv")
