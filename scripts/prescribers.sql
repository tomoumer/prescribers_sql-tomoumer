-- Tennessee Prescribers Database

-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
-- a: npi, 1881634483, BRUCE PENDLEY, M.D., family practice, 358 prescriptions, 99707 total claims

-- SELECT npi, SUM(total_claim_count) AS total_claims
-- FROM prescription
-- GROUP BY npi
-- ORDER BY total_claims DESC
-- LIMIT 5;

-- 1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
-- a: below:

-- WITH sum_claims AS (
-- SELECT npi, SUM(total_claim_count) AS total_claims
-- FROM prescription
-- GROUP BY npi
-- ORDER BY total_claims DESC
-- LIMIT 5
-- )
-- SELECT sum_claims.npi,
-- 	nppes_provider_first_name AS first_name,
-- 	nppes_provider_last_org_name AS last_name,
-- 	specialty_description,
-- 	total_claims
-- FROM sum_claims
-- LEFT JOIN prescriber AS p
-- ON sum_claims.npi = p.npi
-- ORDER BY total_claims DESC;

--2a. Which specialty had the most total number of claims (totaled over all drugs)?
-- Family Practice is at the top with 9,752,347 claims!

-- SELECT 
-- 	specialty_description,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescription AS p1
-- LEFT JOIN prescriber AS p2
-- ON p1.npi = p2.npi
-- GROUP BY specialty_description
-- ORDER BY total_claims DESC
-- LIMIT 5

--2b. Which specialty had the most total number of claims for opioids?
-- a: Nurse Practitioner is the real drug dealer! with 900,845 total opioid claims

-- WITH unique_drugs AS (
-- SELECT DISTINCT drug_name,
-- 	opioid_drug_flag
-- FROM drug
-- )
-- SELECT 
-- 	specialty_description,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescription AS p1
-- LEFT JOIN prescriber AS p2
-- ON p1.npi = p2.npi
-- LEFT JOIN unique_drugs
-- ON p1.drug_name = unique_drugs.drug_name
-- WHERE opioid_drug_flag='Y'
-- GROUP BY specialty_description
-- ORDER BY total_claims DESC
-- LIMIT 5


--2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
-- a: yes, 15 of them, see below

-- (
-- SELECT DISTINCT specialty_description
-- FROM prescriber
-- )
-- EXCEPT
-- (
-- SELECT DISTINCT specialty_description
-- FROM prescriber
-- INNER JOIN prescription
-- USING(npi)
-- );

--2d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3a. Which drug (generic_name) had the highest total drug cost?
-- a: BEXAROTENE $2106640.59

-- SELECT generic_name, total_drug_cost
-- FROM drug d
-- LEFT JOIN prescription p
-- ON d.generic_name = p.drug_name
-- WHERE total_drug_cost IS NOT Null
-- ORDER BY total_drug_cost DESC;

-- 3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
-- a: BEXAROTENE, 901.86 / day

-- SELECT generic_name,
-- 	ROUND(total_drug_cost/total_day_supply, 2) AS  cost_per_day
-- FROM drug d
-- LEFT JOIN prescription p
-- ON d.generic_name = p.drug_name
-- WHERE total_drug_cost IS NOT Null
-- ORDER BY cost_per_day DESC;


-- 4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

-- SELECT
-- 	drug_name,
-- 	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
-- 	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
-- 	ELSE 'neither' END AS drug_type
-- FROM drug

-- 4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
-- a: opioids almost double the spending than antibiotics

-- SELECT
-- 	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
-- 	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
-- 	ELSE 'neither' END AS drug_type,
-- 	SUM(total_drug_cost)::MONEY AS overall_drug_spending
-- FROM prescription p
-- LEFT JOIN drug d
-- ON p.drug_name = d.generic_name
-- GROUP BY drug_type

-- 5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
-- a: 10 distinct cbsa over 33 fipscounty

-- SELECT DISTINCT cbsa, cbsaname
-- FROM cbsa
-- WHERE cbsaname LIKE '%TN%'

-- 5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
-- a: largest Nashville-Davidson--Murfreesboro--Franklin, smallest Morristown

-- SELECT cbsaname,
-- 	SUM(population) as total_population
-- FROM cbsa AS cb
-- LEFT JOIN population as p
-- ON cb.fipscounty = p.fipscounty
-- WHERE cbsaname LIKE '%TN%'
-- GROUP BY cbsaname
-- ORDER BY total_population DESC;

-- 5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
-- a: SEVIER county, 95523 

-- SELECT county, population
-- FROM population
-- FULL JOIN cbsa
-- USING(fipscounty)
-- LEFT JOIN fips_county
-- USING(fipscounty)
-- WHERE cbsa IS NULL
-- ORDER BY population DESC
-- LIMIT 1;