* ==============================================================================
* ==============================================================================
* ==============================================================================
*
* Stata syntax to adapt the IPUMS PMA May 1, 2022 blog post
* (https://tech.popdata.org/pma-data-hub/posts/2022-05-01-phase2-alluvial/)
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
* Note also that there is only a single cd command in this program.  The program
* requires two datasets to be present: pma_00121 and pma_sankey_template4.  
* This program saves and uses datasets named post5_prepped and post5_heatplot 
* and post5_sankey and post5_sankey_1 through post5_sankey_6.  
* It erases them when finished.  It also saves several
* .png image files, using the command: graph export.
*
* The program uses two user-written commands: heatplot and grc1leg2.
* They may be installed by uncommenting and running the four lines
* below that start with 'ssc install' or 'net install'.
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
log using Blog5_log.txt, text replace

* You only need to run these commands once on each Stata computer 
*ssc install heatplot,  replace
*ssc install palettes,  replace
*ssc install colrspace, replace
*net install grc1leg2.pkg

use pma_00121, clear

* Filter data
keep if resultfq_2 == 1
keep if inlist(resident_1,11,22) & inlist(resident_2,11,22)
keep if cp_1 < 90 & cp_2 < 90

*****************************

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

******************************

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

******************************

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

svyset eaid_1, strata(strata_recode) weight(panelweight) 

save post5_prepped, replace

********************************************************************************

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
	   
label define status2 1 "Pregnant in Phase 1" 3 "Using FP in Phase 1" ///
                     2 "Not Using FP in Phase 1", replace
label define status2 1 "Pregnant" 3 "Using FP" 2 "Not Using", replace
label values fpstatus_1 status2
label values fpstatus_2 status2

twoway ///
  (bar estimate fpstatus_2 if fpstatus_2 == fpstatus_1, ///
     color(blue*.5) horizontal barwidth(0.9) ///
     ylabel(1(1)3,valuelabel angle(0) nogrid) ///
     xlabel(0(20)100)) ///
  (bar estimate fpstatus_2 if fpstatus_2 != fpstatus_1, ///
     color(orange*.5) horizontal barwidth(0.9)) ///
  (rcap lcb ucb fpstatus_2 , horizontal lcolor(black)) ///
  ,  by(pop fpstatus_1, graphregion(color(white)) ///
        note("Estimates within each subplot sum to 100%.", size(vsmall)) ///
        col(3)   ///
        title("Change in Contraceptive Use or Non-use", size(medium)) ///
        subtitle("Percent women aged 15-49 who changed contraceptive use status", ///
        size(small))) ///
     subtitle(,lcolor(white) fcolor(white)) ///
     xtitle(Family Planning Status (Phase 2)) ///
     xline(20 40 60 80 100, lcolor(gs15) lwidth(vthin)) ///
     legend(order(1 "No change" 2 "Status changed") size(vsmall) ///
            region(lcolor(white)) symxsize(small) symysize(small)) ///
     ytitle("") ///
     name(f5_01, replace)		   

graph export f5_01.png, width(2000) replace

**************************************

label define status2 1 "Pregnant" 3 "Using FP" 2 "Not Using", replace
decode fpstatus_1, gen(fpstring_1)
decode fpstatus_2, gen(fpstring_2)

heatplot estimate fpstring_2 fpstring_1 , ///
	by(pop, legend(off) graphregion(color(white)) ///
	  note("Percentages in each column of each plot sum to 100%.", size(vsmall)) ///
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

********************************************************************************
 
save post5_heatplot, replace
 
********************************************************************************
use post5_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot fpstatus_1 fpstatus_2 pop margin_1 margin_2 using `postout', replace

forvalues i = 1/3 {
	forvalues k = 1/3 {
		forvalues j = 1/6 {
			capture drop y
			gen y = fpstatus_1 == `i'
			quietly svy, subpop(if pop == `j'): proportion y 
			local postit (`i') (`k') (`j')	(`=100*r(table)[1,2]') // the estimate
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

label define status 1 "Pregnant" 3 "Using FP" 2 "Not Using FP"
label values fpstatus_1 status
label values fpstatus_2 status

********************************************************************************
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
	note("Percentages in each column of each plot sum to 100%.", size(vsmall)) ///
    title("Change in Contraceptive Use or Non-use", size(medium)) ///
    subtitle("Percent women aged 15-49 who changed contraceptive use status", ///
	  size(small)) ///
	graphregion(color(white)) ///
	name(f5_03, replace)
	
graph export f5_03.png, width(2000) replace

graph drop hm1 hm2 hm3 hm4 hm5 hm6
		
********************************************************************************
use post5_prepped, clear

* Prepare to post data to a new dataset
capture postclose toplot
tempfile postout
postfile toplot fpstatus_1 fpstatus_2 pop estimate lcb ucb using `postout', replace

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

********************************************************************************
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
label define pop ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace
label values pop pop

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
		legend( on order(1 "Pregnant" 4 "Not Using FP" 7 "Using FP") cols(1) ///
		  pos(3) region(lcolor(white)) size(small) symxsize(small) symysize(medium) ) ///
		xlabel(none) ///
		title("`country'", size(medium)) ///
		graphregion(color(white)) yscale(lstyle(none)) xscale(lstyle(none)) ///
		name(sub_`i', replace)
}

* Combine them into one figure
grc1leg2 sub_1 sub_2 sub_3 sub_4 sub_5 sub_6, row(2) legend(sub_1) lrow(1) ///
		title("Changes in Contraceptive Use or Non-Use - `country'", size(medium)) ///
		subtitle("Women aged 15-49: PMA Phase 1 to Phase 2", size(medsmall)) ///
		graphregion(color(white)) name(f5_07, replace)
		
graph export f5_07.png, width(2000) replace

graph drop  sub_1 sub_2 sub_3 sub_4 sub_5 sub_6

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

capture log close
