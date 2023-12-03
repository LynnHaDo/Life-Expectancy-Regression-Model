#' ---
#' title: "STAT-140-01: Project Inference"
#' author: "Lynn Do"
#' output:
#'   pdf_document: default
#'   html_document:
#'     df_print: paged
#'   word_document: default
#' ---
#' 
## ----echo=FALSE, message=FALSE, warning=FALSE---------------------------------
library(knitr)
knitr::purl("Project Inference.Rmd", output = "Project Inference.R", documentation = 2)
library(tidyverse)
library(GGally)
library(DAAG)

#' 
#' ### **0. Load dataset (feel free to skip this part)**
#' 
## -----------------------------------------------------------------------------
led_dataset <- read_csv('life_expectancy_data.csv', show_col_types = FALSE) # read data

#' 
## -----------------------------------------------------------------------------
led_dataset <- within(led_dataset, {
  Year_cat <- NA # Initialize a new variable
  Year_cat[Year == 2000] <- "2000"
  Year_cat[Year == 2001] <- "2001"
  Year_cat[Year == 2002] <- "2002"
  Year_cat[Year == 2003] <- "2003"
  Year_cat[Year == 2004] <- "2004"
  Year_cat[Year == 2005] <- "2005"
  Year_cat[Year == 2006] <- "2006"
  Year_cat[Year == 2007] <- "2007"
  Year_cat[Year == 2008] <- "2008"
  Year_cat[Year == 2009] <- "2009"
  Year_cat[Year == 2010] <- "2010"
  Year_cat[Year == 2011] <- "2011"
  Year_cat[Year == 2012] <- "2012"
  Year_cat[Year == 2013] <- "2013"
  Year_cat[Year == 2014] <- "2014"
  Year_cat[Year == 2015] <- "2015"
})

#' 
#' Drop the numerical Year variable column
#' 
## -----------------------------------------------------------------------------
led_dataset <- subset(led_dataset, select = -Year)

#' 
#' Convert the categorical variable ```Year_cat``` from character to factor
#' 
## -----------------------------------------------------------------------------
led_dataset$Year_cat <- factor(led_dataset$Year_cat, levels = c("2015", "2014", "2013", "2012", "2011", "2010", "2009", "2008", "2007", "2006", "2005", "2004", "2003", "2002", "2001", "2000"))
led_dataset %>% 
  head()

#' 
## -----------------------------------------------------------------------------
led_dataset_trimmed = led_dataset %>%
  filter(Year_cat=="2015") %>%
  mutate("DesignName" = Country) %>%
  column_to_rownames(var = "DesignName")
keeps <- c("Life expectancy", "Income composition of resources", "Alcohol")
led_dataset_trimmed <- led_dataset_trimmed[keeps]

#' ### **1. Re-introduction and Insights from Descriptives component**
#' 
#' For this component, I will focus on 4 variables:
#' 
#'   - ```Life expectancy``` (in age) is the response variable in my project, and I am looking for any correlation it has with the country's income composition of resources index and the alcohol consumption. 
#' 
#'   - Compared to other variables like ```GDP``` or ```Percentage expenditure``` of a country, I think the variable ```Income composition of resources``` (HDI index, from 0 - 1) can reflect more precisely how much people in a country spend on resources. I want to explore if the positive relationship I found previously is actually valid. 
#'   
#'   - Last time, when I tried to fit the regression model correlating alcohol consumption (consumption of alcholic beverages in general, including beer, wine and spirits) and life expectancy, I saw a "positive" relationship between them. I thought it might be interesting to determine whether this relationship is caused by chance, or if I just "enforced" a relationship on them. 
#' 
#' ### **2. Set up regression models**
#' 
#' It is clear that the previous models I proposed violate the independence condition. Since the data contains sequential observations in time, the cases are not independent. 
#' 
#' **1. ```Life expectancy``` and ```Income composition of resources```**
#' 
#' Using the same variables ```Life expectancy``` and ```Income composition of resources```, I will analyze their relationship but now only limit the cases to the year 2015, since it is the most recent year in my dataset. I want to find out of the positive relationship is valid. 
#' 
#' **a) Check conditions**
#' 
#' - Independence: need further considerations, since countries may be dependent on each other in terms of economic or spatial relationships.
#' 
#' - Linearity: pass, since there are no extreme bends in the residuals vs. fitted plot.
#' 
#' - Equal variance of residuals: I will assume that this passes, given that the vertical width of the scatter doesn't increase/decrease significantly moving from left to right.
#' 
#' - Outliers: There are 3 outliers. Niger is a high leverage point, but its associated residual is not too weird compared with other points in the dataset. So it is not influential on the slope of the line. The rest 2 outliers (Sierra Leone and Angola) do not have high leverage, so not influential either.
#' 
## -----------------------------------------------------------------------------
income_model <- lm(`Life expectancy` ~ `Income composition of resources`, data=led_dataset_trimmed) # fit a regression model
plot(income_model, which = c(1,5))

#' 
#' - Normality: I want to check if the residuals are nearly normal 
#' 
#' Produce a density plot determine if the residuals follow a normal distribution
#' 
## -----------------------------------------------------------------------------
res <- resid(income_model)
plot(hist(res))

#' 
#' 
#' **b) Find the line equation and $R^2$** 
#' 
## -----------------------------------------------------------------------------
income_model$coefficients

#' 
#' So the model equation is: 
#' 
#' $\widehat{\text{life expectancy}}_i= 39.25408 + 46.92319 \times \text{income composition of resources}_i$
#' 
#' Find the $R^2$ value:
#' 
## -----------------------------------------------------------------------------
summary(income_model)

#' 
#' **c) Interpret**
#' 
#' - Intercept: The value $39.25408$ indicates that for countries with 0 value of the income composition of resources index, the expected life expectancy is $39.25408$ in age. 
#' 
#' - Slope: In this context, since the income composition index can only take values from 0 to 1, the value $46.92319$ indicates that for any 0.1 difference in income composition of resources, there is expected to be a $4.692319$ difference in age in life expectancy. 
#' 
#' - With $R^2 = 0.8233092$, we can say that about 82.33\% of the variation in life expectancy is explained by income composition of resources. This shows `Income composition of resources` is a pretty good predictor for life expectancy in this data.
#' 
#' **d) Hypothesis testing and Confidence interval**
#' 
#' - With a small p-value of $<2.2.10^{-16}$, **we reject the null hypothesis**. This data provides evidence of a relationship between life expectancy and income composition of resources. 
#' 
#' - Moreover, looking at the confidence interval for the slope, we can say that we're 95\% confident that if we have 2 countries that differ 0.1 in income index, their life expectancy is expected to differ by 4.3 to 5 years in life expectancy. 
#' 
## -----------------------------------------------------------------------------
confint(income_model, level = 0.95)

#' 
#' **2. ```Life expectancy``` and ```Alcohol``` and why they cannot be correlated using a linear regression model** 
#' 
#' Similarly to the previous approach, I will extract 2015 data for the linear model involving life expectancy and alcohol consumption.
#' 
## -----------------------------------------------------------------------------
led_dataset_trimmed %>%
  ggplot(aes(y = `Life expectancy`, x = `Alcohol`)) +
  geom_point() +
  geom_smooth(method = 'lm', se = FALSE)

#' 
#' Clearly, there is an extreme lack of data (with 177 rows containing the null value), so it is not reasonable to build a model based off a few data points. Moreover, computing the correlation $r$ of alcohol consumption and life expectancy in the other different years, I also find out that there is no clear linear relationship. 
#' 
## -----------------------------------------------------------------------------
correlation_df <- data.frame(Year=2000:2015)
year_list = levels(unique(led_dataset$Year_cat))
counter = 16
for (x in year_list) {
  # Create a new dataset
  led_dataset_sample = led_dataset%>%
    dplyr::filter(Year_cat==x)
  # Omit the NA rows
  led_dataset_sample <- led_dataset_sample[!(is.na(led_dataset_sample$`Alcohol`)), ]
  # Add correlation score
  correlation_df$`cor(Life expectancy ~ Alcohol)`[counter] <- cor(x=led_dataset_sample$Alcohol, y=led_dataset_sample$`Life expectancy`)
  counter = counter - 1
}

#' 
## -----------------------------------------------------------------------------
correlation_df_sorted <- correlation_df[order(correlation_df$`cor(Life expectancy ~ Alcohol)`, decreasing = TRUE),]
correlation_df_sorted

#' 
#' ### **3. Key takeaways & Next steps**
#' 
#' - It is not always appropriate to apply a linear regression model to any 2 numerical variables—it is vital to check the technical conditions before making any conclusions.
#' 
#' - When checking for the technical conditions and looking at the residual plots, it is uncertain whether the conditions have been met yet. Specifically, for the equal variability condition, I am not sure if there is a more systematic way to check other than just visually making a decision. 
#' 
#' - For the question related to alcohol and life expectancy correlation, I think other tests might be more suitable than using linear regression. Plus, there might possibly be confounding variables that I have not considered. For example, if a country already has abundance of economic resources, alcohol consumption might not be a factor relating to higher life expectancy. 
#' 
#' - Since I have data of each country from several years, for each country, I can pick 2 years (say 2000 and 2015), calculating the difference in life expectancy, and perform the paired group mean test or set up the confidence interval to estimate the mean of differences in life expectancy over the course of 15 years. 
