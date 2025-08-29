# 📚 Library Management System – SQL Project  

## 🎯 Objective  
The goal of this project is to design and implement a **relational database system** for managing a library.  
It covers core operations such as managing books, members, employees, and branches, as well as issuing and returning books with automated workflows.  

---

## 🛠️ Approach  
- Designed normalized **relational tables** with primary/foreign keys and constraints (`branches`, `employees`, `members`, `books`, `issued_status`, `return_status`).  
- Implemented **CRUD operations** (insert, update, delete) to manage library data.  
- Wrote **advanced SQL queries** using joins, group by, aggregate functions, and CTAS (Create Table As Select) for insights.  
- Created a **stored procedure** to automate book return operations and update availability.  
- Generated **reports** on overdue books, rental income, branch performance, and active members.  

---

## 💻 Tech Stack  
- **MySQL** – database engine  
- **SQL (DDL & DML)** – schema creation & data manipulation  
- **Stored Procedures** – workflow automation  
- **CTAS** – summary reporting  

---

## 🌟 Highlights  
- Built a **complete relational schema** with 6+ linked tables.  
- Automated return operations with a **stored procedure**.  
- Created reports on:  
  - 📌 Overdue books (+30 days not returned)  
  - 📌 Total rental income by category  
  - 📌 Active members (borrowed in last 2 months)  
  - 📌 Branch-level performance (books issued, returns, revenue)  
- Showcased strong skills in **SQL schema design, queries, and reporting**.  

---

## 📂 Project Structure  
- `library database.sql` → SQL script containing schema creation, insertions, queries, and reports  

---

## 🚀 How to Run  
1. Open MySQL Workbench or any SQL client.  
2. Create a new database (e.g., `library_db`).  
3. Copy and run the SQL script:  
   ```sql
   source library database.sql;

