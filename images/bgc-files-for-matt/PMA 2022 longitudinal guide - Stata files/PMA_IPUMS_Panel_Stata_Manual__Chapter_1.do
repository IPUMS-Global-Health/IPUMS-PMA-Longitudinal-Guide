* ==============================================================================
* ==============================================================================
* ==============================================================================
*
* Stata syntax to adapt the IPUMS PMA March 1, 2022 blog post 
* (https://tech.popdata.org/pma-data-hub/posts/2022-03-01-phase2-discovery/)
* to feature Stata examples.
*
* Developed at Biostat Global Consulting (www.biostatglobal.com)
*
* Updated November 8, 2022
* 
* ==============================================================================
* ==============================================================================
* ==============================================================================
*
* The program requires two datasets to be present: pma_00126 and pma_00153.  
* This program does not save any output, either in the form of datasets or 
* graphics image files.

* ==============================================================================
*
* Contact Dale Rhoda and Mia Yu with questions: 
* Dale.Rhoda@biostatglobal.com, Mia.Yu@biostatglobal.com
*
* ==============================================================================

cd "Q:/BMGF - PMA IPUMS FP Blog Posts/PMA 2022 longitudinal guide - Stata files"

capture log close
set linesize 80
log using Blog1_log.txt, text replace

use pma_00126, clear

* In BF Phase 1, and had female questionnaire at least partly completed & 
* under age 49 & usual resident who slept here last night.
* Note: To be eligible for Phase 2, the woman had to be < age 49 at Phase 1.
gen of_interest_1 = sample_1 ==  85409 & ///
                    (resultfq_1 == 1 | resultfq_1 == 5 ) & ///
					agehq_1 <  49 & ///
					resident_1 != 21

* In BF Phase 2, and had female and household questionnaire completed & 
* <= age 49 & usual resident or visitor who slept here last night
gen of_interest_2 = sample_2 ==  85412 & ///
                    (resultfq_2 == 1 & resulthq_2 == 1 ) & ///
					agehq_2 <= 49 & ///
					resident_2 != 21 & resident_2 != 31

* Of interest in both studies
gen of_interest_both = of_interest_1 & of_interest_2

label variable cp_1    "Contraceptive user (Phase 1)"
label variable cp_2    "Contraceptive user (Phase 2)"

keep if of_interest_both

table ( cp_1 ) ( cp_2 ) (), nototals missing zerocounts

********************************************************************************

gen cp_both = cp_1 == 1 & cp_2 == 1 if cp_1 < 90
label variable cp_both "Contraceptive user (Phases 1 & 2)"
label define cp_both 1 "Yes" 0 "No", replace
label values cp_both cp_both

* This is a lean svyset call.  We recall that the default vce option is 
* vce(linearized) and the default singleunit option is (missing).  
* Read the svyset documentation if you want to consider using other settings.  
* For now, the defaults are fine.

svyset eaid_1, strata(strata_1) weight(panelweight) 
svy: proportion cp_both

********************************************************************************

* Calculate the design effect for the most recent estimation
estat effects

********************************************************************************

* Generate a dataset of a simple random sample of 5,207 respondents where
* 18.8% have the outcome and estimate the proportion;

clear
set obs 5207
gen y = 0
replace y = 1 if _n < 0.188 * 5207
tab y
svyset _n
svy: proportion y

* Generate a dataset of a simple random sample of 929 respondents where
* 18.8% have the outcome and estimate the proportion;

clear
set obs 929
gen y = 0
replace y = 1 if _n < 0.188 * 929
tab y
svyset _n
svy: proportion y

********************************************************************************

* Now examine the complex data 95% CI width divided by the 
* simple random sample of 5,207 95% CI width and see that it is ~= DEFT

di (.2144-.1638) / (.1987-.1774)

********************************************************************************

use pma_00153, clear

* Phase 1 : had female questionnaire at least partly completed & 
* under age 49 & usual resident who slept here last night
gen of_interest_1 = (resultfq_1 == 1 | resultfq_1 == 5 ) & ///
                    agehq_1 <  49  & resident_1 != 21

* Phase 2 : had female and household questionnaire completed & 
* <= age 49 & usual resident or visitor who slept here last night
gen of_interest_2 = (resultfq_2 == 1 & resulthq_2 == 1 ) & ///
                    agehq_2 <= 49  & resident_2 != 21 & resident_2 != 31

* Of interest in both studies
gen of_interest_both = of_interest_1 & of_interest_2

keep if of_interest_both

table ( strata_1 ) () ( country ) if of_interest_both, ///
      nototals missing zerocounts

********************************************************************************

table ( geocd ) if country == 2, nototals missing zerocounts

tab geocd
tab geocd, nolabel

********************************************************************************

* Note that the values of geocd are distinct from the values of strata_1
sum strata_1
sum geocd

* So make a new variable named strata_recode and set it to strata_1 
* everywhere except DRC and set it to geocd in DRC
clonevar strata_recode = strata_1 
replace  strata_recode = geocd if country == 2

* Now copy the value label from strata_1 into a new label named strata_recode
* and update it with the labels from geocd

label copy STRATA_1 strata_recode, replace
label define strata_recode 1 "Kinshasa, DRC" 2 "Kongo Central, DRC", modify

* Use the new value label with the new variable
label values strata_recode strata_recode

* Note that the new variable is not missing for any women
* of interest from Phase 1 and Phase 2
tab strata_recode, m

********************************************************************************

* Generate cp_both again for this wide dataset
gen cp_both = cp_1 == 1 & cp_2 == 1 if cp_1 < 90
label variable cp_both "Contraceptive user (Phases 1 & 2)"
label define cp_both 1 "Yes" 0 "No", replace
label values cp_both cp_both

svyset eaid_1, strata(strata_recode) weight(panelweight) 

* For Stata to estimate the proportion for each population, 
* we will use the over(varname) option where varname needs to
* be an integer variable - preferably with a value label. 

* So construct a new variable named pop_numeric and give it a 
* unique value for each PMA population.

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

svy : proportion cp_both , over(pop) 

********************************************************************************

use pma_00126, clear

keep if sample_1 == 85409

table ( resident_1 ) () (), nototals missing zerocounts
table ( resident_2 ) () (), nototals missing zerocounts

********************************************************************************

keep if inlist(resident_1,11,22) & inlist(resident_2,11,22)
label variable resident_1 "Resident type - Phase 1"
label variable resident_2 "Resident type - Phase 2"
label define RESIDENT_1 11 "Visitor" 22 "Usual", modify
label define RESIDENT_2 11 "Visitor" 22 "Usual", modify

table ( resident_1 ) ( resident_2 ) (), nototals missing zerocounts

********************************************************************************

use pma_00126, clear

keep if sample_1 == 85409

tab resultfq_2, m

label list RESULTFQ_2

********************************************************************************

use pma_00126, clear

keep if sample_1 == 85409

keep if resultfq_2 == 1

tab resultfq_1 resultfq_2,m

********************************************************************************

use pma_00126, clear

keep if sample_1 == 85409

keep if inlist(resident_1,11,22) & inlist(resident_2,11,22) & resultfq_2 == 1

tab resultfq_1 resultfq_2,m


********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************

* This block of code is not in the chapter, but it explores the % of 
* contraceptive users in phase 1 and phase 2 and then in phases 1 and 2.

use pma_00126, clear

keep if sample_1 ==  85409 | sample_2 ==  85412

* In BF Phase 1, and had female questionnaire at least partly completed & 
* under age 49 & usual resident who slept here last night
* Note: To be eligible for Phase 2, the woman had to be < age 49 at Phase 1.
gen of_interest_1 = sample_1 ==  85409 & ///
                    (resultfq_1 == 1 | resultfq_1 == 5 ) & ///
					agehq_1 <  49 & ///
					resident_1 != 21

* In BF Phase 2, and had female and household questionnaire completed & 
* <= age 49 & usual resident or visitor who slept here last night
gen of_interest_2 = sample_2 ==  85412 & ///
                    (resultfq_2 == 1 & resulthq_2 == 1 ) & ///
					agehq_2 <= 49 & ///
					resident_2 != 21 & resident_2 != 31

* Of interest in both studies
gen of_interest_both = of_interest_1 & of_interest_2

gen cp_both = cp_1 == 1 & cp_2 == 1
label define cp_both 1 "Yes" 0 "No", replace
label values cp_both cp_both

label variable cp_1    "Contraceptive user (Phase 1)"
label variable cp_2    "Contraceptive user (Phase 2)"
label variable cp_both "Contraceptive user (Phases 1 & 2)"

table ( cp_1 ) ( cp_2 ) () if of_interest_both, nototals missing zerocounts

svyset eaid_1, strata(strata_1) weight(fqweight_1) 
svy, subpop(of_interest_1 ):    proportion cp_1

svyset eaid_2, strata(strata_2) weight(fqweight_2) 
svy, subpop(of_interest_2 ):    proportion cp_2

clonevar eaid_either = eaid_1
replace eaid_either = eaid_2 if missing(eaid_either)

svyset eaid_either, strata(strata_1) weight(panelweight) 
svy, subpop(of_interest_both ): proportion cp_both

capture log close