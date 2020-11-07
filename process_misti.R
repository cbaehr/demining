
file <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI Wave1 Data File V3 CSV.csv"

wave1 <- read.csv(file, stringsAsFactors = F)

bad_lon <- which(wave1$m24_lon < 33)

wave1 <- wave1[-bad_lon, ]

summary(wave1$m24_lat)
summary(wave1$m24_lon)

out_file <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI Wave1 Data File V3 CSV updated.csv"
write.csv(wave1, out_file, row.names = F)

###

# wave 2 good

###

file <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI W3 Data File FINAL V7 12-03-2014 CSV.csv"
wave3 <- read.table(file, sep=";", header=T, stringsAsFactors = F)

wave3$m24a <- gsub(",", ".", wave3$m24a)
wave3$m24a <- as.numeric(wave3$m24a)

wave3$m24b <- gsub(",", ".", wave3$m24b)
wave3$m24b <- as.numeric(wave3$m24b)

out_file <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI W3 Data File FINAL V7 12-03-2014 CSV updated.csv"
write.csv(wave3, out_file, row.names = F)

###

library(readxl)

file <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI W4 Data File FINAL V3 19-08-20142_XLS.xlsx"

wave4 <- read_xlsx(file, sheet = 2)
wave4 <- as.data.frame(wave4, stringsAsFactors=F)

out_file <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI W4 Data File FINAL V3 19-08-20142_XLS updated.csv"
write.csv(wave4, out_file, row.names = F)

###

file <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI W5 Data File V3 18-01-2015 CSV.csv"

wave5 <- read.table(file, sep=";", header=T, stringsAsFactors = F)

wave5$m24a <- gsub(",", ".", wave5$m24a)
wave5$m24a <- as.numeric(wave5$m24a)

wave5$m24b <- gsub(",", ".", wave5$m24b)
wave5$m24b <- as.numeric(wave5$m24b)

out_file <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI W5 Data File V3 18-01-2015 CSV updated.csv"

write.csv(wave5, out_file, row.names = F)

###




