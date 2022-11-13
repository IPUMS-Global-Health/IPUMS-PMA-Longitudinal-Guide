* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*
* Stata syntax that appears in the markdown file to adapt the IPUMS PMA
* April 1, 2022 blog post to feature Stata examples.
*
* Developed at Biostat Global Consulting (www.biostatglobal.com)
*
* Updated October 20, 2022
* 
* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*
* Note that we use an 80-character-wide string of asterisks below to note
* where the markdown code chunks start and stop.
*
*
* Note also that there is only a single cd command in this program.  The program
* requires two datasets to be present: pma_00126 and pma_00153.  This program
* does not save any output, either in the form of datasets or graphics image 
* files.
* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

********************************************************************************

cd "Q:/BMGF - PMA IPUMS FP Blog Posts/Blog3/Blog3 Stata Markdown"

use "pma_00120.dta", clear

gen pop = .
replace pop = 1 if country == 1 // Burkina Faso
replace pop = 2 if country == 2 & geocd == 1 // Kinshasa
replace pop = 3 if country == 2 & geocd == 2 // Kongo Central
replace pop = 4 if country == 7 // Kenya
replace pop = 5 if country == 9 & geong == 4 // Kano
replace pop = 6 if country == 9 & geong == 2 // Lagos

label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace

label values pop pop

table ( pop ) ( ) ( ), nototals missing

preserve

********************************************************************************

use "pma_00120.dta", clear
drop if missing(hhid_1) // focus on Phase 1
bysort hhid_1: keep if _n == 1 // keep one row per household
gen completed = inlist(resulthq_1,1,5) // all or part of Phase I HH q
tab completed

********************************************************************************

restore

* Step 1
*group the data by pop and gen new var step = 1 and keep
sort pop
gen step = 1
gen keep = resulthq_1 == 1 | resulthq_1 == 5
* generate a new data to have keep == true only and tab step keep (group by pop)
table (pop) ( step keep ) () if keep == 1, nototals missing zerocounts

* These counts correspond to those at the top of the figure labeled
* Phase 1 household members

********************************************************************************

* Step 2
* filter hh so that only have keep == true then update the step var to 2 and keep var
keep if keep == 1
replace step = 2
drop keep
gen keep = eligible_1 == 1
* tab step and keep, with the new tab table generate label (group by pop)
table (pop) ( step keep ) (), nototals missing zerocounts

* These counts correspond to those in the figure labeled
* Not eligible for Phase 1 FQ

********************************************************************************

* Step 3
* filter hh to only have keep == true then update the step var to 3 and keep var
keep if keep == 1
replace step = 3
drop keep
gen keep = resultfq_1 == 1 | resultfq_1 == 5
* tab step and keep, with the new tab table generate label (group by pop)
table (pop) ( step keep ) (), nototals missing zerocounts

* These counts correspond to those in the figure labeled
* Completed all / part of Phase 1 FQ

********************************************************************************

* Step 4
* filter hh to only have keep == true then update the step var to 4 and keep var
keep if keep == 1
replace step = 4
drop keep
gen keep = surveywilling_1 == 1
* tab step and keep, with the new tab table generate label (group by pop)
table (pop) ( step keep ) (), nototals missing zerocounts

* These counts correspond to those in the figure labeled
* Consented at Phase 1 to Phase 2 follow-up

********************************************************************************

* Step 5
* filter hh to only have keep == true then update the step var to 5 and keep var
keep if keep == 1
replace step = 5
drop keep
gen keep = age_1 < 49
* tab step and keep, with the new tab table generate label (group by pop)
table (pop) ( step keep ) (), nototals missing zerocounts

* These counts correspond to those in the figure labeled
* Women aged 15-49 at Phase 2

********************************************************************************

* Step 6
* filter hh to only have keep == true then update the step var to 6 and keep var; also update samedw var
keep if keep == 1
replace step = 6
drop keep
gen keep = resulthq_2 == 1
gen samedw = samedwelling_2 == 1
*update samedw
replace samedw = 1 if keep == 0 
*table step and keep
table (pop samedw) ( step keep ) (), nototals missing zerocounts

* These counts correspond to those in the figure labeled
* Completed all the Phase 2 HQ survey

********************************************************************************

*rbind the hh_plot with this table

* Step 7
* Filter hh to only have keep == true then update the step var to 7 and keep var
keep if keep == 1
replace step = 7
drop keep
gen keep = hhmemstat_2 == 1 | hhmemstat_2 == 99
*tab step and keep, with the new tab table generate n (as string) and label
table (pop samedw) ( step keep ) (), nototals missing zerocounts

* These counts correspond to those in the figure labeled
* Resident in dwelling

********************************************************************************

* Step 8
* filter hh to only have keep == true then update the step var to 8 and keep var
keep if keep == 1
replace step = 8
drop keep
gen keep = resultfq_2 == 1
*tab step and keep, with the new tab table generate n (as string) and label
table (pop samedw) ( step keep ) (), nototals missing zerocounts

* These counts correspond to those in the figure labeled
* Completed all of the Phase 2 FQ survey

********************************************************************************

* Step 9
* filter hh to only have keep == true then update the step var to 9 and keep = TRUE
keep if keep == 1
replace step = 9
drop keep
gen keep = 1
*tab step and keep, with the new tab table generate n (as string) and label
table (pop) ( step keep ) (), nototals missing zerocounts

* These counts correspond to those in the figure labeled
* Panel Members at Phase 2

