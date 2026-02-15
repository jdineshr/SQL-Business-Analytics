# 📊 Problem Statement – Swiggy Sales Data Analysis

## 🎯 Objective
The objective of this project is to analyze Swiggy food delivery data to generate actionable business insights related to customer behavior, restaurant performance, pricing trends, and operational efficiency. The goal is to support data-driven decision-making for improving revenue, customer satisfaction, and market expansion.

---

## 🧩 Business Context
Swiggy operates in a highly competitive online food delivery market where customer preferences, pricing strategies, and delivery performance directly impact business growth.

The company collects large volumes of transactional data across multiple dimensions such as location, restaurant, cuisine, and customer ratings. However, this data is stored in raw format, making it difficult to extract meaningful insights efficiently.

To solve this, a structured data analysis approach is required using SQL and data modeling techniques.

---

## ⚠️ Problem Statement

The current dataset (`swiggy_data`) contains raw and unstructured food delivery records with potential data quality issues such as missing values, duplicates, and inconsistent formats.

Due to the lack of a proper data model:
- Analysis is slow and inefficient
- Business insights are not easily accessible
- Reporting is inconsistent and difficult to scale

The organization needs a clean, structured, and optimized data system to:
- Ensure data accuracy and reliability
- Enable fast and efficient querying
- Support advanced business analysis and reporting

---

## 🧹 Data Cleaning & Validation Requirements

To ensure data quality, the following issues must be addressed:

### 1. Null Value Handling
Identify and handle missing values in critical columns:
- State
- City
- Order_Date
- Restaurant_Name
- Location
- Category
- Dish_Name
- Price_INR
- Rating
- Rating_Count

---

### 2. Blank / Empty Value Check
Detect and clean empty or blank fields that may impact analysis accuracy.

---

### 3. Duplicate Detection
Identify duplicate records using all business-relevant columns.

---

### 4. Duplicate Removal
Remove duplicate rows using SQL techniques (e.g., ROW_NUMBER()) while retaining one valid record per transaction.

---

## 🏗️ Data Modeling Requirement (Star Schema)

To improve performance and scalability, the raw dataset must be transformed into a **Star Schema**.

### 🔹 Dimension Tables
- dim_date → Year, Month, Quarter, Week
- dim_location → State, City, Location
- dim_restaurant → Restaurant_Name
- dim_category → Cuisine/Category
- dim_dish → Dish_Name

---

### 🔹 Fact Table
- fact_swiggy_orders:
  - Price_INR
  - Rating
  - Rating_Count
  - Foreign keys referencing all dimension tables

---

### 📌 Purpose of Star Schema
- Simplifies complex queries
- Improves performance
- Enables scalable reporting
- Supports BI tools like Power BI / Tableau
- Ensures consistent and reliable aggregations

---

## 📊 Key Business Questions

The analysis aims to answer the following:

### 🔹 Basic KPIs
- What is the total number of orders?
- What is the total revenue generated?
- What is the average dish price?
- What is the average customer rating?

---

### 🔹 Date-Based Analysis
- What are the monthly and quarterly order trends?
- How does order volume change year over year?
- What are the peak ordering days of the week?

---

### 🔹 Location-Based Analysis
- Which cities generate the highest orders?
- What is the revenue contribution by each state?

---

### 🔹 Food & Restaurant Performance
- Which restaurants receive the highest number of orders?
- Which cuisines/categories are most popular?
- What are the most frequently ordered dishes?
- How do different cuisines perform in terms of ratings and orders?

---

### 🔹 Customer Spending Behavior
- How are orders distributed across price ranges?
  - Under ₹100
  - ₹100–199
  - ₹200–299
  - ₹300–499
  - ₹500+
- What pricing segment contributes the most to revenue?

---

### 🔹 Ratings Analysis
- What is the distribution of ratings (1–5)?
- How does rating impact order volume?

---

## 🚀 Expected Outcomes

- Clean and validated dataset ready for analysis
- Well-structured Star Schema for efficient querying
- Accurate and meaningful KPIs
- Deep insights into customer behavior and business performance
- Data-driven recommendations for growth and optimization

---

## 📈 Business Impact

This project will help:
- Improve decision-making using data insights
- Identify high-performing restaurants and locations
- Optimize pricing and promotional strategies
- Enhance customer satisfaction and retention
- Support scalable analytics and dashboard development
