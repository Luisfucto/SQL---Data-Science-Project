# SQL---Data-Science-Project
SQL - Data Science Project. This a Sql project that I carried out in which the main goals were: - identify how valuable a customer is to the company relative to other customers  - determine whether a customer’s behaviour patterns have changed recently  - check if a customer is on the best-value rate plan given their usage


Description of Task:
A telecommunications company is starting a data project to improve their customer analytics capabilities. You have been asked to design a prototype system for this project. The primary purpose of this project is to help customer service agents build a better picture of the customers they speak to on the phone. During informal interviews with the stakeholders, the following features were suggested for the system; the system should give agents the ability to

•	identify how valuable a customer is to the company relative to other customers 
•	determine whether a customer’s behaviour patterns have changed recently 
•	check if a customer is on the best-value rate plan given their usage

Your client is also interested in using in-database data mining techniques to build a churn prediction model; and has asked you to develop a prototype model in their Oracle database. 
Step 1. Import the Data
You have been provided with sample data in multiple .csv format (assignmentData.zip). You will need to import these files into your database; you may reshape the data in your database as you see fit. Any SQL statements you use during this step should be included in a file called importData.sql

Step 2. Discover Insights
Your primary goal here is to provide analytical data on a per-customer basis. This may be generated either through a database view, or as the output of a PL/SQL script. Capture the output for 3 separate users into a single text file for submission, named customerInsights.txt. The SQL script used to create the view/defined the PL/SQL block should be called customerInsights.sql

This is a prototype project so feel free to use your imagination and move beyond the primary goal if you wish.

Step 3. Build a Model

For this part of the assignment you will create three machine learning models using the in-database machine learning features. The label for your machine learning model should be called isChurn, this should evaluate to true if the user cancels their contract in the current month, false otherwise.

You may need to create additional tables, views, and use sampling to prepare the training and test data sets. You may need to create a view that contains the predicted values for the testing data set.

Complete this process by evaluating the accuracy of the models.
Write a PL/SQL program to combine the accuracy measures from the various models and to present them the user. For example, you can use DBMS_OUTPUT function to display the results.

The script used to meet the requirements for Step 3 should be submitted in a file named buildModel.sql. The output from this script should be captured as a text file and submitted as buildModel.txt.

