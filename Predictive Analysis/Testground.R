# This is Hoang Anh testing playgrounds for experimenting different features

# Library
library(tidyverse)
library(xgboost)
library(caret)  # Used for confusion matrix
library(Ckmeans.1d.dp)  # Used for XGBoost visualization
library(DiagrammeR)  # Used for XGBoost visualization


# Read Data
trainDF <- read_csv("../Source/trainingData.csv")
products <- read_csv("../Source/products.csv")  # Used to provide product names (hasn't been incorporated yet)

# Separate Test from Train
set.seed(567)

inTrain <- sample_frac(data.frame(unique(trainDF$order_id)), 0.7)

train <- trainDF %>%
  filter(order_id %in% inTrain$unique.trainDF.order_id.)
test <- trainDF %>%
  filter(!order_id %in% inTrain$unique.trainDF.order_id.)

rm(trainDF)
rm(inTrain)

# Matrix setting
trainIndependents <- train %>% 
  select(-reordered)

testIndependents <- test %>% 
  select(-reordered)

trainingMatrix <- xgb.DMatrix(as.matrix(trainIndependents), label = train$reordered)
testMatrix <- xgb.DMatrix(as.matrix(testIndependents), label = test$reordered)

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

# Prediction 
xgbpred <- predict(model, testMatrix)
test_res <- mutate(test,pred=xgbpred)

# Create Aisle Adjacency Matrix for each user