* Code snippet to be included several times in the larger .do-file
* that accompanies the document named:
*
* IPUMS PMA Longitudinal Analysis Guide - For Stata Users
*
* Construct a new variable named pop and give it a 
* unique value for each PMA population.

gen pop = .
replace pop = 1 if country == 1 // Burkina Faso
replace pop = 2 if country == 2 & geocd == 1 // Kinshasa
replace pop = 3 if country == 2 & geocd == 2 // Kongo Central
replace pop = 4 if country == 7 // Kenya
replace pop = 5 if country == 9 & geong == 4 // Kano
replace pop = 6 if country == 9 & geong == 2 // Lagos

label variable pop "Population"

include label_pop_values.do
