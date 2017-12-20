library(tufte)
library(caret)  # Used for confusion matrix
library(tidyverse)
library(pROC)
knitr::opts_chunk$set(tidy = FALSE, message=FALSE, cache.extra = packageVersion('tufte'))
options(htmltools.dir.version = FALSE)



# Reading In The Data

trainDF <- read_csv("../Source/trainingData.csv")

set.seed(567) # Used for reproducability of results

inTrain <- sample_frac(data.frame(unique(trainDF$order_id)), 0.7)

train <- trainDF %>%
  filter(order_id %in% inTrain$unique.trainDF.order_id.)
test <- trainDF %>%
  filter(!order_id %in% inTrain$unique.trainDF.order_id.)

rm(trainDF)
rm(inTrain)


# Predictive Analysis

## Logistic Regression: Full Model 
modelf <- glm(reordered ~ . - `user_id` - `product_id` - `order_id`, family = binomial(link = 'logit'), data = train)
summary(modelf)

## Testing Function
f1_test <- function (pred, ref,user_id) {
  require(ModelMetrics)
  dt <- tibble(user_id, pred, ref)
  dt <- dt %>%
    group_by(user_id)%>%
    mutate(f1_score = f1Score(pred,ref))%>%
    summarise(f1_score = mean(f1_score,na.rm=TRUE))
  f1_mean <- mean(dt$f1_score,na.rm=TRUE)
  return (f1_mean)
}

## Null Model 
nullPredict <- ifelse(test$user_product.order_streak > 0, 1, 0)
f1_test(nullPredict, test$reordered, test$user_id)

## F1 Score
pred_logit_pre <- predict(modelf, newdata = test, type = 'response')
pred_logit <- ifelse(pred_logit_pre > 0.21, 1, 0)
pred_logit[is.na(pred_logit)]<-0
pred_f1 <- f1_test(pred_logit, test$reordered, test$user_id)
pred_f1
confusionMatrix(pred_logit, test$reordered)

f1_test(nullPredict, test$reordered, test$user_id)

## Plot GLM
pred_logit_pre <- predict(modelf, newdata = test, type = 'response')

ggplot(test, aes(x=pred_logit_pre, y=reordered)) + geom_point() +
  stat_smooth(method="glm", family="binomial", se=TRUE) +
  labs(x="Prediction", y="Actual",
       title="Logistic Regression of Prediction vs. Actual Reordered",
       caption="Data from InstaCart Kaggle Competition")

## ROC Curve
roc(test$reordered, pred_logit, plot=TRUE)
title("ROC Curve for Reordered", line = 3)
confusionMatrix(pred_logit, test$reordered)
