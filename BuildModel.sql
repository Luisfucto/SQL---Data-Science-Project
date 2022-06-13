
---crating the build table from our other main table from the insight analisys:

CREATE TABLE CUSTOMERS_TOTAL_TABLEDATA
AS SELECT * FROM  CUSTOMERS_TOTAL_TABLE;

--modifying type of columns:

alter table CUSTOMERS_TOTAL_TABLEDATA modify PHONE_NUMBER varchar2(20 char);
alter table CUSTOMERS_TOTAL_TABLEDATA modify NRS varchar2(20 char);
alter table CUSTOMERS_TOTAL_TABLEDATA modify PLAN varchar2(20 char);
------
---mchanging the DATE columns:
-----
CREATE TABLE PRUEBA AS
select PHONE_NUMBER, CONTRACT_START_DATE,ltrim(TO_CHAR(CONTRACT_START_DATE,'mm-yyyy'),'0') AS MONTH_YEAR_STARTDATE from CUSTOMERS_TOTAL_TABLEDATA;

CREATE TABLE PRUEBA2 AS
select PHONE_NUMBER, CONTRACT_END_DATE,ltrim(TO_CHAR(CONTRACT_END_DATE,'mm-yyyy'),'0') AS MONTH_YEAR_ENDDATE from CUSTOMERS_TOTAL_TABLEDATA;

CREATE TABLE PRUEBA3 AS
select PHONE_NUMBER, DOB,ltrim(TO_CHAR(DOB,'mm-yyyy'),'0') AS DOB_DATE from CUSTOMERS_TOTAL_TABLEDATA;

---union all o them in one:

CREATE TABLE UNIONDATES AS
SELECT P.PHONE_NUMBER, P.MONTH_YEAR_STARTDATE,P2.MONTH_YEAR_ENDDATE, P3.DOB_DATE
FROM PRUEBA P, PRUEBA2 P2, PRUEBA3 P3
WHERE
P.PHONE_NUMBER = P2.PHONE_NUMBER AND
P.PHONE_NUMBER = P3.PHONE_NUMBER;

DROP TABLE PRUEBA PURGE;
DROP TABLE PRUEBA2 PURGE;
DROP TABLE PRUEBA3 PURGE;

ALTER TABLE UNIONDATES
RENAME COLUMN PHONE_NUMBER TO PHONENUMBER;

---crating my final build data table for the model:

CREATE TABLE CUSTOMERS_TOTAL_TABLEDATA_2 AS
SELECT * FROM CUSTOMERS_TOTAL_TABLEDATA CT
LEFT JOIN  UNIONDATES UN
ON CT.PHONE_NUMBER = UN.PHONENUMBER;

DROP TABLE UNIONDATES PURGE;
DROP TABLE CUSTOMERS_TOTAL_TABLEDATA PURGE;

ALTER TABLE CUSTOMERS_TOTAL_TABLEDATA_2
DROP COLUMN PHONENUMBER;
ALTER TABLE CUSTOMERS_TOTAL_TABLEDATA_2
DROP COLUMN CONTRACT_START_DATE;
ALTER TABLE CUSTOMERS_TOTAL_TABLEDATA_2
DROP COLUMN CONTRACT_END_DATE;
ALTER TABLE CUSTOMERS_TOTAL_TABLEDATA_2
DROP COLUMN DOB;

---creating test table and aply table

CREATE TABLE CUSTOMERS_TOTAL_TABLEDATA_APPLY
AS SELECT * FROM  CUSTOMERS_TOTAL_TABLEDATA_2
WHERE MONTH_YEAR_ENDDATE IS NULL;

create table CUSTOMERS_TOTAL_TABLEDATA_TEST
as select * from CUSTOMERS_TOTAL_TABLEDATA_2
WHERE MONTH_YEAR_ENDDATE IS NOT NULL;

-- Create the settings table:

CREATE TABLE decision_tree_model_settings (
setting_name VARCHAR2(30),
setting_value VARCHAR2(30));

-- Populate the settings table

BEGIN
INSERT INTO decision_tree_model_settings (setting_name, setting_value)
VALUES (dbms_data_mining.algo_name,dbms_data_mining.algo_decision_tree);

INSERT INTO decision_tree_model_settings (setting_name, setting_value)
VALUES (dbms_data_mining.prep_auto,dbms_data_mining.prep_auto_on);
COMMIT;
END;

---creating the model:

BEGIN
DBMS_DATA_MINING.CREATE_MODEL(
model_name => 'isChurn',
   mining_function => dbms_data_mining.classification,
   data_table_name => 'CUSTOMERS_TOTAL_TABLEDATA_2',
   case_id_column_name => 'PHONE_NUMBER',
   target_column_name => 'MONTH_YEAR_ENDDATE',
   settings_table_name => 'decision_tree_model_settings');
END;

-- describing the model settings tables

describe user_mining_model_settings;

-- List all the ODM models created in your Oracle schema => what machine learning models created

SELECT model_name,
   mining_function,
   algorithm,
   build_duration,
   model_size
FROM user_MINING_MODELS;

-- List the algorithm settings used for machine learning model

SELECT setting_name,
   setting_value,
   setting_type
FROM user_mining_model_settings;

-- List the attribute the machine learning model uses. 

SELECT attribute_name,
   attribute_type,
   usage_type,
   target
from all_mining_model_attributes
where model_name = 'isChurn';


-- create a view that will contain the predicted outcomes => labeled data set
CREATE OR REPLACE VIEW demo_class_dt_test_results
AS
SELECT PHONE_NUMBER,
   prediction(isChurn USING *) predicted_value,
   prediction_probability(isChurn USING *) probability
FROM CUSTOMERS_TOTAL_TABLEDATA_TEST;
-- Select the data containing the applied/labeled/scored data set
-- This will be used as input to the calculation of the confusion matrix
SELECT *
FROM demo_class_dt_test_results;


DECLARE
   v_accuracy NUMBER;
BEGIN
DBMS_DATA_MINING.COMPUTE_CONFUSION_MATRIX (
accuracy => v_accuracy,
   apply_result_table_name => 'demo_class_dt_test_results',
   target_table_name => 'CUSTOMERS_TOTAL_TABLEDATA_TEST',
   case_id_column_name => 'PHONE_NUMBER',
   target_column_name => 'MONTH_YEAR_ENDDATE',
   confusion_matrix_table_name => 'demo_class_dt_confusion_matrix',
   score_column_name => 'PREDICTED_VALUE',
   score_criterion_column_name => 'PROBABILITY',
   cost_matrix_table_name => null,
   apply_result_schema_name => null,
   target_schema_name => null,
   cost_matrix_schema_name => null,
   score_criterion_type => 'PROBABILITY');
   DBMS_OUTPUT.PUT_LINE('**** MODEL ACCURACY ****: ' || ROUND(v_accuracy,4));
END;

SELECT * FROM demo_class_dt_confusion_matrix;

BEGIN
   dbms_data_mining.apply(
   model_name => 'isChurn',
   data_table_name => 'CUSTOMERS_TOTAL_TABLEDATA_APPLY',
   case_id_column_name => 'PHONE_NUMBER',
   result_table_name => 'NEW_DATA_SCORED');
END;

---Applying the model to new data WITH SOME EXAMPLES:

SELECT PHONE_NUMBER, PREDICTION(isChurn using *)
FROM CUSTOMERS_TOTAL_TABLEDATA_APPLY;

SELECT PHONE_NUMBER, PREDICTION(isChurn using *), PREDICTION_PROBABILITY(isChurn using *)
FROM CUSTOMERS_TOTAL_TABLEDATA_APPLY
WHERE rownum <=20;




