
library(readxl)

###

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

##############################################

filename <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/Measuring_Impact_of_Stabilization_Initiatives_Survey_Data__MISTI___Survey-response_data.csv"
dat <- read.csv(filename, stringsAsFactors = F)
dat$unique_id <- paste(dat$m2, dat$m1)

###

#wave 1

wave1_filename <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI Wave1 Data File V3 CSV updated.csv"
wave1_geo <- read.csv(wave1_filename, stringsAsFactors = F)
wave1_geo$unique_id <- paste("Wave 1", wave1_geo$m1)

wave1_geo <- wave1_geo[, c("unique_id", "m24_lat", "m24_lon", "m11")]
names(wave1_geo) <- c("unique_id", "m24a", "m24b", "m11")

wave1_merge <- merge(dat, wave1_geo, by="unique_id")

###

#wave 2

#wave2_data <- dat[which(dat$m2=="Wave 2"), ]

wave2_filename <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI Wave2 Data File V2.csv"
wave2_geo <- read.csv(wave2_filename, stringsAsFactors = F)
wave2_geo$unique_id <- paste("Wave 2", wave2_geo$m1)

wave2_geo <- wave2_geo[, c("unique_id", "m24a", "m24b", "m11")]


wave2_merge <- merge(dat, wave2_geo, by="unique_id")

###

#wave 3

#wave3_data <- dat[which(dat$m2=="Wave 3"), ]

wave3_filename <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI W3 Data File FINAL V7 12-03-2014 CSV updated.csv"
wave3_geo <- read.csv(wave3_filename, stringsAsFactors = F)
wave3_geo$unique_id <- paste("Wave 3", wave3_geo$m1)

wave3_geo <- wave3_geo[, c("unique_id", "m24a", "m24b", "m11")]

wave3_merge <- merge(dat, wave3_geo, by="unique_id")

###

#wave4_data <- dat[which(dat$m2=="Wave 4"), ]

wave4_filename <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI W4 Data File FINAL V3 19-08-20142_XLS updated.csv"
wave4_geo <- read.csv(wave4_filename, stringsAsFactors = F)
wave4_geo$unique_id <- paste("Wave 4", wave4_geo$m1)

wave4_geo <- wave4_geo[, c("unique_id", "m24a", "m24b", "m11")]

wave4_merge <- merge(dat, wave4_geo, by="unique_id")

###

#wave5_data <- dat[which(dat$m2=="Wave 5"), ]

wave5_filename <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/MISTI W5 Data File V3 18-01-2015 CSV updated.csv"
wave5_geo <- read.csv(wave5_filename, stringsAsFactors = F)
wave5_geo$unique_id <- paste("Wave 5", wave5_geo$m1)

wave5_geo <- wave5_geo[, c("unique_id", "m24a", "m24b", "m11")]

wave5_merge <- merge(dat, wave5_geo, by="unique_id")

###

misti_full <- rbind(wave1_merge, wave2_merge, wave3_merge, wave4_merge, wave5_merge)

misti_full$month_num <- match(misti_full$m8, month.name)
misti_full$interview_date <- paste(misti_full$month_num, misti_full$m9, misti_full$m7, sep="-")

keep_cols <- c("m1",
               "village",
               "i1",
               "i2",
               "m2",
               "m2a",
               "v1",
               "m3",
               "m4",
               "m5",
               "m6",
               "m7",
               "m8",
               "m9",
               "interview_date",
               "m10",
               "m11.x",
               "m12",
               "m13",
               "m14",
               "m15",
               "m16",
               "m17",
               "m18",
               "m19",
               "m20",
               "m21",
               "m22",
               "m24a",
               "m24b",
               "m25",
               "m25b",
               "q1",
               "q26",
               "q27",
               "q28",
               "q29",
               "q30",
               "q2a",
               "q2b",
               "q3b",
               "q4c",
               "q4d",
               "q31",
               "q11a",
               "q11b",
               "q11c",
               "q11d",
               "q14b",
               "q14c",
               "q14d",
               "q14f",
               "q14g",
               "q15",
               "q16a",
               "q16b",
               "q16c",
               "q16d",
               "q16e",
               "q16f",
               "q16g",
               "q16h",
               "q16i",
               "w1_q36a",
               "w1_q36b",
               "w1_q36c",
               "w1_q36d",
               "w1_q36e",
               "w1_q36f",
               "q32",
               "q33")


keep_cols[which(!keep_cols %in% names(misti_full))]

misti_full <- misti_full[, keep_cols]

names(misti_full)[names(misti_full)=="m11.x"] <- "m11"

out_file <- "/Users/christianbaehr/Box Sync/demining/inputData/misti/misti_full.csv"
write.csv(misti_full, out_file, row.names = F)






