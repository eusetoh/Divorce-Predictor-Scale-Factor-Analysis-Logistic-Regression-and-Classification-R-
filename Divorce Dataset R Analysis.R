library(readxl)
library(psych)
library(corrr)
library(EFA.dimensions)
library(lavaan)
library(lavaanPlot)
library(jmv)

#read data
data <- read_excel("C:/Users/Eusebius/Desktop/Self-Initiated Projects/Divorce Dataset R/divorce.xlsx")

#descriptive exploration
describe(data)
#note that no missing data

#remove the last column "class"
data1 <- data[,1:54]
data1

#examine correlations
corr.test(data1)
rplot(correlate(data1))
KMO(data1)
cortest.bartlett(cor(data1), n = nrow(data1))
#note high MSA & KMO, Bartlett's Test also rejected - likely sufficient correlation for factor analysis

#determining number of factors via parallel analysis
set.seed(0)
RAWPAR(data1, randtype='permuted', extraction='PAF', Ndatasets=8000,
       percentile=99, corkind='pearson', corkindRAND='pearson')
#note that 2 factors are suggested

#Exporatory Factor Analysis (EFA) with both 1 factor and 2 factor structures

#EFA 2 factors
twofsol <- fa(r = data1, nfactors = 2, rotate = "promax", fm = "pa")
print(twofsol, sort = TRUE, cut = .4)

#EFA 1 factors
onefsol <- fa(r = data1, nfactors = 1, fm = "pa")
print(onefsol, sort = TRUE, cut = .4)

#choose 2 factor structure - Delta BIC of < -5 indicates that 2 factor structure is better
#factor 1 labelled as compatibility/alignment, factor 2 labelled as conflict/defensiveness
#remove items which cross-load/low factor loading (items 25, 29, 6, 46, 36, 33, 34, 31)

#Confirmatory Factor Analysis with Final Model
model <- '
  compatibility =~ Atr10 + Atr12 + Atr18 + Atr16 + Atr20 + Atr3 + Atr4 + Atr14 + Atr15 + Atr2 + Atr7 + Atr11 + Atr1 + Atr9 + Atr30 + Atr26 + Atr8 + Atr17 + Atr19 + Atr24 + Atr13 + Atr40 + Atr28 + Atr27 + Atr39 + Atr5 + Atr37 + Atr22 + Atr21 + Atr32 + Atr41 + Atr38
  conflict =~ Atr47 + Atr45 + Atr43 + Atr52 + Atr42 + Atr23 + Atr35 + Atr54 + Atr53 + Atr51 + Atr49 + Atr50 + Atr44 + Atr48
'

model.fit <- sem(model=model, data=data, meanstructure = FALSE)
summary(model.fit, standardized=TRUE, fit.measures=TRUE)
standardizedSolution(model.fit)
lavaanPlot(model.fit, coefs = TRUE)

#model fit is not great (using Hu & Bentler's heuristics). SRMR < 0.08 though
#factor correlation 0.944 - factors may be a duplication and thus redundant
#strange because negatively worded items did not seem to have negative factor loadings

# Compute summation scores for compatibility and conflict
data$summation_compatibility <- rowSums(data[, c("Atr10", "Atr12", "Atr18", "Atr16", "Atr20", "Atr3", 
                                             "Atr4", "Atr14", "Atr15", "Atr2", "Atr7", "Atr11", 
                                             "Atr1", "Atr9", "Atr30", "Atr26", "Atr8", "Atr17", 
                                             "Atr19", "Atr24", "Atr13", "Atr40", "Atr28", "Atr27", 
                                             "Atr39", "Atr5", "Atr37", "Atr22", "Atr21", "Atr32", 
                                             "Atr41", "Atr38")], na.rm = TRUE)

data$summation_conflict <- rowSums(data[, c("Atr47", "Atr45", "Atr43", "Atr52", "Atr42", "Atr23", 
                                        "Atr35", "Atr54", "Atr53", "Atr51", "Atr49", "Atr50", 
                                        "Atr44", "Atr48")], na.rm = TRUE)

#add summary data and outcome (married/divorced) to new table
summary_data <- data[, c("summation_compatibility", "summation_conflict", "Class")]
summary_data

#Logistic Regression with both predictors
logRegBin(    
  data = summary_data,    
  dep = Class,    
  covs = vars(summation_compatibility,summation_conflict),
  blocks = list( list( "summation_compatibility", "summation_conflict")),    
  refLevels = list( list(var="Class", ref="0")),    
  modelTest = TRUE,    
  bic = TRUE,    
  pseudoR2 = c("r2mf", "r2cs", "r2n"),    
  omni = TRUE,    
  ci = TRUE,    
  OR = TRUE,    
  emMeans = ~ hours,    
  emmTables = TRUE,
  emmPlots=FALSE,
  class = TRUE,
  acc = TRUE,
  cutOff = 0.5)

#output seems abnormal - model as a whole significant, but individual parameters individually all not significant. Likely due to multicollinearity issue. Add predictors individual to check

#Logistic Regression with summation_compatibility
logRegBin(    
  data = summary_data,    
  dep = Class,    
  covs = vars(summation_compatibility),
  blocks = list( list( "summation_compatibility")),    
  refLevels = list( list(var="Class", ref="0")),    
  modelTest = TRUE,    
  bic = TRUE,    
  pseudoR2 = c("r2mf", "r2cs", "r2n"),    
  omni = TRUE,    
  ci = TRUE,    
  OR = TRUE,    
  emMeans = ~ hours,    
  emmTables = TRUE,
  emmPlots=FALSE,
  class = TRUE,
  acc = TRUE,
  cutOff = 0.5)

#Logistic Regression with summation_conflict
logRegBin(    
  data = summary_data,    
  dep = Class,    
  covs = vars(summation_conflict),
  blocks = list( list( "summation_conflict")),    
  refLevels = list( list(var="Class", ref="0")),    
  modelTest = TRUE,    
  bic = TRUE,    
  pseudoR2 = c("r2mf", "r2cs", "r2n"),    
  omni = TRUE,    
  ci = TRUE,    
  OR = TRUE,    
  emMeans = ~ hours,    
  emmTables = TRUE,
  emmPlots=FALSE,
  class = TRUE,
  acc = TRUE,
  cutOff = 0.5)

#Pseudo R2 of model with summation_compatibility is higher. Accuracy also higher. First model chosen as final model.

#limitations
#factor structure needs improvement. Presence of negatively worded items, but yet very few negative factor loadings. Need to re-evaluate factor structure
#logistic model had overly high accuracy - might have risk of over fitting. Need to validate model on another sample
