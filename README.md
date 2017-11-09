# InstaCart Market Basket
Which products will an Instacart consumer purchase again?

This project is based on the data provided by InstaCart during this [Kaggle competition.](https://www.kaggle.com/c/instacart-market-basket-analysis)

# Setup
Download the data provided by InstaCart [here.](https://www.kaggle.com/c/instacart-market-basket-analysis/data)

Be sure to download all of the files except for `sample_submission.csv.zip`, this project does not make use of that file.

Once downloaded make sure that all of the .csv files are exported to a subdirectory called `Source`.

If you find that your machine of choice lacks to computing power to work with the datasets as they are than we recommend you run `/DataPrep/CreateSampleDatasets.R` which will produce 20% randomly sampled `orders` and `order_products` datasets according to `user_id` in a reproducible manner.

# Citation

The data used in this project was made publicly available courtesy of InstaCart.

“The Instacart Online Grocery Shopping Dataset 2017”, Accessed from https://www.instacart.com/datasets/grocery-shopping-2017 on <11/08/2017>