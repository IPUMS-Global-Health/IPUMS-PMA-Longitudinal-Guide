[//]: # (Stata-compatible markdown file to adapt the IPUMS PMA April 1, 2022 blog post to feature Stata examples.)
[//]: # (Developed at Biostat Global Consulting [www.biostatglobal.com] by Mia Yu, Caitlin Clary, and Dale Rhoda)
[//]: # (Send questions to Dale.Rhoda@biostatglobal.com)
[//]: # (Updated October 20, 2022)

<<dd_version: 2>>

# Chapter 4 - Visualizing Panel Membership

Note: We have not tried to reproduce the R blog post here, but as a placeholder have
developed code to reproduce the counts for the rows in the CONSORT figure.  
These counts could be compiled into a dataset and some code developed to 
make a figure similar to the one made with ggplot.

We will revisit the topic of whether to develop this further or not at a future
date, along with the question of what code will be needed to extend this example
to include data from Phase 3.

~~~~
<<dd_do>>

cd "Q:\BMGF - PMA IPUMS FP Blog Posts\Blog3"

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
* group the data by pop and gen new var step = 1 and keep
sort pop
gen step = 1
gen keep = resulthq_1 == 1 | resulthq_1 == 5
* generate a new data to have keep == true only and tab step keep (group by pop)
table (pop) ( step keep ) () if keep == 1, nototals missing zerocounts

* These counts correspond to those at the top of the figure labeled
* Phase 1 household members


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



keep if keep == 1
replace step = 3
drop keep
gen keep = resultfq_1 == 1 | resultfq_1 == 5
table (pop) ( step keep ) (), nototals missing zerocounts



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

<</dd_do>>
~~~~

**Note:** Again, not clear whether we will replicate the narrative from this blog post, but I'm posting the footnotes here in case we decide to use them.

<section class="footnotes footnotes-end-of-document"
role="doc-endnotes">
<hr />
<ol>
<li id="fn1" role="doc-endnote"><p>Questionnaires administered in each
country may vary from this <strong>Core Household Questionnaire</strong>
- <a href="https://pma.ipums.org/pma/enum_materials.shtml">click
here</a> for details.<a href="#fnref1" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn2" role="doc-endnote"><p>Questionnaires administered in each
country may vary from this <strong>Core Female Questionnaire</strong> -
<a href="https://pma.ipums.org/pma/enum_materials.shtml">click here</a>
for details.<a href="#fnref2" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn3" role="doc-endnote"><p>Women who completed the Phase 1
Female Questionnaire but declined to participate in the panel were given
an opportunity to join the panel again at Phase 2 (if eligible). They
are not panel members as shown in <a
href="https://pma.ipums.org/pma-action/variables/PANELWOMAN">PANELWOMAN_2</a>,
but they may be listed as such in <a
href="https://pma.ipums.org/pma-action/variables/PANELWOMAN">PANELWOMAN_3</a>
if they agree to participation in the panel going forward.<a
href="#fnref3" class="footnote-back" role="doc-backlink">↩︎</a></p></li>
<li id="fn4" role="doc-endnote"><p>The “study area” is area within which
resident enumerators should attempt to find panel women that have moved
out of their Phase 1 dwelling. This may extend beyond the woman’s
original EA as determined by in-country administrators - see <a
href="https://www.pmadata.org/data/survey-methodology">PMA Phase 2 and
Phase 3 Survey Protocol</a> for details.<a href="#fnref4"
class="footnote-back" role="doc-backlink">↩︎</a></p></li>
</ol>
</section>