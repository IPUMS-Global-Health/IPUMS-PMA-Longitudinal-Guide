cd "Q:/BMGF - PMA IPUMS FP Blog Posts/Blog2/Blog2 Stata Markdown"

use "pma_00119.dta", clear

********************************************************************************

sort fqinstid phase

list fqinstid phase age panelwoman ///
     if strmatch(fqinstid, "011*") | ///
	    strmatch(fqinstid, "015*"), separator(8) noobs

********************************************************************************

gen non_panel = fqinstid == ""
label define fqinstid_blank 0 "fqinstid is not blank" 1 "fqinstid is blank"
label values non_panel fqinstid_blank

label variable panelwoman "Woman in the panel"
table (phase panelwoman) (non_panel), nototals missing

********************************************************************************

gen keep = 1 if phase == 1
replace keep = 1 if phase == 2 & resultfq == 1
bysort fqinstid : egen keep_both = sum(keep)
keep if keep_both == 2
drop keep keep_both

********************************************************************************

gen keep = 1 if phase == 1 & (resident == 11 | resident == 22)
replace keep = 2 if phase == 2 & (resident == 11 | resident == 22)
bysort fqinstid : egen keep_both = sum(keep)
keep if keep_both == 3
drop keep keep_both

********************************************************************************

gen pop_numeric = .
replace pop_numeric = 1 if country == 1 // Burkina Faso
replace pop_numeric = 2 if country == 2 & geocd == 1 // Kinshasa
replace pop_numeric = 3 if country == 2 & geocd == 2 // Kongo Central
replace pop_numeric = 4 if country == 7 // Kenya
replace pop_numeric = 5 if country == 9 & geong == 4 // Kano
replace pop_numeric = 6 if country == 9 & geong == 2 // Lagos

label define pop_numeric ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace

label values pop_numeric pop_numeric
           
table ( pop_numeric ) ( phase) ( ), nototals missing

********************************************************************************
********************************************************************************
********************************************************************************

use "pma_00116.dta", clear

********************************************************************************

sort fqinstid

list fqinstid age_1 age_2 panelwoman_1 panelwoman_2 ///
     if strmatch(fqinstid, "011*") | ///
        strmatch(fqinstid, "015*"), separator(8) noobs
													   
********************************************************************************

list resultfq_1 age_1 resultfq_2 age_2 ///
     if fqinstid == "0C8VQU6B03BXLAVVZ8SB90EKQ"

********************************************************************************

use "pma_00119.dta", clear
list phase age resultfq if fqinstid == "0C8VQU6B03BXLAVVZ8SB90EKQ"

********************************************************************************

use "pma_00116.dta", clear
keep if resultfq_2 == 1 & resultfq_1 != .

********************************************************************************

keep if inlist(resident_1, 11, 22)
keep if inlist(resident_2, 11, 22)

********************************************************************************

gen pop_numeric = .
replace pop_numeric = 1 if country == 1 // Burkina Faso
replace pop_numeric = 2 if country == 2 & geocd == 1 // Kinshasa
replace pop_numeric = 3 if country == 2 & geocd == 2 // Kongo Central
replace pop_numeric = 4 if country == 7 // Kenya
replace pop_numeric = 5 if country == 9 & geong == 4 // Kano
replace pop_numeric = 6 if country == 9 & geong == 2 // Lagos

label define pop_numeric ///
           1 "Burkina Faso" ///
           2 "DRC-Kinshasa" ///
           3 "DRC-Kongo Central" ///
           4 "Kenya" ///
           5 "Nigeria-Kano" ///
           6 "Nigeria-Lagos", replace

label values pop_numeric pop_numeric
           
table ( pop_numeric ) ( ), nototals missing

********************************************************************************

use "pma_00116.dta", clear
keep if resultfq_2 == 1 & resultfq_1 != .

keep if inlist(resident_1, 11, 22)
keep if inlist(resident_2, 11, 22)

keep fqinstid age_1 pregnant_1 age_2 pregnant_2

reshape long age_ pregnant_ , i(fqinstid) j(phase)
rename age_ age
rename pregnant_ pregnant

*******************************************************************************
*******************************************************************************
*******************************************************************************

* This code is not in the .md file.  Experimenting with xt* commands.
 
cd "Q:/BMGF - PMA IPUMS FP Blog Posts/Blog2/Blog2 Stata Markdown"

use "pma_00119.dta", clear

bysort fqinstid : egen panel = max(panelwoman )
keep if panel == 1
egen id = group(fqinstid )
xtset id phase

xtdescribe

xttab pregnant
