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
  library(plyr)
  library(dplyr)
  library(plm)
  library(dynlm)
  library(tidyr)
  library(data.table)
  library(stringi)
  library(stringr)
  library(lubridate)
  library(randomForest)
  library(glmnet)
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

test_data <- city_data_m1 %>%
  select(city,
         City.Tier,
         `GDP总值(亿元)`,
         `常住城镇人口(万人)`,
         `城镇居民人均可支配收入（元）`,
         `SocialConsumption.(亿元)`,
         `RetailOTC.(万元）`) %>%
  data.frame(row.names = city_data_m1$city)

##-- 34-fold cross validation
pred_rf <- data.frame()

fold <- rep(1:34, times = 120)
mtry <- rep(1:6, each = 34, times = 20)
ntree <- rep(seq(50, 1000, by = 50), each = 204)
comb <- cbind(fold, mtry, ntree)

cv_rf <- function(fold, mtry, ntree) {
  train <- train_data[-fold, ]
  test <- train_data[fold, ]
  
  model <- randomForest(Sample.人次 ~ ., data = train, mtry = mtry, ntree = ntree)
  
  prediction <- predict(model, subset(test, select = -Sample.人次))
  
  temp <- data.frame(cbind(subset(test, select = Sample.人次), prediction))
}

system.time(pred_rf <- mdply(comb, cv_rf))

msefun <- function(pred, sample) mean((pred - sample) ^ 2)
rsqfun <- function(pred, sample) 1 - sum((pred - sample) ^ 2) / sum((mean(sample) - sample) ^ 2)

eval <- pred_rf %>%
  group_by(mtry, ntree) %>%
  dplyr::summarise(rsq. = rsqfun(prediction, Sample.人次))
# mtry = 5, ntree = 150, rsq. = 0.7567895

##-- model
rf_model <- randomForest(Sample.人次 ~ ., data = train_data, mtry = 5, ntree = 150)

rsq. <- predict(rf_model, subset(train_data, select = -Sample.人次)) %>%
  data.frame() %>%
  dplyr::rename("pred" = ".") %>%
  bind_cols(train_data) %>%
  summarise(rsq. = rsqfun(pred, Sample.人次))

##-- prediction
pop_pred_rf <- predict(rf_model, test_data) %>%
  data.frame() %>%
  dplyr::rename("Sample.人次" = ".") %>%
  bind_cols(city_data_m1)

##-- reslut
universe_data <- sample_data_m %>%
  mutate(flag = 0) %>%
  bind_rows(pop_pred_rf) %>%
  mutate(flag = ifelse(is.na(flag), 1, flag)) %>%
  select(Province, Prefecture, city, Sample.人次, City.Tier, `GDP总值(亿元)`, `常住城镇人口(万人)`,
         `城镇居民人均可支配收入（元）`, `SocialConsumption.(亿元)`, `RetailOTC.(万元）`, flag)

write.xlsx(universe_data, "03_Outputs/universe_data_rf_1123.xlsx")





