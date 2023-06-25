-- Data cleaning 

--  Checking for any NULL or Innacurate values 

SELECT 
    *
FROM
    patient
WHERE
    id IS NULL OR age IS NULL
        OR education IS NULL
        OR sex IS NULL;

SELECT * FROM smoking_status 
WHERE patient_id IS NULL OR is_smoking IS NULL
OR cigsPerDay IS NULL;

SELECT DISTINCT cigsPerDay FROM smoking_status 
WHERE is_smoking ='NO';

SELECT * FROM cardiovascular_info 
WHERE BPMeds IS NULL OR prevalentStroke IS NULL 
OR PrevalentHyp IS NULL OR sysBP IS NULL OR diaBP IS NULL
OR heartRate IS NULL OR TenYearCHD IS NULL; 

SELECT * FROM other_risk_factors
WHERE diabetes IS NULL OR totChol IS NULL
OR BMI IS NULL OR glucose IS NULL;

-- No NULL Values Now checking if all tables have the same number of entries

SELECT COUNT(*) FROM patient;
SELECT COUNT(*) FROM smoking_status;
SELECT COUNT(*) FROM cardiovascular_info;
SELECT COUNT(*) FROM other_risk_factors;
 
-- uneven number of entries between tables 
-- only use inner join and join on other_risk_factors

-- Making adjustments to patients table 
-- changing the education number codes to what is assumed to be the corresponding level of education  
SELECT id, age, sex, education, 
CASE 
WHEN education = '1' THEN 'high school' 
WHEN education = '2' THEN 'bachelors' 
WHEN education = '3' THEN 'masters' 
WHEN education = '4' THEN  'phd'
END AS education_level  
FROM patient;

ALTER TABLE patient 
MODIFY education VARCHAR(15);

SET SQL_SAFE_UPDATES = 0;
UPDATE patient 
SET education = CASE 
WHEN education = '1' THEN 'high school' 
WHEN education = '2' THEN 'bachelors' 
WHEN education = '3' THEN 'masters' 
WHEN education = '4' THEN  'phd'
END;

-- change sex from F AND M to female and male 

SELECT id, age, education, sex,
CASE 
WHEN sex = 'M' THEN 'male' 
WHEN sex = 'F' THEN 'female' 
END AS newSex 
FROM patient; 

ALTER TABLE patient 
MODIFY sex VARCHAR(10);

SET SQL_SAFE_UPDATES = 0;
UPDATE patient 
SET sex = CASE 
WHEN sex = 'M' THEN 'male' 
WHEN sex = 'F' THEN 'female' 
END;

-- Adding and additional column for age range 
-- counting number of people in each individual age to determine appropriate interval size 
SELECT age, COUNT(*) FROM patient 
GROUP BY age ORDER BY age DESC; 

-- Counting number in each age range to make things even
SELECT COUNT(DISTINCT CASE WHEN age BETWEEN 32 AND 37 THEN id ELSE NULL END) AS '32-37',
COUNT(DISTINCT CASE WHEN age BETWEEN 38 AND 43 THEN id ELSE NULL END) AS '38-43',
COUNT(DISTINCT CASE WHEN age BETWEEN 44 AND 49 THEN id ELSE NULL END) AS '44-49',
COUNT(DISTINCT CASE WHEN age BETWEEN 50 AND 55 THEN id ELSE NULL END) AS '50-55',
COUNT(DISTINCT CASE WHEN age > 55 THEN id ELSE NULL END) AS '56+'
FROM patient;

ALTER TABLE patient 
     ADD COLUMN age_range VARCHAR(10)
     AFTER age;

SET SQL_SAFE_UPDATES = 0;
UPDATE patient 
SET age_range = CASE 
WHEN age BETWEEN 32 AND 37 THEN '32-37' 
WHEN age BETWEEN 38 AND 43 THEN '38-43' 
WHEN age BETWEEN 44 AND 49 THEN '44-49'  
WHEN age BETWEEN 50 AND 55 THEN '50-55'  
WHEN age > 55 THEN '56+'
END;

-- making adjustments to smoking_status table  

SELECT * FROM smoking_status;

-- want to add an additional column to our smoking_status table
-- that classifies people as non users, avg users and heavy users

SELECT cigsPerDay, COUNT(*) AS numppl
FROM smoking_status GROUP BY cigsPerDay ORDER BY cigsPerDay;

    SELECT 
    COUNT(DISTINCT CASE WHEN cigsPerDay = 0 THEN patient_id ELSE NULL END) AS 'non user',
	COUNT(DISTINCT CASE WHEN cigsPerDay > 0 AND cigsPerDay < 20 THEN patient_id ELSE NULL END) AS 'avg user',
    COUNT(DISTINCT CASE WHEN cigsPerDay >= 20 THEN patient_id ELSE NULL END) AS 'heavy user'
    FROM smoking_status; 
        
    ALTER TABLE smoking_status 
     ADD COLUMN cig_usage VARCHAR(15)
     AFTER cigsPerDay;
     
SET SQL_SAFE_UPDATES = 0;
UPDATE smoking_status
SET cig_usage = CASE 
WHEN cigsPerDay = 0 THEN 'non user' 
WHEN cigsPerDay > 0 AND cigsPerDay < 20 THEN 'avg user' 
WHEN cigsPerDay >= 20 THEN 'heavy user'  
END;

-- renaming column for consistency 

ALTER TABLE smoking_status 
RENAME COLUMN cigsPerDay TO cigs_per_day; 

-- Making modifications to cardiovascular_info table
DESC cardiovascular_info;
SELECT * FROM cardiovascular_inf;
 
-- Systolic Blood pressure is used more in studies so going to drop diaBP 
-- also dropping 10 year chd because of the way these values were given in original data set

ALTER TABLE cardiovascular_info 
DROP COLUMN diaBP;

ALTER TABLE cardiovascular_info 
DROP COLUMN TenYearCHD;

-- change BPmeds, prevalentStroke, prevalentHyp to YES and NO for consistency

ALTER TABLE cardiovascular_info 
MODIFY BPMeds VARCHAR(3);

SET SQL_SAFE_UPDATES = 0;
UPDATE cardiovascular_info
SET BPMeds = CASE 
WHEN BPMeds = 0 THEN 'NO' 
WHEN BPMeds = 1 THEN 'YES'  
END;

ALTER TABLE cardiovascular_info
RENAME COLUMN BPMeds TO bp_meds; 

ALTER TABLE cardiovascular_info 
MODIFY prevalentStroke VARCHAR(3);

SET SQL_SAFE_UPDATES = 0;
UPDATE cardiovascular_info
SET prevalentStroke = CASE 
WHEN prevalentStroke = 0 THEN 'NO' 
WHEN prevalentStroke = 1 THEN 'YES'  
END;

ALTER TABLE cardiovascular_info
RENAME COLUMN prevalentStroke TO prevalent_stroke; 

SELECT * FROM cardiovascular_info;

ALTER TABLE cardiovascular_info 
MODIFY prevalentHyp VARCHAR(3);

SET SQL_SAFE_UPDATES = 0;
UPDATE cardiovascular_info
SET prevalentHyp = CASE 
WHEN prevalentHyp = 0 THEN 'NO' 
WHEN prevalentHyp = 1 THEN 'YES'  
END;

ALTER TABLE cardiovascular_info
RENAME COLUMN prevalentHyp TO prevalent_hyp; 

SELECT * FROM cardiovascular_info;

ALTER TABLE cardiovascular_info
RENAME COLUMN sysBP TO sys_bp; 

ALTER TABLE cardiovascular_info
RENAME COLUMN heartRate TO heart_rate; 

-- changeing original plans because of heart rate guidlines
-- and because our blood sys blood pressure range will indicate hypertension or high blood pressure 

ALTER TABLE cardiovascular_info 
DROP COLUMN prevalent_hyp;

ALTER TABLE cardiovascular_info 
DROP COLUMN heart_rate;

-- adding column for blood pressure range 
-- Criterion from "centers for disease control and prevention levels of blood pressure"
-- x = arbritrary persons blood pressure 
-- x < 120 => x is normal 
-- 120 <= x <= 139  => x is at risk
-- x >= 140 => x has high blood pressure  

 SELECT 
    COUNT(DISTINCT CASE WHEN sys_bp < 120 THEN patient_id ELSE NULL END) AS 'normal',
	COUNT(DISTINCT CASE WHEN sys_bp BETWEEN 121 AND 139 THEN patient_id ELSE NULL END) AS 'at risk',
    COUNT(DISTINCT CASE WHEN sys_bp >= 140 THEN patient_id ELSE NULL END) AS 'high blood pressure'
    FROM cardiovascular_info; 
    
ALTER TABLE cardiovascular_info 
ADD COLUMN sys_bp_level VARCHAR(20)
AFTER sys_bp;
    
SET SQL_SAFE_UPDATES = 0;
UPDATE cardiovascular_info
SET sys_bp_level = CASE 
WHEN sys_bp < 120 THEN 'normal'  
WHEN sys_bp BETWEEN 120 AND 139 THEN 'at risk'  
WHEN sys_bp > 139 THEN 'high blood pressure'  
END;

--  Modify other_risk_factors table  
SELECT * FROM other_risk_factors;


-- Changing diabetes column to YES and NO for consistency 
ALTER TABLE other_risk_factors 
MODIFY diabetes VARCHAR(3);


SET SQL_SAFE_UPDATES = 0;
UPDATE other_risk_factors
SET diabetes = CASE 
WHEN diabetes = 0 THEN 'NO' 
WHEN diabetes = 1 THEN 'YES'  
END;

-- Based on various changes glucose varies depending on the state of individual
-- as such will drop glucose column 
 
ALTER TABLE other_risk_factors 
DROP COLUMN  glucose;

-- adding cholestrol level column 
-- counting number of people who belong to each group 
 SELECT 
    COUNT(DISTINCT CASE WHEN totChol < 200 THEN patient_id ELSE NULL END) AS 'desirable',
	COUNT(DISTINCT CASE WHEN totChol BETWEEN 200 AND 239 THEN patient_id ELSE NULL END) AS 'borderline high',
    COUNT(DISTINCT CASE WHEN totChol >= 240 THEN patient_id ELSE NULL END) AS 'high'
    FROM other_risk_factors; 
    
ALTER TABLE other_risk_factors 
ADD column chol_level VARCHAR(20)
AFTER totChol; 

SET SQL_SAFE_UPDATES = 0;
UPDATE other_risk_factors
SET chol_level = CASE 
WHEN totChol < 200  THEN 'desirable' 
WHEN totChol BETWEEN 200 AND 239 THEN 'borderline high'
WHEN totChol >= 240 THEN 'high'
END;

-- renaming column for consistency 
ALTER TABLE other_risk_factors
RENAME COLUMN totChol TO tot_chol; 
    
-- Adding BMI level column
-- BMI levels found from NHS inform 

-- Counting to see how many people are in each category      
     SELECT 
    COUNT(DISTINCT CASE WHEN BMI < 18.5 THEN patient_id ELSE NULL END) AS 'underweight',
	COUNT(DISTINCT CASE WHEN BMI BETWEEN 18.5 AND 24.9 THEN patient_id ELSE NULL END) AS 'healthy range',
    COUNT(DISTINCT CASE WHEN BMI BETWEEN 24.91 AND 29.9 THEN patient_id ELSE NULL END) AS 'overweight',
	COUNT(DISTINCT CASE WHEN BMI BETWEEN 29.91 AND 39.9 THEN patient_id ELSE NULL END) AS 'obese',
	COUNT(DISTINCT CASE WHEN BMI > 39.91 THEN patient_id ELSE NULL END) AS 'severe obesity'
    FROM other_risk_factors; 


ALTER TABLE other_risk_factors 
ADD column BMI_level VARCHAR(20)
AFTER BMI; 

SET SQL_SAFE_UPDATES = 0;
UPDATE other_risk_factors 
SET 
    BMI_level = CASE
        WHEN BMI < 18.5 THEN 'underweight'
        WHEN BMI BETWEEN 18.5 AND 24.9 THEN 'healthy range'
        WHEN BMI BETWEEN 24.91 AND 29.9 THEN 'overweight'
        WHEN BMI BETWEEN 29.91 AND 39.9 THEN 'obese'
        WHEN BMI > 39.91 THEN 'severe obesity'
    END;

-- End Of Data Cleaning 
