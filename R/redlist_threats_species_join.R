# Require Red List API Package, must be installed before hand
require(rredlist)


# Set Working Directory - these should be modified based on Source File location
setwd("~/Documents/TNC/projects/Constultancies/OldWork/ssaBiodiversityThreats")
dataDir = "Data/"

# REDLIST API Token - Used in Functinos that Call RedList API
#### Note: in order to use this script a user must obtain a unique Token 
#### from the IUCN. Paste the token below as the KEY variable, and the script
#### will run.


# Get Citation for IUCN Red List API
rl_citation(key=key)
# Get Citation for IUCN Red List Client Package
citation(package = 'rredlist')

# Read In Maxwell et al 2016 Raw Data
spData <- read.csv(paste(dataDir, 
                              "Maxwell et al 2016 raw_data.csv", 
                              sep=""))

# sub-Saharan Africa ISO Country Codes 
countryCodes = c("AO","BJ","BW","BF","BI","CM","CV","CF","TD","KM","CG","CD",
                 "CI","DJ","GQ","ER","ET","GA","GM","GH","GN","GW","KE","LS",
                 "LR","MG","MW","ML","MR","MU","YT","MZ","NA","NE","NG","RE",
                 "RW","SN","SH","ST","SC","SL","SO","ZA","SS","SD","SZ","TZ",
                 "TG","UG","ZM","ZW")

# west <- c("BJ", "BF", "CI", "CV", "GM", "GH", "GN", "GW", "LR", "ML", "MU", "NE", "NG", "SN", "SL", "TG")
# central <- c("CM", "CF", "TD", "CG", "CD",  "GQ", "GA", "ST")
# east <- c("BI", "DJ", "ER", "ET", "KE", "RW", "SO", "SS", "SD", "TZ", "UG")
# southern <- c("AO", "BW", "KM", "LS", "MG", "MW", "MU", "MZ", "NA", "SC", "ZA", "SZ", "ZM", "ZW")

west <- c("BJ", "BF", "CI", "GM", "GH", "GN", "GW", "LR", "ML", "MR", "NE", "NG", "SN", "SL", "TG")
central <- c("AO", "CM", "CF", "TD", "CG", "CD",  "GQ", "GA")
east <- c("BI", "DJ", "ER", "ET", "KE","MW", "MZ", "RW", "SO", "SS", "TZ", "UG", "ZM", "ZW")
southern <- c("BW", "LS", "NA", "ZA", "SZ")

ssa <- c(west, central, east, southern)




coLists = list(west, central, east, southern, ssa)
names = c('West', 'Central', 'East', 'Southern', 'SSA')


outputs <-list()

for(j in 1:5) {
  
  # Total Number of SSA Country Codes to use in For Loop
  countryCodes <- coLists[[j]]
  n = length(countryCodes)
  name = names[j]
  #  Creates an Empty List to Populate
  ssaRedList <- list()
  
  #  Loops through Country Codes and Selects Species for Each Country, 
  #   Populates the Empty List with Results
  for(i in 1:n) {
    # Get ith country code
    iso <- countryCodes [i]
    # Get Red List Species for ith Country
    iCo <- rl_sp_country(iso, key)
    # Convert List of Species to a Data Frame
    iCo <- as.data.frame(iCo)
    iCo <- iCo['result.scientific_name']
    # Populate Empty List with Each Subset
    ssaRedList[[i]] <- iCo
    # Delay 3 seconds before calling red list API
    Sys.sleep(3) 
  }
  
  # Convert list of subsets to on Data Frame
  ssaSpecies <- do.call('rbind', ssaRedList)
  
  # Convert Vector to a Data Frame  
  ssaSp <- as.data.frame(unique(ssaSpecies$result.scientific_name))
  
  # Change the Column Name
  colnames(ssaSp) <- 'spScName'
  
  # Writes SSA IUCN Subset to CSV file in the Data Directory
  write.csv(ssaSp, file = paste("Data/", name, "_IUCNspecies_SSA.csv",  sep = ''))
  
  # Get Number of Unique SSA Species
  length(ssaSp$spScName)
  
  # Merge Maxwell Raw Data and SSA Species - 
  # Result is Maxwell Data subset by Species in SSA
  ssaData <- merge(spData, ssaSp, by.x = 'friendly_name', by.y = 'spScName', 
                   all = FALSE, incomparables = NULL)
  
  # Get Number of Unique SSA Species in Maxwell Dataset
  length(unique(ssaData$friendly_name))
  
  # Convert Threats Into Factor Variable
  ssaData$title <- as.factor(ssaData$title)
  
  # Count the Frequency of Each Threat
  threats <- as.data.frame(table(ssaData$title))
  
  # Change Column Names
  colnames(threats) <- c('Threat', 'Count')
  
  # Order the Data By Threat Frequecy
  ssaThreats <- threats[order(-threats$Count), ] 
  
  write.csv(ssaThreats, file = paste('Data/', name , '-ssaBiodiversityThreats.csv', sep=""))
  outputs[[j]] <- ssaThreats
}
west <- outputs[[1]]
central <- outputs[[2]]
east <- outputs[[3]]
southern <- outputs[[4]]
ssa <- outputs[[5]]


ssa$ssa <- rank(-ssa$Count, ties.method = "min")
ssa <- ssa[c(1,3)]


west$west <- rank(-west$Count, ties.method = "min")
west <- west[c(1,3)]

east$east <- rank(-east$Count, ties.method = "min")
east <- east[c(1,3)]

central$central <- rank(-central$Count, ties.method = "min")
central <- central[c(1,3)]

southern$southern <- rank(-southern$Count, ties.method = "min")
southern <- southern[c(1,3)]

ssaThreats <- merge(ssa, west, by=c("Threat"), all=T)
ssaThreats <- merge(ssaThreats, east, by=c("Threat"), all=T)
ssaThreats <- merge(ssaThreats, central, by=c("Threat"), all=T)
ssaThreats <- merge(ssaThreats, southern, by=c("Threat"), all=T)


ssaThreats <- ssaThreats[order(ssaThreats$ssa),]
write.csv(ssaThreats, 'ssaThreats_update_2-7-2020.csv')
