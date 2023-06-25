-- Data Exploration

USE cardio_risk_project;

-- 1) What percentage of people in each age and age have high blood pressure?

SELECT 
    patient.age_range,
    COUNT(*) AS age_range_count,
    COUNT(IF(cardiovascular_info.sys_bp_level = 'high blood pressure',
        cardiovascular_info.patient_id,
        NULL)) AS high_BP_count,
    ROUND(COUNT(IF(cardiovascular_info.sys_bp_level = 'high blood pressure',
                cardiovascular_info.patient_id,
                NULL)) / COUNT(*),
            2) * 100 AS percent_with_high_BP
FROM
    patient
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
GROUP BY patient.age_range
ORDER BY percent_with_high_BP DESC;

SELECT patient.age, 
COUNT(*) AS age_count, 
COUNT(IF(cardiovascular_info.sys_bp_level = 'high blood pressure', cardiovascular_info.patient_id,NULL)) AS high_BP_count,
ROUND(COUNT(IF(cardiovascular_info.sys_bp_level = 'high blood pressure', cardiovascular_info.patient_id,NULL))/COUNT(*),2) * 100 
AS percent_with_high_BP
FROM patient INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id 
GROUP BY patient.age ORDER BY percent_with_high_BP DESC;


-- 2) Are all these people taking blood pressure medications? 

SELECT 
    patient.age_range,
    COUNT(IF(cardiovascular_info.sys_bp_level = 'high blood pressure',
        cardiovascular_info.patient_id,
        NULL)) AS high_BP_count,
    COUNT(IF(cardiovascular_info.bp_meds = 'YES'
            AND cardiovascular_info.sys_bp_level = 'high blood pressure',
        cardiovascular_info.patient_id,
        NULL)) AS num_ppl_on_meds
FROM
    patient
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
GROUP BY patient.age_range
ORDER BY 2 DESC;


-- 3) How many of these people with high blood pressure are at risk of stroke? 

SELECT patient.age_range,
COUNT(IF(cardiovascular_info.sys_bp_level = 'high blood pressure', cardiovascular_info.patient_id,NULL)) AS high_BP_count,
COUNT(IF(cardiovascular_info.prevalent_stroke = 'YES' AND cardiovascular_info.sys_bp_level = 'high blood pressure', cardiovascular_info.patient_id,NULL)) AS num_ppl_at_risk
FROM patient INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id 
GROUP BY patient.age_range ORDER BY 2 DESC;

-- 4) What are the blood pressure ranges for different age groups and ages? 
-- Furthermore select 2 ages and 2 age groups for close examination. 

SELECT DISTINCT patient.age_range,  
MIN(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age_range) AS min_bp,
AVG(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age_range) AS avg_bp, 
MAX(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age_range) AS max_bp
FROM patient INNER JOIN cardiovascular_info 
ON patient.id = cardiovascular_info.patient_id
ORDER BY avg_bp DESC, max_bp DESC, min_bp DESC;

SELECT COUNT(*) FROM patient INNER JOIN cardiovascular_info 
ON patient.id = cardiovascular_info.patient_id
WHERE patient.age_range = '56+';  

SELECT COUNT(*) FROM patient INNER JOIN cardiovascular_info 
ON patient.id = cardiovascular_info.patient_id
WHERE patient.age_range = '32-37'; 

SELECT DISTINCT patient.age,  
MIN(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age) AS min_bp,
AVG(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age) AS avg_bp, 
MAX(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age) AS max_bp
FROM patient INNER JOIN cardiovascular_info 
ON patient.id = cardiovascular_info.patient_id
ORDER BY avg_bp DESC, max_bp DESC, min_bp DESC 
LIMIT 10;

SELECT COUNT(*) FROM patient INNER JOIN cardiovascular_info 
ON patient.id = cardiovascular_info.patient_id
WHERE patient.age = 61;  

SELECT DISTINCT age,  
MIN(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age) AS min_bp,
AVG(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age) AS avg_bp, 
MAX(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age) AS max_bp
FROM patient INNER JOIN cardiovascular_info 
ON patient.id = cardiovascular_info.patient_id
ORDER BY avg_bp ASC, max_bp ASC, min_bp ASC 
LIMIT 10;

SELECT COUNT(*) FROM patient INNER JOIN cardiovascular_info 
ON patient.id = cardiovascular_info.patient_id
WHERE patient.age = 36; 

-- 5)  Is blood pressure and age correlated in this dataset? 

-- using population correlation value 
SELECT  
        (AVG(cardiovascular_info.sys_bp * patient.age) - AVG(cardiovascular_info.sys_bp) * AVG(patient.age)) / 
        (SQRT(AVG(cardiovascular_info.sys_bp * cardiovascular_info.sys_bp ) - AVG(cardiovascular_info.sys_bp) * AVG(cardiovascular_info.sys_bp)) * 
        SQRT(AVG(patient.age * patient.age) - AVG(patient.age) * AVG(patient.age))) 
        AS correlation_coefficient_population
        FROM patient INNER JOIN cardiovascular_info 
ON patient.id = cardiovascular_info.patient_id;
 
-- 6) Note that Smoking is less accepted now then it was back then. 
-- For each of the four groups how many people are smokers and how many people are non smokers? 

-- Age range: 56+ 
SELECT COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id ELSE NULL END) AS smokers,
		COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id ELSE NULL END) AS non_smokers
FROM patient 
INNER JOIN smoking_status ON patient.id = smoking_status.patient_id
WHERE patient.age_range = '56+';

-- Age range: 32-37
SELECT COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id ELSE NULL END) AS smokers,
		COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id ELSE NULL END) AS non_smokers
FROM patient 
INNER JOIN smoking_status ON patient.id = smoking_status.patient_id
WHERE patient.age_range = '32-37';

-- Age: 61
SELECT COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id ELSE NULL END) AS smokers,
		COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id ELSE NULL END) AS non_smokers
FROM patient 
INNER JOIN smoking_status ON patient.id = smoking_status.patient_id
WHERE patient.age = 61;

-- Age:36
SELECT COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id ELSE NULL END) AS smokers,
		COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id ELSE NULL END) AS non_smokers
FROM patient 
INNER JOIN smoking_status ON patient.id = smoking_status.patient_id
WHERE patient.age = 36;

-- 7) For each of our four groups how many people are smokers and how many are nonsmokers with high blood pressure? 

SELECT COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id ELSE NULL END) AS smokers,
		COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id ELSE NULL END) AS non_smokers
FROM patient 
INNER JOIN smoking_status ON patient.id = smoking_status.patient_id
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE patient.age_range = '56+' AND cardiovascular_info.sys_bp_level = 'high blood pressure';

SELECT COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id ELSE NULL END) AS smokers,
		COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id ELSE NULL END) AS non_smokers
FROM patient 
INNER JOIN smoking_status ON patient.id = smoking_status.patient_id
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE patient.age_range = '32-37' AND cardiovascular_info.sys_bp_level = 'high blood pressure';

SELECT COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id ELSE NULL END) AS smokers,
		COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id ELSE NULL END) AS non_smokers
FROM patient 
INNER JOIN smoking_status ON patient.id = smoking_status.patient_id
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE patient.age = 61 AND cardiovascular_info.sys_bp_level = 'high blood pressure';

SELECT COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id ELSE NULL END) AS smokers,
		COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id ELSE NULL END) AS non_smokers
FROM patient 
INNER JOIN smoking_status ON patient.id = smoking_status.patient_id
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE patient.age = 36 AND cardiovascular_info.sys_bp_level = 'high blood pressure';

-- 8) repeat question 7) but with people of all ages. 
SELECT COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id ELSE NULL END) AS smokers,
		COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id ELSE NULL END) AS non_smokers
FROM patient 
INNER JOIN smoking_status ON patient.id = smoking_status.patient_id
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE cardiovascular_info.sys_bp_level = 'high blood pressure';

-- 9) How many people are smokers and how many people are non smokers?
SELECT COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id ELSE NULL END) AS smokers,
		COUNT(DISTINCT CASE WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id ELSE NULL END) AS non_smokers
FROM smoking_status;

-- 10) Does heavy cigarette usage influence high blood pressure?
SELECT age_range, cig_usage, sys_bp_level, COUNT(*) AS high_bp_count
FROM patient 
INNER JOIN smoking_status ON patient.id = smoking_status.patient_id
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE sys_bp_level ='high blood pressure' GROUP BY age_range, cig_usage ORDER BY high_bp_count DESC;

SELECT 
COUNT(DISTINCT CASE WHEN sys_bp_level = 'at risk' OR sys_bp_level = 'high blood pressure' THEN smoking_status.patient_id ELSE NULL END) AS num_issues,
COUNT(DISTINCT CASE WHEN sys_bp_level = 'normal' THEN smoking_status.patient_id ELSE NULL END) AS num_no_issues
FROM patient 
INNER JOIN smoking_status ON patient.id = smoking_status.patient_id
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE cig_usage = 'heavy user';

-- 11) Are people with diabetes more likely to have high blood pressure? 

SELECT sys_bp_level, COUNT(*) AS num_ppl_with_diabetes  FROM patient 
INNER JOIN other_risk_factors ON patient.id = other_risk_factors.patient_id
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE diabetes= 'YES' GROUP BY sys_bp_level ORDER BY 2 DESC;

-- 12) What is the impact of high and borderline high blood pressure on cholestrol? 

SELECT chol_level, COUNT(*) AS num_ppl_with_high_bp  FROM patient 
INNER JOIN other_risk_factors ON patient.id = other_risk_factors.patient_id
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE cardiovascular_info.sys_bp_level = 'high blood pressure' 
GROUP BY chol_level ORDER BY 2 DESC;


-- 13) Are people outside the healthy BMI range likely to have higher blood pressures? 
SELECT BMI_level, COUNT(*) AS num_ppl_with_high_bp  FROM patient 
INNER JOIN other_risk_factors ON patient.id = other_risk_factors.patient_id
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE cardiovascular_info.sys_bp_level = 'high blood pressure' 
GROUP BY BMI_level ORDER BY 2 DESC;

-- 14) Does sex affect blood pressure levels? 

SELECT sex, sys_bp_level, COUNT(*) AS gender_counts FROM patient 
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
GROUP BY sex, sys_bp_level ORDER BY sys_bp_level DESC, gender_counts DESC;
 
SELECT sex, sys_bp_level, 
COUNT(*) / (SELECT COUNT(*) FROM patient WHERE sex = 'female') * 100 AS percent_of_females FROM patient 
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE sex = 'female' GROUP BY sex, sys_bp_level ORDER BY percent_of_females DESC;

SELECT sex, sys_bp_level, 
COUNT(*) / (SELECT COUNT(*) FROM patient WHERE sex = 'male') * 100 AS percent_of_males FROM patient 
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE sex = 'male' GROUP BY sex, sys_bp_level ORDER BY percent_of_males DESC;

-- 15) Repeat the same steps for education levels 

-- high school graduates 

SELECT education, sys_bp_level, 
COUNT(*) / (SELECT COUNT(*) FROM patient WHERE education = 'high school') * 100 AS percent_hs FROM patient 
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE education = 'high school' GROUP BY education, sys_bp_level ORDER BY percent_hs DESC;

-- Bachelors degrees 

SELECT education, sys_bp_level, 
COUNT(*) / (SELECT COUNT(*) FROM patient WHERE education = 'bachelors') * 100 AS percent_bs FROM patient 
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE education = 'bachelors' GROUP BY education, sys_bp_level ORDER BY percent_bs DESC;
  
-- Masters degrees  

SELECT education, sys_bp_level, 
COUNT(*) / (SELECT COUNT(*) FROM patient WHERE education = 'masters') * 100 AS percent_ms FROM patient 
INNER JOIN cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE education = 'masters' GROUP BY education, sys_bp_level ORDER BY percent_ms DESC;

-- PhDs

SELECT 
    education,
    sys_bp_level,
    COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            patient
        WHERE
            education = 'phd') * 100 AS percent_phd
FROM
    patient
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE
    education = 'phd'
GROUP BY education , sys_bp_level
ORDER BY percent_phd DESC;





/* From all of this we can conclude that age, cigarate usage diabetes, and cholestrol significantly effect chances 
of an individual having blood pressure. 
gender and education seem to have some effects on blood pressure. 
BMI have very little effects on blood pressure. 
*/
