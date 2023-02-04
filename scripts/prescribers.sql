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
-- INNER JOIN prescriber AS p
-- ON sum_claims.npi = p.npi
-- ORDER BY total_claims DESC;

-- also possible, Michael's code, grouping together various parts:
/*SELECT 
	nppes_provider_first_name AS first_name,
	nppes_provider_last_org_name AS last_name,
	specialty_description,
	SUM(total_claim_count) AS total_claims
FROM prescription
INNER JOIN prescriber
USING(npi)
GROUP BY npi, first_name, last_name, specialty_description
ORDER BY total_claims DESC;*/

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
-- LIMIT 5;

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
-- LIMIT 5;

-- doing this it was found out that actually, some generic_drug names have been mislabelled (meaning, two drug_names have both a flag for YES and NO!!)

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
-- a: dependign on what high is ... Case Manager/Care Coordinator, Orthopaedic Surgery, Interventional Pain Management, Anesthesiology, Pain Management, Hand Surgery, Surgical Oncology all have abouve 50%

-- WITH distinct_drugs AS (
-- SELECT DISTINCT drug_name,
-- 	opioid_drug_flag
-- FROM drug
-- )
-- SELECT specialty_description,
-- 	SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count ELSE 0 END) AS total_opioid_claims,
-- 	SUM(CASE WHEN opioid_drug_flag = 'N' THEN total_claim_count ELSE 0 END)
-- 	 AS total_other_claims,
-- 	ROUND(SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count END) *  100.0 / SUM(total_claim_count), 2) AS percentage_opioid_claims
-- FROM prescriber p1
-- LEFT JOIN prescription p2
-- ON p1.npi = p2.npi
-- INNER JOIN drug AS distinct_drugs
-- on p2.drug_name = distinct_drugs.drug_name
-- GROUP BY specialty_description
-- ORDER BY percentage_opioid_claims DESC NULLS LAST;


/* Alison's code:
SELECT t1.specialty_description, t1.total_opioid_claim, t2.total_specialty, ROUND(t1.total_opioid_claim * 100.0 / t2.total_specialty, 1) AS Percent
FROM 
  (SELECT specialty_description, SUM(total_claim_count) AS total_opioid_claim
 FROM prescription 
 LEFT JOIN prescriber 
 USING(npi)
 LEFT JOIN drug 
 USING(drug_name)
 WHERE opioid_drug_flag = 'Y'
 GROUP BY specialty_description) AS t1
LEFT JOIN
    (SELECT specialty_description, SUM(total_claim_count) AS total_specialty
 FROM prescription 
 LEFT JOIN prescriber 
 USING(npi)
 LEFT JOIN drug 
 USING(drug_name)
 GROUP BY specialty_description) AS t2
ON (t1.specialty_description = t2.specialty_description)
ORDER BY Percent DESC;
*/

-- 3a. Which drug (generic_name) had the highest total drug cost?
-- a: INSULIN $104,264,066.35

-- SELECT 
-- 	generic_name,
-- 	SUM(total_drug_cost)::money AS total_cost
-- FROM prescription p
-- INNER JOIN drug d
-- ON p.drug_name = d.drug_name
-- GROUP BY generic_name
-- ORDER BY total_cost DESC;

-- 3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
-- a: BEXAROTENE, 901.86 / day

-- SELECT generic_name,
-- 	ROUND(SUM(total_drug_cost)/SUM(total_day_supply), 2)::money AS  cost_per_day
-- FROM prescription p
-- INNER JOIN drug d
-- ON p.drug_name = d.drug_name
-- GROUP BY generic_name
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

-- WITH distinct_drugs AS (
-- SELECT DISTINCT drug_name,
-- opioid_drug_flag,
-- antibiotic_drug_flag
-- FROM drug
-- WHERE opioid_drug_flag = 'Y'
-- 	 OR antibiotic_drug_flag = 'Y'
-- )
-- SELECT
-- 	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
-- 	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
-- 	ELSE 'neither' END AS drug_type,
-- 	SUM(total_drug_cost)::MONEY AS overall_drug_spending
-- FROM prescription p
-- LEFT JOIN distinct_drugs
-- ON p.drug_name = distinct_drugs.drug_name
-- GROUP BY drug_type;


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

-- 6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
-- a: 9 of them

-- SELECT drug_name, total_claim_count
-- FROM prescription
-- WHERE total_claim_count >= 3000;

-- 6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

-- SELECT
-- 	p.drug_name,
-- 	total_claim_count,
-- 	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
-- 	ELSE 'not opioid' END AS drug_type
-- FROM prescription p
-- LEFT JOIN drug d
-- ON p.drug_name = d.drug_name
-- WHERE total_claim_count >= 3000;

-- 6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

-- SELECT
-- 	p.drug_name,
-- 	total_claim_count,
-- 	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
-- 	ELSE 'not opioid' END AS drug_type,
-- 	nppes_provider_last_org_name,
-- 	nppes_provider_first_name
-- FROM prescription p
-- LEFT JOIN drug d
-- ON p.drug_name = d.drug_name
-- LEFT JOIN prescriber pre
-- ON p.npi = pre.npi
-- WHERE total_claim_count >= 3000;

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

-- 7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

-- SELECT npi, drug_name
-- FROM prescriber p1
-- CROSS JOIN drug d
-- WHERE specialty_description = 'Pain Management'
-- 	AND nppes_provider_city = 'NASHVILLE'
-- 	AND opioid_drug_flag = 'Y';


-- 7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

-- SELECT p1.npi,
-- 		d.drug_name,
-- 		SUM(total_claim_count)
-- FROM prescriber p1
-- CROSS JOIN drug d
-- LEFT JOIN prescription p2
-- ON d.drug_name = p2.drug_name
-- WHERE specialty_description = 'Pain Management'
-- 	AND nppes_provider_city = 'NASHVILLE'
-- 	AND opioid_drug_flag = 'Y'
-- GROUP BY p1.npi, d.drug_name;

-- 7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

-- SELECT p1.npi,
-- 		d.drug_name,
-- 		COALESCE(SUM(total_claim_count), 0) AS sum_claims
-- FROM prescriber p1
-- CROSS JOIN drug d
-- LEFT JOIN prescription p2
-- ON d.drug_name = p2.drug_name
-- WHERE specialty_description = 'Pain Management'
-- 	AND nppes_provider_city = 'NASHVILLE'
-- 	AND opioid_drug_flag = 'Y'
-- GROUP BY p1.npi, d.drug_name;

-- ====== PART 2

-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?
-- a: 4458

-- SELECT COUNT(npi)
-- FROM prescriber
-- WHERE npi NOT IN
-- 	(SELECT DISTINCT npi
-- 	FROM prescription); 

-- 2a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

-- SELECT generic_name, SUM(total_claim_count) AS total_claims
-- FROM prescriber p1
-- LEFT JOIN prescription p2
-- ON p1.npi = p2.npi
-- LEFT JOIN drug d
-- ON p2.drug_name = d.drug_name
-- WHERE specialty_description = 'Family Practice'
-- 	AND generic_name IS NOT NULL
-- GROUP BY d.generic_name
-- ORDER BY total_claims DESC
-- LIMIT 5;

-- 2b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.

-- SELECT generic_name, SUM(total_claim_count) AS total_claims
-- FROM prescriber p1
-- LEFT JOIN prescription p2
-- ON p1.npi = p2.npi
-- LEFT JOIN drug d
-- ON p2.drug_name = d.drug_name
-- WHERE specialty_description = 'Cardiology'
-- 	AND generic_name IS NOT NULL
-- GROUP BY d.generic_name
-- ORDER BY total_claims DESC
-- LIMIT 5;

-- 2c. Which drugs appear in the top five prescribed for both Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.
-- a: ATORVASTATIN CALCIUM and AMLODIPINE BESYLATE

-- (SELECT generic_name
-- FROM prescriber p1
-- LEFT JOIN prescription p2
-- ON p1.npi = p2.npi
-- LEFT JOIN drug d
-- ON p2.drug_name = d.drug_name
-- WHERE specialty_description = 'Family Practice'
-- 	AND generic_name IS NOT NULL
-- GROUP BY d.generic_name
-- ORDER BY SUM(total_claim_count) DESC
-- LIMIT 5)
-- INTERSECT
-- (SELECT generic_name
-- FROM prescriber p1
-- LEFT JOIN prescription p2
-- ON p1.npi = p2.npi
-- LEFT JOIN drug d
-- ON p2.drug_name = d.drug_name
-- WHERE specialty_description = 'Cardiology'
-- 	AND generic_name IS NOT NULL
-- GROUP BY d.generic_name
-- ORDER BY SUM(total_claim_count) DESC
-- LIMIT 5);

-- 3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
-- 3a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.

-- SELECT npi,
-- 	nppes_provider_city,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescriber AS p1
-- INNER JOIN prescription AS p2
-- USING(npi)
-- WHERE nppes_provider_city = 'NASHVILLE'
-- GROUP BY npi, nppes_provider_city
-- ORDER BY total_claims DESC
-- LIMIT 5;

-- 3b. Now, report the same for Memphis.

-- SELECT npi,
-- 	nppes_provider_city,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescriber AS p1
-- INNER JOIN prescription AS p2
-- USING(npi)
-- WHERE nppes_provider_city = 'MEMPHIS'
-- GROUP BY npi, nppes_provider_city
-- ORDER BY total_claims DESC
-- LIMIT 5;

-- 3c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

-- (SELECT npi,
-- 	nppes_provider_city,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescriber AS p1
-- INNER JOIN prescription AS p2
-- USING(npi)
-- WHERE nppes_provider_city = 'NASHVILLE'
-- GROUP BY npi, nppes_provider_city
-- ORDER BY total_claims DESC
-- LIMIT 5)
-- UNION
-- (SELECT npi,
-- 	nppes_provider_city,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescriber AS p1
-- INNER JOIN prescription AS p2
-- USING(npi)
-- WHERE nppes_provider_city = 'MEMPHIS'
-- GROUP BY npi, nppes_provider_city
-- ORDER BY total_claims DESC
-- LIMIT 5)
-- UNION
-- (SELECT npi,
-- 	nppes_provider_city,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescriber AS p1
-- INNER JOIN prescription AS p2
-- USING(npi)
-- WHERE nppes_provider_city = 'KNOXVILLE'
-- GROUP BY npi, nppes_provider_city
-- ORDER BY total_claims DESC
-- LIMIT 5)
-- UNION
-- (SELECT npi,
-- 	nppes_provider_city,
-- 	SUM(total_claim_count) AS total_claims
-- FROM prescriber AS p1
-- INNER JOIN prescription AS p2
-- USING(npi)
-- WHERE nppes_provider_city = 'CHATTANOOGA'
-- GROUP BY npi, nppes_provider_city
-- ORDER BY total_claims DESC
-- LIMIT 5)

-- 4. Find all counties which had an above-average (for the state) number of overdose deaths in 2017. Report the county name and number of overdose deaths.
-- can't do it, missing table!

--5a. Write a query that finds the total population of Tennessee.

-- SELECT SUM(population)
-- FROM population

--5b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.

-- SELECT
-- 	county,
-- 	population,
-- 	ROUND(100.0 * population / (SELECT SUM(population) FROM population),2) AS perc_population 
-- FROM population
-- LEFT JOIN fips_county
-- USING(fipscounty)
-- ORDER BY perc_population DESC
