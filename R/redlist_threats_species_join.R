# Require Red List API Package, must be installed before running this script
require(rredlist)

# Set Working Directory to Source File Location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
w_dir <- getwd()

input_directory = "input_data/"

# REDLIST API Token - Used in functions that call redlist API
#### Note: in order to use this script a user must obtain a unique Token
#### from the IUCN. Paste the token below as the KEY variable, and the script
#### will run.
key = Sys.getenv('redlistKey')

# Get Citation for IUCN Red List API
rl_citation(key = key)

# Get Citation for IUCN Red List Client Package
citation(package = 'rredlist')

# Read In Maxwell et al 2016 Raw Data
maxwell_threats <- read.csv(paste(input_directory,
                          "Maxwell_et_al_2016 raw_data.csv",
                          sep = ""))

# sub-Saharan Africa ISO Country Codes
countryCodes = c(
  "AO",
  "BJ",
  "BW",
  "BF",
  "BI",
  "CM",
  "CV",
  "CF",
  "TD",
  "KM",
  "CG",
  "CD",
  "CI",
  "DJ",
  "GQ",
  "ER",
  "ET",
  "GA",
  "GM",
  "GH",
  "GN",
  "GW",
  "KE",
  "LS",
  "LR",
  "MG",
  "MW",
  "ML",
  "MR",
  "MU",
  "YT",
  "MZ",
  "NA",
  "NE",
  "NG",
  "RE",
  "RW",
  "SN",
  "SH",
  "ST",
  "SC",
  "SL",
  "SO",
  "ZA",
  "SS",
  "SD",
  "SZ",
  "TZ",
  "TG",
  "UG",
  "ZM",
  "ZW"
)

# regional codes
west <-
  c("BJ",
    "BF",
    "CI",
    "GM",
    "GH",
    "GN",
    "GW",
    "LR",
    "ML",
    "MR",
    "NE",
    "NG",
    "SN",
    "SL",
    "TG")
central <- c("AO", "CM", "CF", "TD", "CG", "CD",  "GQ", "GA")
east <-
  c("BI",
    "DJ",
    "ER",
    "ET",
    "KE",
    "MW",
    "MZ",
    "RW",
    "SO",
    "SS",
    "TZ",
    "UG",
    "ZM",
    "ZW")
southern <- c("BW", "LS", "NA", "ZA", "SZ")

# combine for all of SSA
ssa <- c(west, central, east, southern)

# Create lists to loop over
country_lists = list(west, central, east, southern, ssa)
regional_names = c('West', 'Central', 'East', 'Southern', 'SSA')

# Create empty list to populate
outputs <- list()


for (j in 1:5) {
  # Total Number of SSA Country Codes to use in For Loop
  country_codes <- country_lists[[j]]
  
  n = length(country_codes)
  
  name = regional_names[j]
  #  Creates an Empty List to Populate
  ssaRedList <- list()
  
  #  Loops through Country Codes and Selects Species for Each Country,
  #   Populates the Empty List with Results
  for (i in 1:n) {
    # Get ith country code
    iso <- country_codes [i]
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
  
  # # Writes SSA IUCN Subset to CSV file in the Data Directory
  # write.csv(ssaSp,
  #           file = paste("outputs/", name, "_IUCN_Maxwell_Species.csv",  sep = ''))
  
  
  # Merge Maxwell Raw Data and SSA Species -
  # Result is Maxwell Data subset by Species in SSA
  ssaData <-
    merge(
      maxwell_threats,
      ssaSp,
      by.x = 'friendly_name',
      by.y = 'spScName',
      all = FALSE,
      incomparables = NULL
    )
  
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
  
  write.csv(ssaThreats, file = paste('outputs/', name , '_threat_species_counts.csv', sep =
  ""))
  outputs[[j]] <- ssaThreats
}

west <- outputs[[1]]
central <- outputs[[2]]
east <- outputs[[3]]
southern <- outputs[[4]]
ssa <- outputs[[5]]


ssa$ssa <- rank(-ssa$Count, ties.method = "min")
ssa <- ssa[c(1, 3)]


west$west <- rank(-west$Count, ties.method = "min")
west <- west[c(1, 3)]

east$east <- rank(-east$Count, ties.method = "min")
east <- east[c(1, 3)]

central$central <- rank(-central$Count, ties.method = "min")
central <- central[c(1, 3)]

southern$southern <- rank(-southern$Count, ties.method = "min")
southern <- southern[c(1, 3)]

ssaThreats <- merge(ssa, west, by = c("Threat"), all = T)
ssaThreats <- merge(ssaThreats, east, by = c("Threat"), all = T)
ssaThreats <- merge(ssaThreats, central, by = c("Threat"), all = T)
ssaThreats <- merge(ssaThreats, southern, by = c("Threat"), all = T)


ssaThreats <- ssaThreats[order(ssaThreats$ssa),]
write.csv(ssaThreats,
          paste("outputs/", "ssa_ranked_threats.csv", sep = ""))
