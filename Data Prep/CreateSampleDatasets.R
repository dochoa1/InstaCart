# This file is used to create reproducable random sampling of the orders and order_product datasets. Should be used
# if working on those whole datasets is too computationally strenuous.

library(tidyverse)


# Reading in the original data
prior_orders <- read_csv("../Source/orders.csv") %>%
  filter(eval_set == "prior") 
order_products <- read_csv("../Source/order_products__prior.csv")
products <- read_csv("../Source/products.csv")
departments <- read_csv("../Source/departments.csv")
aisles <- read_csv("../Source/aisles.csv")


# Randomly sampling the data
set.seed(42)  # Allows for reproducable sample results
random_users <- sample(unique(prior_orders$user_id), 40000)  #40000 users are randomly chosen (~20% sample)

prior_orders_sample40k <-
  subset(prior_orders, user_id %in% random_users)

order_products_sample40k <-
  subset(order_products, order_id %in% unique(prior_orders_sample40k$order_id))

orders_full40k_tem <- 
  prior_orders_sample40k %>%
  left_join(order_products_sample40k, by = "order_id") %>%
  left_join(products, by = "product_id") %>%
  left_join(departments, by = "department_id") %>%
  left_join(aisles, by = "aisle_id") %>%
  select(order_dow, order_hour_of_day, 
         product_name, aisle, department, 
         user_id, order_id, order_number, 
         reordered, add_to_cart_order, days_since_prior_order) 
orders_full40k <- 
  orders_full40k_tem %>%
  mutate(order_dow = recode_factor(order_dow, `0`="Sunday", `1`="Monday", `2`="Tuesday", `3`="Wednesday",
                                   `4`="Thursday", `5`="Friday", `6`="Saturday"),
         order_hour_of_day = factor(order_hour_of_day,
                                    levels=c("00", "01", "02", "03", "04",
                                             "05", "06", "07", "08", "09",
                                             "10", "11", "12", "13", "14",
                                             "15", "16", "17", "18", "19",
                                             "20", "21", "22", "23", "24"))) 

# Before & After Analysis
# Before sampling:
#   prior - 3.2 million rows  
#   order_products - 32.4 million rows
# After sampling:
#   prior - 620 thousand rows
#   order_products - 6.23 million rows


# Clean
rm(random_users, orders_full40k_tem)


# Write
write.csv(prior_orders_sample40k, "../Source/prior_orders_sample40k.csv")
write.csv(order_products_sample40k, "../Source/prior_order_products_sample40k.csv")
write.csv(orders_full40k, "../Source/orders_full40k.csv")
