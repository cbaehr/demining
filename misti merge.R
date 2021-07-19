
## need the sf library
library(sf)

## load the complete MISTI panel with village column (panel)
misti <- read.csv("/Users/christianbaehr/Box Sync/demining/inputData/misti/misti_full.csv",stringsAsFactors = F)

## load the empty grid I sent Brad for the extract (panel)
empty_grid_misti <- st_read("/Users/christianbaehr/Downloads/empty_grid_misti.geojson", stringsAsFactors = F)

## extract village coordinates from geometry
empty_grid_misti[, c("x", "y")] <- st_coordinates(st_centroid(empty_grid_misti$geometry))

## convert from sf to data frame for convenience
empty_grid_misti <- data.frame(empty_grid_misti)

## drop sf geometry before merge
empty_grid_misti <- empty_grid_misti[, names(empty_grid_misti)!="geometry"]

## join complete MISTI panel with empty grid
misti_merge <- cbind(misti, 
                     empty_grid_misti)

## ensure MISTI panel latitude agrees with lat used for extract
all.equal(misti_merge$m24a, 
          misti_merge$y)
## ensure MISTI panel longitude agrees with lon used for extract
all.equal(misti_merge$m24b, 
          misti_merge$x)

all.equal(factor(misti_merge$village), factor(misti_merge$m24b))

misti_merge$merge_id <- paste(misti_merge$village, misti_merge$m2)

all.equal(aggregate(misti_merge[, c("merge_id", "m24b")], by=list(misti_merge$merge_id), FUN=mean),
          aggregate(misti_merge[, c("merge_id", "m24b")], by=list(misti_merge$merge_id), FUN=max))
a=aggregate(misti_merge[, c("merge_id", "m24b")], by=list(misti_merge$merge_id), FUN=mean)
b=aggregate(misti_merge[, c("merge_id", "m24b")], by=list(misti_merge$merge_id), FUN=max)


all.equal(aggregate(misti_merge[, c("village", "m24b")], by=list(misti_merge$village), FUN=mean),
          aggregate(misti_merge[, c("village", "m24b")], by=list(misti_merge$village), FUN=max))
a=aggregate(misti_merge[, c("village", "m24b")], by=list(misti_merge$village), FUN=mean)
b=aggregate(misti_merge[, c("village", "m24b")], by=list(misti_merge$village), FUN=max)

names(a) <- c("group_a", "blah_a", "x_a")
names(b) <- c("group_b", "blah_a", "x_b")

c <- cbind(a, b)

all.equal(c$x_a, c$x_b)

View(c[c$x_a!=c$x_b,])

## drop redundant village observations to create village-level cross-section
misti_cross <- misti_merge[!duplicated(misti_merge$village), ]

## load in Miranda extract data
extract <- read.csv("/Users/christianbaehr/Downloads/merge_misti_allgeoquery.csv", stringsAsFactors = F)

## merge extract rows with cross-sectional MISTI data
out <- merge(misti_cross, 
             extract, 
             by="survey_id")

## drop some MISTI columns. These are in panel form and you'll want to 
## re-merge with the cross-sectional MISTI
drop <- c(names(misti), "x", "y")
drop <- drop[!drop %in% c("m1", "village", "m3", "m4", "m5", "m6", "m21", "m24a", "m24b")]
out <- out[, (!names(out) %in% drop)]

## write MISTI cross-section
write.csv(out, 
          "/Users/christianbaehr/Downloads/misti_out.csv", 
          row.names=F)




