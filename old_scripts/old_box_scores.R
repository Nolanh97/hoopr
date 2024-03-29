library(ncaahoopR)
library(readr)

seasons <- paste0(2002:2021, gsub("0\\.", "-", sprintf("%.2f", seq(.03, .22, 0.01))))
for(j in 1:length(seasons)) {
  schedules <- dir(paste(seasons[j], "schedules", sep = "/"), full.names = T)
  schedules_clean <- dir(paste(seasons[j], "schedules", sep = "/"), full.names = F)
  # schedules <- schedules[grepl("UConn", schedules)]
  # schedules_clean <- schedules_clean[grepl("UConn", schedules_clean)]
  n <- length(schedules)
  for(i in 1:n) {
    ### Read in Schedule
    s <- read_csv(schedules[i])
    n1 <- nrow(s)
    ### Try to Scrape PBP
    for(k in 1:n1) {
      cat("Scraping Game", k, "of", n1, "for Team", i, "of", n, "(Season =", seasons[j], ")\n")
      team <- gsub("_", " ", gsub("_schedule.csv", "", schedules_clean[i]))
      file <- paste(seasons[j], "box_scores", gsub(" ", "_", team), paste0(s$game_id[k], ".csv"), sep = "/")
      if(!file.exists(file)) {
        box <- try(get_boxscore(s$game_id[k]))
        box_team <- ifelse(team == "UConn", team, dict$ESPN_PBP[dict$ESPN == team])
        box[box_team]
        
        if(class(box) != "try-error" & box_team %in% names(box)) {
          ### Create Date Directory if Doesn't Exist
          if(!dir.exists(paste(seasons[j], "box_scores", sep = "/"))) {
            dir.create(paste(seasons[j], "box_scores", sep = "/")) 
          }
          if(!dir.exists(paste(seasons[j], "box_scores", gsub(" ", "_", team), sep = "/"))) {
            dir.create(paste(seasons[j], "box_scores", gsub(" ", "_", team), sep = "/"))
          }
          df <- as.data.frame(box[[box_team]])
          df$date <- s$date[k]
          df$opponent <- s$opponent[k]
          df$location <- s$location[k]
          write_csv(df, file)
        }
       
      }
    }
  }
}
