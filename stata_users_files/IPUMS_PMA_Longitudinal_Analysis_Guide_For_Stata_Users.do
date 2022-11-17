* ==============================================================================
* ==============================================================================
* ==============================================================================
*
* Stata syntax to adapt the IPUMS PMA blog posts from March 1 to May 15, 2022
* to feature Stata examples.
*
* Those blog posts may be found here:
* (https://tech.popdata.org/pma-data-hub/posts/2022-03-01-phase2-discovery/)
* (https://tech.popdata.org/pma-data-hub/posts/2022-03-15-phase2-formats/)
* (https://tech.popdata.org/pma-data-hub/posts/2022-04-01-phase2-members/)
* (https://tech.popdata.org/pma-data-hub/posts/2022-04-15-phase2-indicators/)
* (https://tech.popdata.org/pma-data-hub/posts/2022-05-01-phase2-alluvial/)
* (https://tech.popdata.org/pma-data-hub/posts/2022-05-15-phase2-calendar/)
*
*
* The Stata syntax to match the R results was developed by Mia Yu and
* Dale Rhoda and Caitlin Clary at Biostat Global Consulting. 
* (www.biostatglobal.com)
*
* Contact us with questions about the Stata syntax:
* Dale.Rhoda@biostatglobal.com, Mia.Yu@biostatglobal.com
*
* This code is featured in a PDF guide entitled
* IPUMS PMA Longitudinal Analysis Guide For Stata Users
* 
* Available at:
* https://github.com/IPUMS-Global-Health/IPUMS-PMA-Longitudinal-Guide/blob/main/stata_users.pdf
*
* ==============================================================================
*
* CD to the working diretory that holds the relevant datasets, and
* the .do-files that are sometimes "included" in this program as well 
* as the program named sankey_plot_with_legend.ado.
*

cd "Q:/BMGF - PMA IPUMS FP Blog Posts/PMA 2022 longitudinal guide - Stata files"

* ==============================================================================
*
* Revision history
*
* Date          Person           Change
* ----------    --------------  ------------------------------------------------
* 2022-11-14    Dale Rhoda      Assembled chapter files into a single .do-file
*                               and developed two .do files to be included
*                               for oft-repeated code snippets 
* 2022-11-15	  Dale Rhoda		  Changed dataset filenames to 01-07 and updated
*                               the code for Chapter 3 to match Matt's layout.
*
* ==============================================================================
*
* Install user-written programs
*
* This program uses several user-written commands (.ado files).
*
* To install them, run the following four commands once on your Stata computer:
*
* ssc install heatplot,  replace
* ssc install palettes,  replace
* ssc install colrspace, replace
* net install grc1leg2.pkg
*


* Open a log file

capture log close
set linesize 80
log using IPUMS_PMA_Longitudinal_Analysis_log.txt, text replace

* ==============================================================================
* ==============================================================================
* ==============================================================================
*
**# Chapter 1 - Introduction
*
* ==============================================================================
* ==============================================================================
* ==============================================================================
*
* The code for Chapter 1 requires two datasets to be present in the current
* working directory: pma_00001 and pma_00002.  
*
* ==============================================================================
*

use pma_00001, clear

keep if sample_1 == 85409

* In version 17, Stata updated the table command.  If the user is running
* version 17 or after, use the table command; otherwise use the older tab
* command.

if `c(userversion)' >= 17 table ( resident_1 ) () (), nototals missing zerocounts
else tab resident_1, missing

if `c(userversion)' >= 17 table ( resident_2 ) () (), nototals missing zerocounts
else tab resident_2, missing

************************************************************

keep if inlist(resident_1,11,22) & inlist(resident_2,11,22)
label variable resident_1 "Resident type - Phase 1"
label variable resident_2 "Resident type - Phase 2"
label define RESIDENT_1 11 "Visitor" 22 "Usual", modify
label define RESIDENT_2 11 "Visitor" 22 "Usual", modify

if `c(userversion)' >= 17 table ( resident_1 ) ( resident_2 ) (), nototals missing zerocounts
else tab resident_1 resident_2, missing

************************************************************

use pma_00001, clear
keep if sample_1 == 85409
tab resultfq_2, m

************************************************************

use pma_00001, clear
keep if sample_1 == 85409
keep if resultfq_2 == 1
tab resultfq_1 resultfq_2,m

************************************************************

use pma_00001, clear
keep if sample_1 == 85409
keep if inlist(resident_1,11,22) & inlist(resident_2,11,22) & resultfq_2 == 1

if `c(userversion)' >= 17 table ( cp_1 ) ( cp_2 ) (), nototals missing zerocounts
else tab cp_1 cp_2, missing

************************************************************

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

************************************************************

* Calculate the design effect for the most recent estimation
estat effects
************************************************************

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

************************************************************

* Now examine the complex data 95% CI width divided by the 
* simple random sample of 5,207 95% CI width and see that it is ~= DEFT

di (.213738 - .1634491) / (.1986672 - .1774417)

************************************************************

use pma_00002, clear

keep if inlist(resident_1,11,22) & inlist(resident_2,11,22) & resultfq_2 == 1 & ///
  cp_1 < 90 & cp_2 < 90

if `c(userversion)' >= 17 table ( strata_1 ) if country == 2, nototals missing zerocounts
else tab strata_1 if country == 2, missing

tab geocd, nolabel

************************************************************

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

* Note: We have saved thes last five commands in a code snippet .do file, so
* in the remainder of this .do-file when we need to make the strata_recode
* variable, we will simply use the code: include gen_strata_recode.do

* Note that the new variable is not missing for any women
* of interest from Phase 1 and Phase 2
tab strata_recode, m

************************************************************

* Generate cp_both again for this wide dataset
gen cp_both = cp_1 == 1 & cp_2 == 1 if cp_1 < 90

label variable cp_both "Contraceptive user (Phases 1 & 2)"
label define cp_both 1 "Yes" 0 "No", replace
label values cp_both cp_both

svyset eaid_1, strata(strata_recode) weight(panelweight) 

* For Stata to estimate the proportion for each population, 
* we will use the over(varname) option where varname needs to
* be an integer variable - preferably with a value label. 

* So construct a new variable named pop and give it a 
* unique value for each PMA population.

* Construct a new variable named pop_numeric and give it a 
* unique value for each PMA population.

gen pop = .
replace pop = 1 if country == 1 // Burkina Faso
replace pop = 2 if country == 2 & geocd == 1 // Kinshasa
replace pop = 3 if country == 2 & geocd == 2 // Kongo Central
replace pop = 4 if country == 7 // Kenya
replace pop = 5 if country == 9 & geong == 4 // Kano
replace pop = 6 if country == 9 & geong == 2 // Lagos

label variable pop "Population"

label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace

label values pop pop

* NOTE: We re-generate this pop variable several times in this .do-file, so 
* have saved the pop-related commands above in a code snippet named
* gen_pop.do.  This program runs it below by saying: include gen_pop.do
*
* Note: We also apply this variable label several times so have also saved
* a code snippet named label_pop_values.do

************************************************************
* Estimate the proportions across responses and populations

svy : proportion cp_both , over(pop) 


        ************************************************************
        ************************************************************
        ************************************************************
        ************************************************************
        ************************************************************

        * This block of code is not in the chapter, but it explores the % of 
        * contraceptive users in phase 1 and phase 2 and then in phases 1 and 2.

        use pma_00001, clear

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

        if `c(userversion)' >= 17 table ( cp_1 ) ( cp_2 ) () ///
          if of_interest_both, nototals missing zerocounts
        else tab cp_1 cp_2 if of_interest_both, missing

        svyset eaid_1, strata(strata_1) weight(fqweight_1) 
        svy, subpop(of_interest_1 ):    proportion cp_1

        svyset eaid_2, strata(strata_2) weight(fqweight_2) 
        svy, subpop(of_interest_2 ):    proportion cp_2

        clonevar eaid_either = eaid_1
        replace eaid_either = eaid_2 if missing(eaid_either)

        svyset eaid_either, strata(strata_1) weight(panelweight) 
        svy, subpop(of_interest_both ): proportion cp_both
        
* ==============================================================================
* ==============================================================================
* ==============================================================================
*
**# Chapter #2 - Longitudinal Data Extracts
*
* ==============================================================================
* ==============================================================================
* ==============================================================================
* 
* The code for Chapter 2 requires two datasets to be present in the 
* working directory: pma_00003 and pma_00004.  
*
* ==============================================================================

* Import the long format data
use pma_00003, clear

************************************************************

* a simple example to show what long data looks like 
* (var: FQINSTID, PHASE, AGE, PANELWOMAN)
sort fqinstid
list fqinstid phase age panelwoman if strmatch(fqinstid, "011*") | ///
     strmatch(fqinstid, "015*"), separator(8) noobs

************************************************************

* tab to show the data include non-panel women 
* (var: PHASE, PANELWOMAN, FQINSTID == "")
gen non_panel = fqinstid == ""
label define fqinstid_blank 0 "fqinstid is not blank" 1 "fqinstid is blank", replace
label values non_panel fqinstid_blank

if `c(userversion)' >= 17 table (phase panelwoman) (non_panel), nototals missing
else bysort phase panelwoman: tab non_panel,  missing

************************************************************

* Filter the data to keep data for women with data in both phases 

gen keep = 1 if phase == 1
replace keep = 1 if phase == 2 & resultfq == 1
bysort fqinstid : egen keep_both = sum(keep)
keep if keep_both == 2
drop keep keep_both

************************************************************

* Filter the data to keep data for de facto women with data in both phases 

gen keep = 1 if phase == 1 & (resident == 11 | resident == 22)
replace keep = 2 if phase == 2 & (resident == 11 | resident == 22)
bysort fqinstid : egen keep_both = sum(keep)
keep if keep_both == 3
drop keep keep_both

************************************************************

* Include the code snippet that makes the pop variable
include gen_pop.do
           
if `c(userversion)' >= 17 table ( pop ) ( phase) ( ), nototals missing
else tab pop phase, missing

************************************************************

* Import the wide format data
use pma_00004, clear
* show the data for the same FQINSTID to show the difference 
* between long and wide data
list fqinstid age_1 age_2 panelwoman_1 panelwoman_2 ///
     if strmatch(fqinstid, "011*") | ///
        strmatch(fqinstid, "015*"), separator(8) noobs

************************************************************

* Demonstrate why wide is not exactly half of long 
* (use the orignal long data not the filtered one)

list resultfq_1 age_1 resultfq_2 age_2 ///
     if fqinstid == "0C8VQU6B03BXLAVVZ8SB90EKQ", noobs

************************************************************

use pma_00003, clear
list phase age resultfq ///
     if fqinstid == "0C8VQU6B03BXLAVVZ8SB90EKQ", noobs

************************************************************

* import wide data again
use pma_00004, clear

*filter the wide data to drop who didn't get interviewed in 
* phase 1 or didn't complete phase 2
keep if resultfq_2 == 1 & resultfq_1 != .

*filter the wide data to keep de facto only
keep if resident_1 == 11 | resident_1 == 22
keep if resident_2 == 11 | resident_2 == 22

* Include the code snippet that makes the pop variable
include gen_pop.do
           
if `c(userversion)' >= 17 table ( pop ) ( ), nototals missing
else tab pop, missing

************************************************************

use pma_00004, clear
keep if resultfq_2 == 1 & resultfq_1 != .

keep if inlist(resident_1, 11, 22)
keep if inlist(resident_2, 11, 22)

keep fqinstid age_1 pregnant_1 age_2 pregnant_2

reshape long age_ pregnant_ , i(fqinstid) j(phase)
rename age_ age
rename pregnant_ pregnant

* ==============================================================================
* ==============================================================================
* ==============================================================================
*
**# Chapter #3 - Panel Membership
*
* ==============================================================================
* ==============================================================================
* ==============================================================================

* The code for Chapter 3 requires two datasets to be present in the working 
* directory: pma_00005.  
*
* ==============================================================================

use pma_00005, clear

* Include the code snippet that makes the pop variable
include gen_pop.do

if `c(userversion)' >= 17 {  // user is running Stata v17 or higher
	
    * Overview of pop
    table ( pop ) ( ) ( ), nototals missing
	
	* Phase 1 HH q'aire
    table ( resulthq_1 ) () (), nototals missing

	************************************************************
	* What portion of HH completed all or part of the Phase 1 HH q'aire
	preserve
	use pma_00005, clear
	drop if missing(hhid_1) // focus on Phase 1
	bysort hhid_1: keep if _n == 1 // keep one row per household
	gen completed = inlist(resulthq_1,1,5) // all or part of Phase I HH q
	tab completed
	restore
	************************************************************
	
	* Exclude non-interviewed HHs
	table (pop) if inlist(resulthq_1,1,5), nototals missing
	
	* HH q'aire results by eligibility status
	table ( resulthq_1 eligible_1) () (), nototals missing
	
	* Result of the Female q'aire
	table (resultfq_1), nototals missing
	
	* Proportion of eligible women who completed the Phase 1 Female q'aire
	gen completed_fq1 = inlist(resultfq_1,1,5)
	tab completed_fq1 if eligible_1 == 1
	
	* Eligible to participate in the panel study at Phase 1
	table (pop) if completed_fq1 == 1, nototals missing
	
	* Women willing to participate in the panel study
	table ( pop ) if surveywilling_1 == 1, nototals missing
	
	* Note that some women had no response or a missing response
	tab surveywilling_1 if completed_fq1 == 1
	
	* Phase 2 HH q'aire
	table ( resulthq_2 ) () (), nototals missing
	
	* Phase 2 lived in same dwelling as in Phase 1
	table ( samedwelling_2 ) () (), nototals missing
	
	* By HH type at Phase 2
	table ( samedwelling_2 hhtype_2) () (), nototals missing
	
	* Was Phase 1 HH member listed on the HH roster for Phase 2
	table ( hhmemstat_2 ) () (), nototals missing
	
	* Panel 1 women living in this dwelling at Phase 2
	table ( hhpanelp2_2 ) () (), nototals missing
	
	* Phase 2 Female q'aire
	table ( resultfq_2 ) () (), nototals missing
	
	* Proportion of women who compleded Phase 2 Female q'aire
	* who were *also* available at Phase 1
	tab panelwoman_2 if resultfq_2 == 1
	
    * Check the proportion of potential panel members from Phase 1
	* who completed the Phase 2 Female q'aire
	gen check = resultfq_2 == 1 if ///
	surveywilling_1 == 1 & age_1< 49 & !missing(resultfq_2)
	tab check if surveywilling_1 == 1 & age_1< 49, missing

	* Total number of potential panel members per Phase 1 sample
	* that ultimately completed a Phase 2 Female q'aire
	keep if surveywilling_1 == 1 & age_1 < 49
	table ( pop ) if resultfq_2 == 1, nototals missing	
}

else {  // users running an older version of Stata 

    * Overview of pop
    tab pop, missing
	
	* Phase 1 HH q'aire
    tab resulthq_1, missing

	************************************************************
	* What portion of HH completed all or part of the Phase 1 HH q'aire
	preserve
	use pma_00005, clear
	drop if missing(hhid_1) // focus on Phase 1
	bysort hhid_1: keep if _n == 1 // keep one row per household
	gen completed = inlist(resulthq_1,1,5) // all or part of Phase I HH q
	tab completed
	restore
	************************************************************
	
	* Exclude non-interviewed HHs
	tab pop if inlist(resulthq_1,1,5), missing
	
	* HH q'aire results by eligibility status
	bysort eligible_1: tab resulthq_1, missing
	
	* Result of the Female q'aire
	tab resultfq_1, missing
	
	* Proportion of eligible women who completed the Phase 1 Female q'aire
	gen completed_fq1 = inlist(resultfq_1,1,5)
	tab completed_fq1 if eligible_1 == 1
	
	* Eligible to participate in the panel study at Phase 1
	tab pop if completed_fq1 == 1,missing
	
	* Women willing to participate in the panel study
	tab pop if surveywilling_1 == 1, missing
	
	* Note that some women had no response or a missing response
	tab surveywilling_1 if completed_fq1 == 1
	
	* Phase 2 HH q'aire
	tab resulthq_2, missing
	
	* Phase 2 lived in same dwelling as in Phase 1
	tab samedwelling_2, missing
	
	* By HH type at Phase 2
	bysort hhtype_2: tab samedwelling_2, missing
	
	* Was Phase 1 HH member listed on the HH roster for Phase 2
	tab hhmemstat_2, missing
	
	* Panel 1 women living in this dwelling at Phase 2
	tab hhpanelp2_2, missing
	
	* Phase 2 Female q'aire
	tab resultfq_2, missing
	
	* Proportion of women who compleded Phase 2 Female q'aire
	* who were *also* available at Phase 1
	tab panelwoman_2 if resultfq_2 == 1
	
    * Check the proportion of potential panel members from Phase 1
	* who completed the Phase 2 Female q'aire
	gen check = resultfq_2 == 1 if ///
	surveywilling_1 == 1 & age_1< 49 & !missing(resultfq_2)
	tab check if surveywilling_1 == 1 & age_1< 49, missing

	* Total number of potential panel members per Phase 1 sample
	* that ultimately completed a Phase 2 Female q'aire
	keep if surveywilling_1 == 1 & age_1 < 49
	tab pop if resultfq_2 == 1, missing		
}

* ==============================================================================
* ==============================================================================
* ==============================================================================
*
**# Chapter #4 - Family Planning Indicators
*
* ==============================================================================
* ==============================================================================
* ==============================================================================

* The code for Chapter 4 requires two datasets to be present in the working 
* directory: pma_00006.  

* ==============================================================================

use pma_00006, clear

* keep de facto in both phases data only
keep if inlist(resident_1,11,22) & inlist(resident_2,11,22)

*keep only who complete phase 2
keep if resultfq_2 == 1

*only keep those who respond to the question about contraceptives
keep if cp_1 < 90 & cp_2 <90

************************************************************

* Include the code snippet that makes the strata_recode variable
include gen_strata_recode.do

* Include the code snippet that makes the pop variable
include gen_pop.do
           
if `c(userversion)' >= 17 table ( pop ) ( ) ( ), nototals missing           
else tab pop, missing

************************************************************

svyset eaid_1, strata(strata_recode) weight(panelweight) 

label variable cp_1    "Contraceptive user (Phase 1)"
label variable cp_2    "Contraceptive user (Phase 2)"

// Phase 2 status among women not using contraceptives in Phase 1
svy: proportion cp_2 if cp_1 == 0 , over(pop) 

// Phase 2 status among women using contraceptives in Phase 1
svy: proportion cp_2 if cp_1 == 1 , over(pop)

svy: proportion cp_2, over(pop cp_1)

svy, subpop(if pop == 1): proportion cp_2 if cp_1 == 0
svy, subpop(if pop == 1): proportion cp_2 if cp_1 == 1

di "Study Population: Burkina Faso"
svy, subpop(if pop == 1): tab cp_1 cp_2 , row ci nomarginals pearson null

forvalues i = 1/6 {
    di "Study Population: `: label pop `i''"
    svy, subpop(if pop == `i'): tab cp_1 cp_2 , row ci nomarginals pearson null
}

************************************************************

* Not included in chapter because it will not include confidence intervals

graph hbar (percent) [aweight=panelweight], ///
    by(pop cp_1, cols(2) note("Bars in each subplot of the figure sum to 100%." ///
      "Graphs by country and Phase 1 contraceptive use status.", ///
      size(vsmall)) ///
        title(Phase 2 Contraceptive Use Status, size(medium)) ) ///
    over(cp_2) ///
    ytitle(Percent, size(small)) ///
    name(f4_00, replace)
    
graph export f4_00.png, width(2000) replace

save post4_prepped, replace

clear 
use post4_prepped, clear

************************************************************

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot cp_1 cp_2 pop estimate lcb ucb using `postout', replace

forvalues i = 0/1 {
    forvalues j = 1/6 {
        quietly svy, subpop(if cp_1 == `i' & pop == `j') : proportion cp_2 
        * We extract the estimates from column 2 of r(table) because we are 
        * summarizing the proportion who were using contraception in phase 2,
        * which means we want to know the proportion of 1's or yes responses.
        post toplot (`i') (1) (`j') ///
                    (`=100*r(table)[1,2]') /// // the estimate
                    (`=100*r(table)[5,2]') /// // the LCB
                    (`=100*r(table)[6,2]')     // the UCB
    }
}
capture postclose toplot
use `postout', clear

label define yesno 0 "No" 1 "Yes", replace

include label_pop_values.do

label values cp_1 yesno
label values cp_2 yesno
label variable cp_1 "Contraceptive user (Phase 1)"
label variable cp_2 "Contraceptive user (Phase 2)"

* Basic graph 
twoway (bar estimate cp_1, horizontal  ///
        ylabel(0(1)1, valuelabel ) ///
        xlabel(0(20)100)) ///
        (rcap lcb ucb cp_1 , horizontal ) ///
        ,  by(pop, legend(off) ) ///
           xtitle(Contraceptive user (Phase 2) (%)) ///
           name(f4_01, replace)
graph export f4_01.png, width(2000) replace

* Additional aesthetic options           
twoway (bar estimate cp_1 if cp_2 == 1 , ///
           color(blue*.5) horizontal barwidth(0.9) ///
           ylabel(0(1)1,valuelabel angle(0) nogrid) ///
           xlabel(0(20)100)) ///
        (rcap lcb ucb cp_1 if cp_2 == 1, horizontal lcolor(black)) ///
        ,  by(pop, graphregion(color(white)) legend(off) note("")) ///
           subtitle(,lcolor(white) fcolor(white)) ///
           xtitle(Contraceptive user (Phase 2) (%)) ///
           xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
           name(f4_02, replace)
           
graph export f4_02.png, width(2000) replace
           
************************************************************

        * The code in this block is not in the book chapter, but presents another
        * way of capturing the values of estimate, lcb, and ucb with a single
        * estimation command, but then several blocks of data management afterward.
        *
        * I find the method of the loop with the post commands to be easiest to
        * remember, but the two methods result in the same dataset.
                   
        use post4_prepped, clear

        * Generate all the estimates and lcbs and ucbs at once
        svy: proportion cp_2, over(pop cp_1)

        * Steps to pull them into memory and prepare to plot
        matrix out = r(table)
        clear
        svmat out
        xpose, clear
        keep v1 v5 v6
        rename v1 estimate
        rename v5 lcb
        rename v6 ucb
        replace estimate = estimate * 100
        replace lcb = lcb * 100
        replace ucb = ucb * 100

        * Add cp_1 and cp_2 and pop values back into the dataset
        gen cp_1 = 0
        replace cp_1 = 1 if mod(_n,2) == 0

        gen cp_2 = 0
        replace cp_2 = 1 in 13/24

        gen pop = .
        local row 1
        forvalues i = 1/2 {
            forvalues j = 1/6 {
                forvalues k = 1/2 {    
                    replace pop = `j' in `row'
                    local ++row
                }
            }
        }

        * Add value labels
        include label_pop_values.do

        label values cp_1 yesno
        label values cp_2 yesno

        label variable cp_1    "Contraceptive user (Phase 1)"
        label variable cp_2    "Contraceptive user (Phase 2)"

        * Plot with updated aesthetic options           
        twoway (bar estimate cp_1 if cp_2 == 1 , ///
                   color(blue*.5) horizontal barwidth(0.9) ///
                   ylabel(0(1)1,valuelabel angle(0) nogrid) ///
                   xlabel(0(20)100)) ///
                (rcap lcb ucb cp_1 if cp_2 == 1, horizontal lcolor(black)) ///
                ,  by(pop, graphregion(color(white)) legend(off) note("")) ///
                   subtitle(,lcolor(white) fcolor(white)) ///
                   xtitle(Contraceptive user (Phase 2) (%)) ///
                   xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
                   name(f4_03, replace)
                   
        graph export f4_03.png, width(2000) replace

************************************************************
use post4_prepped, clear

svy, subpop(if cp_1 == 1 & pop == 1): proportion cp_2  // top row for Burkina Faso
svy, subpop(if cp_1 == 1 & pop == 3): proportion cp_2  // top row for DRC-Kongo Central
* Check Rao-Scott
svy, subpop(if inlist(pop,1,3) & cp_1 == 1): tab cp_2 pop , null pearson col

************************************************************

* Generate new vars to show the status of female in both phases
gen fpstatus_1 = 1 if pregnant_1 == 1
replace fpstatus_1 = 3 if pregnant_1 != 1 & cp_1 == 1
replace fpstatus_1 = 2 if pregnant_1 != 1 & cp_1 == 0

gen fpstatus_2 = 1 if pregnant_2 == 1
replace fpstatus_2 = 3 if pregnant_2 != 1 & cp_2 == 1
replace fpstatus_2 = 2 if pregnant_2 != 1 & cp_2 == 0

label define status 1 "Pregnant" 3 "Using FP" 2 "Not Using FP"
label values fpstatus_1 status
label values fpstatus_2 status

label variable fpstatus_1 "Family planning status at Phase 1"
label variable fpstatus_2 "Family planning status at Phase 2"

************************************************************

list pregnant_1 cp_1 fpstatus_1 pregnant_2 cp_2 fpstatus_2 in 1/12, noobs sep(12)

************************************************************

save post4_prepped, replace

use post4_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot fpstatus_1 fpstatus_2 pop estimate lcb ucb using `postout', replace

forvalues i = 1/3 {
    forvalues k = 1/3 {
        forvalues j = 1/6 {
            capture drop y
            gen y = fpstatus_2 == `k'
            quietly svy, subpop(if fpstatus_1 == `i' & pop == `j'): proportion y 
            post toplot (`i') (`k') (`j') ///
                        (`=100*r(table)[1,2]') /// // the estimate
                        (`=100*r(table)[5,2]') /// // the LCB
                        (`=100*r(table)[6,2]')     // the UCB
        }
    }
}
capture postclose toplot
use `postout', clear

label define status 1 "Pregnant" 3 "Using FP" 2 "Not Using FP"
label values fpstatus_1 status
label values fpstatus_2 status
include label_pop_values.do

label variable fpstatus_1 "Family Planning Status (Phase 1)"
label variable fpstatus_2 "Family Planning Status (Phase 2)"
       
label define status2 1 "Pregnant in Phase 1" 3 "Using FP in Phase 1" ///
                     2 "Not Using FP in Phase 1", replace
label values fpstatus_1 status2

* Plot with updated aesthetic options           
twoway (bar estimate fpstatus_2 if fpstatus_2 == fpstatus_1, ///
           color(blue*.5) horizontal barwidth(0.9) ///
           ylabel(1(1)3,valuelabel angle(0) nogrid) ///
           xlabel(0(20)100)) ///
        (bar estimate fpstatus_2 if fpstatus_2 != fpstatus_1, ///
           color(orange*.5) horizontal barwidth(0.9)) ///
        (rcap lcb ucb fpstatus_2 , horizontal lcolor(black)) ///
        ,  by(pop fpstatus_1, graphregion(color(white)) ///
              note("Estimates within each subplot sum to 100%." ///
                   "Graphs by population and Phase 1 status.", size(vsmall)) ///
                   col(3) ) ///
           subtitle(,lcolor(white) fcolor(white)) ///
           ytitle(Family Planning Status (Phase 2)) ///
           xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
           legend(order(1 "No change" 2 "Status changed") size(vsmall) ///
                  region(lcolor(white)) symxsize(small) symysize(small)) ///
           xtitle("Percent") ///
           name(f4_04, replace)           
graph export f4_04.png, width(2000) replace

************************************************************
use post4_prepped, clear

* Table of methods
if `c(userversion)' >= 17 table ( fpcurreffmethrc_1 ) ( ) ( ), nototals missing
else tab fpcurreffmethrc_1, missing

* Generate new variables to recode the methods to 3 categories 
label define fpmethod 4 "Long-acting" 3 "Short-acting" 2 "Traditional" 1 "None", replace

foreach v in fpcurreffmethrc_1 fpcurreffmethrc_2 {
    gen cat_`v' = 4 if `v' < 120
    replace cat_`v' = 3 if `v' >= 120 & `v' < 200
    replace cat_`v' = 2 if `v' >= 200 & `v' < 900
    replace cat_`v' = 1 if cat_`v' == .
    
    label values cat_`v' fpmethod
}

save post4_prepped, replace

************************************************************

use post4_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot methcat_1 methcat_2 pop estimate lcb ucb using `postout', replace

forvalues i = 1/4 {
    forvalues k = 1/4 {
        forvalues j = 1/6 {
            capture drop y
            gen y = cat_fpcurreffmethrc_2 == `k'
            quietly svy, subpop(if cat_fpcurreffmethrc_1 == `i' & pop == `j'): proportion y 
            post toplot (`i') (`k') (`j') ///
                            (`=100*r(table)[1,2]') /// // the estimate
                            (`=100*r(table)[5,2]') /// // the LCB
                            (`=100*r(table)[6,2]')     // the UCB
        }
    }
}
capture postclose toplot
use `postout', clear

label define fpmethod 4 "Long-acting" 3 "Short-acting" 2 "Traditional" 1 "None", replace
label values methcat_1 fpmethod
label values methcat_2 fpmethod
include label_pop_values.do

label variable methcat_1 "Family Planning Method (Phase 1)"
label variable methcat_2 "Family Planning Method (Phase 2)"
       
* Plot with updated aesthetic options           
twoway (bar estimate methcat_2 if methcat_1 == methcat_2, ///
           color(blue*.5) horizontal barwidth(0.9) ///
           ylabel(1(1)4,valuelabel angle(0) nogrid labsize(small)) ///
           xlabel(0(20)100)) ///
        (bar estimate methcat_2 if methcat_1 != methcat_2, ///
           color(orange*.5) horizontal barwidth(0.9)) ///
        (rcap lcb ucb methcat_2 , horizontal lcolor(black)) ///
        ,  by(pop (methcat_1), graphregion(color(white)) ///
              note("Estimates within each subplot sum to 100%." ///
                   "Graphs by population and Phase 1 method.", size(vsmall)) ///
                   col(4) ) ///
           subtitle(,size(small) lcolor(white) fcolor(white)) ///
           ytitle(Family Planning Method (Phase 2), size(small)) ///
           xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
           legend(order(1 "No change" 2 "Method changed") size(vsmall) ///
                  region(lcolor(white)) symxsize(small) symysize(small)) ///
           xtitle("Percent") ///
           name(f4_05, replace)        
           
graph export f4_05.png, width(2000) replace

************************************************************

use post4_prepped, clear

*gen CHG_FPCURR - Change in contraceptive use between Phase 1 and Phase 2

************************************************************

gen chg_fpcurr = .
replace chg_fpcurr = 1 if fpcurreffmethrc_1 < 900 & fpcurreffmethrc_2 < 900 & ///
    fpcurreffmethrc_1 != fpcurreffmethrc_2
replace chg_fpcurr = 2 if fpcurreffmethrc_1 < 900 & fpcurreffmethrc_2 < 900 & ///
    fpcurreffmethrc_1 == fpcurreffmethrc_2
replace chg_fpcurr = 3 if fpcurreffmethrc_1 > 900 & fpcurreffmethrc_2 > 900
replace chg_fpcurr = 4 if fpcurreffmethrc_1 > 900 & fpcurreffmethrc_2 < 900
replace chg_fpcurr = 5 if fpcurreffmethrc_1 < 900 & fpcurreffmethrc_2 > 900

label define chg_fpcurr 1 "Changed methods" 2 "Continued method" ///
                        3 "Continued non-use" 4 "Started using" ///
                        5 "Stopped using", replace
label values chg_fpcurr chg_fpcurr
label var chg_fpcurr "Phase 1 to 2 Family Planning Change Status"

* Generate age categories
gen cat_age_2 = .
replace cat_age_2 = 1 if age_2 < 20
replace cat_age_2 = 2 if age_2 >= 20 & age_2 < 25
replace cat_age_2 = 3 if age_2 >= 25 

label define cat_age_2 1 "15-19" 2 "20-24" 3 "25-49", replace
label values cat_age_2 cat_age_2
label var cat_age_2 "Age category at Phase 2"

save post4_prepped, replace

************************************************************

use post4_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot cat_age_2 chg_fpcurr pop estimate lcb ucb using `postout', replace

forvalues i = 1/3 {
    forvalues k = 1/5 {
        forvalues j = 1/6 {
            capture drop y
            gen y = chg_fpcurr == `k'
            quietly svy, subpop(if cat_age_2 == `i' & pop == `j'): proportion y 
            post toplot (`i') (`k') (`j') ///
                        (`=100*r(table)[1,2]') /// // the estimate
                        (`=100*r(table)[5,2]') /// // the LCB
                        (`=100*r(table)[6,2]')     // the UCB
        }
    }
}
capture postclose toplot
use `postout', clear

label define cat_age_2 1 "15-19" 2 "20-24" 3 "25-49", replace
label define chg_fpcurr 1 "Changed methods" 2 "Continued method" ///
                        3 "Continued non-use" 4 "Started using" ///
                        5 "Stopped using", replace

label values cat_age_2 cat_age_2
label values chg_fpcurr chg_fpcurr

include label_pop_values.do

label var chg_fpcurr  "Phase 1 to 2 Family Planning Change Status"
       
twoway (bar estimate cat_age_2 , ///
           color(blue*.5) horizontal barwidth(0.9) ///
           ylabel(1(1)3,valuelabel angle(0) nogrid labsize(small)) ///
           xlabel(0(20)100)) ///
        (rcap lcb ucb cat_age_2 , horizontal lcolor(black)) ///
        ,  by(pop chg_fpcurr, graphregion(color(white)) ///
              note("Estimates across each row of the figure sum to 100%.", ///
                size(vsmall)) col(5) legend(off) ) ///
           subtitle(,size(small) lcolor(white) fcolor(white)) ///
           xtitle("Changes in Family Planning Status, Phase 1 to Phase 2", ///
              size(small)) ///
           xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
           ytitle("") ///
           name(f4_06, replace)
           
graph export f4_06.png, width(2000) replace

************************************************************


************************************************************

use post4_prepped, clear

gen cat_educattgen_2 = .
replace cat_educattgen_2 = 1 if educattgen_2 < 3
replace cat_educattgen_2 = 2 if educattgen_2 == 3
replace cat_educattgen_2 = 3 if educattgen_2 == 4

label define cat_educattgen_2 1 "None/Primary" 2 "Secondary" 3 "Tertiary", replace
label values cat_educattgen_2 cat_educattgen_2
label var cat_educattgen_2 "Education Category at Phase 2"

save post4_prepped, replace

************************************************************

************************************************************

use post4_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot cat_educattgen_2 chg_fpcurr pop estimate lcb ucb ///
  using `postout', replace

forvalues i = 1/3 {
    forvalues k = 1/5 {
        forvalues j = 1/6 {
            capture drop y
            gen y = chg_fpcurr == `k'
            quietly svy, subpop(if cat_educattgen_2 == `i' & pop == `j'): proportion y 
            post toplot (`i') (`k') (`j') ///
                        (`=100*r(table)[1,2]') /// // the estimate
                        (`=100*r(table)[5,2]') /// // the LCB
                        (`=100*r(table)[6,2]')     // the UCB
        }
    }
}
capture postclose toplot
use `postout', clear

label define cat_educattgen_2 1 "None/Primary" 2 "Secondary" 3 "Tertiary", replace
label define chg_fpcurr 1 "Changed methods" 2 "Continued method" ///
                        3 "Continued non-use" 4 "Started using" ///
                        5 "Stopped using", replace

label values cat_educattgen_2 cat_educattgen_2
label values chg_fpcurr chg_fpcurr

include label_pop_values.do

label var chg_fpcurr "Phase 1 to 2 Family Planning Change Status"
       
* Plot with updated aesthetic options           
twoway (bar estimate cat_educattgen_2 , ///
           color(blue*.5) horizontal barwidth(0.9) ///
           ylabel(1(1)3,valuelabel angle(0) nogrid labsize(small)) ///
           xlabel(0(20)100)) ///
        (rcap lcb ucb cat_educattgen_2 , horizontal lcolor(black)) ///
        ,  by(pop chg_fpcurr, graphregion(color(white)) ///
              note("Estimates across each row of the figure sum to 100%.", ///
                size(vsmall)) col(5) legend(off) ) ///
           subtitle(,size(small) lcolor(white) fcolor(white)) ///
           xtitle("Changes in Family Planning Status, Phase 1 to Phase 2", ///
             size(small)) ///
           xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
           ytitle("") ///
           name(f4_07, replace)
           
graph export f4_07.png, width(2000) replace


************************************************************

use post4_prepped, clear

capture drop y
gen y = chg_fpcurr == 3

svy, subpop(if inlist(cat_educattgen_2,2,3) & pop == 6): ///
     tab cat_educattgen_2 y if cat_educattgen_2 > 1 , row pearson null ci

************************************************************

use post4_prepped, clear

gen cat_marstat_2 = .
replace cat_marstat_2 = 1 if marstat_2 == 21 | marstat_2 == 22
replace cat_marstat_2 = 2 if cat_marstat_2 != 1

label define cat_marstat_2 1 "In union" 2 "Not in union", replace
label values cat_marstat_2 cat_marstat_2
label variable cat_marstat_2 "Marital status at Phase 2"

save, replace

************************************************************

use post4_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot cat_marstat_2 chg_fpcurr pop estimate lcb ucb ///
         using `postout', replace

forvalues i = 1/2 {
    forvalues k = 1/5 {
        forvalues j = 1/6 {
            capture drop y
            gen y = chg_fpcurr == `k'
            quietly svy, subpop(if cat_marstat_2 == `i' & pop == `j'): proportion y 
            post toplot (`i') (`k') (`j') ///
                        (`=100*r(table)[1,2]') /// // the estimate
                        (`=100*r(table)[5,2]') /// // the LCB
                        (`=100*r(table)[6,2]')     // the UCB
        }
    }
}
capture postclose toplot
use `postout', clear

label define cat_marstat_2 1 "In union" 2 "Not in union", replace
label define chg_fpcurr 1 "Changed methods" 2 "Continued method" ///
                        3 "Continued non-use" 4 "Started using" ///
                        5 "Stopped using", replace

label values cat_marstat_2 cat_marstat_2
label values chg_fpcurr chg_fpcurr

include label_pop_values.do

label var chg_fpcurr "Phase 1 to 2 Family Planning Change Status"
       
* Plot with updated aesthetic options           
twoway (bar estimate cat_marstat_2 , ///
           color(blue*.5) horizontal barwidth(0.9) ///
           ylabel(1(1)2,valuelabel angle(0) nogrid labsize(small)) ///
           xlabel(0(20)100)) ///
        (rcap lcb ucb cat_marstat_2 , horizontal lcolor(black)) ///
        ,  by(pop chg_fpcurr, graphregion(color(white)) ///
              note("Estimates across each row of the figure sum to 100%.", ///
                size(vsmall)) col(5) legend(off) ) ///
           subtitle(,size(small) lcolor(white) fcolor(white)) ///
           xtitle("Changes in Family Planning Status, Phase 1 to Phase 2", ///
             size(small)) ///
           xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
           ytitle("") ///
           name(f4_08, replace)
           
graph export f4_08.png, width(2000) replace

************************************************************

use post4_prepped, clear

gen cat_birthevent_2 = .
replace cat_birthevent_2 = 1 if inlist(birthevent_2,0,99)
replace cat_birthevent_2 = 2 if inlist(birthevent_2,1,2)
replace cat_birthevent_2 = 3 if inlist(birthevent_2,3,4)
replace cat_birthevent_2 = 4 if birthevent_2 >= 5 & birthevent_2 < 90

label define cat_birthevent_2 1 "None" 2 "One-two" 3 "Three-four" 4 "Five +", replace
label values cat_birthevent_2 cat_birthevent_2

label var cat_birthevent_2 "Parity (number of live births) at Phase 2"

save, replace

************************************************************

use post4_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot cat_birthevent_2 chg_fpcurr pop estimate lcb ucb ///
  using `postout', replace

forvalues i = 1/4 {
    forvalues k = 1/5 {
        forvalues j = 1/6 {
            capture drop y
            gen y = chg_fpcurr == `k'
            quietly svy, subpop(if cat_birthevent_2 == `i' & pop == `j'): proportion y 
            post toplot (`i') (`k') (`j') ///
                        (`=100*r(table)[1,2]') /// // the estimate
                        (`=100*r(table)[5,2]') /// // the LCB
                        (`=100*r(table)[6,2]')     // the UCB
        }
    }
}
capture postclose toplot
use `postout', clear

label define cat_birthevent_2 1 "None" 2 "One-two" 3 "Three-four" 4 "Five +", replace
label define chg_fpcurr 1 "Changed methods" 2 "Continued method" ///
                        3 "Continued non-use" 4 "Started using" ///
                        5 "Stopped using", replace

label values cat_birthevent_2 cat_birthevent_2
label values chg_fpcurr chg_fpcurr

include label_pop_values.do

label var chg_fpcurr "Phase 1 to 2 Family Planning Change Status"
       
* Plot with updated aesthetic options           
twoway (bar estimate cat_birthevent_2 , ///
           color(blue*.5) horizontal barwidth(0.9) ///
           ylabel(1(1)4,valuelabel angle(0) nogrid labsize(small)) ///
           xlabel(0(20)100)) ///
        (rcap lcb ucb cat_birthevent_2 , horizontal lcolor(black)) ///
        ,  by(pop chg_fpcurr, graphregion(color(white)) ///
              note("Estimates across each row of the figure sum to 100%.", ///
                size(vsmall)) col(5) legend(off) ) ///
           subtitle(,size(small) lcolor(white) fcolor(white)) ///
           xtitle("Changes in Family Planning Status, Phase 1 to Phase 2", ///
             size(small)) ///
           xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
           ytitle("") ///
           name(f4_09, replace)
           
graph export f4_09.png, width(2000) replace

************************************************************

use post4_prepped, clear

* Women who didn't use any method at phase 1
keep if cp_1 == 0

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot unmetyn_1 pop estimate lcb ucb using `postout', replace

forvalues i = 0/1 {
    forvalues j = 1/6 {
        capture drop y
        gen y = cp_2 == 1
        quietly svy, subpop(if unmetyn_1 == `i' & pop == `j'): proportion y 
        post toplot (`i') (`j') ///
                    (`=100*r(table)[1,2]') /// // the estimate
                    (`=100*r(table)[5,2]') /// // the LCB
                    (`=100*r(table)[6,2]')     // the UCB
    }
}
capture postclose toplot
use `postout', clear

label define unmetyn_1 0 "No" 1 "Yes", replace
label values unmetyn_1 unmetyn_1

include label_pop_values.do

twoway (bar estimate unmetyn_1 , ///
           color(blue*.5) horizontal barwidth(0.9) ///
           ylabel(0(1)1,valuelabel angle(0) nogrid labsize(small)) ///
           xlabel(0(20)100)) ///
        (rcap lcb ucb unmetyn_1 , horizontal lcolor(black)) ///
        ,  by(pop , graphregion(color(white)) ///
              note("Among women who were not using family planning in Phase 1.", ///
                   size(vsmall)) col(1) legend(off) ) ///
           subtitle(,size(small) lcolor(white) fcolor(white)) ///
           xtitle("Had adopted a method of family planning in Phase 2", ///
             size(small)) ///
           xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
           ytitle("Had unmet need in Phase 1") ///
              ysize(10) xsize(8) ///
           name(f4_10, replace)
           
graph export f4_10.png, width(2000) replace

************************************************************

use post4_prepped, clear

* Women who didn't use any method at Phase 1
keep if cp_1 == 0 

* Outcome is women using contraception in Phase 2
gen y = cp_2 == 1
label variable y "Using contraception in Phase 2"
label variable unmetyn_1 "Unmet Need in Phase 1"

* Test for difference in Burkina Faso
svy, subpop(if pop == 1 ): tab unmetyn_1 y, row pearson null ci

* Test for difference in Nigeria-Kano
svy, subpop(if pop == 5 ): tab unmetyn_1 y, row pearson null ci

************************************************************

use post4_prepped, clear

keep if cp_1 == 0 & inlist(fppartsupport_1,0,1,97)
replace fppartsupport_1 = 2 if fppartsupport_1 == 97 

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot fppartsupport_1 pop estimate lcb ucb using `postout', replace

forvalues i = 0/2 {
    forvalues j = 1/6 {
        capture drop y
        gen y = cp_2 == 1
        quietly svy, subpop(if fppartsupport_1 == `i' & pop == `j'): proportion y 
        post toplot (`i') (`j') ///
                    (`=100*r(table)[1,2]') /// // the estimate
                    (`=100*r(table)[5,2]') /// // the LCB
                    (`=100*r(table)[6,2]')     // the UCB
    }
}
capture postclose toplot
use `postout', clear

label define fppartsupport_1 0 "No" 1 "Yes" 2 `"Do not know"', replace
label values fppartsupport_1 fppartsupport_1

include label_pop_values.do

twoway (bar estimate fppartsupport_1 , ///
           color(blue*.5) horizontal barwidth(0.9) ///
           ylabel(0(1)2,valuelabel angle(0) nogrid labsize(small)) ///
           xlabel(0(20)100)) ///
        (rcap lcb ucb fppartsupport_1 , horizontal lcolor(black)) ///
        ,  by(pop , graphregion(color(white)) ///
              note("Among women who were not using family planning in Phase 1.", ///
                   size(vsmall)) col(1) legend(off) ) ///
           subtitle(,size(small) lcolor(white) fcolor(white)) ///
           xtitle("Had adopted a method of family planning in Phase 2", size(small)) ///
           xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
           ytitle("Partner supportive of family planning in Phase 1") ///
           ysize(10) xsize(8) ///
           name(f4_11, replace)
           
graph export f4_11.png, width(2000) replace

************************************************************

use post4_prepped, clear

keep if cp_1 == 0

if `c(userversion)' >= 17 table (fpplanwhen_1) ( ) ( ), nototals missing
else tab fpplanwhen_1, missing

gen fpplanyr_1 =  (fpplanval_1  <= 12 & fpplanwhen_1 == 1) | ///
                  (fpplanval_1 == 1   & fpplanwhen_1 == 2) | ///
                  inlist(fpplanwhen_1,3,4)

label define fpplanyr_1 0 "No" 1 "Yes", replace
label values fpplanyr_1 fpplanyr_1

label var fpplanyr_1 "Plan to start using family planning within 1 year at Phase 1"

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot fpplanyr_1 pop estimate lcb ucb using `postout', replace

forvalues i = 0/1 {
    forvalues j = 1/6 {
        capture drop y
        gen y = cp_2 == 1
        quietly svy, subpop(if fpplanyr_1 == `i' & pop == `j'): proportion y 
        post toplot (`i') (`j') ///
                    (`=100*r(table)[1,2]') /// // the estimate
                    (`=100*r(table)[5,2]') /// // the LCB
                    (`=100*r(table)[6,2]')     // the UCB
    }
}
capture postclose toplot
use `postout', clear

label define fpplanyr_1 0 "No" 1 "Yes", replace
label values fpplanyr_1 fpplanyr_1

include label_pop_values.do

twoway (bar estimate fpplanyr_1 , ///
           color(blue*.5) horizontal barwidth(0.9) ///
           ylabel(0(1)1,valuelabel angle(0) nogrid labsize(small)) ///
           xlabel(0(20)100)) ///
        (rcap lcb ucb fpplanyr_1 , horizontal lcolor(black)) ///
        ,  by(pop , graphregion(color(white)) ///
              note("Among women who were not using family planning in Phase 1.", ///
                   size(vsmall)) col(1) legend(off) ) ///
           subtitle(,size(small) lcolor(white) fcolor(white)) ///
           xtitle("Had adopted a method of family planning in Phase 2", size(small)) ///
           xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
           ytitle("Respondent plans to adopt a FP method within a year at Phase 1") ///
           ysize(10) xsize(8) ///
           name(f4_12, replace) 
           
graph export f4_12.png, width(2000) replace

* Cleanup
capture erase post4_prepped.dta

* ==============================================================================
* ==============================================================================
* ==============================================================================
*
**# Chapter #5 - Advanced Data Visualization
*
* ==============================================================================
* ==============================================================================
* ==============================================================================
*
* The code for Chapter 5 requires two datasets to be present in the working 
* directory: pma_00006 and pma_sankey_template4.  
*
* ==============================================================================

use pma_00006, clear

* Filter data
keep if resultfq_2 == 1
keep if inlist(resident_1,11,22) & inlist(resident_2,11,22)
keep if cp_1 < 90 & cp_2 < 90

*****************************

* Include the code snippet that makes the pop variable
include gen_pop.do

******************************

* Include the code snippet that makes the strata_recode variable
include gen_strata_recode.do

******************************

* Generate new vars to show the status of female in both phases
gen fpstatus_1 = 1 if pregnant_1 == 1
replace fpstatus_1 = 3 if pregnant_1 != 1 & cp_1 == 1
replace fpstatus_1 = 2 if pregnant_1 != 1 & cp_1 == 0

gen fpstatus_2 = 1 if pregnant_2 == 1
replace fpstatus_2 = 3 if pregnant_2 != 1 & cp_2 == 1
replace fpstatus_2 = 2 if pregnant_2 != 1 & cp_2 == 0

label define status 1 "Pregnant" 3 "Using FP" 2 "Not Using FP", replace
label values fpstatus_1 status
label values fpstatus_2 status

label variable fpstatus_1 "Family planning status at Phase 1"
label variable fpstatus_2 "Family planning status at Phase 2"

svyset eaid_1, strata(strata_recode) weight(panelweight) 

save post5_prepped, replace

************************************************************

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot fpstatus_1 fpstatus_2 pop estimate lcb ucb using `postout', replace

forvalues i = 1/3 {
    forvalues k = 1/3 {
        forvalues j = 1/6 {
            capture drop y
            gen y = fpstatus_2 == `k'
            quietly svy, subpop(if fpstatus_1 == `i' & pop == `j'): proportion y 
            post toplot (`i') (`k') (`j') ///
                        (`=100*r(table)[1,2]') /// // the estimate
                        (`=100*r(table)[5,2]') /// // the LCB
                        (`=100*r(table)[6,2]')     // the UCB
        }
    }
}
capture postclose toplot
use `postout', clear

label define status 1 "Pregnant" 3 "Using FP" 2 "Not Using FP", replace
label values fpstatus_1 status
label values fpstatus_2 status
include label_pop_values.do

label variable fpstatus_1 "Family Planning Status (Phase 1)"
label variable fpstatus_2 "Family Planning Status (Phase 2)"
       
label define status2 1 "Pregnant in Phase 1" 3 "Using FP in Phase 1" ///
                     2 "Not Using FP in Phase 1", replace
label define status2 1 "Pregnant" 3 "Using FP" 2 "Not Using", replace
label values fpstatus_1 status2
label values fpstatus_2 status2

twoway (bar estimate fpstatus_2 if fpstatus_2 == fpstatus_1, ///
           color(blue*.5) horizontal barwidth(0.9) ///
           ylabel(1(1)3,valuelabel angle(0) nogrid) ///
           xlabel(0(20)100)) ///
        (bar estimate fpstatus_2 if fpstatus_2 != fpstatus_1, ///
           color(orange*.5) horizontal barwidth(0.9)) ///
        (rcap lcb ucb fpstatus_2 , horizontal lcolor(black)) ///
        ,  by(pop fpstatus_1, graphregion(color(white)) ///
              note("Estimates within each subplot sum to 100%." ///
                   "Graphs by population and Phase 1 status.", size(vsmall)) ///
                   col(3) ) ///
           subtitle(,lcolor(white) fcolor(white)) ///
           ytitle(Family Planning Status (Phase 2)) ///
           xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
           legend(order(1 "No change" 2 "Status changed") size(vsmall) ///
                  region(lcolor(white)) symxsize(small) symysize(small)) ///
           xtitle("Percent") ///
           name(f5_01, replace)    

graph export f5_01.png, width(2000) replace

**************************************

label define status2 1 "Pregnant" 3 "Using FP" 2 "Not Using", replace
decode fpstatus_1, gen(fpstring_1)
decode fpstatus_2, gen(fpstring_2)

heatplot estimate fpstring_2 fpstring_1 , ///
    by(pop, legend(off) graphregion(color(white)) ///
      note("Percentages in each column of each plot sum to 100%.", ///
        size(vsmall)) ///
      title("Change in Contraceptive Use or Non-use", size(medium)) ///
      subtitle("Percent women aged 15-49 who changed contraceptive use status", ///
      size(small))) ///
    values(format(%4.0f)) ///
    color(spmap greens, intensity(.80)) ///
    cuts(10 20 30 40 50 60 70 80 90) ///
    discrete ///
    xlabel(, labsize(small) angle(45)) ///
    ylabel(,labsize(small)) ///
    subtitle(,lcolor(white) fcolor(white) size(small)) ///
    xtitle("Phase 1 Status", size(small)) ///
    ytitle("Phase 2 Status", size(small)) ///
    name(f5_02, replace)
    
graph export f5_02.png, width(2000) replace

************************************************************
 
save post5_heatplot, replace
 
************************************************************
use post5_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot fpstatus_1 fpstatus_2 pop margin_1 margin_2 ///
  using `postout', replace

forvalues i = 1/3 {
    forvalues k = 1/3 {
        forvalues j = 1/6 {
            capture drop y
            gen y = fpstatus_1 == `i'
            quietly svy, subpop(if pop == `j'): proportion y 
            local postit (`i') (`k') (`j') (`=100*r(table)[1,2]') // estimate
            capture drop y
            gen y = fpstatus_2 == `k'
            quietly svy, subpop(if pop == `j'): proportion y 
            local postit `postit' (`=100*r(table)[1,2]') // the estimate
            post toplot `postit'
        }
    }
}
capture postclose toplot
use `postout', clear
merge 1:1 fpstatus_1 fpstatus_2 pop using post5_heatplot,

label define status 1 "Pregnant" 3 "Using FP" 2 "Not Using FP", replace
label values fpstatus_1 status
label values fpstatus_2 status

************************************************************
capture drop fpstring_1 
capture drop fpstring_2

decode  fpstatus_1, gen(fpstring_1)
decode  fpstatus_2, gen(fpstring_2)
replace fpstring_1 = fpstring_1 + " " + string(margin_1, "%4.0f") + "%"
replace fpstring_2 = fpstring_2 + " " + string(margin_2, "%4.0f") + "%"

* Make each of the six population sub-plots
forvalues i = 1/6 {

    heatplot estimate fpstring_2 fpstring_1 if pop == `i', ///
        legend(off) graphregion(color(white))  ///
        values(format(%4.0f)) ///
        color(spmap greens, intensity(.80)) ///
        discrete ///
        xlabel(,  labsize(small) angle(45)) ///
        ylabel(,  labsize(small)) ///
        subtitle("`: label pop `i''", size(small)) ///
        xtitle("") ytitle("") ///
        name(hm`i', replace)
        
}

graph combine hm1 hm2 hm3 hm4 hm5 hm6, ///
    rows(2) ///
    b1title(Phase 1 Status, size(small)) ///
    l1title(Phase 2 Status, size(small)) ///
    note("Percentages in each column of each plot sum to 100%.", ///
      size(vsmall)) ///
    title("Change in Contraceptive Use or Non-use", size(medium)) ///
    subtitle("Percent women aged 15-49 who changed contraceptive use status", ///
      size(small)) ///
    graphregion(color(white)) ///
    name(f5_03, replace)
    
graph export f5_03.png, width(2000) replace

graph drop hm1 hm2 hm3 hm4 hm5 hm6
        
************************************************************
use post5_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot fpstatus_1 fpstatus_2 pop estimate lcb ucb ///
  using `postout', replace

forvalues i = 1/3 {
    forvalues k = 1/3 {
        forvalues j = 1/6 {
            capture drop y
            gen y = fpstatus_1 == `i' & fpstatus_2 == `k'
            quietly svy, subpop(if pop == `j'): proportion y 
            post toplot (`i') (`k') (`j') ///
                        (`=100*r(table)[1,2]') /// // the estimate
                        (`=100*r(table)[5,2]') /// // the LCB
                        (`=100*r(table)[6,2]')     // the UCB
        }
    }
}
capture postclose toplot
use `postout', clear

label define status 1 "Pregnant" 3 "Using FP" 2 "Not Using FP", replace
label values fpstatus_1 status
label values fpstatus_2 status
include label_pop_values.do

label variable estimate "Joint probability of Phase 1 and Phase 2"

decode fpstatus_1, gen(fpstring_1)
decode fpstatus_2, gen(fpstring_2)

heatplot estimate fpstring_2 fpstring_1 , ///
    by(pop, legend(off) graphregion(color(white)) ///
      note("Percentages in each plot sum to 100%.", size(vsmall)) ///
      title("Joint Probabilities - All Combinations", size(small))) ///
    values(format(%4.0f)) ///
    color(spmap greens, intensity(.80)) ///
    cuts(10 20 30 40 50 60 70 80 90) ///
    discrete ///
    xlabel(, labsize(small) angle(45)) ///
    ylabel(, labsize(small) nogrid) ///
    subtitle(,lcolor(white) fcolor(white) size(small)) ///
    xtitle("Phase 1 Status", size(small)) ///
    ytitle("Phase 2 Status", size(small)) ///
    name(f5_04, replace)
    
graph export f5_04.png, width(2000) replace

heatplot estimate fpstring_2 fpstring_1 if fpstring_2 != fpstring_1, ///
    by(pop, legend(off) graphregion(color(white)) ///
      note("", size(vsmall)) ///
      title("Joint Probabilities - Those Who Changed", size(small))) ///
    values(format(%4.0f)) ///
    color(spmap greens, intensity(.80)) ///
    cuts(10 20 30 40 50 60 70 80 90) ///
    discrete ///
    xlabel(, labsize(small) angle(45)) ///
    ylabel(, labsize(small) nogrid) ///
    subtitle(,lcolor(white) fcolor(white) size(small)) ///
    xtitle("Phase 1 Status", size(small)) ///
    ytitle("Phase 2 Status", size(small)) ///
    name(f5_05, replace) 
    
graph export f5_05.png, width(2000) replace
    
heatplot estimate fpstring_2 fpstring_1 if fpstring_2 == fpstring_1, ///
    by(pop, legend(off) graphregion(color(white)) ///
      note("", size(vsmall)) ///
      title("Joint Probabilities - Those Who Did Not Change", size(small))) ///
    values(format(%4.0f)) ///
    color(spmap greens, intensity(.80)) ///
    cuts(10 20 30 40 50 60 70 80 90) ///
    discrete ///
    xlabel(, labsize(small) angle(45)) ///
    ylabel(, labsize(small) nogrid) ///
    subtitle(,lcolor(white) fcolor(white) size(small)) ///
    xtitle("Phase 1 Status", size(small)) ///
    ytitle("Phase 2 Status", size(small)) ///
    name(f5_06, replace)
    
graph export f5_06.png, width(2000) replace

************************************************************
use post5_prepped, clear

capture postclose toplot
tempfile postout
postfile toplot row pop width str25 label0 using `postout', replace

forvalues j = 1/6 {
    local row 1
    forvalues m = 1/3 {
        forvalues i = 1/3 {
            forvalues k = 1/3 {
                local postit (`row') (`j')
                capture drop y
                gen y = fpstatus_1 == `i' & fpstatus_2 == `k'
                quietly svy, subpop(if pop == `j'): proportion y
                local postit `postit' (`=100*r(table)[1,2]') 
                if `row' <= 9 {
                    capture drop y
                    gen y = fpstatus_1 == `i'
                    quietly svy, subpop(if pop == `j'): proportion y
                    post toplot `postit' ("`=round(100*r(table)[1,2],1)'%")
                }
                else if `row' <= 18 {
                    post toplot `postit' ("`=round(100*r(table)[1,2],1)'%")
                }
                else if `row' <= 21 {
                    capture drop y 
                    gen y = fpstatus_2 == `k'
                    quietly svy, subpop(if pop == `j'): proportion y
                    post toplot (`row') (`j') (0) ("`=round(100*r(table)[1,2])'%")
                }
                local ++row
            }
        }
    }
}

capture postclose toplot
use `postout', clear

include label_pop_values.do

save post5_sankey, replace

* Make the six sub-plots
forvalues i = 1/6 {
    
    use pma_sankey_template4, clear
    capture drop width
    capture drop label0
    capture drop pop
    gen pop = `i'
    merge 1:1 pop row using post5_sankey
    keep if _merge == 3
    drop _merge
    local country = "`:label pop `i''"
    gen country = "`country'"
    save post5_sankey_`i', replace  // Save the dataset for review

    replace label0 = "<1%" if label0 == "0%"
    sankey_plot_with_legend x1 y00 x2 y11, ///
        width0(width) adjust extra color(color) label0(label0) ///
        xsize(10) ysize(6) labcolor(edkblue*2) labsize(small) ///
        legend( on order(1 "Pregnant" 4 "Not Using FP" 7 "Using FP") rows(1) ///
          pos(6) region(lcolor(white)) size(small) symxsize(small) ///
          symysize(medium) ) ///
        xlabel(none) ///
        title("`country'", size(medium)) ///
        graphregion(color(white)) yscale(lstyle(none)) xscale(lstyle(none)) ///
        name(sub_`i', replace)
}

* Combine them into one figure
grc1leg2 sub_1 sub_2 sub_3 sub_4 sub_5 sub_6, row(2) legend(sub_1) ///
        title("Changes in Contraceptive Use or Non-Use - `country'", ///
          size(medium)) ///
        subtitle("Women aged 15-49: PMA Phase 1 to Phase 2", size(medsmall)) ///
        graphregion(color(white)) name(f5_07, replace)
        
graph export f5_07.png, width(2000) replace

* We do not drop these six sub-plots here as the user may wish to look
* at them carefully in Stata's graph viewer.
*graph drop  sub_1 sub_2 sub_3 sub_4 sub_5 sub_6

* Cleanup
capture erase post5_prepped.dta
capture erase post5_heatplot.dta
capture erase post5_sankey.dta
capture erase post5_sankey_1.dta
capture erase post5_sankey_2.dta
capture erase post5_sankey_3.dta
capture erase post5_sankey_4.dta
capture erase post5_sankey_5.dta
capture erase post5_sankey_6.dta

* ==============================================================================
* ==============================================================================
* ==============================================================================
*
**# Chapter #6 - Contraceptive Calendar
* 
* ==============================================================================
* ==============================================================================
* ==============================================================================
*
* The code for Chapter 6 requires two datasets to be present in the working
* directory: pma_00007.  
*
* ==============================================================================

use pma_00007, clear

* Filter the data to keep only who complete FQ and belong to de facto population
keep if resultfq_1 == 1 & resultfq_2 == 1
keep if resident_1 == 11 | resident_1 == 22
keep if resident_2 == 11 | resident_2 == 22

* Generate string code for each country
decode country, gen(country_cal)
replace country_cal = "BF" if country_cal == "burkina faso"
replace country_cal = "CD" if country_cal == "congo, democratic republic"
replace country_cal = "KE" if country_cal == "kenya"
replace country_cal = "NG" if country_cal == "nigeria"

* Generate a short ID variable for each woman
gen id = _n, before(sample_1)

************************************************************

* Generate CMC variables
gen intfqcmc_1 = intfqmon_1 +12*(intfqyear_1 -1900) if ///
                 intfqmon_1 < 90 & intfqyear_1 < 9000
gen intfqcmc_2 = intfqmon_2 +12*(intfqyear_2 -1900) if ///
                 intfqmon_2 < 90 & intfqyear_2 < 9000

foreach s in kid1stbirth lastbirth otherbirth panelbirth ///
             pregend panelpregend fpbeginuse {
    gen `s'cmc_1 = `s'mo_1 + 12*(`s'yr_1 - 1900) if ///
                   `s'mo_1 < 90 & `s'yr_1 < 9000
    gen `s'cmc_2 = `s'mo_2 + 12*(`s'yr_2 - 1900) if ///
                   `s'mo_2 < 90 & `s'yr_2 < 9000                   
}

************************************************************

* List six rows fron a contracted frequency dataset 
* (The same six lines shown in the R blog post.)
preserve
contract panelbirthmo_2 panelbirthyr_2 panelbirthcmc_2, freq(freq)
describe
list in -6/-1, nolabel noobs sep(6)
restore

************************************************************

* Gen the cmc date for the first month of each country's survey
gen calstart_1 = 2017
replace calstart_1 = 2018 if country_cal == "BF"
gen calstart_2 = 2018
replace calstart_1 = 12*(calstart_1 -1900) + 1
replace calstart_2 = 12*(calstart_2 -1900) + 1

************************************************************

* Gen vars that cover a range of months in each sample
gen calstop_1 = intfqcmc_1
gen calstop_2 = intfqcmc_2

************************************************************

* list 10 samples to show that CALENDARKE_1 is blank for these women 
* from Burkina Faso
list id country_cal calendarbf_1 calendarke_1 in 1/10 ///
  if country_cal == "BF", noobs sep(10)

************************************************************

* Save the filtered dataset for later use
save post6_filtered_dataset, replace

************************************************************

* keep only certain vars
keep id country_cal cal*

save post6_cal1, replace

************************************************************

* reshape the data to long
reshape long calendarke_ calendarkewhy_ calendarng_ calendarngwhy_ ///
        calendarbf_ calendarbfwhy_ calendarcd_ calendarcdwhy_ ///
        calstart_ calstop_ , i(id) j(phase)
rename calendarbfwhy_ calendarbfwhy
rename calendarbf_ calendarbf
rename calendarcdwhy_ calendarcdwhy
rename calendarcd_ calendarcd
rename calendarkewhy_ calendarkewhy
rename calendarke_ calendarke
rename calendarng_ calendarng
rename calendarngwhy_ calendarngwhy
rename calstart_ calstart
rename calstop_ calstop

list in 1/10

************************************************************

* relocate calendarbfwhy calendarbf
order calendarbf* , before(calendarke)

* rename variables
foreach i in calendarbf calendarcd calendarke calendarng {
    rename `i' `i'fpstatus
}

foreach v in calendar*why {
    rename `v' `v'stop
}

* reshape again to long
reshape long calendar@fpstatus calendar@whystop, i(id phase) j(country) string
rename calendarfpstatus fpstatus
rename calendarwhystop whystop

************************************************************

list in 1/8

************************************************************

* keep only where country_cal == country_cal
keep if upper(country) == country_cal

list in 1/6

************************************************************
* drop country_cal
drop country_cal
* list 10 samples
list in 1/10
* gen a var to indicate if fpstatus == "" and proportion table of this variable
gen empty_fpstatu = fpstatus == ""

if `c(userversion)' >= 17 table ( empty_fpstatu ) () (), nototals ///
  statistic(frequency) statistic(proportion) missing
else tab empty_fpstatu, missing
************************************************************

* save this dataset for later use
drop empty_fpstatu
save post6_cal1, replace

************************************************************

* import the filtered data
use post6_filtered_dataset, clear
keep id *cmc* pregnant* fpcurreffmethrc*
drop intfq*
* reshape to long
unab vars : *_1
local vars " `vars'" 
local vars : subinstr local vars "_1" " ", all

reshape long pregnant_ fpcurreffmethrc_ kid1stbirthcmc_ lastbirthcmc_ ///
             otherbirthcmc_ panelbirthcmc_ pregendcmc_ panelpregendcmc_ ///
             fpbeginusecmc_ , i(id) j(phase)

rename pregnant_ pregnant
rename fpcurreffmethrc_ fpcurreffmethrc
rename kid1stbirthcmc_ kid1stbirthcmc
rename lastbirthcmc_ lastbirthcmc
rename otherbirthcmc_ otherbirthcmc
rename panelbirthcmc_ panelbirthcmc
rename pregendcmc_ pregendcmc
rename panelpregendcmc_ panelpregendcmc
rename fpbeginusecmc_ fpbeginusecmc

* merge this dataset with the dataset we saved as post6_cal1 by id and phase
merge 1:1 id phase using post6_cal1,  nogenerate 
* generate calmissing var
gen criteria = 0
foreach v of varlist *cmc {
    replace criteria  = 1 if `v'!= . & `v' >= calstart
}
gen calmissing = 0, after(phase)
replace calmissing = 1 if fpstatus == "" & whystop == "" & ///
                          (pregnant == 1 | criteria == 1)
drop criteria
* relocate calstart
order calstart , after(calmissing)
* show 10 obs
list in 1/10

************************************************************

* create another prop table to compare with simply using fpstatus as criteria
gen empty_fpstatu = fpstatus == ""
if `c(userversion)' >= 17 table ( empty_fpstatu ) ( calmissing ) (), ///
  nototals statistic(frequency) statistic(proportion) 
else tab empty_fpstatu calmissing, cell missing
drop empty_fpstatu

************************************************************

* relabel fpcurreffmethrc
gen fpcur = fpcurreffmethrc
label define fpcurreffmethrc_code 999 "0" 101 "1" 102 "2" 111 "3" 112 "4" ///
                                  121 "5" 123 "5" 131 "7" 132 "8" 141 "9" ///
                                  142 "10" 151 "11" 152 "12" 160 "13" ///
                                  170 "14" 210 "30" 220 "31" 240 "39", replace
label values fpcur fpcurreffmethrc_code
decode fpcur, gen(fpcurreffmethrc_new)
drop fpcur
* gen caldur to calculate the duration of each woman
gen caldur = calstop - calstart + 1
* replace ", fpstatus" caldur times

************************************************************

* Generate a long string of repeated values of fpcurreffmethrc_new and 
* insert it into fpstatus, for respondents where fpstatus == "" & calmissing == 0
capture drop longstring 
gen longstring = ""
sum caldur

forvalues i = 1/`=r(max)' {
    replace longstring = longstring + fpcurreffmethrc_new + ", " if `i' <= caldur
}
replace longstring = substr(longstring, 1, strlen(longstring) - 2)
replace fpstatus = longstring if trim(fpstatus) == "" & calmissing == 0
drop longstring

generate new_string = subinstr(fpstatus,"  ", "", .)
* drop variables
drop *cmc caldur calstop calmissing pregnant fpcurreffmethrc ///
     fpcurreffmethrc_new fpstatus

************************************************************

* reshape it to long so one value per row
rename new_string value_fpstatus
rename whystop value_whystop
reshape long value_, i(id phase) j(name) string
rename value_ value
list in 1/10

************************************************************

* calculate the number of variables we need to generate by 
* counting the number of "," then plus 1
gen l1 = length(value)
gen l2= length(subinstr(value,",","",.))
gen tempvalue = trim(value)
replace tempvalue = subinstr(tempvalue,",",", ",.)

gen l = l1 - l2
replace l = l+1 if l != 0

summarize l

************************************************************

local num = `r(max)'

* Insert | into empty spaces in the variable named value 
* so we can strip out the commas
forvalues i = 1/10 {
    replace value = subinstr(trim(value)," ","",.)
}
forvalues i = 1/10 {
    replace value = subinstr(value,",,",",|,",.)
}
replace value = "|" + value if substr(value,1,1) == ","
replace value = value + "|" if substr(value,-1,1) == ","

replace value = strreverse(subinstr(value,","," ",.))

*split value to variables
forvalues n = 1/`num' {
    gen value`n' = word(value,`n') if `n' <= l & word(value,`n') != "|"

}

drop l1 l2 l value

list in 1

************************************************************

* reshape to long again by value
reshape long value, i(id phase name) j(month)
list in 1/10

************************************************************

* gen calcmc to mark the calendar month
gen calcmc = calstart + month - 1

************************************************************

keep id phase calcmc name value
* reshape wide
reshape wide value, i(id phase calcmc) j(name) string
reshape wide valuefpstatus valuewhystop, i(id calcmc) j(phase)
rename valuefpstatus1 fpstatus_1
rename valuefpstatus2 fpstatus_2
rename valuewhystop1 whystop_1 
rename valuewhystop2 whystop_2
replace fpstatus_1 = trim(fpstatus_1)
replace fpstatus_2 = trim(fpstatus_2)
* filter data
drop if missing(fpstatus_1) & fpstatus_2 == ""
* sort data
gsort id -calcmc
list in 1/40, noobs

************************************************************

save post6_cals, replace

************************************************************

* import the filtered data
use post6_filtered_dataset, clear
keep if fpcurreffmethrc_1 == 999
replace unmetyn_1 = unmetyn_1 == 1

* mutate variables
gen fpplanyr_1 = 0
replace fpplanyr_1 = 1 if fpplanwhen_1 == 1 & fpplanval_1 <= 12
replace fpplanyr_1 = 1 if fpplanwhen_1 == 2 & fpplanval_1 == 1
replace fpplanyr_1 = 1 if fpplanwhen_1 == 3 | fpplanwhen_1 == 4

************************************************************

******the two way proportion tables for plot******
version 15
levelsof country
foreach lev in `r(levels)' {
    if `c(userversion)' >= 17 table ( unmetyn_1 ) ( fpplanyr_1 ) () ///
      if country == `lev', statistic(proportion)
    else tab unmetyn_1 fpplanyr_1 if country == `lev', cell nofreq
}

save post6_nonusers, replace

************************************************************

* Post 16 row dataset to make the joint & marginal probability plots

svyset _n, strata(country)

capture postclose toplot
tempfile postout
postfile toplot unmetyn_1 fpplanyr_1 country margin_u margin_f joint ///
    using `postout', replace

levelsof country, local(clist)
foreach j in `clist' {
    forvalues i = 0/1 {
        forvalues k = 0/1 {
            capture drop y
            gen y = unmetyn_1 == `i'
            quietly svy, subpop(if country == `j'): proportion y 
            local postit (`i') (`k') (`j') (`=100*r(table)[1,2]') 
            capture drop y
            gen y = fpplanyr_1 == `k'
            quietly svy, subpop(if country == `j'): proportion y 
            local postit `postit' (`=100*r(table)[1,2]') 
            capture drop y
            gen y = unmetyn_1 == `i' & fpplanyr_1 == `k'
            quietly svy, subpop(if country == `j'): proportion y 
            local postit `postit' (`=100*r(table)[1,2]') 
            post toplot `postit'            
        }
    }
}
capture postclose toplot
use `postout', clear

label define country 1 "BF" 2 "CD" 7 "KE" 9 "NG", replace
label values country country

gen     margin_f_label = "Plan 1 Yr "     + string(round(margin_f,1.1)) + "%" ///
    if fpplanyr_1 == 1
replace margin_f_label = "No Plan 1 Yr "  + string(round(margin_f,1.1)) + "%" ///
    if fpplanyr_1 == 0
gen     margin_u_label = "Unmet Need "    + string(round(margin_u,1.1)) + "%" ///
    if unmetyn_1 == 1
replace margin_u_label = "No Unmet Need " + string(round(margin_u,1.1)) + "%" ///
    if unmetyn_1 == 0

************************************************************

* Make four sub-plots

foreach c in 1 2 7 9 {    
    heatplot joint margin_f_label margin_u_label if country == `c', ///
        legend(off) graphregion(color(white))  ///
        values(format(%4.1f)) ///
        cuts(5 10 15 20 25) ///
        color(purples, intensity(0.6)) ///
        discrete ///
        xlabel(,  labsize(small) angle(45)) ///
        ylabel(,  labsize(small)) ///
        subtitle("`: label country `c''", size(small)) ///
        xtitle("") ytitle("") ///
        name(hm`c', replace)
}

* Combine them together
graph combine hm1 hm2 hm7 hm9, ///
  rows(2) ///
  title("Non-users: Unmet Need and Intentions to Adopt a Method within 1 Year", ///
    size(medium)) ///
  subtitle("Unweighted percentage among sampled women not currently using any method at Phase 1", ///
    size(small)) ///
  note("Percentages in each plot sum to 100%.", size(vsmall)) ///
  graphregion(color(white)) ///
  name(f6_01, replace)
    
graph export f6_01.png, width(2000) replace
    
capture graph drop hm1 hm2 hm7 hm9

************************************************************

* Continue data management to prep for exploratory survival analysis

use post6_nonusers, clear

* keep only certain variables
keep id country intfqcmc_1 unmetyn_1 fpplanyr_1
save post6_nonusers, replace
* merge post6_nonuser and post6_cals
use post6_cals, clear
merge m:1 id using post6_nonusers, nogenerate 
* only keep months after intfqcmc_1 and exclude women for whom either 
* UNMETYN_1 or FPPLANYR_1 is missing, NIU, or otherwise coded NA
keep if calcmc >= intfqcmc_1
keep if !missing(fpstatus_2) & !missing(unmetyn_1) & !missing(fpplanyr_1)
list in 1/20, noobs

************************************************************

* keep variable and gen mo & use
gen mo = calcmc - intfqcmc_1
gen use = fpstatus_2 != "0" & fpstatus_2 != "B" & ///
          fpstatus_2 != "P" & fpstatus_2 != "T"

************************************************************

* gen usemo, stop and rc
* changes made here:
* change the variable stop to event; stop2 to event2 
bysort id: gen usemo = mo if use == 1
bysort id: egen use_sum = sum(use)
bysort id: egen event = min(usemo) if use_sum >= 1
bysort id: egen event2 = max(mo) if use_sum == 0
replace event = event2 if missing(event)
drop event2 use_sum
bysort id: gen rc = 1 if event == mo & use == 0
bysort id: replace rc = 0 if event == mo & use == 1

************************************************************

* filter data to keep only the last month a woman is not using any method
* change the variable stop to event 
keep if event == mo

************************************************************

gen     interact_1 = "Unmet Need, Plan 1 Yr"       if unmetyn_1 == 1 & ///
  fpplanyr_1 == 1
replace interact_1 = "Unmet Need, No Plan 1 Yr"    if unmetyn_1 == 1 & ///
  fpplanyr_1 == 0
replace interact_1 = "No Unmet Need, Plan 1 Yr"    if unmetyn_1 == 0 & ///
  fpplanyr_1 == 1
replace interact_1 = "No Unmet Need, No Plan 1 Yr" if unmetyn_1 == 0 & ///
  fpplanyr_1 == 0
  
save post6_survival,replace

************************************************************

use post6_survival, clear
gen notrc = !rc

* Survial analysis stset command to set up for sts list and sts graph commands
* Because we have failures at month zero, we specify the "origin(min)" option
* which counts participants as entering observation at the earliest time
* observed minus 1.  This helps us match the R survival analysis output. 
stset mo, failure(notrc) origin(min)

************************************************************

* Look at failures for Burkina Faso in tabular format, by unmet need status
sts list if co == 1, failure by(unmetyn_1 )

************************************************************

sts graph if co == 1, failure by(unmetyn_1 ) ylabel(0(.2)1.0, angle(0)) ///
ci title(Burkina Faso, size(small)) graphregion(color(white))  ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) legend(size(small) symxsize(small) ///
symysize(small) region(lcolor(none)) order(1 "No unmet need" 3 "Unmet need") ///
row(1)) name(hm1, replace) xtitle(Months After Phase 1 Interview, size(small)) 

sts graph if co == 2, failure by(unmetyn_1 ) ylabel(0(.2)1.0, angle(0)) ///
ci title(DR Congo, size(small))     graphregion(color(white))   ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) legend(size(small) symxsize(small) ///
symysize(small) region(lcolor(none)) order(1 "No unmet need" 3 "Unmet need") ///
row(1)) name(hm2, replace) xtitle(Months After Phase 1 Interview, size(small))

sts graph if co == 7, failure by(unmetyn_1 ) ylabel(0(.2)1.0, angle(0)) ///
ci title(Kenya, size(small))        graphregion(color(white))  ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) legend(size(small) symxsize(small) ///
symysize(small) region(lcolor(none)) order(1 "No unmet need" 3 "Unmet need") ///
row(1)) name(hm3, replace) xtitle(Months After Phase 1 Interview, size(small))

sts graph if co == 9, failure by(unmetyn_1 ) ylabel(0(.2)1.0, angle(0)) ///
ci title(Nigeria, size(small))      graphregion(color(white))  ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) legend(size(small) symxsize(small) ///
symysize(small) region(lcolor(none)) order(1 "No unmet need" 3 "Unmet need") ///
row(1)) name(hm4, replace) xtitle(Months After Phase 1 Interview, size(small))

grc1leg2  hm1 hm2 hm3 hm4, rows(2) graphregion(color(white)) legend(hm1) ///
name(f6_02, replace) ///
title(Predicted Time to FP Adoption by Phase 1 Unmet Need Status, size(small)) ///
xcommon ycommon

graph export f6_02.png, width(2000) replace

************************************************************

sts graph if co == 1, failure by(fpplanyr_1 ) ylabel(0(.2)1.0, angle(0)) ///
ci title(Burkina Faso, size(small)) graphregion(color(white))  ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) legend(size(small) symxsize(small) ///
symysize(small) region(lcolor(none)) order(1 "No plan 1yr" 3 "Plan 1yr") ///
row(1)) name(hm1, replace) xtitle(Months After Phase 1 Interview, size(small))

sts graph if co == 2, failure by(fpplanyr_1 ) ylabel(0(.2)1.0, angle(0)) ///
ci title(DR Congo, size(small))     graphregion(color(white))  ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) legend(size(small) symxsize(small) ///
symysize(small) region(lcolor(none)) order(1 "No plan 1yr" 3 "Plan 1yr") ///
row(1)) name(hm2, replace) xtitle(Months After Phase 1 Interview, size(small))

sts graph if co == 7, failure by(fpplanyr_1 ) ylabel(0(.2)1.0, angle(0)) ///
ci title(Kenya, size(small))        graphregion(color(white))  ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) legend(size(small) symxsize(small) ///
symysize(small) region(lcolor(none)) order(1 "No plan 1yr" 3 "Plan 1yr") ///
row(1)) name(hm3, replace) xtitle(Months After Phase 1 Interview, size(small))

sts graph if co == 9, failure by(fpplanyr_1 ) ylabel(0(.2)1.0, angle(0)) ///
ci title(Nigeria, size(small))      graphregion(color(white))  ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) legend(size(small) symxsize(small) ///
symysize(small) region(lcolor(none)) order(1 "No plan 1yr" 3 "Plan 1yr") ///
row(1)) name(hm4, replace) xtitle(Months After Phase 1 Interview, size(small))

grc1leg2  hm1 hm2 hm3 hm4, rows(2) graphregion(color(white)) legend(hm1) ///
name(f6_03, replace) ///
title(Predicted Time to FP Adoption by Intentions Within 1 Year of Phase 1, ///
size(small)) xcommon ycommon

graph export f6_03.png, width(2000) replace

************************************************************

sts graph if co == 1, failure by(interact_1 ) ylabel(0(.2)1.0, angle(0)) ///
ci title(Burkina Faso, size(small)) graphregion(color(white)) ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) ///
legend(size(small) symxsize(small) ///
symysize(small) region(lcolor(none)) ///
order(9 "No need; No plan" 10 "No need; Plan 1yr" 11 "Unmet need; No plan" ///
12 "Unmet need; Plan 1yr" )) name(hm1, replace) ///
xtitle(Months After Phase 1 Interview, size(small))
        
sts graph if co == 2, failure by(interact_1 ) ylabel(0(.2)1.0, angle(0)) ///
ci title(DR Congo, size(small))     graphregion(color(white))  ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) ///
legend(size(small) symxsize(small) ///
symysize(small) region(lcolor(none)) ///
order(9 "No need; No plan" 10 "No need; Plan 1yr" 11 "Unmet need; No plan" ///
12 "Unmet need; Plan 1yr" )) name(hm2, replace) ///
xtitle(Months After Phase 1 Interview, size(small))

sts graph if co == 7, failure by(interact_1 ) ylabel(0(.2)1.0, angle(0)) ///
ci title(Kenya, size(small))        graphregion(color(white))  ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) ///
legend(size(small) symxsize(small) ///
symysize(small) region(lcolor(none)) ///
order(9 "No need; No plan" 10 "No need; Plan 1yr" 11 "Unmet need; No plan" ///
12 "Unmet need; Plan 1yr" )) name(hm3, replace) ///
xtitle(Months After Phase 1 Interview, size(small))

sts graph if co == 9, failure by(interact_1 ) ylabel(0(.2)1.0, angle(0)) ///
ci title(Nigeria, size(small))      graphregion(color(white))  ///
yline(1,lcolor(ltblue*.5) lwidth(thin)) ///
legend(size(small) symxsize(small) ///
symysize(small) region(lcolor(none)) ///
order(9 "No need; No plan" 10 "No need; Plan 1yr" 11 "Unmet need; No plan" ///
 12 "Unmet need; Plan 1yr" )) name(hm4, replace) ///
 xtitle(Months After Phase 1 Interview, size(small))

grc1leg2  hm1 hm2 hm3 hm4, rows(2) graphregion(color(white)) legend(hm1) ///
name(f6_04, replace) ///
title(Predicted Time to FP Adoption by Phase 1 Intentions and Unmet Need, ///
size(small)) xcommon ycommon

graph export f6_04.png, width(2000) replace

************************************************************

* Cleanup

capture erase post6_filtered_dataset.dta
capture erase post6_cal1.dta
capture erase post6_cals.dta
capture erase post6_nonusers.dta
capture erase post6_survival.dta

capture log close
