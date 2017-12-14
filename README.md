# InstaCart Market Basket
Which products will an Instacart consumer purchase again?

This project is based on the data provided by InstaCart during this [Kaggle competition.](https://www.kaggle.com/c/instacart-market-basket-analysis)

# Setup
Download the data provided by InstaCart [here.](https://www.kaggle.com/c/instacart-market-basket-analysis/data)

Be sure to download all of the files except for `sample_submission.csv.zip`, this project does not make use of that file.

Once downloaded make sure that all of the .csv files are exported to a subdirectory called `Source`.

If you find that your machine of choice lacks to computing power to work with the datasets as they are than we recommend you run `/DataPrep/CreateSampleDatasets.R` which will produce 20% randomly sampled `orders` and `order_products` datasets according to `user_id` in a reproducible manner. The percentage randomly sampled can be configured in the file.

If you would like to see predictions made by our models on the data then you will first need to run `/DataPrep/OriginalSamplingCode.R` on the desired data (sampled or not). This formats the data to be suited for predictive models. The output will be found at `/DataPrep/trainingData.csv` and `/DataPrep/testingData.csv`.

After the testing and training datasets have been created then you can run the gradient boosting model on the data and analyze its results at `/PredictiveAnalysis/PredictiveAnalysis_Orders.Rmd`.

# Citation

The data used in this project was made publicly available courtesy of InstaCart.

“The Instacart Online Grocery Shopping Dataset 2017”, Accessed from https://www.instacart.com/datasets/grocery-shopping-2017 on <11/08/2017>