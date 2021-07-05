##### Description #####
##
##  This is an approximation of reporting clients
##  by pregnancy status each month for a maternal
##  and child health program. The raw data include
##  3 variables:
##    - id: a unique identifier for each client
##    - status: the client's status (Pregnant or NonPregnant)
##      at each data collection point
##    - admin.date: the date the data were collected
##
##  Data are collected when clients are enrolled
##  (either Pregnant or NonPregnant) and after
##  delivery (when a Pregnant woman becomes NonPregnant).
##  
##  The program's funder would like a monthly
##  report of how many Pregnant and NonPregnant
##  clients were served in each month. Women clients
##  can be counted as either Pregnant or NonPregnant
##  from one month to another, depending on their
##  pregnancy status as assessed during data collection.
##  All clients in this example are active every month after
##  they are enrolled (i.e., no clients in this example
##  have become inactive).
##  
##  The final output
##  (called monthly.report.output in this example)
##  will be a data frame with each row as a month
##  in the program, with a count of active Pregnant
##  and NonPregnant clients each month.
##

##### 1. Install Packages  #####
# install.packages("zoo")
# install.packages("tidyverse")
# install.packages("lubridate")
# install.packages("reshape2")
# install.packages("kableExtra")

##### 2. Load Packages #####
library(zoo)
library(tidyverse)
library(lubridate)
library(reshape2)
library(kableExtra)

##### 3. Set Program Reporting Start/End Dates #####
start.date = ymd("2020-01-01")
end.date = ymd(today())

##### 4. Load Data #####

##  Create some fake data
##  
##  NOTE: In this example, clients can enroll
##  as either pregnant or non-pregnant. If they 
##  enroll as pregnant, they will have a follow-up
##  data collection event after delivery. Thus,
##  clients may have multiple data collection
##  events (rows).

id <- c(101,103,104,119,101,110,103)  ##  Client ID Numbers
status <- c("Pregnant","Pregnant","Pregnant","NonPregnant","NonPregnant","Pregnant","NonPregnant")  ##  Pregnancy status at admin date
admin.date <- c("1/29/2020","3/4/2020","3/19/2020","5/26/2020","10/17/2020","10/4/2020","7/2/2020") ##  Date clients were administered a data collection tool

##  Combine fake data into a data frame
client.data <- as.data.frame(cbind(id, status, admin.date))

##  Code each admin.date by month (using zoo's as.yearmon() function)
client.data$admin.month <- as.yearmon(mdy(as.character(client.data$admin.date)))

##### 5. Transform Data  #####
##  Create data frame with all months between start date and end date
Month = as.yearmon(seq(start.date, end.date, by = "month"))

ids.and.all.months <- expand.grid(id = unique(client.data$id), Month = Month)

month.and.status <- expand.grid(Month = Month, 
                                status = unique(client.data$status))

##  Merge
client.data.by.month <- merge(ids.and.all.months, client.data, 
                             by.x = c("id","Month"), by.y = c("id","admin.month"),
                             all = T)

##  Re-order data by client and month
client.data.by.month = client.data.by.month[order(client.data.by.month$id,client.data.by.month$Month),]

##  Fill in pregnancy status between administrative dates
client.data.by.month <- client.data.by.month %>% 
  group_by(id) %>% 
  mutate(report.status = na.locf0(status))

##### 6. Aggregate Data  #####

##  Create a data frame with a count of clients (rows)
##  by status each month (for now, this includes NA, which
##  are months before clients were enrolled/active).
monthly.report <- client.data.by.month %>% 
  group_by(Month,report.status) %>%
  count(name = "Total")

##  Add all pregnancy statuses, even if
##  no clients were active with that status each month.
monthly.report.output.long <- merge(month.and.status, monthly.report,
                             by.x=c("Month","status"),
                             by.y=c("Month","report.status"),
                             all.x=T)

##  Replace NAs with 0s.
monthly.report.output.long[is.na(monthly.report.output.long)] <- 0

##  Re-cast the output so that each pregnancy status is a column.
monthly.report.output <- dcast(monthly.report.output.long, Month ~ status, 
                             value.var = "Total")

##### 7. Final Output  #####

##  Create a table of the final monthly report
kableExtra::kbl(monthly.report.output) %>% kableExtra::kable_minimal()
