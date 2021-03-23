# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# ProjectName:  地级市样本人数预测
# Purpose:      Prediction
# programmer:   Zhe Liu
# Date:         11-23-2018
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# loading the required packages
options(java.parameters = "-Xmx2048m")

suppressPackageStartupMessages({
  library(openxlsx)
  library(RODBC)
  library(dplyr)
  library(plm)
  library(dynlm)
  library(tidyr)
  library(data.table)
  library(stringi)
  library(stringr)
  library(lubridate)
  library(gbm)
  library(xgboost)
})

##-- data
train_data <- sample_data_m %>%
  select(Sample.人次,
         City.Tier,
         `GDP总值(亿元)`,
         `常住城镇人口(万人)`,
         `城镇居民人均可支配收入（元）`,
         `SocialConsumption.(亿元)`,
         `RetailOTC.(万元）`) %>%
  data.frame(row.names = sample_data_m$city)

test_data <- city_data_m %>%
  filter(!(city %in% sample_data_m$city)) %>%
  select(city,
         City.Tier,
         `GDP总值(亿元)`,
         `常住城镇人口(万人)`,
         `城镇居民人均可支配收入（元）`,
         `SocialConsumption.(亿元)`,
         `RetailOTC.(万元）`) %>%
  data.frame()
row.names(test_data) <- test_data$city
test_data <- select(test_data, -city)

##-- cross validation
fold <- vector("list", 34)
for (i in 1:34) {
  fold[i] <- i
}

train_data_m <- as.matrix(train_data[, 2:7])
label_data <- as.matrix(train_data[, 1])

cv.res <- xgb.cv(params = list(booster = "gbtree",
                               eta = 0.4,
                               objective = "reg:linear"),
                 data = train_data_m, nrounds = 30, nfold = 34,
                 label = label_data, metrics = list("rmse"), folds = fold)

# eta  iter.  rmse
# 0.1   18  73874.40
# 0.2   10  75486.28
# 0.3    6  77161.49
# 0.4    4  73427.41
# 0.5    4  85194.02
# 0.6    2  98652.07
# 0.7    2  97045.36
# 0.8    3  104548.9
# 0.9    2  102539.9
# 1.0    1  120828.3

# best iteration = 12

##-- model
xgb_model <- xgboost(params = list(booster = "gbtree",
                                   eta = 0.4,
                                   objective = "reg:linear"),
                     data = train_data_m, label = label_data,
                     nrounds = 4)

##-- prediction
test_data_m <- as.matrix(test_data)

pop_pred <- predict(xgb_model, test_data_m) %>%
  data.frame() %>%
  rename("Sample.人次" = ".") %>%
  bind_cols(test_data) %>%
  data.frame(row.names = row.names(test_data))




