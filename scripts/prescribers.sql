-- Tennessee Prescribers Database

-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
-- a: Michael Cox, M.D. internal medicine, 434 total claims

-- SELECT *
-- from prescriber
-- WHERE npi IN (
-- 	SELECT npi
-- 	FROM prescriber
-- 	LEFT JOIN prescription
-- 	USING(npi)
-- 	LEFT JOIN drug
-- 	USING(drug_name)
-- 	GROUP BY npi
-- 	ORDER BY COUNT(*) DESC
-- 	LIMIT 1
-- );

-- 1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
-- a: see above

-- SELECT
-- 	npi,
-- 	nppes_provider_first_name AS first_name,
-- 	nppes_provider_last_org_name AS last_name,
-- 	specialty_description,
-- 	COUNT(*) as total_claims
-- FROM prescriber
-- LEFT JOIN prescription
-- USING(npi)
-- LEFT JOIN drug
-- USING(drug_name)
-- GROUP BY npi, first_name, last_name, specialty_description
-- ORDER BY total_claims DESC
-- LIMIT 10;

--2a. Which specialty had the most total number of claims (totaled over all drugs)?
-- Nurse Practitioner is at the top with 176,782 claims!

-- SELECT specialty_description, COUNT(*) AS total_claims
-- FROM prescriber
-- LEFT JOIN prescription
-- USING(npi)
-- LEFT JOIN drug
-- USING(drug_name)
-- GROUP BY specialty_description
-- ORDER BY total_claims DESC;

--2b. Which specialty had the most total number of claims for opioids?
-- a: again, Nurse Practitioner

-- SELECT specialty_description, COUNT(*) AS total_claims
-- FROM prescriber
-- LEFT JOIN prescription
-- USING(npi)
-- LEFT JOIN drug
-- USING(drug_name)
-- WHERE opioid_drug_flag='Y'
-- GROUP BY specialty_description
-- ORDER BY total_claims DESC;

--2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT specialty_description
FROM prescriber
LEFT JOIN prescription
USING(npi)
WHERE drug_name IS NULL;

--2d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
