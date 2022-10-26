[//]: # (Stata-compatible markdown file to adapt the IPUMS PMA March 1, 2022 blog post to feature Stata examples.)
[//]: # (Developed at Biostat Global Consulting [www.biostatglobal.com] by Mia Yu, Caitlin Clary, and Dale Rhoda)
[//]: # (Send questions to Dale.Rhoda@biostatglobal.com)
[//]: # (Updated October 19, 2022)

<<dd_version: 2>>

  
  <meta name="citation_reference" content="citation_title=Evaluating Confidence Interval Methods for Binomial Proportions in Clustered Surveys;citation_publication_date=2015;citation_volume=3;citation_doi=10.1093/jssam/smv024;citation_issn=2325-0984;citation_author=Natalie Dean;citation_author=Marcello Pagano"/>


# Family Planning Panel Data Now Available from IPUMS PMA

## Background

Dating back to 2013, the original PMA survey design included high-frequency, **cross-sectional** samples of women and service delivery points collected from eleven countries participating in [Family Planning 2020](http://progress.familyplanning2020.org/) (FP2020) - a global partnership that supports the rights of women and girls to decide for themselves whether, when, and how many children they want to have. These surveys were designed to monitor annual progress towards [FP2020 goals](http://progress.familyplanning2020.org/measurement) via population-level estimates for several [core indicators](http://www.track20.org/pages/data_analysis/core_indicators/overview.php). 

Beginning in 2019, PMA surveys were redesigned under a renewed partnership called [Family Planning 2030](https://fp2030.org/) (FP2030). These new surveys have been refocused on reproductive and sexual health indicators, and they feature a **longitudinal panel** of women of childbearing age. This design will allow researchers to measure contraceptive dynamics and changes in women's fertility intentions over a **three year period** via annual in-person interviews.<a href="#fn1" class="footnote-ref" id="fnref1" role="doc-noteref"><sup>1</sup></a>

Questions on the redesigned survey cover topics like:

  * awareness, perception, knowledge, and use of contraceptive methods
  * perceived quality and side effects of contraceptive methods among current users
  * birth history and fertility intentions 
  * aspects of health service provision 
  * domains of empowerment 
  
## Sampling 

PMA panel data includes a mixture of **nationally representative** and **sub-nationally representative** samples from eight participating countries. The panel study consists of three data collection phases, each spaced one year apart. IPUMS PMA has released data from the first *two* phases for countries where Phase 1 data collection began in 2019; we have released data from only the *first* phase for countries where Phase 1 data collection began in August or September 2020. Phase 3 data collection and processing is currently underway. 

** XXX - Insert blog post table here **

PMA uses a multi-stage clustered sample design, with stratification at the urban-rural level or by sub-region. Geographically defined sample clusters - called [enumeration areas](https://pma.ipums.org/pma-action/variables/EAID#description_section) (EAs) -- are provided by the national statistics agency in each country.<a href="#fn2" class="footnote-ref" id="fnref2" role="doc-noteref"><sup>2</sup></a> These EAs are sampled using a *probability proportional to size* (PPS) method relative to the population distribution in each stratum.

At Phase 1, 35 household dwellings were selected at random within each EA. Resident enumerators visited each dwelling and invited one household member to complete a [Household Questionnaire](https://pma.ipums.org/pma/resources/questionnaires/hhf/PMA-Household-Questionnaire-English-2019.10.09.pdf)<a href="#fn3" class="footnote-ref" id="fnref3"
role="doc-noteref"><sup>3</sup></a> that includes a census of all household members and visitors who stayed there during the night before the interview. Female household members and visitors aged 15-49 were then invited to complete a subsequent Phase 1 [Female Questionnaire](https://pma.ipums.org/pma/resources/questionnaires/hhf/PMA-Female-Questionnaire-English-2019.10.09.pdf).<a href="#fn4" class="footnote-ref" id="fnref4"
role="doc-noteref"><sup>4</sup></a>

<aside>
Questionnaires are administered in-person by <strong>resident
enumerators</strong> visiting selected households in each EA. These are
typically women over age 21 living in (or near) each EA and who hold at
least a high school diploma.
</aside>

One year later, resident enumerators visited the same dwellings and administered a Phase 2 Household Questionnaire. A panel member in Phase 2 is any woman still age 15-49 who could be reached for a second Female Questionnaire, either because:

  * she still lived there, or
  * she had moved elsewhere within the study area,<a href="#fn5"
class="footnote-ref" id="fnref5" role="doc-noteref"><sup>5</sup></a> but at least one member of the Phase 1 household remained and could help resident enumerators locate her new dwelling.<a href="#fn6" class="footnote-ref" id="fnref6" role="doc-noteref"><sup>6</sup></a>

<aside>
<a
href="https://pma.ipums.org/pma-action/variables/SAMEDWELLING#codes_section">SAMEDWELLING</a>
indicates whether a Phase 2 female respondent resided in her Phase 1
dwelling or a new one.
</aside>

Additionally, resident enumerators administered the Phase 2 Female Questionnaire to *new* women in sampled households who:

  * reached age 15 after Phase 1
  * joined the household after Phase 1
  * declined the Female Questionnaire at Phase 1, but agreed to complete it at Phase 2

<aside>
<a
href="https://pma.ipums.org/pma-action/variables/PANELWOMAN#codes_section">PANELWOMAN</a>
indicates whether a Phase 2 household member completed the Phase 1
Female Questionnaire.
</aside>

When you select the new **Longitudinal** sample option at checkout, you'll be able to include responses from every available phase of the study. These samples are available in either "long" format (responses from each phase will be organized in separate rows) or "wide" format (responses from each phase will be organized in columns).

![long_radio_resized](long_radio_resized.png)

In addition to following up with women in the panel over time, PMA also adjusted sampling so that a cross-sectional sample could be produced concurrently with each data collection phase. These samples mainly overlap with the data you'll obtain for a particular phase in the longitudinal sample, except that replacement households were drawn from each EA where more than 10% of households from the previous phase were no longer there. Conversely, panel members who were located in a new dwelling at Phase 2 will not be represented in the cross-sectional sample drawn from that EA. These adjustments ensure that population-level indicators may be derived from cross-sectional samples in a given year, even if panel members move or are lost to follow-up. 

<aside>
<p><a
href="https://pma.ipums.org/pma-action/variables/CROSS_SECTION#codes_section">CROSS_SECTION</a>
indicates whether a household member in a longitudinal sample is also
included in the cross-sectional sample for a given year (every person in
a cross-sectional sample is included in the longitudinal sample).</p>
We'll cover <strong>sample composition</strong> in much greater detail
in an upcoming chapter. ** XXX - Mention which chapter **
</aside>

You'll find PMA cross-sectional samples dating back to 2013 if you select the **Cross-sectional** sample option at checkout. 

![cross_radio_resized](cross_radio_resized.png)

## Survey Design Elements
In upcoming chapters, we'll demonstrate how to incorporate PMA sampling weights and information about its stratified cluster sampling procedure into your analysis.

Whether you intend to work with a new **Longitudinal** or **Cross-sectional** data extract, you'll find the same set of sampling weights available for all PMA Family Planning surveys dating back to 2013.<a href="#fn7" class="footnote-ref" id="fnref7" role="doc-noteref"><sup>7</sup></a> 
 
  * [HQWEIGHT](https://pma.ipums.org/pma-action/variables/HQWEIGHT#description_section) can be used to generate cross-sectional population estimates from questions on the Household Questionnaire.<a href="#fn8" class="footnote-ref" id="fnref8" role="doc-noteref"><sup>8</sup></a>
  * [FQWEIGHT](https://pma.ipums.org/pma-action/variables/FQWEIGHT#description_section) can be used to to generate cross-sectional population estimates from questions on the Female Questionnaire.<a href="#fn9" class="footnote-ref" id="fnref9" role="doc-noteref"><sup>9</sup></a>
  * [EAWEIGHT](https://pma.ipums.org/pma-action/variables/EAWEIGHT#description_section) can be used to compare the selection probability of a particular household with that of its EA.

<aside>
A fourth Family Planning survey weight, [POPWT](https://pma.ipums.org/pma-action/variables/POPWT#description_section), is currently available only for **Cross-sectional** data extracts and Phase 1 panel data.<a href="#fn10" class="footnote-ref"
id="fnref10" role="doc-noteref"><sup>10</sup></a>
</aside>

Additionally, PMA created a new weight, [PANELWEIGHT](https://pma.ipums.org/pma-action/variables/PANELWEIGHT#description_section), 
which should be used in longitudinal analyses spanning multiple phases, as it adjusts for loss to follow-up. `PANELWEIGHT` is available only for **Longitudinal** data extracts. 

For example, suppose we wanted to estimate the proportion of reproductive age women in Burkina Faso who were using contraception at the time of data collection for both Phase 1 and Phase 2. In a cross-sectional or "long" longitudinal extract, you'll find this information in the variable `CP`. In a "wide" longitudinal extract, you'll find it in `CP_1` for Phase 1, and in `CP_2` for Phase 2. We'll be working with a "wide" extract loaded into Stata.  This code restricts the dataset to the women we are interested in, and counts the number of respondents in who were known to be using contraceptives in both Phases 1 and 2.

<aside>
Variable names in a "wide" extract have a numeric suffix corresponding
with a data collection phase. <code>CP_1</code> is the Phase 1 version
of <a
href="https://pma.ipums.org/pma-action/variables/CP#codes_section">CP</a>,
while <code>CP_2</code> comes from Phase 2.
</aside>

~~~~
<<dd_ignore>>

cd "Q:/BMGF - PMA IPUMS FP Blog Posts/Blog1/Blog1 Stata Markdown"

use "pma_00126.dta", clear

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

label variable cp_1    "Contraceptive user (Phase 1)"
label variable cp_2    "Contraceptive user (Phase 2)"

keep if of_interest_both

table ( cp_1 ) ( cp_2 ) (), nototals missing zerocounts
<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>

cd "Q:/BMGF - PMA IPUMS FP Blog Posts/Blog1/Blog1 Stata Markdown"

use "pma_00126.dta", clear

* In BF Phase 1, and had female questionnaire at least partly completed & 
* under age 49 & usual resident who slept here last night
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
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
table ( cp_1 ) ( cp_2 ) (), nototals missing zerocounts
<</dd_do>>
~~~~

To go beyond counts and estimate a population percentage, we will need to tell Stata that we are working with a sample survey dataset and stipulate the sample design (specify which variables identify strata and clusters) and where to find the survey weights.  This is accomplished with the [svyset](https://www.stata.com/manuals/svysvyset.pdf) command.

We use `eaid_1` as the cluster ID<a href="#fn13" class="footnote-ref" id="fnref13" role="doc-noteref"><sup>13</sup></a> and `strata_1` as the stratum ID<a href="#fn14" class="footnote-ref" id="fnref14" role="doc-noteref"><sup>14</sup></a> and `panelweight' holds the survey weight.

We also generate a binary 0/1 variable that indicates which women were using contraception in both Phase 1 and 2.

~~~~
<<dd_ignore>>

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

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>

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

<</dd_do>>

<<dd_do>>
svyset eaid_1, strata(strata_1) weight(panelweight) 
svy: proportion cp_both
<</dd_do>>
~~~~

This is our first look at Stata's output for estimating proportions.  The top of the output table lists the number of strata and the number of PSUs in the dataset, along with the number of respondents in the sample and the sum of their weights (under the heading: Population size).  The number of design degrees of freedom (df) is the number of PSUs minus the number of strata.<a href="#fn15" class="footnote-ref" id="fnref15" role="doc-noteref"><sup>15</sup></a>  

The lower portion of the table lists the values of the outcome variable, or in this case their value labels: No and Yes.  It lists the proportion of the population that are estimated to have each outcome, that proportion's standard error, and a two-sided survey-adjusted confidence interval for the proportion.

Stata's default confidence interval is the so-called "logit interval" which is one of several possibilities.<a
href="#fn11" class="footnote-ref" id="fnref11"
role="doc-noteref"><sup>11</sup></a> For now we will simply say that the default logit interval is a fine choice for most circumstances.    To request a different kind of confidence interval, read about the options and specify what you want using the `citype()` option to the `svy: proportion` command (e.g., `citype(wilson)` or `citype(exact)`).

To describe this output in an English language sentence, we might say something like: "Based on this survey sample of 5,207 women from Burkina Faso, we estimate that if the surveys were free from bias then about 18.8% women who were eligible to be sampled in the PMA surveys would be self-reported users of contraception in both Phases 1 and 2 (95% CI: 16.4-21.4%)."  

With survey data collected from using a complex sample design that employs strata and/or clusters, we sometimes like to report the **design effect** which is an index of the statistical precision penalty that we pay for using that sample design.  In Stata, we can see the design effect by issuing the following post-estimation command [estat effects](https://www.stata.com/manuals/svysvypostestimation.pdf)

~~~~
<<dd_ignore>>
* Calculate the design effect for the most recent estimation
estat effects
<</dd_ignore>>
~~~~
&nbsp;
~~~~
<<dd_do>>
* Calculate the design effect for the most recent estimation
estat effects
<</dd_do>>
~~~~~

We see that the design effect (DEFF) is 5.6, which we might interpret by saying "The confidence interval for this estimation is as wide as we would expect from a simple random sample of this sample size (5,207) divided by 5.6 or about 929 respondents."  

The DEFT is the square root of DEFF and we might use it in a sentence thus: "Because of the complex sample design and heterogeneity of survey weights, the confidence interval for this estimation is 2.4 times wider than we would expect from a simple random sample of size 5,207 respondents."

The figure 929 is sometimes called the **effective sample size**.  

Let's take a moment and estimate proportions from two simple random samples where 18.8% of the respondents have the outcome: one where the sample size is 5,207 and one where the sample size is 929.  We can do this by generating an empty dataset with the appropriate number of respondents and a binary variable named y.

~~~~
<<dd_ignore>>

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

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>
* Generate a dataset of a simple random sample of 5,207 respondents where
* 18.8% have the outcome and estimate the proportion;

clear
set obs 5207
gen y = 0
replace y = 1 if _n < 0.188 * 5207
tab y
svyset _n
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
svy: proportion y
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do : quietly>>
* Generate a dataset of a simple random sample of 929 respondents where
* 18.8% have the outcome and estimate the proportion;

clear
set obs 929
gen y = 0
replace y = 1 if _n < 0.188 * 929
tab y
svyset _n
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
svy: proportion y
<</dd_do>>
~~~~

Now let's compare the CI width from the simple random sample with N=5,207 with that from the complex sample with N=5,207.

~~~~
<<dd_ignore>>
* Now examine the complex data 95% CI width divided by the 
* simple random sample of 5,207 95% CI width and see that it is ~= DEFT

di (.2144-.1638) / (.1987-.1774)
<</dd_ignore>>
~~~~

~~~~
<<dd_do>>
* Now examine the complex data 95% CI width divided by the 
* simple random sample of 5,207 95% CI width and see that it is ~= DEFT

di (.2144-.1638) / (.1987-.1774)
<</dd_do>>
~~~~~

It can be disheartening to know that the teams did all the work to  interview 5,207 respondents and yet for this estimation that sample only has the statistical precision of a simple random sample of 929 respondents.  The statistical penalty is because of both a clustering effect -- spatial heterogeneity in the outcome across PSUs -- and because of heterogeneity in the survey weights.  In some survey reporting contexts you will be expected to report either DEFF or DEFT, or both.  Be clear about which one you are reporting.  The design effect will vary across outcomes, across strata, and across PMA Phases, so if it is of interest, estimate it anew for each analysis.  You can learn more about the survey design effect in materials on survey sampling statistics.  **See Section [XXX].**

** Consider adding a short section on organ pipe plots. **

This syntax and `svyset` command worked well for Burkina Faso, but take note: the variable [STRATA](https://pma.ipums.org/pma-action/variables/STRATA#codes_section) is *not available* for samples collected from DRC - Kinshasa or DRC - Kongo Central.  If your extract includes any DRC sample, you'll need to amend this variable to include a unique numeric code for each of those regions.    

For example, let's look at a different wide extract, containing all of the samples included in this data release. Notice that `STRATA_1` lists the sample strata for all values of [COUNTRY](https://pma.ipums.org/pma-action/variables/COUNTRY#codes_section) *except* for DRC, where the variable is missing. 

~~~~
<<dd_ignore>>

use "pma_00153.dta", clear

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
      
<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>

use "pma_00153.dta", clear

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
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
table ( strata_1 ) () ( country ) if of_interest_both, ///
      nototals missing zerocounts
<</dd_do>>
~~~~

We can replace those values with numeric codes from the variable [GEOCD](https://pma.ipums.org/pma-action/variables/GEOCD#codes_section): 

~~~~
<<dd_ignore>>
table ( geocd ) if country == 2, nototals missing zerocounts

tab geocd
tab geocd, nolabel
<</dd_ignore>>
~~~~

~~~~
<<dd_do>>
table ( geocd ) if country == 2, nototals missing zerocounts

tab geocd
tab geocd, nolabel
<</dd_do>>
~~~~

If `GEOCD` is not missing, we'll use its numeric code in place of `STRATA_1`. Otherwise, we'd like to leave `STRATA_1` unchanged. To avoid confusion with the original variable `STRATA_1`, we'll call our new variable `STRATA_RECODE`.

~~~~
<<dd_ignore>>

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

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>

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
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
tab strata_recode, m
<</dd_do>>
~~~~

Now, we can use `STRATA_RECODE` with the `svyset` command to obtain population estimates for each nationally representative or sub-nationally representative sample.

~~~~
<<dd_ignore>>

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

gen pop_numeric = .
replace pop_numeric = 1 if country == 1              // Burkina Faso
replace pop_numeric = 2 if country == 2 & geocd == 1 // Kinshasa
replace pop_numeric = 3 if country == 2 & geocd == 2 // Kongo Central
replace pop_numeric = 4 if country == 7              // Kenya
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

svy : proportion cp_both , over(pop_numeric) 

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>

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

gen pop_numeric = .
replace pop_numeric = 1 if country == 1              // Burkina Faso
replace pop_numeric = 2 if country == 2 & geocd == 1 // Kinshasa
replace pop_numeric = 3 if country == 2 & geocd == 2 // Kongo Central
replace pop_numeric = 4 if country == 7              // Kenya
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
svy : proportion cp_both , over(pop_numeric) 
<</dd_do>>
~~~~

## Inclusion Criteria for Analysis 

In the remainder of this manual, we'll be showcasing code you can use to reproduce key indicators included in the **PMA Longitudinal Brief** for each sample. In many cases, you'll find separate reports available in English and French, and for both national and sub-national summaries. For reference, here are the highest-level population summaries available in English for each sample where Phase 2 IPUMS PMA data is currently available:

  * [Burkina Faso](https://www.pmadata.org/sites/default/files/data_product_results/Burkina%20National_Phase%202_Panel_Results%20Brief_English_Final.pdf)
  * [DRC - Kinshasa](https://www.pmadata.org/sites/default/files/data_product_results/DRC%20Kinshasa_%20Phase%202%20Panel%20Results%20Brief_English_Final.pdf)
  * [DRC - Kongo Central](https://www.pmadata.org/sites/default/files/data_product_results/DRC%20Kongo%20Central_%20Phase%202%20Panel%20Results%20Brief_English_Final.pdf)
  * [Kenya](https://www.pmadata.org/sites/default/files/data_product_results/Kenya%20National_Phase%202_Panel%20Results%20Brief_Final.pdf)
  * [Nigeria - Kano](https://www.pmadata.org/sites/default/files/data_product_results/Nigeria%20KANO_Phase%202_Panel_Results%20Brief_Final.pdf)
  * [Nigeria - Lagos](https://www.pmadata.org/sites/default/files/data_product_results/Nigeria%20LAGOS_Phase%202_Panel_Results%20Brief_Final.pdf) 

Panel data in these reports is limited to the *de facto* population of women who completed the Female Questionnaire in both Phase 1 and Phase 2. This includes women who slept in the household during the night before the interview for the Household Questionnaire. The *de jure* population includes women who are usual household members, but who slept elsewhere that night. We will remove *de jure* cases recorded in the variable [RESIDENT](https://pma.ipums.org/pma-action/variables/RESIDENT#codes_section). 

<aside>
Missing data in <code>RESIDENT_2</code> represent women who
were lost to follow-up in Phase 2.
</aside>

For example, returning to our "wide" data extract for Burkina Faso, you can see the number of women who slept in the household before the Household Questionnaire for each phase reported in `RESIDENT_1` and `RESIDENT_2`: 

~~~~
<<dd_ignore>>

use "pma_00126.dta", clear

keep if sample_1 == 85409

table ( resident_1 ) () (), nototals missing zerocounts
table ( resident_2 ) () (), nototals missing zerocounts

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>
use "pma_00126.dta", clear

keep if sample_1 == 85409

<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
table ( resident_1 ) () (), nototals missing zerocounts
table ( resident_2 ) () (), nototals missing zerocounts
<</dd_do>>
~~~~

The *de facto* population is represented in codes 11 and 22. We will use an `if` statement or `keep` statement to include only those cases.

~~~~
<<dd_ignore>>

keep if inlist(resident_1,11,22) & inlist(resident_2,11,22)
label variable resident_1 "Resident type - Phase 1"
label variable resident_2 "Resident type - Phase 2"
label define RESIDENT_1 11 "Visitor" 22 "Usual", modify
label define RESIDENT_2 11 "Visitor" 22 "Usual", modify

table ( resident_1 ) ( resident_2 ) (), nototals missing zerocounts

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>

keep if inlist(resident_1,11,22) & inlist(resident_2,11,22)
label variable resident_1 "Resident type - Phase 1"
label variable resident_2 "Resident type - Phase 2"
label define RESIDENT_1 11 "Visitor" 22 "Usual", modify
label define RESIDENT_2 11 "Visitor" 22 "Usual", modify
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
table ( resident_1 ) ( resident_2 ) (), nototals missing zerocounts
<</dd_do>>
~~~~

Additionally, these reports only include women who completed (or partially completed) both Female Questionnaires. This information is reported in [RESULTFQ](https://pma.ipums.org/pma-action/variables/RESULTFQ#codes_section). In our "wide" extract, this information appears in `RESULTFQ_1` and `RESULTFQ_2`: if you select the "Female Respondents" option at checkout, only women who completed (or partially completed) the Phase 1 Female Questionnaire will be included in your extract.

![cases_resized](cases_resized.png)

We'll further restrict our sample by selecting only cases where `RESULTFQ_2` shows that the woman also completed the Phase 2 questionnaire. Notice that, in addition to each of the value 1 through 10, there are several non-response codes numbered 90 through 99. You'll see similar values repeated across all IPUMS PMA variables, except that they will be left-padded to match the maximum width of a particular variable (e.g. 9999 is used for INTFQYEAR, which represents a 4-digit year for the Female Interview).

~~~~
<<dd_ignore>>

use "pma_00126.dta", clear

keep if sample_1 == 85409

tab resultfq_2, m

label list RESULTFQ_2

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>
use "pma_00126.dta", clear

keep if sample_1 == 85409

tab resultfq_2, m

<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
label list RESULTFQ_2
<</dd_do>>
~~~~

Possible **non-response codes** include: 

  * `95` Not interviewed (female questionnaire)
  * `96` Not interviewed (household questionnaire)
  * `97` Don't know
  * `98` No response or missing 
  * `99` NIU (not in universe)

A missing value in an IPUMS extract indicates that a particular variable is not provided for a selected sample. In a "wide" **Longitudinal** extract, it may also signify that a particular person was not included in the data from a particular phase. Here, an missing result in `RESULTFQ_2` indicates that a Female Respondent from Phase 1 was not found in Phase 2.

You can drop incomplete Phase 2 female responses as follows: 

~~~~
<<dd_ignore>>

use "pma_00126.dta", clear

keep if sample_1 == 85409

keep if resultfq_2 == 1

tab resultfq_1 resultfq_2,m

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>
use "pma_00126.dta", clear

keep if sample_1 == 85409

keep if resultfq_2 == 1
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
tab resultfq_1 resultfq_2,m
<</dd_do>>
~~~~

Generally, we will combine both filtering steps together in a single function like so:

~~~~
<<dd_ignore>>

use "pma_00126.dta", clear

keep if sample_1 == 85409

keep if inlist(resident_1,11,22) & inlist(resident_2,11,22) & resultfq_2  == 1

tab resultfq_1 resultfq_2,m

<</dd_ignore>>
~~~~

~~~~
<<dd_do : quietly>>
use "pma_00126.dta", clear

keep if sample_1 == 85409

keep if inlist(resident_1,11,22) & inlist(resident_2,11,22) & resultfq_2  == 1
<</dd_do>>
~~~~
&nbsp;
~~~~
<<dd_do>>
tab resultfq_1 resultfq_2,m
<</dd_do>>
~~~~

In upcoming chapters, we'll use the remaining cases to show how PMA generates key indicators for **contraceptive use status** and **family planning intentions and outcomes**. The summary report for each country includes measures disaggregated by demographic variables like:

  * [MARSTAT](https://pma.ipums.org/pma-action/variables/MARSTAT#codes_section) - marital status 
  * [EDUCATT](https://pma.ipums.org/pma-action/variables/EDUCATT#codes_section) and [EDUCATTGEN](https://pma.ipums.org/pma-action/variables/EDUCATTGEN#codes_section) - highest attended level of education<a href="#fn16" class="footnote-ref" id="fnref16" role="doc-noteref"><sup>16</sup></a>
  * [AGE](https://pma.ipums.org/pma-action/variables/AGE#codes_section) - age<a href="#fn17" class="footnote-ref" id="fnref17"
role="doc-noteref"><sup>17</sup></a>
  * [WEALTHQ](https://pma.ipums.org/pma-action/variables/WEALTHQ#codes_section) and [WEALTHT](https://pma.ipums.org/pma-action/variables/WEALTHT#codes_section) - household wealth quintile or tertile<a href="#fn18" class="footnote-ref" id="fnref18" role="doc-noteref"><sup>18</sup></a>
  * [URBAN](https://pma.ipums.org/pma-action/variables/URBAN#codes_section) and [SUBNATIONAL](https://pma.ipums.org/pma-action/variables/SUBNATIONAL#codes_section) - geographic location<a href="#fn19" class="footnote-ref" id="fnref19" role="doc-noteref"><sup>19</sup></a>


<div class="sourceCode" id="cb15"><pre
class="sourceCode r distill-force-highlighting-css"><code class="sourceCode r"></code></pre></div>
<div id="refs" class="references csl-bib-body hanging-indent"
role="doc-bibliography">
<div id="ref-Dean-Pagano" class="csl-entry" role="doc-biblioentry">
Dean, Natalie, and Marcello Pagano. 2015. <span>“<span
class="nocase">Evaluating Confidence Interval Methods for Binomial
Proportions in Clustered Surveys</span>.”</span> <em>Journal of Survey
Statistics and Methodology</em> 3 (4): 484–503. <a
href="https://doi.org/10.1093/jssam/smv024">https://doi.org/10.1093/jssam/smv024</a>.
</div>
</div>
<section class="footnotes footnotes-end-of-document" role="doc-endnotes">

<ol>
<li id="fn1" role="doc-endnote"><p>In addition to these three in-person
surveys, PMA also conducted telephone interviews with panel members
focused on emerging issues related to the COVID-19 pandemic in 2020.
These telephone surveys are already available for several countries -
see our series on <a href="../../index.html#category:COVID-19">PMA
COVID-19 surveys</a> for details.<a href="#fnref1" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn2" role="doc-endnote"><p><a
href="https://tech.popdata.org/pma-data-hub/posts/2021-10-15-nutrition-climate/PMA_displacement.pdf">Displaced
GPS coordinates</a> for the centroid of each EA are available for most
samples <a
href="https://www.pmadata.org/data/request-access-datasets">by
request</a> from PMA. IPUMS PMA provides shapefiles for PMA countries <a
href="https://pma.ipums.org/pma/gis_boundary_files.shtml">here</a>.<a
href="#fnref2" class="footnote-back" role="doc-backlink">↩︎</a></p></li>
<li id="fn3" role="doc-endnote"><p>Questionnaires administered in each
country may vary from this <strong>Core Household Questionnaire</strong>
- <a href="https://pma.ipums.org/pma/enum_materials.shtml">click
here</a> for details.<a href="#fnref3" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn4" role="doc-endnote"><p>Questionnaires administered in each
country may vary from this <strong>Core Female Questionnaire</strong> -
<a href="https://pma.ipums.org/pma/enum_materials.shtml">click here</a>
for details.<a href="#fnref4" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn5" role="doc-endnote"><p>The “study area” is area within which
resident enumerators should attempt to find panel women that have moved
out of their Phase 1 dwelling. This may extend beyond the woman’s
original EA as determined by in-country administrators - see <a
href="https://www.pmadata.org/data/survey-methodology">PMA Phase 2 and
Phase 3 Survey Protocol</a> for details.<a href="#fnref5"
class="footnote-back" role="doc-backlink">↩︎</a></p></li>
<li id="fn6" role="doc-endnote"><p>In cases where no Phase 1 household
members remained in the dwelling at Phase 2, women from the household
are considered lost to follow-up (LTFU). A panel member is also
considered LTFU if a Phase 2 Household Questionnaire was not completed,
if she declined to participate, or if she was deceased or otherwise
unavailable.<a href="#fnref6" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn7" role="doc-endnote"><p>For thorough discussion of the
types of weights available in both R and Stata, we recommend <a
href="https://notstatschat.rbind.io/2020/08/04/weights-in-statistics/">this
blog post</a> by Dr. Lumley.<a href="#fnref7" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn8" role="doc-endnote"><p><code>HQWEIGHT</code> reflects the <a
href="https://pma.ipums.org/pma/resources/documentation/weighting_memo.pdf">calculated
selection probability</a> for a household in an EA, normalized at the
population-level. Users intending to estimate population-level
indicators for <em>households</em> should restrict their sample to one
person per household via <a
href="https://pma.ipums.org/pma-action/variables/LINENO#description_section">LINENO</a>
- see <a href="https://pma.ipums.org/pma/weightguide.shtml#hh">household
weighting guide</a> for details.<a href="#fnref8" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn9" role="doc-endnote"><p><code>FQWEIGHT</code> adjusts
<code>HQWEIGHT</code> for female non-response within the EA, normalized
at the population-level - see <a
href="https://pma.ipums.org/pma/weightguide.shtml#female">female
weighting guide</a> for details.<a href="#fnref9" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn10" role="doc-endnote"><p><code>POPWT</code> can be used to
estimate population-level <em>counts</em> - <a
href="https://pma.ipums.org/pma/population_weights.shtml">click here</a>
or check out <a href="https://www.youtube.com/watch?v=GnCq26t4zgM">this
video</a> for details.<a href="#fnref10" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn11" role="doc-endnote"><p>See Dean &amp; Pagano <span
class="citation" data-cites="Dean-Pagano">(<a href="#ref-Dean-Pagano"
role="doc-biblioref">2015</a>)</span> for discussion. If you estimate a proportion where the sample have either 0% or 100% of respondents with the outcome, then as of the time of this writing, neither Stata nor R's `survey` package will report a confidence interval. Here at Biostat Global Consulting, we have written programs in both Stata and R that yield meaningful confidence intervals for any proportion.  Those programs are made freely available as part of software we have written for the World Health Organization.  If you want to learn more about them, write to us at Dale.Rhoda@biostatglobal.com or Caitlin.Clary@biostatglobal.com.<a href="#fnref11"
class="footnote-back" role="doc-backlink">↩︎</a></p></li>
<li id="fn12" role="doc-endnote"><p><p>See <a href="https://www.stata.com/manuals/rproportion.pdf">Stata's help for the <code>proportion</code> command</a> for a complete list of <code>citype()</code> methods.<a href="#fnref12" class="footnote-back" role="doc-backlink">↩︎</a></p></li>
<li id="fn13" role="doc-endnote"><p>As we’ll see in an upcoming post,
women are considered “lost to follow-up” if they moved outside the study
area after Phase 1. Therefore, <code>EAID_1</code> and
<code>EAID_2</code> are identical for all panel members: you can use
either one to identify sample clusters.<a href="#fnref13"
class="footnote-back" role="doc-backlink">↩︎</a></p></li>
<li id="fn14" role="doc-endnote"><p>As with <a
href="https://pma.ipums.org/pma-action/variables/EAID#codes_section">EAID</a>,
you may use either <code>STRATA_1</code> or <code>STRATA_2</code> if
your analysis is restricted to panel members.<a href="#fnref14"
class="footnote-back" role="doc-backlink">↩︎</a></p></li>
<li id="fn15" role="doc-endnote"><p>Some survey materials guide analysts to only report results for estimates or tests where the relative standard error (100 x standard error of the estimate / the estimate itself) is no greater than 30% or where there are at least twelve degrees of freedom.  See the Centers for Disease Control and Prevention's <a href="https://www.cdc.gov/nchs/tutorials/nhanes-cms/variance/variance.htm">NHANES CMS tutorial</a>.<a href="#fnref15" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn16" role="doc-endnote"><p>Levels in <code>EDUCATT</code> may vary by country; <code>EDUCATTGEN</code> recodes country-specific levels in four general categories.<a href="#fnref16" class="footnote-back" role="doc-backlink">↩︎</a></p></li>
<li id="fn17" role="doc-endnote"><p>Ages are frequently reported in
five-year groups: 15-19, 20-24, 25-29, 30-34, 35-39, 40-44, and 45-49.<a
href="#fnref17" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn18" role="doc-endnote"><p>Households are divided into
quintiles/tertiles relative to the distribution of an asset <a
href="https://pma.ipums.org/pma-action/variables/SCORE#description_section">SCORE</a>
weighted for all sampled households. For subnationally-representative
samples (DRC and Nigeria), separate wealth distributions are calculated
for each sampled region.<a href="#fnref18" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn19" role="doc-endnote"><p><code>SUBNATIONAL</code> includes
subnational regions for all sampled countries; country-specific
variables are also available on the <a
href="https://pma.ipums.org/pma-action/variables/group?id=hh_geo">household
- geography</a> page.<a href="#fnref19" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
</ol>
</section>


<!--radix_placeholder_site_after_body-->
<!--/radix_placeholder_site_after_body-->
<!--radix_placeholder_appendices-->
<div class="appendix-bottom">
  <h3 id="references">References</h3>
  <div id="references-listing"></div>
</div>
