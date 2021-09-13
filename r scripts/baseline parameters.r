library(tidyverse)
library(lubridate)
library(scales)
library(patchwork)
library(readxl)
library(janitor)


early_model.df <- read_csv("Data/Netlogo/general/cycles/gen_early_ cycles.csv") %>%
  clean_names()

early_model.df <- early_model.df %>%
  mutate(timesteps = 0:1000)


early_model_long.df <- early_model.df %>%
  gather(output_names, value, -timesteps)

# removes number to trial column then deletes numbers in names and then deletes last _ if there
early_model_long.df  <- early_model_long.df %>%
  mutate(trial = str_extract(output_names, "(\\d)+"),
         output_names = str_remove(output_names, "(\\d)+"),
         output_names = str_remove(output_names, "\\_$"))

# makes numeric
early_model_long.df  <- early_model_long.df %>%
  mutate(trial = as.numeric(trial))

# adds in 0 for NA values
early_model_long.df  <- early_model_long.df %>%  
  mutate(trial = ifelse(is.na(trial), 0, trial))


# this converts to wide
early_model_wide.df <- early_model_long.df %>%
  spread(key = output_names, value = value)

# now Kate wants - starts with pre
early_subset.df <- early_model_wide.df %>%
  select(timesteps, trial, starts_with("pre"),
         starts_with("post"),
         starts_with("hatch"),
         starts_with("early"),
         starts_with("late"),
         starts_with("adult"),
         starts_with("total"),
  )


early_subset.df <- early_subset.df %>%
  gather(mort_time, mort_percent, -timesteps, -trial, - adult_number, -premort_adults, - postmort_adults,
         -hatch_interval, - total_mosquito_number
  )

early_subset.df <- early_subset.df %>%
  mutate(mort_time = as.character(mort_time)) %>%
  mutate(hatch_interval = as.character(hatch_interval)) 

early_subset.df <- early_subset.df %>%
  mutate(mort_time  = dplyr::recode(mort_time, "early_juvenile_mortality" = "early")) %>%
  mutate(mort_time  = dplyr::recode(mort_time, "late_juvenile_mortality" = "late")) %>%
  mutate(hatch_interval = dplyr::recode(hatch_interval, "1" = "asynch")) %>%
  mutate(hatch_interval  = dplyr::recode(hatch_interval, "70" = "synch")) 

early_only <- early_subset.df %>%
  filter(mort_time == "early") %>%
  filter(mort_percent > 0)


#write_csv(early_subset.df, "data/Netlogo/general/early_subset_food_r.csv")


###late mortality files input ###


late_model.df <- read_csv("Data/Netlogo/general/cycles/gen_late_cycles.csv")%>%
  clean_names()


late_model.df <- late_model.df %>%
  mutate(timesteps = 0:1000)


late_model_long.df <- late_model.df %>%
  gather(output_names, value, -timesteps)

# removes number to trial column then deletes numbers in names and then deletes last _ if there
late_model_long.df  <- late_model_long.df %>%
  mutate(trial = str_extract(output_names, "(\\d)+"),
         output_names = str_remove(output_names, "(\\d)+"),
         output_names = str_remove(output_names, "\\_$"))

# makes numeric
late_model_long.df  <- late_model_long.df %>%
  mutate(trial = as.numeric(trial))

# adds in 0 for NA values
late_model_long.df  <- late_model_long.df %>%  
  mutate(trial = ifelse(is.na(trial), 0, trial))


# this converts to wide
late_model_wide.df <- late_model_long.df %>%
  spread(key = output_names, value = value)

# now Kate wants - starts with pre
late_subset.df <- late_model_wide.df %>%
  select(timesteps, trial, starts_with("pre"),
         starts_with("post"),
         starts_with("hatch"),
         starts_with("early"),
         starts_with("late"),
         starts_with("adult"),
         starts_with("total"),
  )


late_subset.df <- late_subset.df %>%
  gather(mort_time, mort_percent, -timesteps, -trial, - adult_number, -premort_adults, - postmort_adults,
         -hatch_interval, - total_mosquito_number
  )

late_subset.df <- late_subset.df %>%
  mutate(mort_time = as.character(mort_time)) %>%
  mutate(hatch_interval = as.character(hatch_interval)) 

late_subset.df <- late_subset.df %>%
  mutate(mort_time  = dplyr::recode(mort_time, "early_juvenile_mortality" = "early")) %>%
  mutate(mort_time  = dplyr::recode(mort_time, "late_juvenile_mortality" = "late")) %>%
  mutate(hatch_interval = dplyr::recode(hatch_interval, "1" = "asynch")) %>%
  mutate(hatch_interval  = dplyr::recode(hatch_interval, "70" = "synch")) 

late_subset.df <- late_subset.df %>%
  filter(mort_time == "late")

late_only <-late_subset.df %>%
  filter(mort_percent > 0 ) %>%
  mutate(trial = (trial + 200))

control.df.synch <- late_subset.df  %>%
  filter(mort_percent == 0)  %>%
  filter(hatch_interval == "synch") %>% 
  arrange(trial) %>%
  mutate(trial = (trial = rep(0:24, each = 1001)))

control.df.asynch <- late_subset.df  %>%
  filter(mort_percent == 0)  %>%
  filter(hatch_interval == "asynch") %>% 
  arrange(trial) %>%
  mutate(trial = (trial = rep(25:49, each = 1001)))

control.df <- bind_rows(control.df.asynch, control.df.synch)


control.df.early <- control.df %>%
  mutate(trial = (trial + 100)) %>%
  mutate(mort_time  = dplyr::recode(mort_time, "late"="early"))
  


late_subset.df <- bind_rows(late_only, control.df)

write_csv(late_subset.df, "data/Netlogo/general/cycles/late_subset_cycles.csv")


#incorporate the control groups into the early subset too
early_only <- early_only %>%
  mutate(trial = (trial + 1000))

early_subset.df <- bind_rows(early_only, control.df.early)


write_csv(early_subset.df, "data/Netlogo/general/cycles/early_subset_cycles.csv")




late_subset.df <- read_csv("data/Netlogo/general/cycles/late_subset_cycles.csv") %>%
  clean_names()

early_subset.df <- read_csv("data/Netlogo/general/cycles/early_subset_cycles.csv") %>%
  clean_names()


combined <- bind_rows(late_subset.df, early_subset.df)

write_csv(combined, "data/Netlogo/general/cycles/combined_cycles.csv")



#how many trials ended before 1000 timesteps?
end_point.df <- combined %>%
  group_by(trial) %>%
  filter(total_mosquito_number == 0) %>%
  filter(timesteps == min(timesteps))


#select the end time point for each trial when mosquitoes were still present
final_results.df <- combined %>% 
  group_by(trial) %>%
  filter(timesteps == max(timesteps))


#make a variable for the differnce between pre and post adults, and a variable for if the population persisted
forgraphs.df <- final_results.df %>%
  mutate(diff = (postmort_adults - premort_adults)) %>%
  mutate(pop_persist = ifelse(timesteps < 1000, 0, 1))

write_csv(forgraphs.df, "data/Netlogo/general/forgraphs_gen_cycles.csv")




cbPalette2 <- c("#56B4E9", "#009E73")




sum_forstats <- forgraphs.df %>%
  group_by(mort_percent, mort_time, hatch_interval) %>%
  summarize(mean_diff = mean(diff, na.rm = TRUE)) 

sum_forstats

forgraphs.df %>%
  ungroup()

ggplot(forgraphs.df, aes(mort_percent, diff, color = hatch_interval)) + 
  geom_pointrange(mapping = aes(x = mort_percent, y = diff, color = hatch_interval),
                  stat = "summary",
                  fun.ymin = min,
                  fun.ymax = max,
                  fun.y = mean,
                  position = position_dodge(width = 5)) +
  scale_color_manual(values = cbPalette2)+
  facet_wrap(~mort_time)+
  geom_hline(yintercept= 6.28) +
  geom_hline(yintercept = 4.76, linetype = "dashed") +
  theme(plot.subtitle = element_text(vjust = 1), 
                                                         plot.caption = element_text(vjust = 1), 
                                                         axis.line = element_line(linetype = "solid"), 
                                                         panel.background = element_rect(fill = "white")) +labs(title = "Comparing Adult Numbers Pre and Post Mortality, 2 peaks of 4pt cycle ", 
                                                                                                                x = "Mortality %", y = "Difference in Adult Number", 
                                                                                                                colour = "Cohort Synchony")




#get rid of control doubles (which we needed for graphing)
forsas <- forgraphs.df %>%
  group_by(trial) %>%
  filter(!(mort_time == "early" & mort_percent == 0))

#label control
forsas <- forsas %>%
  mutate(mort_time  = if_else(mort_percent == 0, "control", mort_time)) 



write_csv(forsas, "data/Netlogo/general/sasfiles/forsas_2peaks.csv")





