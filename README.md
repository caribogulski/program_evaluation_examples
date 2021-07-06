# program_evaluation_examples
An example of monthly reporting for a maternal/child health program evaluation

As a program evaluator for the Healthy Start program (https://mchb.hrsa.gov/maternal-child-health-initiatives/healthy-start), I reported on several key performance measures and client counts on a monthly basis. I had to keep a running count of clients active in our program by stats (Pregnant/Non-Pregnant) and by month, even if they hadn't participated in a data collection event in a current month (but continued to receive services).

This R code snippet utlizes the `na.locf` from the `zoo` package to pull statuses from prior data collection events forward in time to provide an accurate count of clients by pregnancy status. 
