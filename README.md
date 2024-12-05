R script doing (1) exploratory factor analysis, (2) confirmatory factor analysis, (3) logistic regression and classification with Divorce Predictor Dataset (https://www.kaggle.com/datasets/rabieelkharoua/split-or-stay-divorce-predictor-dataset?resource=download)

Exploratory Factor Analysis

      1. Determine Factor Structure of Divorce Predictor Scale
          a. Factor strucutre not pre-specified in dataset (even though the author talks about a 5 factor structure)
          b. Use exploratory factor analysis to get a basic idea of the factor strucutre
      2. Determine number of factors
          a. Ensure sufficient correlation to do factor analysis using KMO, MSA, and Barlett's Test of Sphericity
          b. Use parallel analysis to give an indication of the maximum number of factors (found to be two)
          c. Explored both one and two factor models
      3. Two factor model chosen as better model
          a. Using principal axis factoring
          b. Factor loading of 0.4 used as threshold for sufficiently large factor loading
          c. Factors labelled as compatibility and conflict
      4. Model might have flaws
          a. Negatively worded items did not have negative factor loadings
          b. Items that load onto a single factor do not seem to be homogenous

Confirmatory Factor Analysis

    1. Refine model to remove items that cross load or do not load onto any factor well
    2. Conduct a confirmatory factor analysis to determine model fit of final model
        a. Model fit was found to not be ideal
        b. Factor correlations also extremely high (0.944) - factors may be redundant

Logistic Regression and Classification

    1. Performed logistic regression with both predictors
        a. Found that p-values were abnormal - likely to due multicollinearty
    2. Performed logistic regression with compatibility as predictor only
    3. Performed logistic regression with conflict as predictor only
    4. Choose model with compatibility as final model due to better classification results and higher pseudo-R2

Conclusions and Limitations
    1. Factor Structure needs improvement. With poor fit and non-homogenous factors, theorectically should not have proceeded with Logistic Regression
    2. Logistic model surprisingly had extremely high accuracy (>95%). Might have risk of overfitting. Need to validate model with another sample.
          
