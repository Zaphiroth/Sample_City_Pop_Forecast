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

##-- data preprocessing
city_tier_m <- city_tier %>%
  mutate(city = sub("市", "", city))

city_data_m <- city_data %>%
  dplyr::rename("city" = "地级市") %>%
  group_by(city) %>%
  dplyr::summarise(`GDP总值(亿元)` = sum(`GDP总值(亿元)`, na.rm = TRUE),
                   `常住城镇人口(万人)` = sum(`常住城镇人口(万人)`, na.rm = TRUE),
                   `城镇居民人均可支配收入（元）` = mean(`城镇居民人均可支配收入（元）`, na.rm = TRUE),
                   `SocialConsumption.(亿元)` = sum(`SocialConsumption.(亿元)`, na.rm = TRUE),
                   `RetailOTC.(万元）` = sum(`RetailOTC.(万元）`, na.rm = TRUE)) %>%
  mutate(city = sub("市", "", city)) %>%
  left_join(city_tier_m, by = "city") %>%
  mutate(City.Tier.2010 = ifelse(is.na(City.Tier.2010), 5, City.Tier.2010)) %>%
  dplyr::rename("City.Tier" = "City.Tier.2010") %>%
  filter(!(city %in% c("北京", "上海", "广州", "深圳", "天津", "杭州")))

city_imp <- city_data_m %>%
  filter(is.na(Province)) %>%
  mutate(city = c("阿克苏", "毕节地区", "昌都地区", "海东地区", "海南省省直辖县级行政区划",
                  "河南省省直辖县级行政区划", "湖北省省直辖县级行政区划", "湖南湘江新区",
                  "林芝地区", "思茅", "日喀则地区", "三沙", "山南地区", "吐鲁番地区",
                  "新疆维吾尔自治区直辖县级行政区划"),
         Province = c("新疆", "贵州", "西藏", "青海", "海南", "河南", "湖北", "湖南", "西藏",
                      "云南", "西藏", "海南", "西藏", "新疆", "新疆"),
         Prefecture = c("阿克苏地区", "毕节地区", "昌都地区", "海东地区", "海南省省直辖县级行政区划",
                        "河南省省直辖县级行政区划", "湖北省省直辖县级行政区划", "湖南湘江新区",
                        "林芝地区", "普洱市", "日喀则地区", "三沙市", "山南地区", "吐鲁番地区",
                        "新疆维吾尔自治区直辖县级行政区划"))

city_data_m1 <- city_data_m %>%
  filter(!is.na(Province)) %>%
  bind_rows(city_imp)

sample_data_m <- sample_data %>%
  dplyr::rename("city" = "行标签") %>%
  mutate(city = sub("市", "", city)) %>%
  left_join(city_data_m1, by = c("city", "City.Tier"))







