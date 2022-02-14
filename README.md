Sub-Saharan Africa Threats to Biodiversity - RedList Analysis
---------------

## What does this analysis do?
This is the R analysisthat produces the data used for the RedList analysis in Leisher et al. (In Press).

This analysis utilizes the species level threat data from [Maxwell et al. 2016](https://www.nature.com/articles/536143a.pdf) and species range data from [The IUCN Red List of Threatened Species](https://www.iucnredlist.org/), to extract species level threats for sub-Saharan Africa as a whole (not including island nations) and for each of the four regions, West, Central, East, and Southern, as defined by the [United Nations Statiscal Division](https://unstats.un.org/unsd/methodology/m49/). The analysis outputs tables with the total counts of each defined threat and the relative ranks of these threat for each of the regions and SSA as a whole.


### Inputs
To run this analyis the following is required:

#### Input Data
1. Data from [Maxwell et al. 2016](https://www.nature.com/articles), input as a CSV - Permissions are required to access this data.

2. [The IUCN Red List of Threatened Species](https://www.iucnredlist.org/) species range data by country, accessed through the [Red List API](https://apiv3.iucnredlist.org/).

#### API Token
1. A unique API token to access the [Red List API](https://apiv3.iucnredlist.org/) through the [rredlist](https://github.com/ropensci/rredlist) R client library.

#### R Libraries
1. [rredlist](https://github.com/ropensci/rredlist)


### Outputs
1. CSVs for SSA and each region containing a list of the species analyzed.

2. CSVs for SSA and each region of the frequency of threats and their relative rankings by count.

3.  A combined CSV, containing the frequency of threats and their relative ranking for each of the four sub-regions and SSA.
