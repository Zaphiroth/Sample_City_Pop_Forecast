# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# ProjectName:  地级市样本人数预测
# Purpose:      Prediction
# programmer:   Zhe Liu
# Date:         11-23-2018
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

##-- loading the required packages
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
})

##-- readin the raw data
sample_data <- read.xlsx("02_Inputs/Sample city.xlsx")
city_data <- read.xlsx("02_Inputs/data_for_clustering.xlsx", sheet = "county")

colnames(city_data) <- c("省", "地级市", "区/县(县级市）", "2015年行政区划编码", "GDP总值(亿元)", 
                         "GDP增长率（%）", "常住人口(万人)", "常住城镇人口(万人)", "常住乡村人口(万人)", 
                         "常住人口出生率(‰)", "新生儿数", "城镇居民人均可支配收入（元）", 
                         "城镇居民人均可支配收入增长率（%）", "农民人均可支配收入（元）", 
                         "农民人均可支配收入增长率（%）", "SocialConsumption.(亿元)", "RetailOTC.(万元）", 
                         "SampleVaccineData")

city_tier <- read.xlsx("02_Inputs/city tier 2010.xlsx")







