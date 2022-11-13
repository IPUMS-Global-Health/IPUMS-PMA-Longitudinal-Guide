[//]: # (Stata-compatible markdown file to adapt the IPUMS PMA March 15, 2022 blog post to feature Stata examples.)
[//]: # (Developed at Biostat Global Consulting [www.biostatglobal.com] by Mia Yu, Caitlin Clary, and Dale Rhoda)
[//]: # (Send questions to Dale.Rhoda@biostatglobal.com)
[//]: # (Updated October 19, 2022)

<<dd_version: 2>>

# Chapter 3 - Longitudinal Data Extracts

When we introduced new harmonized panel data from PMA in our last post, we mentioned that we've made big changes to the [IPUMS PMA website](https://pma.ipums.org/pma/) making it easy to compare women's responses across each phase of data collection. This includes a new option allowing users to choose whether to organize panel data in either **long** or **wide** format. In this post, we'll practice building a data extract in both formats and discuss the advantages of each.

## Getting Started

PMA panel data represent women aged 15-49 from sampled households in eight participating countries. IPUMS PMA makes it possible to combine data from multiple samples from the same unit of analysis: you'll need to select the **Family Planning** topic under the **Person** unit of analysis to begin browsing available samples and variables. 

![select-data_resized](select-data_resized.png)

![unit_resized](unit_resized.png)

## Sample Selection

Once you've selected the **Family Planning** option, you'll next need to choose between cross-sectional or longitudinal samples. Cross-sectional samples are selected by default; these are nationally or sub-nationally representative samples collected each year dating backward as far as 2013.

![cross-sectional_resized](cross-sectional_resized.png)

<aside>
Annual cross-sectional samples are also available for each of the countries participating in the new PMA panel study. See our [last post](../2022-03-01-phase2-discovery/) for details.
</aside>

Longitudinal samples are only available from 2019 onward, and they include all of the available phases for each sampled country (sub-nationally representative samples for DRC and Nigeria are listed separately). You'll only find longitudinal samples for countries where Phase 2 data has been made available; Phase 1 data for Cote d'Ivoire, India, and Uganda can currently be found under the Cross-sectional sample menu (Phase 2 data will be released soon!). 

Clicking the Longitudinal button reveals options for either **long** or **wide** format. You'll find the same samples available in either case:

![long_resized](long_resized.png)

![wide_resized](wide_resized.png)

**Important:** if you decide to change formats after selecting variables, your Data Cart will be emptied and you'll need to begin again from scratch.

![dialogue_resized](dialogue_resized.png)

After you've selected one of the available longitudinal formats, choose one or more samples listed below. There are also several Sample Members options listed:

  * **Female Respondents** only includes women who completed *all or part* of a Female Questionnaire. **This option selects all members of the panel study.** In addition, it includes women who only participated in only one phase - we will demonstrate how to identify and drop these cases below.<a href="#fn1" class="footnote-ref" id="fnref1" role="doc-noteref"><sup>1</sup></a>
  * **Female Respondents and Household Members** adds records for all other members of a Female Respondent's household. These household members did not complete the Female Questionnaire, but were listed on the household roster provided by the respondent to a Household Questionnaire. Basic [demographic](https://internal.pma.ipums.org/pma-action/variables/group?id=hh_roster) variables are available for each household member, as are common [wealth](https://internal.pma.ipums.org/pma-action/variables/group?id=hh_wealth), [water](https://internal.pma.ipums.org/pma-action/variables/group?id=water_watersource), [sanitation](https://internal.pma.ipums.org/pma-action/variables/group?id=water_wash), and other variables shared for all members of the same household.  
  * **Female Respondents and Female Non-respondents** includes all women who were eligible to participate in a Female Questionnaire. Eligible women are those age 15-49 who were listed on the roster collected in a Household Questionnaire. If an eligible woman declined the Female Questionnaire or was not available, variables associated with that questionnaire will be coded "Not interviewed (female questionnaire)".
  * **All Cases** includes all members listed on the household roster from a Household Questionnaire. If the Household Questionnaire was declined or if no respondent was available, any panel member appearing in other phases of the study will be coded "Not interviewed (household questionnaire)" for variables associated with the missing Household Questionnaire. 

<aside>
<a
href="https://pma.ipums.org/pma-action/variables/PANELWOMAN#codes_section">PANELWOMAN</a> indicates whether an individual is a member of the panel study. 

<a
href="https://pma.ipums.org/pma-action/variables/RESULTFQ#codes_section">RESULTFQ</a> indicates whether an individual completed the Female Questionnaire. 

<a
href="https://pma.ipums.org/pma-action/variables/RESIDENT#codes_section">RESIDENT</a> indicates whether an individual is included in the *de facto* population.

<a
href="https://pma.ipums.org/pma-action/variables/ELIGIBLE#codes_section">ELIGIBLE</a> indicates whether an individual was eligible for the female questionnaire.

<a
href="https://pma.ipums.org/pma-action/variables/RESULTHQ#codes_section">RESULTHQ</a> indicates whether a member of the individual's household completed the Household Questionnaire. 
</aside>

![cases_resized](cases_resized.png)

After you've selected samples and sample members for your extract, click the "Submit Sample Selections" button to return to the main data browsing menu.

## Variable Selection

You can browse IPUMS PMA variables by topic or alphabetically by name, or you can [search](https://pma.ipums.org/pma-action/variables/search) for a particular term in a variable name, label, value labels, or description. 

![topics_resized](topics_resized.png)

In this example, we'll select the [Discontinuation of Family Planning](https://pma.ipums.org/pma-action/variables/group?id=fem_fpst) topic. The availability of each associated variable is shown in a table containing all of the samples we've selected. 

  * `X` indicates that the variable is available for *all phases*
  * `/` indicates that the variable is available for *one phase*
  * `-` indicates that the variable is not available for *any phase*
  
You can click the `+` button to add a variable to your cart, or click a variable name to learn more.

![table_resized](table_resized.png)

Let's take a look at the variable [PREGNANT](https://pma.ipums.org/pma-action/variables/PREGNANT#codes_section). You'll find the variable name and label shown at the top of the page. Below, you'll see several tabs beginning with the [CODES](https://pma.ipums.org/pma-action/variables/PREGNANT#codes_section) tab. For discrete variables, this tab shows all of the available codes and value labels associated with each response. You'll also see the same `X`, `/`, and `-` symbols in a table indicating the availability of each response in each sample.

![codes-fr_resized](codes-fr_resized.png)

<aside>
"Case-count view" is not available for longitudinal samples, where each sample includes data from multiple phases. For cross-sectional samples, this option shows the frequency of each response.
</aside>

Above, there are no responses for "Not interviewed (female questionnaire)" and "Not interviewed (household questionnaire)"; this is because only samples members included in a "Female Respondents" extract are displayed by default. If we instead choose "All Cases", this variable will include those response options because we'll include every person listed on the household roster (even if the Household or Female Questionnaire was not completed).

![codes-all_resized](codes-all_resized.png)

The symbol `/` again indicates that a particular response is available for some - but not all - phases of the study. For `PREGNANCY` it indicates that one of the options was either unavailable or was not selected by any sample respondents in a particular phase. If a variable was not included in all phases of the study, all response options will be marked with this symbol. For example, consider the variable [COVIDCONCERN](https://pma.ipums.org/pma-action/variables/COVIDCONCERN#codes_section), indicating the respondent's level of concern about becoming infected with COVID-19.  

![covidconcern_resized](covidconcern_resized.png)

Because Phase 1 questionnaires were administered prior to the emergence of COVID-19, this variable only appeared on Phase 2 questionnaires. The symbol `/` indicates limited availability across phases. 

You'll find a detailed description for each variable on the [DESCRIPTION](https://pma.ipums.org/pma-action/variables/PREGNANT#description_section) tab. This tab also indicates whether a particular question appeared on the Household or Female Questionnaire.

![desc_resized](desc_resized.png)

The [COMPARABILITY](https://pma.ipums.org/pma-action/variables/PREGNANT#comparability_section) tab describes important differences between samples. Additionally, it may contain information about similar variables appearing in [DHS](https://dhsprogram.com/) samples provided by [IPUMS DHS](https://www.idhsdata.org/idhs/). 

![comp_resized](comp_resized.png)

The [UNIVERSE](https://pma.ipums.org/pma-action/variables/PREGNANT#universe_section) tab describes selection criteria for this question. In this case, there are some differences between samples: 

  * In DRC samples, all women aged 15-49 received this question.
  * For all other samples, the question was skipped if any such woman previously indicated that she was menopausal or had a hysterectomy.

![universe_resized](universe_resized.png)

The [AVAILABILITY](https://pma.ipums.org/pma-action/variables/PREGNANT#availability_section) tab shows all other samples (including cross-sectional samples) where this variable is available.

![avail_resized](avail_resized.png)

Finally, you'll find the full text of each question on the [QUESTIONNAIRE TEXT](https://pma.ipums.org/pma-action/variables/PREGNANT#questionnaire_text_section) tab. Each phase of the survey is shown separately, and you may click the "view entire document: text" link to view the complete questionnaire for a particular sample in any given phase.

![question_resized](question_resized.png)

Use the buttons at the top of this page to add the variable to your Data Cart, or to "VIEW CART" and begin checkout. 

![buttons_resized](buttons_resized.png)

## Loading an Extract into Stata

Your Data Cart shows all of the variables you've selected, plus several "preselected" variables that will be automatically included in your extract. Click the "CREATE DATA EXTRACT" button to prepare your download.

![cart_resized](cart_resized.png)

Before you submit an extract request, you'll have the opportunity to choose a "Data Format". You'll notice that data formatted for Stata, SPSS, and SAS are also available. CSV files are provided, but not recommended. (If you wish to change Sample Members, you may do so again here.)

**XXX need to change the image here**

**XXX need to change the image here**

Click "APPLY SELECTIONS" to return to the previous screen. There, you may add a description and then proceed to the download page.

**XXX need to change the image here**

## Long Data Structure

We've downloaded a **long** data extract (Female Respondents only).

~~~~
<<dd_ignore>>

cd "Q:/BMGF - PMA IPUMS FP Blog Posts/Blog2/Blog2 Stata Markdown"

use "pma_00119.dta", clear

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>

cd "Q:/BMGF - PMA IPUMS FP Blog Posts/Blog2/Blog2 Stata Markdown"

use "pma_00119.dta", clear

<</dd_do>>
~~~~ 

In a **long** extract, data from each phase will be organized in *separate rows*. Here, responses from three panel members are shown:

~~~~
<<dd_ignore>>

sort fqinstid phase

list fqinstid phase age panelwoman ///
     if strmatch(fqinstid, "011*") | ///
        strmatch(fqinstid, "015*"), separator(8) noobs
<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>

sort fqinstid phase
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
list fqinstid phase age panelwoman ///
     if strmatch(fqinstid, "011*") | ///
        strmatch(fqinstid, "015*"), separator(8) noobs
<</dd_do>>
~~~~  

Each panel member receives a unique ID shown in [FQINSTID](https://pma.ipums.org/pma-action/variables/FQINSTID#codes_section). The variable [PHASE](https://pma.ipums.org/pma-action/variables/PHASE#codes_section) shows that each woman's responses to the Phase 1 Female Questionnaire appears in the first row, while her Phase 2 responses appear in the second. [AGE](https://pma.ipums.org/pma-action/variables/AGE#codes_section) shows each woman's age when she completed the Female Questionnaire for each phase.

[PANELWOMAN](https://pma.ipums.org/pma-action/variables/PANELWOMAN#codes_section) indicates whether the woman completed all or part of the Female Questionnaire in a *prior* phase, and that she'd agreed to continue participating in the panel study at that time. The value `NA` appears in the rows for Phase 1, as `PANELWOMAN` was not included in Phase 1 surveys. 

We mentioned above that you'll also include responses from some non-panel members when you request an extract with Female Respondents. These include women who did not complete all or part the Female Questionnaire in a prior phase, as indicated by [PANELWOMAN](https://pma.ipums.org/pma-action/variables/PANELWOMAN#codes_section). These women are not assigned a value for [FQINSTID](https://pma.ipums.org/pma-action/variables/FQINSTID#codes_section) - instead, you'll find an empty string:

~~~~
<<dd_ignore>>

gen non_panel = fqinstid == ""
label define fqinstid_blank 0 "fqinstid is not blank" 1 "fqinstid is blank"
label values non_panel fqinstid_blank
label variable panelwoman "Woman in the panel"
table (phase panelwoman) (non_panel), nototals missing

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>

gen non_panel = fqinstid == ""
label define fqinstid_blank 0 "fqinstid is not blank" 1 "fqinstid is blank"
label values non_panel fqinstid_blank
label variable panelwoman "Woman in the panel"
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
table (phase panelwoman) (non_panel), nototals missing
<</dd_do>>
~~~~  

For most longitudinal analysis applications, you'll need to drop non-panel members together with any women who did not fully complete the Phase 2 Female Questionnaire. We'll demonstrate using a combination of `bysort` and `egen` to ensure that there is one row for every FQINSTID where PHASE == 1 and another row where PHASE == 2 & RESULTFQ == 1.

~~~~
<<dd_ignore>>

gen keep = 1 if phase == 1
replace keep = 1 if phase == 2 & resultfq == 1
bysort fqinstid : egen keep_both = sum(keep)
keep if keep_both == 2
drop keep keep_both

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>

gen keep = 1 if phase == 1
replace keep = 1 if phase == 2 & resultfq == 1
bysort fqinstid : egen keep_both = sum(keep)
keep if keep_both == 2
drop keep keep_both

<</dd_do>>
~~~~  

The PMA Longitudinal Briefs published for each sample also include only members of the *de facto* population. These are women who slept in the household during the night prior to the interview for each Household Questionnaire, such that [RESIDENT](https://pma.ipums.org/pma-action/variables/RESIDENT#codes_section) takes the value `11` or `22`. We can use a similar strategy to keep only *de facto* members who appear in both phases.

~~~~
<<dd_ignore>>

gen keep = 1 if phase == 1 & (resident == 11 | resident == 22)
replace keep = 2 if phase == 2 & (resident == 11 | resident == 22)
bysort fqinstid : egen keep_both = sum(keep)
keep if keep_both == 3
drop keep keep_both

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>

gen keep = 1 if phase == 1 & (resident == 11 | resident == 22)
replace keep = 2 if phase == 2 & (resident == 11 | resident == 22)
bysort fqinstid : egen keep_both = sum(keep)
keep if keep_both == 3
drop keep keep_both

<</dd_do>>
~~~~  

Following these steps, you can check the size of each analytic sample like so: 

~~~~
<<dd_ignore>>

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
      
<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>

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
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
table ( pop_numeric ) ( phase) ( ), nototals missing
<</dd_do>>
~~~~

<aside>
Reminder: samples for DRC and Nigeria are sub-nationally representative, so we'll show separate frequencies for each <a href="https://pma.ipums.org/pma-action/variables/GEOCD#codes_section">GEOCD</a> and <a href="https://pma.ipums.org/pma-action/variables/GEONG#codes_section">GEONG</a>.
</aside>

## Wide Data Structure

We've also downloaded a **wide** data extract (Female Respondents only).

In a **wide** extract, all of the responses from one woman appear in the *same row*. The IPUMS extract system appends a numeric suffix to each variable name corresponding with the phase from which it was drawn. Consider our three example panel members again: 

~~~~
<<dd_ignore>>

use "pma_00116.dta", clear

sort fqinstid

list fqinstid age_1 age_2 panelwoman_1 panelwoman_2 ///
     if strmatch(fqinstid, "011*") | ///
        strmatch(fqinstid, "015*"), separator(8) noobs

<</dd_ignore>>
~~~~

~~~~
<<dd_do: quietly>>

use "pma_00116.dta", clear

sort fqinstid
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
list fqinstid age_1 age_2 panelwoman_1 panelwoman_2 ///
     if strmatch(fqinstid, "011*") | ///
        strmatch(fqinstid, "015*"), separator(8) noobs
<</dd_do>>
~~~~

Each panel member has one unique ID shown in [FQINSTID](https://pma.ipums.org/pma-action/variables/FQINSTID#codes_section). However, [AGE](https://pma.ipums.org/pma-action/variables/AGE#codes_section) is parsed into two columns: `AGE_1` shows each woman's age at Phase 1, and `AGE_2` shows her age at Phase 2.

As we've discussed, [PANELWOMAN](https://pma.ipums.org/pma-action/variables/PANELWOMAN#codes_section) is not available for Phase 1, as it indicates whether the woman completed all or part of the Female Questionnaire in a *prior* phase. For this reason, all values in `PANELWOMAN_1` are missing. Most variables are copied once for each phase, even if they - like `PANELWOMAN_1` - are not available for all phases. 

You might expect the total length of a **wide** extract to be half the length of a corresponding **long** extract. This is not the case! A **wide** extract includes one row for each woman who completed all or part of the Female Questionnaire *for any phase* - you'll find placeholder columns for phases where the interview was not conducted. 

~~~~
<<dd_ignore>>

list resultfq_1 age_1 resultfq_2 age_2 ///
     if fqinstid == "0C8VQU6B03BXLAVVZ8SB90EKQ", noobs

<</dd_ignore>>
~~~~

~~~~
<<dd_do>>
list resultfq_1 age_1 resultfq_2 age_2 ///
     if fqinstid == "0C8VQU6B03BXLAVVZ8SB90EKQ", noobs
<</dd_do>>
~~~~

In a **long** extract, rows for the missing phase are dropped. In this example, the woman was "not at home" for the Phase 2 Female Questionnaire. When we select a **long** extract containing only Female Respondents, her Phase 2 row is excluded automatically (it will be included if you request an extract containing Female Respondents and Female Non-respondents). 

~~~~
<<dd_ignore>>

use "pma_00119.dta", clear
list phase age resultfq ///
     if fqinstid == "0C8VQU6B03BXLAVVZ8SB90EKQ", noobs

<</dd_ignore>>
~~~~

~~~~
<<dd_do: quietly>>

use "pma_00119.dta", clear
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
list phase age resultfq ///
     if fqinstid == "0C8VQU6B03BXLAVVZ8SB90EKQ", noobs
<</dd_do>>
~~~~

Again: for most longitudinal analysis applications, you'll need to remove cases where women were not interviewed for Phase 1 or where the Phase 2 Female Questionnaire was not completed:

~~~~
<<dd_ignore>>

use "pma_00116.dta", clear
keep if resultfq_2 == 1 & resultfq_1 != .

<</dd_ignore>>
~~~~

~~~~
<<dd_do: quietly>>

use "pma_00116.dta", clear
keep if resultfq_2 == 1 & resultfq_1 != .

<</dd_do>>
~~~~

The *de facto* population appearing in PMA Longitudinal Briefs is defined in **wide** extracts by cases where the values `11` or `12` appear in *both* `RESIDENT_1` and `RESIDENT_2`:

~~~~
<<dd_ignore>>

keep if inlist(resident_1, 11, 22)
keep if inlist(resident_2, 11, 22)

<</dd_ignore>>
~~~~

~~~~
<<dd_do: quietly>>

keep if inlist(resident_1, 11, 22)
keep if inlist(resident_2, 11, 22)

<</dd_do>>
~~~~

Following these steps, each analytic sample contains the same number of cases shown in the final **long** format extract above. 

~~~~
<<dd_ignore>>

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

<</dd_ignore>>
~~~~

~~~~
<<dd_do: quietly>>

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
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
table ( pop_numeric ) ( ), nototals missing
<</dd_do>>
~~~~

## Which format is best for me? 

The choice between **long** and **wide** formats ultimately depends on your research objectives.

Many data manipulation tasks, for example, are faster and easier to perform in the **wide** format. In the example above, we needed to identify women who completed a Female Questionnaire and were members of the *de facto* population in both phases. In the long format, we first had to use bysort and egen and keep to pare the dataset down to women with good data for both phases.

On the other hand, some of the longitudinal analysis commands require data to be in a long format - this includes both the suite of so-called `st' [commands for time-to-event or survival analysis](https://www.stata.com/manuals/st.pdf) and the suite of so-called `xt` commands for [analyzing panel data](https://www.stata.com/manuals/xt.pdf). Users who prefer the wide format for data cleaning and exploration can manually switch to long format with help from Stata's `reshape` command, for example:

~~~~
<<dd_ignore>>

use "pma_00116.dta", clear
keep if resultfq_2 == 1 & resultfq_1 != .

keep if inlist(resident_1, 11, 22)
keep if inlist(resident_2, 11, 22)

keep fqinstid age_1 pregnant_1 age_2 pregnant_2

reshape long age_ pregnant_ , i(fqinstid) j(phase)
rename age_ age
rename pregnant_ pregnant

<</dd_ignore>>
~~~~

~~~~
<<dd_do: quietly>>

use "pma_00116.dta", clear
keep if resultfq_2 == 1 & resultfq_1 != .

keep if inlist(resident_1, 11, 22)
keep if inlist(resident_2, 11, 22)

keep fqinstid age_1 pregnant_1 age_2 pregnant_2

<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
reshape long age_ pregnant_ , i(fqinstid) j(phase)
rename age_ age
rename pregnant_ pregnant
<</dd_do>>
~~~~

<aside>
For more examples using `reshape`, check out the chapters on contraceptive calendar and migration data (Chapters XXX and XXX respectively)!
</aside>

Executing the `reshape` command with more variables takes practice, and we imagine many users will find it easier to simply work with data in the long format from the beginning.  If you want to become adept at converting between long and wide formats, consult the [Stata documentation](https://www.stata.com/manuals/dreshape.pdf) or watch some of the numerous tutorials on the `reshape` command available on YouTube.

Fortunately, the updated IPUMS PMA extract system makes it easy to select the samples, sample members, and variables that matter to your particular research question. New choices for **long** and **wide** data formats save an additional data cleaning step, allowing you to jump into longitudinal analysis as quickly as possible. 

<section class="footnotes" role="doc-endnotes">
<hr />
<ol>
<li id="fn1" role="doc-endnote"><p>Women who completed all or part of the Female Questionnaire in <em>more than one phase</em> of the study are considered <strong>panel members</strong>. Women who completed it only at Phase 1 are included in a longitudinal extract, but they are not <strong>panel members</strong>. Likewise, women who completed it for the first time at Phase 2 are included, but are not <strong>panel members</strong> if they 1) will reach age 50 before Phase 3, or 2) declined the invitation to participate again in Phase 3.<a href="#fnref1" class="footnote-back" role="doc-backlink">↩︎</a></p></li>
</ol>
</section>
