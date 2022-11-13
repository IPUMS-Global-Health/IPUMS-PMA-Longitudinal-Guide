* ==============================================================================
* ==============================================================================
* ==============================================================================
*
* Stata syntax to adapt the IPUMS PMA May 15, 2022 blog post 
* (https://tech.popdata.org/pma-data-hub/posts/2022-05-15-phase2-calendar/)
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
* Note also that there is only a single cd command in this program.  

* The program requires two datasets to be present: pma_00122.  
* This program saves and uses several temporary datasets which are erased
* at the bottom of the program.  It also saves several f06_*.png image files, 
* using the command: graph export.
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
set linesize 75
log using Blog6_log.txt, text replace

* You only need to run these commands once on each Stata computer 
*ssc install heatplot,  replace
*ssc install palettes,  replace
*ssc install colrspace, replace
*net install grc1leg2.pkg

use pma_00122, clear

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

********************************************************************************

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

********************************************************************************

* List six rows fron a contracted frequency dataset 
* (The same six lines shown in the R blog post.)
preserve
contract panelbirthmo_2 panelbirthyr_2 panelbirthcmc_2, freq(freq)
describe
list in -6/-1, nolabel noobs sep(6)
restore

********************************************************************************

* Gen the cmc date for the first month of each country's survey
gen calstart_1 = 2017
replace calstart_1 = 2018 if country_cal == "BF"
gen calstart_2 = 2018
replace calstart_1 = 12*(calstart_1 -1900) + 1
replace calstart_2 = 12*(calstart_2 -1900) + 1

********************************************************************************

* Gen vars that cover a range of months in each sample
gen calstop_1 = intfqcmc_1
gen calstop_2 = intfqcmc_2

********************************************************************************

* list 10 samples to show that CALENDARKE_1 is blank for these women from Burkina Faso
list id country_cal calendarbf_1 calendarke_1 in 1/10 if country_cal == "BF", noobs sep(10)

********************************************************************************

* Save the filtered dataset for later use
save post6_filtered_dataset, replace

********************************************************************************

* keep only certain vars
keep id country_cal cal*

save post6_cal1, replace

********************************************************************************

* reshape the data to long
reshape long calendarke_ calendarkewhy_ calendarng_ calendarngwhy_ calendarbf_ calendarbfwhy_ calendarcd_ calendarcdwhy_ calstart_ calstop_ , i(id) j(phase)
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

********************************************************************************

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

********************************************************************************

list in 1/8

********************************************************************************

* keep only where country_cal == country_cal
keep if upper(country) == country_cal

list in 1/6

********************************************************************************
* drop country_cal
drop country_cal
* list 10 samples
list in 1/10
* gen a var to indicate if fpstatus == "" and proportion table of this variable
gen empty_fpstatu = fpstatus == ""
table ( empty_fpstatu ) () (), nototals statistic(frequency) statistic(proportion) missing

********************************************************************************

* save this dataset for later use
drop empty_fpstatu
save post6_cal1, replace

********************************************************************************

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
replace calmissing = 1 if fpstatus == "" & whystop == "" & (pregnant == 1 | criteria == 1)
drop criteria
* relocate calstart
order calstart , after(calmissing)
* show 10 obs
list in 1/10

********************************************************************************

* create another prop table to compare with simply using fpstatus as criteria
gen empty_fpstatu = fpstatus == ""
table ( empty_fpstatu ) ( calmissing ) (), nototals statistic(frequency) statistic(proportion) 
drop empty_fpstatu

********************************************************************************

* relabel fpcurreffmethrc
gen fpcur = fpcurreffmethrc
label define fpcurreffmethrc_code 999 "0" 101 "1" 102 "2" 111 "3" 112 "4" 121 "5" 123 "5" 131 "7" 132 "8" 141 "9" 142 "10" 151 "11" 152 "12" 160 "13" 170 "14" 210 "30" 220 "31" 240 "39"
label values fpcur fpcurreffmethrc_code
decode fpcur, gen(fpcurreffmethrc_new)
drop fpcur
* gen caldur to calculate the duration of each woman
gen caldur = calstop - calstart + 1
* replace ", fpstatus" caldur times

********************************************************************************

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
drop *cmc caldur calstop calmissing pregnant fpcurreffmethrc fpcurreffmethrc_new fpstatus

********************************************************************************

* reshape it to long so one value per row
rename new_string value_fpstatus
rename whystop value_whystop
reshape long value_, i(id phase) j(name) string
rename value_ value
list in 1/10

********************************************************************************

* calculate the number of variables we need to generate by counting the number of "," then plus 1
gen l1 = length(value)
gen l2= length(subinstr(value,",","",.))
gen tempvalue = trim(value)
replace tempvalue = subinstr(tempvalue,",",", ",.)

gen l = l1 - l2
replace l = l+1 if l != 0

summarize l

********************************************************************************

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

********************************************************************************

* reshape to long again by value
reshape long value, i(id phase name) j(month)
list in 1/10

********************************************************************************

* gen calcmc to mark the calendar month
gen calcmc = calstart + month - 1

********************************************************************************

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

********************************************************************************

save post6_cals, replace

********************************************************************************

* import the filtered data
use post6_filtered_dataset, clear
keep if fpcurreffmethrc_1 == 999
replace unmetyn_1 = unmetyn_1 == 1

* mutate variables
gen fpplanyr_1 = 0
replace fpplanyr_1 = 1 if fpplanwhen_1 == 1 & fpplanval_1 <= 12
replace fpplanyr_1 = 1 if fpplanwhen_1 == 2 & fpplanval_1 == 1
replace fpplanyr_1 = 1 if fpplanwhen_1 == 3 | fpplanwhen_1 == 4

********************************************************************************

******the two way proportion tables for plot******
levelsof country
foreach lev in `r(levels)' {
	table ( unmetyn_1 ) ( fpplanyr_1 ) () if country == `lev', statistic(proportion)
}

save post6_nonusers, replace

********************************************************************************

* Post 16 row dataset to make the joint & marginal probability plots

svyset _n, strata(country)

capture postclose toplot
tempfile postout
postfile toplot unmetyn_1 fpplanyr_1 country margin_u margin_f joint using `postout', replace

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

gen     margin_f_label = "Plan 1 Yr "     + string(round(margin_f,1.1)) + "%" if fpplanyr_1 == 1
replace margin_f_label = "No Plan 1 Yr "  + string(round(margin_f,1.1)) + "%" if fpplanyr_1 == 0
gen     margin_u_label = "Unmet Need "    + string(round(margin_u,1.1)) + "%" if unmetyn_1 == 1
replace margin_u_label = "No Unmet Need " + string(round(margin_u,1.1)) + "%" if unmetyn_1 == 0

********************************************************************************

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
	title("Non-users: Unmet Need and Intentions to Adopt a Method within 1 Year", size(medium)) ///
	subtitle("Unweighted percentage among sampled women not currently using any method at Phase 1", size(small)) ///
	note("Percentages in each plot sum to 100%.", size(vsmall)) ///
	graphregion(color(white)) ///
	name(f6_01, replace)
	
graph export f6_01.png, width(2000) replace
	
capture graph drop hm1 hm2 hm7 hm9

********************************************************************************

* Continue data management to prep for exploratory survival analysis

use post6_nonusers, clear

* keep only certain variables
keep id country intfqcmc_1 unmetyn_1 fpplanyr_1
save post6_nonuser, replace
* merge post6_nonuser and post6_cals
use post6_cals, clear
merge m:1 id using post6_nonuser, nogenerate 
* only keep months after intfqcmc_1 and exclude women for whom either 
* UNMETYN_1 or FPPLANYR_1 is missing, NIU, or otherwise coded NA
keep if calcmc >= intfqcmc_1
keep if !missing(fpstatus_2) & !missing(unmetyn_1) & !missing(fpplanyr_1)
list in 1/20, noobs

********************************************************************************

* keep variable and gen mo & use
gen mo = calcmc - intfqcmc_1
gen use = fpstatus_2 != "0" & fpstatus_2 != "B" & fpstatus_2 != "P" & fpstatus_2 != "T"

********************************************************************************

* gen usemo, stop and rc
* changes made here:
* change the variable stop to adopt; stop2 to adopt2 
bysort id: gen usemo = mo if use == 1
bysort id: egen use_sum = sum(use)
bysort id: egen adopt = min(usemo) if use_sum >= 1
bysort id: egen adopt2 = max(mo) if use_sum == 0
replace adopt = adopt2 if missing(adopt)
drop adopt2 use_sum
bysort id: gen rc = 1 if adopt == mo & use == 0
bysort id: replace rc = 0 if adopt == mo & use == 1

********************************************************************************

* filter data to keep only the last month a woman is not using any method
* change the variable stop to adopt 
keep if adopt == mo

********************************************************************************

gen     interact_1 = "Unmet Need, Plan 1 Yr"       if unmetyn_1 == 1 & fpplanyr_1 == 1
replace interact_1 = "Unmet Need, No Plan 1 Yr"    if unmetyn_1 == 1 & fpplanyr_1 == 0
replace interact_1 = "No Unmet Need, Plan 1 Yr"    if unmetyn_1 == 0 & fpplanyr_1 == 1
replace interact_1 = "No Unmet Need, No Plan 1 Yr" if unmetyn_1 == 0 & fpplanyr_1 == 0
save post6_survival,replace

********************************************************************************

use post6_survival, clear
gen notrc = !rc

* Survial analysis stset command to set up for sts list and sts graph commands
* Because we have failures at month zero, we specify the "origin(min)" option
* which counts participants as entering observation at the earliest time
* observed minus 1.  This helps us match the R survival analysis output. 
stset mo, failure(notrc) origin(min)

********************************************************************************

* Look at failures for Burkina Faso in tabular format, by unmet need status
sts list if co == 1, failure by(unmetyn_1 )

********************************************************************************

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

********************************************************************************

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

********************************************************************************

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

********************************************************************************

* Cleanup

capture erase post6_filtered_dataset.dta
capture erase post6_cal1.dta
capture erase post6_cals.dta
capture erase post6_nonuser.dta
capture erase post6_survival.dta

capture log close
