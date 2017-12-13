# This is Hoang Anh testing playgrounds for experimenting different features

setwd("D:/Macalester/ProjDS/InstaCart/Source")

# Library
library(tidyverse)
library(xgboost)
library(caret)  # Used for confusion matrix
library(Ckmeans.1d.dp)  # Used for XGBoost visualization
library(DiagrammeR)  # Used for XGBoost visualization

# Testing function
f1_test <- function (pred, ref, user_id) {
  require(ModelMetrics)
  dt <- tibble(user_id, pred, ref)
  dt <- dt %>%
    group_by(user_id)%>%
    mutate(f1_score = f1Score(pred,ref))%>%
    summarise(f1_score = mean(f1_score,na.rm=TRUE))
  f1_mean <- mean(dt$f1_score,na.rm=TRUE)
  return (f1_mean)
}

#

# Read Data
trainDF <- read_csv("../Source/trainingData.csv")
products <- read_csv("../Source/products.csv")  # Used to provide product names (hasn't been incorporated yet)

# Separate Test from Train
set.seed(567) # Used for reproducability of results

inTrain <- sample_frac(data.frame(unique(trainDF$order_id)), 0.7)

train <- trainDF %>%
  filter(order_id %in% inTrain$unique.trainDF.order_id.)
test <- trainDF %>%
  filter(!order_id %in% inTrain$unique.trainDF.order_id.)

rm(trainDF)
rm(inTrain)

# Matrix setting
trainIndependents <- train %>% 
  select(-reordered, -product_id, -order_id, -user_id)

testIndependents <- test %>% 
  select(-reordered,  -product_id, -order_id, -user_id)

trainingMatrix <- xgb.DMatrix(as.matrix(trainIndependents), label = train$reordered)
testMatrix <- xgb.DMatrix(as.matrix(testIndependents), label = test$reordered)

# Null model
nullPredict <- ifelse(test$user_product.order_streak > 0, 1, 0)
f1_test(nullPredict,test$reordered,test$user_id)


# Parameters setting
params <- list("objective" = "binary:logistic",
               "max_depth" = 6,
               "eta" = 0.3,
               "min_child_weight" = 1,
               "subsample" = 0.8)
# Cross Validation
cv <- xgb.cv(data = trainingMatrix, nfold=5, param=params, nrounds=80, early_stopping_rounds=10, verbose=TRUE)

# Model training
model <- xgb.train(data = trainingMatrix, param=params, nrounds=40, verbose=FALSE)
importance <- xgb.importance(colnames(trainingMatrix), model = model)
xgb.ggplot.importance(importance)

# Finding threshold
xgbpred_train <- predict(model,trainingMatrix)
kk=seq(0.01,0.99,length=100)
threshold = c()
for (k in kk){
  xgbpred_k <- ifelse(xgbpred_train > k, 1, 0) # 0.1 is threshold I came up with after messing around, experiment with it
  threshold <- c(threshold,f1_test(xgbpred_k,train$reordered,train$user_id))
}
plot(kk,threshold)
which.max(threshold)
cutoff <- kk[23]



# Prediction 
xgbpred <- predict(model, testMatrix)
xgbpred <- ifelse(xgbpred > cutoff, 1, 0) # 0.1 is threshold I came up with after messing around, experiment with it
f1_test(xgbpred,test$reordered,test$user_id)

nullPredict <- ifelse(test$user_product.order_streak > 0, 1, 0)
accuracy.Test(nullPredict,test$reordered)


###########################

#### AISLE ANALYSIS

# Prepare Data
aisles = read_csv("../Source/aisles.csv")
departments = read_csv("../Source/departments.csv")
products = read_csv("../Source/products.csv")
order_products_sample40 = read_csv("../Source/order_products_sample40.csv")

orders_aisles_sample40 <- order_products_sample40%>%
  left_join(products)
  select(order_id,aisle_id)%>%
  distinct(order_id,aisle_id)

# Convert the table of order_id and aisles_id into an incidence matrix
aisle_incidence=as.matrix(table(cbind.data.frame(order=orders_aisles_sample40$order_id,aisle=c(orders_aisles_sample40$aisle_id))))
# Multiple with its transpose to create the adjacency matrix for 
aisle_adjacency=t(aisle_incidence)%*%aisle_incidence
# Divide each row with corresponding diagonal value
aisle_probability <- aisle_adjacency*(1/diag(aisle_adjacency))
