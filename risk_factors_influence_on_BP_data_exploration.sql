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
/*
56+ = 53%
50-55 = 35%
44-49 = 24%
38-43 = 13%
32-37 = 8%

Older age ranges have a higher proportion of people with high BP than younger age ranges. 
*/

SELECT 
    patient.age,
    COUNT(*) AS age_count,
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
GROUP BY patient.age
ORDER BY percent_with_high_BP DESC;

/*
The specific age group with the highest proportion of people with high BP is 66, with over 75% having high BP.
One can observe that for everyone over 60, at least half the members of that age group have high BP. 
 Age groups under 40 have no more than 20% of people in their age group with high BP.
*/
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
/*
56+ high BP = 467. people using BP meds = 54
50-55 high BP = 232, people using BP meds = 11
44-49 high BP = 171, people using BP meds = 12
38-43 high BP = 107, people using BP meds = 4
32-37 high BP 16, people using BP meds = 0 

From this data we can see that health providers need to be a little better with prescribing bp meds.
*/



SELECT 
    patient.age_range,
    COUNT(IF(cardiovascular_info.sys_bp_level = 'high blood pressure',
        cardiovascular_info.patient_id,
        NULL)) AS high_BP_count,
    COUNT(IF(cardiovascular_info.prevalent_stroke = 'YES'
            AND cardiovascular_info.sys_bp_level = 'high blood pressure',
        cardiovascular_info.patient_id,
        NULL)) AS num_ppl_at_risk
FROM
    patient
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
GROUP BY patient.age_range
ORDER BY 2 DESC;

/*
56+ 12
50-55 3
44-49 0
38-43 0
32-27 0 

Very few people with high BP are at risk of stroke. 
*/

-- 4) What are the blood pressure ranges for different age groups and ages? 

SELECT DISTINCT patient.age_range,  
MIN(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age_range) AS min_bp,
AVG(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age_range) AS avg_bp, 
MAX(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age_range) AS max_bp
FROM patient INNER JOIN cardiovascular_info 
ON patient.id = cardiovascular_info.patient_id
ORDER BY avg_bp DESC, max_bp DESC, min_bp DESC;

/*
56+ min = 83.5 avg = 144.8 max bp = 295
50-55 min = 94 avg = 135 max bp = 230
44-49 min = 90 avg = 128 max bp = 243
38-43 min = 85 avg = 123 max bp = 199
32-37 min = 83.5 avg = 119 max bp = 197.5 
*/

SELECT DISTINCT patient.age,  
MIN(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age) AS min_bp,
AVG(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age) AS avg_bp, 
MAX(cardiovascular_info.sys_bp) OVER(PARTITION BY patient.age) AS max_bp
FROM patient INNER JOIN cardiovascular_info 
ON patient.id = cardiovascular_info.patient_id
ORDER BY avg_bp DESC, max_bp DESC, min_bp DESC 
LIMIT 10;

-- People that belong to age groups 60 and over have the highest blood pressure ranges

SELECT 
    (AVG(cardiovascular_info.sys_bp * patient.age) - AVG(cardiovascular_info.sys_bp) * AVG(patient.age)) / (SQRT(AVG(cardiovascular_info.sys_bp * cardiovascular_info.sys_bp) - AVG(cardiovascular_info.sys_bp) * AVG(cardiovascular_info.sys_bp)) * SQRT(AVG(patient.age * patient.age) - AVG(patient.age) * AVG(patient.age))) AS correlation_coefficient_population
FROM
    patient
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id;
 
 -- The correlation score was 0.40. We can conclude that age and bp are positivley correlated. 
 
SELECT 
    COUNT(DISTINCT CASE
            WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id
            ELSE NULL
        END) AS smokers,
    COUNT(DISTINCT CASE
            WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id
            ELSE NULL
        END) AS non_smokers
FROM
    patient
        INNER JOIN
    smoking_status ON patient.id = smoking_status.patient_id
WHERE
    patient.age_range = '56+';

-- Age range: 32-37
SELECT 
    COUNT(DISTINCT CASE
            WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id
            ELSE NULL
        END) AS smokers,
    COUNT(DISTINCT CASE
            WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id
            ELSE NULL
        END) AS non_smokers
FROM
    patient
        INNER JOIN
    smoking_status ON patient.id = smoking_status.patient_id
WHERE
    patient.age_range = '32-37';

/* 
56+: smokers = 331, non smokers = 573 
 32 - 37: smokers = 115, non smokers 77 
 
 There are more smokers in the younger age range than older age range. 
*/

SELECT 
    COUNT(DISTINCT CASE
            WHEN smoking_status.is_smoking = 'YES' THEN smoking_status.patient_id
            ELSE NULL
        END) AS smokers,
    COUNT(DISTINCT CASE
            WHEN smoking_status.is_smoking = 'NO' THEN smoking_status.patient_id
            ELSE NULL
        END) AS non_smokers
FROM
    patient
        INNER JOIN
    smoking_status ON patient.id = smoking_status.patient_id
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE
    cardiovascular_info.sys_bp_level = 'high blood pressure';

/*
Of the people with high blood pressure 398 people are smokers and 590 are non-smokers. Roughly 40% of people 
wtih high blood pressures are smokers. Thus we can conclude that smoking is a major contributer to high blood pressure.
*/

SELECT 
    age_range, COUNT(*) AS heavy_users
FROM
    patient
        INNER JOIN
    smoking_status ON patient.id = smoking_status.patient_id
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE
    cig_usage = 'heavy user'
GROUP BY age_range;

/*
Number Of Heavy Cig Users

50-55 = 173
56+ = 171
32-37 = 66
44-49 = 240 
38-43 = 290

*/


SELECT 
    age_range,
    cig_usage,
    sys_bp_level,
    COUNT(*) AS high_bp_count
FROM
    patient
        INNER JOIN
    smoking_status ON patient.id = smoking_status.patient_id
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE
    sys_bp_level = 'high blood pressure'
        AND cig_usage = 'heavy user'
GROUP BY age_range , cig_usage
ORDER BY high_bp_count DESC;

--  Heavy Cig usage combined with old age is more likely to lead to high bp.

SELECT 
    COUNT(DISTINCT CASE
            WHEN
                sys_bp_level = 'at risk'
                    OR sys_bp_level = 'high blood pressure'
            THEN
                smoking_status.patient_id
            ELSE NULL
        END) AS num_issues,
    COUNT(DISTINCT CASE
            WHEN sys_bp_level = 'normal' THEN smoking_status.patient_id
            ELSE NULL
        END) AS num_no_issues
FROM
    patient
        INNER JOIN
    smoking_status ON patient.id = smoking_status.patient_id
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE
    cig_usage = 'heavy user';

/*
Of the people who are heavy cigarette users exactly 628 have high bp or at risk of high bp, and 312 have no issues.
We can conclude thavy cigarette usage can eventually lead to high blood pressure. 
*/


SELECT 
    chol_level, COUNT(*) AS num_ppl_with_high_bp
FROM
    patient
        INNER JOIN
    other_risk_factors ON patient.id = other_risk_factors.patient_id
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE
    cardiovascular_info.sys_bp_level = 'high blood pressure'
GROUP BY chol_level
ORDER BY 2 DESC;

/*
high chol = 500 people with high BP
borderline high = 291 people with high BP
desirable = 116 people with high BP 
*/

SELECT 
    BMI_level, COUNT(*) AS num_ppl_with_high_bp
FROM
    patient
        INNER JOIN
    other_risk_factors ON patient.id = other_risk_factors.patient_id
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE
    cardiovascular_info.sys_bp_level = 'high blood pressure'
GROUP BY BMI_level
ORDER BY 2 DESC;
/*
People in the overweight BMI category have the highest number of people with high blood pressure.
The BMI categories with the lowest number of people with high blood pressure are the severe obesity 
and the underweight category. This most likely because people in these BMI groups are uncommon in this 
data set. 
*/

SELECT 
    sex, sys_bp_level, COUNT(*) AS gender_counts
FROM
    patient
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
GROUP BY sex , sys_bp_level
ORDER BY sys_bp_level DESC , gender_counts DESC;
 
SELECT 
    sex,
    sys_bp_level,
    COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            patient
        WHERE
            sex = 'female') * 100 AS percent_of_females
FROM
    patient
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE
    sex = 'female'
GROUP BY sex , sys_bp_level
ORDER BY percent_of_females DESC;

SELECT 
    sex,
    sys_bp_level,
    COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            patient
        WHERE
            sex = 'male') * 100 AS percent_of_males
FROM
    patient
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE
    sex = 'male'
GROUP BY sex , sys_bp_level
ORDER BY percent_of_males DESC;

/*
There is a greater proportion of males at risk but smaller proportion of males at normal or high blood pressure. The blood pressure 
 levels for women are almost evenly distributed among at risk, high BP, and normal. 
*/

SELECT 
    education,
    sys_bp_level,
    COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            patient
        WHERE
            education = 'high school') * 100 AS percent_hs
FROM
    patient
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE
    education = 'high school'
GROUP BY education , sys_bp_level
ORDER BY percent_hs DESC;

-- Bachelors degrees 

SELECT 
    education,
    sys_bp_level,
    COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            patient
        WHERE
            education = 'bachelors') * 100 AS percent_bs
FROM
    patient
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE
    education = 'bachelors'
GROUP BY education , sys_bp_level
ORDER BY percent_bs DESC;
  
-- Masters degrees  

SELECT 
    education,
    sys_bp_level,
    COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            patient
        WHERE
            education = 'masters') * 100 AS percent_ms
FROM
    patient
        INNER JOIN
    cardiovascular_info ON patient.id = cardiovascular_info.patient_id
WHERE
    education = 'masters'
GROUP BY education , sys_bp_level
ORDER BY percent_ms DESC;

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

/*
 As education level increases, the proportion of people with high BP gets smaller and smaller. 
However, people with higher education levels have a greater proportion of people at risk than people with high school diplomas. 
In addition, it's important to note that there were more people with high school diplomas and bachelor's degrees than people with Ph.D.s 
and master's degrees.

*/ 



