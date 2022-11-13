* ==============================================================================
* ==============================================================================
* ==============================================================================
*
* Stata syntax to adapt the IPUMS PMA April 19, 2022 blog post
* (https://tech.popdata.org/pma-data-hub/posts/2022-04-15-phase2-indicators/)
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
* The program requires one dataset to be present: pma_00121.  This program
* saves and uses a temporary dataset named post4_prepped.  It deletes that
* dataset when finished.  It also saves several .png image files, using 
* the command: graph export.
*
* ==============================================================================
*
* Contact Dale Rhoda and Mia Yu with questions: 
* Dale.Rhoda@biostatglobal.com, Mia.Yu@biostatglobal.com
*
* ==============================================================================

cd "Q:/BMGF - PMA IPUMS FP Blog Posts/PMA 2022 longitudinal guide - Stata files"

capture log close
set linesize 80
log using Blog4_log.txt, text replace

use pma_00121, clear

********************************************************************************

*keep de facto in both phases data only
*changes made: use inlist
*keep if (resident_1 == 11 | resident_1 == 22) & (resident_2 == 11 | resident_2 == 22)
keep if inlist(resident_1,11,22) & inlist(resident_2,11,22)
********************************************************************************

*keep only who complete phase 2
keep if resultfq_2 == 1

********************************************************************************

*only keep those who response to the question about contraceptives
keep if cp_1 < 90 & cp_2 <90

********************************************************************************

* Make a new variable named strata_recode that is defined everywhere
*
* We will use it when we svyset this dataset.

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

********************************************************************************

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

********************************************************************************

* Not included in chapter because it will not include confidence intervals

graph hbar (percent) [aweight=panelweight], ///
    by(pop cp_1, cols(2) note("Bars in each subplot of the figure sum to 100%." ///
	  "Graphs by country and Phase 1 contraceptive use status.", ///
	  size(vsmall)) ///
  	  title(Phase 2 Contraceptive Use Status, size(medium)) ) ///
    over(cp_2) ///
	ytitle(Percent, size(small)) ///
	name(f4_00, replace)
	
* graph export f4_00.png, width(2000) replace

********************************************************************************

save post4_prepped, replace

********************************************************************************

clear 
use post4_prepped, clear

********************************************************************************

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
label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace
label values cp_1 yesno
label values cp_2 yesno
label values pop pop
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
		   
********************************************************************************

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
		label define yesno 0 "No" 1 "Yes", replace
		label define pop ///
				   1 "Burkina Faso" ///
				   2 "DRC-Kinshasa" ///
				   3 "DRC-Kongo Central" ///
				   4 "Kenya" ///
				   5 "Nigeria-Kano" ///
				   6 "Nigeria-Lagos", replace
		label values cp_1 yesno
		label values cp_2 yesno
		label values pop pop

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

********************************************************************************
use post4_prepped, clear

svy, subpop(if cp_1 == 1 & pop == 1): proportion cp_2  // top row for Burkina Faso
svy, subpop(if cp_1 == 1 & pop == 3): proportion cp_2  // top row for DRC-Kongo Central
* Check Rao-Scott
svy, subpop(if inlist(pop,1,3) & cp_1 == 1): tab cp_2 pop , null pearson col

********************************************************************************

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

********************************************************************************

list pregnant_1 cp_1 fpstatus_1 pregnant_2 cp_2 fpstatus_2 in 1/12, noobs sep(12)

********************************************************************************

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
label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace
label values pop pop

label variable fpstatus_1 "Family Planning Status (Phase 1)"
label variable fpstatus_2 "Family Planning Status (Phase 2)"
	   
label define status2 1 "Pregnant in Phase 1" 3 "Using FP in Phase 1" 2 "Not Using FP in Phase 1", replace
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
		      note("Estimates within each subplot sum to 100%.", size(vsmall)) col(3)  ) ///
		   subtitle(,lcolor(white) fcolor(white)) ///
		   xtitle(Family Planning Status (Phase 2)) ///
		   xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
		   legend(order(1 "No change" 2 "Status changed") size(vsmall) ///
		          region(lcolor(white)) symxsize(small) symysize(small)) ///
		   ytitle("") ///
		   name(f4_04, replace)		   
graph export f4_04.png, width(2000) replace

********************************************************************************
use post4_prepped, clear

* Table of methods
table ( fpcurreffmethrc_1 ) ( ) ( ), nototals missing

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

********************************************************************************

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
label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace
label values pop pop

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
		      note("Estimates within each subplot sum to 100%." "Graphs by population and Phase 1 method.", size(vsmall)) col(4)  ) ///
		   subtitle(,size(small) lcolor(white) fcolor(white)) ///
		   xtitle(Family Planning Method (Phase 2), size(small)) ///
		   xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
		   legend(order(1 "No change" 2 "Method changed") size(vsmall) ///
		          region(lcolor(white)) symxsize(small) symysize(small)) ///
		   ytitle("") ///
		   name(f4_05, replace)		
		   
graph export f4_05.png, width(2000) replace


********************************************************************************

use post4_prepped, clear


*gen CHG_FPCURR - Change in contraceptive use between Phase 1 and Phase 2

********************************************************************************

gen chg_fpcurr = .
replace chg_fpcurr = 1 if fpcurreffmethrc_1 < 900 & fpcurreffmethrc_2 < 900 & fpcurreffmethrc_1 != fpcurreffmethrc_2
replace chg_fpcurr = 2 if fpcurreffmethrc_1 < 900 & fpcurreffmethrc_2 < 900 & fpcurreffmethrc_1 == fpcurreffmethrc_2
replace chg_fpcurr = 3 if fpcurreffmethrc_1 > 900 & fpcurreffmethrc_2 > 900
replace chg_fpcurr = 4 if fpcurreffmethrc_1 > 900 & fpcurreffmethrc_2 < 900
replace chg_fpcurr = 5 if fpcurreffmethrc_1 < 900 & fpcurreffmethrc_2 > 900

label define chg_fpcurr 1 "Changed methods" 2 "Continued method" 3 "Continued non-use" 4 "Started using" 5 "Stopped using", replace
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

********************************************************************************

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
label define chg_fpcurr 1 "Changed methods" 2 "Continued method" 3 "Continued non-use" 4 "Started using" 5 "Stopped using", replace

label values cat_age_2 cat_age_2
label values chg_fpcurr chg_fpcurr

label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace
label values pop pop

label var chg_fpcurr  "Phase 1 to 2 Family Planning Change Status"
	   
twoway (bar estimate cat_age_2 , ///
           color(blue*.5) horizontal barwidth(0.9) ///
           ylabel(1(1)3,valuelabel angle(0) nogrid labsize(small)) ///
           xlabel(0(20)100)) ///
		(rcap lcb ucb cat_age_2 , horizontal lcolor(black)) ///
		,  by(pop chg_fpcurr, graphregion(color(white)) ///
		      note("Estimates across each row of the figure sum to 100%.", size(vsmall)) col(5) legend(off) ) ///
		   subtitle(,size(small) lcolor(white) fcolor(white)) ///
		   xtitle("Changes in Family Planning Status, Phase 1 to Phase 2", size(small)) ///
		   xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
		   ytitle("") ///
		   name(f4_06, replace)
		   
graph export f4_06.png, width(2000) replace

********************************************************************************


********************************************************************************

use post4_prepped, clear

gen cat_educattgen_2 = .
replace cat_educattgen_2 = 1 if educattgen_2 < 3
replace cat_educattgen_2 = 2 if educattgen_2 == 3
replace cat_educattgen_2 = 3 if educattgen_2 == 4

label define cat_educattgen_2 1 "None/Primary" 2 "Secondary" 3 "Tertiary", replace
label values cat_educattgen_2 cat_educattgen_2
label var cat_educattgen_2 "Education Category at Phase 2"

save post4_prepped, replace

********************************************************************************

********************************************************************************

use post4_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot cat_educattgen_2 chg_fpcurr pop estimate lcb ucb using `postout', replace

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
label define chg_fpcurr 1 "Changed methods" 2 "Continued method" 3 "Continued non-use" 4 "Started using" 5 "Stopped using", replace

label values cat_educattgen_2 cat_educattgen_2
label values chg_fpcurr chg_fpcurr

label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace
label values pop pop

label var chg_fpcurr "Phase 1 to 2 Family Planning Change Status"
	   
* Plot with updated aesthetic options		   
twoway (bar estimate cat_educattgen_2 , ///
           color(blue*.5) horizontal barwidth(0.9) ///
		   ylabel(1(1)3,valuelabel angle(0) nogrid labsize(small)) ///
		   xlabel(0(20)100)) ///
		(rcap lcb ucb cat_educattgen_2 , horizontal lcolor(black)) ///
		,  by(pop chg_fpcurr, graphregion(color(white)) ///
		      note("Estimates across each row of the figure sum to 100%.", size(vsmall)) col(5) legend(off) ) ///
		   subtitle(,size(small) lcolor(white) fcolor(white)) ///
		   xtitle("Changes in Family Planning Status, Phase 1 to Phase 2", size(small)) ///
		   xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
		   ytitle("") ///
		   name(f4_07, replace)
		   
graph export f4_07.png, width(2000) replace


********************************************************************************

use post4_prepped, clear

capture drop y
gen y = chg_fpcurr == 3

svy, subpop(if inlist(cat_educattgen_2,2,3) & pop == 6): ///
     tab cat_educattgen_2 y if cat_educattgen_2 > 1 , row pearson null ci

********************************************************************************

use post4_prepped, clear

gen cat_marstat_2 = .
replace cat_marstat_2 = 1 if marstat_2 == 21 | marstat_2 == 22
replace cat_marstat_2 = 2 if cat_marstat_2 != 1

label define cat_marstat_2 1 "In union" 2 "Not in union", replace
label values cat_marstat_2 cat_marstat_2
label variable cat_marstat_2 "Marital status at Phase 2"

save, replace

********************************************************************************

use post4_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot cat_marstat_2 chg_fpcurr pop estimate lcb ucb using `postout', replace

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
label define chg_fpcurr 1 "Changed methods" 2 "Continued method" 3 "Continued non-use" 4 "Started using" 5 "Stopped using", replace

label values cat_marstat_2 cat_marstat_2
label values chg_fpcurr chg_fpcurr

label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace
label values pop pop

label var chg_fpcurr "Phase 1 to 2 Family Planning Change Status"
	   
* Plot with updated aesthetic options		   
twoway (bar estimate cat_marstat_2 , ///
		   color(blue*.5) horizontal barwidth(0.9) ///
		   ylabel(1(1)2,valuelabel angle(0) nogrid labsize(small)) ///
		   xlabel(0(20)100)) ///
		(rcap lcb ucb cat_marstat_2 , horizontal lcolor(black)) ///
		,  by(pop chg_fpcurr, graphregion(color(white)) ///
		      note("Estimates across each row of the figure sum to 100%.", size(vsmall)) col(5) legend(off) ) ///
		   subtitle(,size(small) lcolor(white) fcolor(white)) ///
		   xtitle("Changes in Family Planning Status, Phase 1 to Phase 2", size(small)) ///
		   xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
		   ytitle("") ///
		   name(f4_08, replace)
		   
graph export f4_08.png, width(2000) replace

********************************************************************************

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

********************************************************************************

use post4_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot cat_birthevent_2 chg_fpcurr pop estimate lcb ucb using `postout', replace

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
label define chg_fpcurr 1 "Changed methods" 2 "Continued method" 3 "Continued non-use" 4 "Started using" 5 "Stopped using", replace

label values cat_birthevent_2 cat_birthevent_2
label values chg_fpcurr chg_fpcurr

label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace
label values pop pop

label var chg_fpcurr "Phase 1 to 2 Family Planning Change Status"
	   
* Plot with updated aesthetic options		   
twoway (bar estimate cat_birthevent_2 , ///
		   color(blue*.5) horizontal barwidth(0.9) ///
		   ylabel(1(1)4,valuelabel angle(0) nogrid labsize(small)) ///
		   xlabel(0(20)100)) ///
		(rcap lcb ucb cat_birthevent_2 , horizontal lcolor(black)) ///
		,  by(pop chg_fpcurr, graphregion(color(white)) ///
		      note("Estimates across each row of the figure sum to 100%.", size(vsmall)) col(5) legend(off) ) ///
		   subtitle(,size(small) lcolor(white) fcolor(white)) ///
		   xtitle("Changes in Family Planning Status, Phase 1 to Phase 2", size(small)) ///
		   xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
		   ytitle("") ///
		   name(f4_09, replace)
		   
graph export f4_09.png, width(2000) replace

********************************************************************************

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

label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace
label values pop pop

twoway (bar estimate unmetyn_1 , ///
		   color(blue*.5) horizontal barwidth(0.9) ///
		   ylabel(0(1)1,valuelabel angle(0) nogrid labsize(small)) ///
		   xlabel(0(20)100)) ///
		(rcap lcb ucb unmetyn_1 , horizontal lcolor(black)) ///
		,  by(pop , graphregion(color(white)) ///
		      note("Among women who were not using family planning in Phase 1.", ///
			       size(vsmall)) col(1) legend(off) ) ///
		   subtitle(,size(small) lcolor(white) fcolor(white)) ///
		   xtitle("Had adopted a method of family planning in Phase 2", size(small)) ///
		   xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
		   ytitle("Had unmet need in Phase 1") ///
   		   ysize(10) xsize(8) ///
		   name(f4_10, replace)
		   
graph export f4_10.png, width(2000) replace

********************************************************************************

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

********************************************************************************

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

label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace
label values pop pop

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

********************************************************************************

use post4_prepped, clear

keep if cp_1 == 0

table (fpplanwhen_1) ( ) ( ), nototals missing

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

label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace
label values pop pop

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

capture log close


********************************************************************************
********************************************************************************
********************************************************************************
/*******************************************************************************
* This code does not appear in the chapter and would need some additional 
* development work. Maybe come back to it later.  

* Experiment with using graph combine to make the figure and
* put the 3 labels at the top:  Pregnant in Phase 1; Not Using in Phase 1;
* and Using FP in Phase 1

Maybe come back to it later.   
		   
preserve
keep if fpstatus_1 == 1
twoway (bar estimate fpstatus_2 if fpstatus_2 == fpstatus_1 & fpstatus_1 == 1, ///
        color(blue*.5) horizontal ///
		ylabel(1(1)3,valuelabel angle(0) nogrid) ///
		xlabel(0(20)100)) ///
		(bar estimate fpstatus_2 if fpstatus_2 != fpstatus_1  & fpstatus_1 == 1, ///
		color(orange*.5) horizontal) ///
		(rcap lcb ucb fpstatus_2 , horizontal lcolor(black)) ///
		,  by(pop , graphregion(color(white)) ///
		      note("") col(1) title(Pregnant in Phase 1, size(medsmall)) ///	  
			  ) ///
		   subtitle("") /// ,lcolor(white) fcolor(white)) ///
		   xtitle("") ///
		   xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
		   ytitle("") ///
		   legend(order(1 "No change" 2 "Status changed") size(vsmall) ///
		          region(lcolor(white)) symxsize(small) symysize(small)) ///				   
		   name(nicer3, replace)		   
restore		   		   
		 
		preserve
keep if fpstatus_1 == 2
twoway (bar estimate fpstatus_2 if fpstatus_2 == fpstatus_1 , ///
        color(blue*.5) horizontal ///
		ylabel(1(1)3,valuelabel angle(0) nogrid) ///
		xlabel(0(20)100)) ///
		(bar estimate fpstatus_2 if fpstatus_2 != fpstatus_1, ///
		color(orange*.5) horizontal) ///
		(rcap lcb ucb fpstatus_2 , horizontal lcolor(black)) ///
		,  by(pop , graphregion(color(white)) ///
		      note("") col(1) title(Not Using in Phase 1, size(medsmall))  legend(off) ) ///
		   subtitle("") /// ,lcolor(white) fcolor(white)) ///
		   xtitle("") ///
		   xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
		   legend(off) ///
		   ytitle("") ///
		    ///
		   name(nicer4, replace)		   
restore		 
		preserve
keep if fpstatus_1 == 3
twoway (bar estimate fpstatus_2 if fpstatus_2 == fpstatus_1 , ///
        color(blue*.5) horizontal ///
		ylabel(1(1)3,valuelabel angle(0) nogrid) ///
		xlabel(0(20)100)) ///
		(bar estimate fpstatus_2 if fpstatus_2 != fpstatus_1, ///
		color(orange*.5) horizontal) ///
		(rcap lcb ucb fpstatus_2 , horizontal lcolor(black)) ///
		,  by(pop , graphregion(color(white)) ///
		      note("") col(1) title(Not Using in Phase 1, size(medsmall))  legend(off) ) ///
		   subtitle("") /// ,lcolor(white) fcolor(white)) ///
		   xtitle("") ///
		   xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
		   ///
		   ytitle("") ///
		    ///
		   name(nicer5, replace)		   
restore			 

* grc1leg is a user-written command for doing graph combine and 
* only showing the legend from a single one of the constituent plots

* It's not working quite right here.  Maybe move the legend statements
* inside the 'by' parentheses above ??

grc1leg nicer3 nicer4 nicer5 , row(1) leg(nicer3) 

clear
set obs 1
gen y = 1
gen x = 1

twoway (scatter y x, ms(O) mcolor(white)) (scatter y x, ms(X) mcolor(white)),  ///
       text(2 50 "Nigeria-Lagos" ) ///
	   name(n1, replace) xlabel(0(20)100) ylabel(1(1)3, nogrid) ///
	   legend(all) graphregion(color(white)) xscale(off) yscale(off)
twoway scatter y x, ms(i) ///
       text(2 50 "Nigeria-Kano" ) ///
	   name(n2, replace) xlabel(0(20)100) ylabel(1(1)3, nogrid) graphregion(color(white)) xscale(off) yscale(off)
twoway scatter y x, ms(i) ///
       text(2 50 "Kenya" ) ///
	   name(n3, replace) xlabel(0(20)100) ylabel(1(1)3, nogrid) graphregion(color(white)) xscale(off) yscale(off)
twoway scatter y x, ms(i) ///
       text(2 50 "DRC-Kongo Central" ) ///
	   name(n4, replace) xlabel(0(20)100) ylabel(1(1)3, nogrid) graphregion(color(white)) xscale(off) yscale(off)
twoway scatter y x, ms(i) ///
       text(2 50 "DRC-Kinshasa") ///
	   name(n5, replace) xlabel(0(20)100) ylabel(1(1)3, nogrid) graphregion(color(white)) xscale(off) yscale(off)
twoway scatter y x, ms(i) ///
       text(2 50 "Burkina Faso") ///
	   name(n6, replace) xlabel(0(20)100) ylabel(1(1)3, nogrid)	graphregion(color(white)) xscale(off) yscale(off)

graph combine n6 n5 n4 n3 n2 n1, col(1) name(nstack, replace) title(Title here) graphregion(color(white)) plotregion(color(white))

grc1leg n6 n5 n4 n3 n2 n1, leg(n1) col(1) name(nstack, replace) title(Title here) graphregion(color(white)) plotregion(color(white))

graph combine nicer3 nicer4 nicer5 nstack, row(1)

grc1leg nicer3 nicer4 nicer5 nstack, row(1) leg(nicer3) 

********************************************************************************/