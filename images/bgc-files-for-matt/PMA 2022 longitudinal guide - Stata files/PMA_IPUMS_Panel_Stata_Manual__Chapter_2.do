* ==============================================================================
* ==============================================================================
* ==============================================================================
*
* Stata syntax to adapt the IPUMS PMA March 15, 2022 blog post 
* (https://tech.popdata.org/pma-data-hub/posts/2022-03-15-phase2-formats/)
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
log using Blog2_log.txt, text replace

* Import the long format data
use pma_00119, clear

********************************************************************************

* a simple example to show what long data looks like 
* (var: FQINSTID, PHASE, AGE, PANELWOMAN)
sort fqinstid
list fqinstid phase age panelwoman if strmatch(fqinstid, "011*") | ///
     strmatch(fqinstid, "015*"), separator(8) noobs

********************************************************************************

* tab to show the data include non-panel women 
* (var: PHASE, PANELWOMAN, FQINSTID == "")
gen non_panel = fqinstid == ""
label define fqinstid_blank 0 "fqinstid is not blank" 1 "fqinstid is blank"
label values non_panel fqinstid_blank
table (phase panelwoman) (non_panel), nototals missing

********************************************************************************

* Filter the data to keep data for women with data in both phases 

gen keep = 1 if phase == 1
replace keep = 1 if phase == 2 & resultfq == 1
bysort fqinstid : egen keep_both = sum(keep)
keep if keep_both == 2
drop keep keep_both

********************************************************************************

* Filter the data to keep data for de facto women with data in both phases 

gen keep = 1 if phase == 1 & (resident == 11 | resident == 22)
replace keep = 2 if phase == 2 & (resident == 11 | resident == 22)
bysort fqinstid : egen keep_both = sum(keep)
keep if keep_both == 3
drop keep keep_both

********************************************************************************

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
           
table ( pop ) ( phase) ( ), nototals missing

********************************************************************************

* Import the wide format data
use pma_00116, clear
* show the data for the same FQINSTID to show the difference 
* between long and wide data
list fqinstid age_1 age_2 panelwoman_1 panelwoman_2 ///
     if strmatch(fqinstid, "011*") | ///
	    strmatch(fqinstid, "015*"), separator(8) noobs

********************************************************************************

* Demonstrate why wide is not exactly half of long 
* (use the orignal long data not the filtered one)

list resultfq_1 age_1 resultfq_2 age_2 ///
     if fqinstid == "0C8VQU6B03BXLAVVZ8SB90EKQ", noobs

********************************************************************************

use pma_00119, clear
list phase age resultfq ///
     if fqinstid == "0C8VQU6B03BXLAVVZ8SB90EKQ", noobs

********************************************************************************

* import wide data again
use pma_00116, clear

*filter the wide data to drop who didn't get interviewed in 
* phase 1 or didn't complete phase 2
keep if resultfq_2 == 1 & resultfq_1 != .

*filter the wide data to keep de facto only
keep if resident_1 == 11 | resident_1 == 22
keep if resident_2 == 11 | resident_2 == 22

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
           
table ( pop ) ( ), nototals missing

********************************************************************************

use pma_00116, clear
keep if resultfq_2 == 1 & resultfq_1 != .

keep if inlist(resident_1, 11, 22)
keep if inlist(resident_2, 11, 22)

keep fqinstid age_1 pregnant_1 age_2 pregnant_2

reshape long age_ pregnant_ , i(fqinstid) j(phase)
rename age_ age
rename pregnant_ pregnant

capture log close