
#' This is an example to clustering patients from keren et al. paper:
#'                https://www.cell.com/cell/pdf/S0092-8674(18)31100-0.pdf
#' Here we just use Macrophage cell type as cells of interest.

rm(list=ls())

# invoke source codes
source(".../Codes/ExtractFeatures.R")
source(".../Codes/Locator.R")

#######################################################################################################
# If the input Data is a 'SpatialExperiment' object (spe), First user has to convert it as a dataframe:
# df_counts <- as.data.frame(as.matrix(t(counts(spe))))
# df_colData <- as.data.frame(as.matrix(colData(spe)))
# df_coords <- as.data.frame(as.matrix(spatialCoords(spe)))
# Data <- cbind(df_colData, df_counts, df_coords)

#######################################################
# Main Data must be included below columns:
#  - Image ID (string or integer)
#  - cell ID (integer)
#  - celltype names (string)
#  - X position (float)
#  - Y position (float)
#  - Meta celltype (binary: 1 if cell is tumor and 0 otherwise)
#  - ExistingClasses (if there are any such as: Survival or PAM50 data)

DataPath = ".../Data/"

KerenData <- fread(paste(DataPath,"KerenData.csv",sep=""))
KerenData <- data.frame(KerenData)
KerenData <- KerenData[(KerenData$MixingClass!="Cold"),]
KerenData = data.frame(KerenData)

# Parameters and columns setting for main data
SampleID_col = 2
CellID_col = 1
CellType_col = 6
CellTypesOfInterest = 'Macrophages'
MarkersOfInterest_col = NULL
Zscore = TRUE
PositivityCutoff = 0.5
MetaCellType_col = 3
X_col = 4
Y_col = 5
r = 100 
minCount = 10
ExistingClass_col = 7
Nseed = 1234
colnames(KerenData)[SampleID_col] <- "sample_id"
colnames(KerenData)[CellType_col] <- "CellType"
colnames(KerenData)[CellID_col] <- "cell_id"
colnames(KerenData)[MetaCellType_col] <- "MetaCellType"
colnames(KerenData)[X_col] <- "Pos_X"
colnames(KerenData)[Y_col] <- "Pos_Y"

# Parameters and columns setting for Survival data
SurvivalSampleID_col = 1
SurvivalTime_col = 2
SurvivalCensored_col = 3
KerenSurvival <- fread(paste(DataPath,"KerenSurvival.csv",sep=""))
SurvivalData <- data.frame(KerenSurvival)
colnames(SurvivalData)[SurvivalSampleID_col] <- "sample_id"
colnames(SurvivalData)[SurvivalTime_col] <- "SurvivalTime"
colnames(SurvivalData)[SurvivalCensored_col] <- "Censored"


##########################################################
#                                                        #
#               Feature extraction                       #
#                                                        #
##########################################################

start_time <- Sys.time()

KerenFeatures <- Extract_Features(Data = KerenData)

end_time <- Sys.time()
print(end_time - start_time)


##########################################################
#                                                        #
#            Run main function "TIMEClust"               #
#                                                        #
##########################################################

# 
start_time <- Sys.time()

OutPuts <- TIMEClust(FeatureData = KerenFeatures, 
                   MainData = KerenData,
                   SurvivalData = SurvivalData,
                   Cutoff = 'Mean')

end_time <- Sys.time()
print(end_time - start_time)

#
#files and plots

# csv file for clusterd cells information
print(head(OutPuts$ClusteredData))

# csv file for samples information
print(head(OutPuts$SampleData))

# Heatmap plot
print(OutPuts$Heatmap)

# Tsne plot
print(OutPuts$Tsne)

# Box plot
print(OutPuts$Boxplot)

# Bar plot
print(OutPuts$Barplot)

# Map plot
print(OutPuts$MapPlot)

# Alluvium plot
print(OutPuts$AlluviumPlot)

# Survival plot
print(OutPuts$SurvivalPlots)
