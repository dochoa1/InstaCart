# InstaCart Market Basket
Which products will an Instacart consumer purchase again?

This project is based on the data provided by InstaCart during this [Kaggle competition.](https://www.kaggle.com/c/instacart-market-basket-analysis)

# Setup
Download the data provided by InstaCart [here.](https://www.kaggle.com/c/instacart-market-basket-analysis/data)

Be sure to download all of the files except for `sample_submission.csv.zip`, this project does not make use of that file.

Once downloaded make sure that all of the .csv files are exported to a subdirectory called `Source`.

If you find that your machine of choice lacks to computing power to work with the datasets as they are than we recommend you run `/DataPrep/OriginalSamplingCode.R` which will produce 20% randomly sampled `orders` and `order_products` datasets according to `user_id` in a reproducible manner. The percentage randomly sampled can be configured in the file. This files can be found in the `Source` directory.

If you would like to see predictions made by our models on the data then you will first need to run `/DataPrep/OriginalSamplingCode.R` on the desired data (sampled or not). This formats the data to be suited for predictive models. The output will be found at `/Source/trainingData.csv` and `/Source/testingData.csv`.

After the testing and training datasets have been created then you can run the gradient boosting model on the data and analyze its results at `/PredictiveAnalysis/PredictiveAnalysis_Orders.Rmd`.

# Run the deep learning model
Download Anaconda and Jupyter notebook. Packages needed are sklearn, pandas, numpy and keras. Data used are `/Source/trainingData.csv` and `/Source/testingData.csv`. The model takes about two hours to run. The training data is divided into 80% train and 20% test. After building the model on the training data, it is used to make predictions on the testing data. 

# Run the logistic regression model
The file titled `Logit_originalDf.R` runs logistic regression model on the above-mentioned data frame. The rest of the logit files run logit on wrangled data sets. The first wrangling of the original data is a data frame titled `data_final` which can be found in the file titled `PredictiveDataPrep_alt` in the `DataPrep` folder. Other subsets of  `data_final` comes from the file `PredictiveDataPrep_sample`. The data frames used in the analysis among the subset data are `df.ordProd` which is a filtered version of `data_final` containing users who have ordered 15 or more times and purchased at least 100 products. `df.ordProd900` is a sample of 900 users from `df.ordProd`. Both `PredictiveDataPrep_alt` and `PredictiveDataPrep_sample` contain save codes that will save the data to the `Source` folder.

Some of the data frames under `PredictiveDataPrep_sample` come from clustering files, so run the clustering files first on logit analysis that has been done on clustered `user_id` or `product_name`. The clustered data frames the logit analysis uses are: `clust3_Uid`, `clust4_Uid`, and `clust3_Prod`. 

The data is divided into 70% train and 30% test. As with other models, the predictions from the training data are made on the testing data. 

# Run the clusters
All cluster files that begin with `PredictiveAnalysis_Clusterby` require `df.ordProd900` in the file `PredictiveDataPrep_sample` under `DataPrep` folder. These files contain save code that will save the data to the `Source` folder.


# Citation

The data used in this project was made publicly available courtesy of InstaCart.

“The Instacart Online Grocery Shopping Dataset 2017”, Accessed from https://www.instacart.com/datasets/grocery-shopping-2017 on <11/08/2017>
