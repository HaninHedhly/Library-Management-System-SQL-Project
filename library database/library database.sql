-- Library System Management SQL Project

-- Create table "Branch"

CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);

-- Create table "Employee"

CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"

CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);

-- Create table "Books"

CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);

-- Create table "IssueStatus"

CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);


-- Create table "ReturnStatus"

CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);




-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

select * from books ;

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status
WHERE issued_id = 'IS121';

DELETE FROM issued_status
WHERE issued_id = 'IS121' ;

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';


-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
    ist.issued_emp_id,
     e.emp_name
    -- COUNT(*)
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
GROUP BY 1, 2
HAVING COUNT(ist.issued_id) > 1

-- CTAS ( create table as select )

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt**

CREATE TABLE book_cnts
AS    
SELECT 
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

SELECT * FROM
book_cnts;


-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic' ;


-- Task 8: Find Total Rental Income by Category:


SELECT
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1

-- Task 9 : List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= DATE_SUB(CURDATE(), INTERVAL 180 DAY);

-- task 10 List Employees with Their Branch Manager's Name and their branch details:

SELECT 
    e1.*,
    b.manager_id,
    e2.emp_name as manager
FROM employees as e1
JOIN  
branch as b
ON b.branch_id = e1.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:

CREATE TABLE books_price_greater_than_seven
AS    
SELECT * FROM Books
WHERE rental_price > 7

SELECT * FROM 
books_price_greater_than_seven

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
    DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS null


-- task 13 : 🎯 Objectif : Lister les emprunts non rendus depuis plus de 30 jours

SELECT 
    ist.issued_member_id,                               -- ID du membre
    m.member_name,                                      -- Nom du membre
    bk.book_title,                                      -- Titre du livre
    ist.issued_date,                                    -- Date d'emprunt
    DATEDIFF(CURDATE(), ist.issued_date) AS over_dues_days
    -- Nombre de jours écoulés depuis l'emprunt
FROM issued_status AS ist                               -- Table des emprunts
JOIN members AS m
    ON m.member_id = ist.issued_member_id               -- Relie emprunt → membre
JOIN books AS bk
    ON bk.isbn = ist.issued_book_isbn                   -- Relie emprunt → livre
LEFT JOIN return_status AS rs
    ON rs.issued_id = ist.issued_id                     -- Info de retour (s'il existe)
WHERE 
    rs.return_date IS NULL                              -- Livre pas encore rendu
    AND DATEDIFF(CURDATE(), ist.issued_date) > 30       -- + de 30 jours
ORDER BY ist.issued_member_id   -- Tri par ID membre


/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';



-- 1️⃣ Changer le délimiteur pour pouvoir utiliser les ; à l'intérieur
DELIMITER $$

-- 2️⃣ Création de la procédure
CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    -- Déclaration des variables locales
    DECLARE v_isbn VARCHAR(50) DEFAULT '';
    DECLARE v_book_name VARCHAR(80) DEFAULT '';

    -- Vérifier si l'emprunt existe
    IF EXISTS (SELECT 1 FROM issued_status WHERE issued_id = p_issued_id) THEN

        -- Récupérer l'ISBN et le nom du livre
        SELECT issued_book_isbn, issued_book_name
        INTO v_isbn, v_book_name
        FROM issued_status
        WHERE issued_id = p_issued_id
        LIMIT 1;

        -- Insérer le retour dans return_status
        INSERT INTO return_status(return_id, issued_id, return_date)
        VALUES (p_return_id, p_issued_id, CURDATE());

        -- Mettre le livre comme disponible
        UPDATE books
        SET status = 'yes'
        WHERE isbn = v_isbn;

        -- Afficher un message de confirmation
        SELECT CONCAT('✅ Thank you for returning the book: ', v_book_name) AS message;

    ELSE
        -- Si l'emprunt n'existe pas
        SELECT CONCAT('❌ Error: Issued ID ', p_issued_id, ' does not exist.') AS message;
    END IF;

END$$


DELIMITER ;




-- 📌 Objectif : Générer un rapport de performance par branche
--   - Nombre de livres empruntés
--   - Nombre de livres rendus
--   - Revenu total généré par les locations

-- 1️⃣ Création de la table branch_reports
CREATE TABLE branch_reports AS
SELECT 
    b.branch_id,                                  -- ID de la branche
    b.manager_id,                                 -- ID du manager de la branche
    COUNT(ist.issued_id) AS number_book_issued,  -- Nombre total de livres empruntés
    SUM(CASE WHEN rs.return_id IS NOT NULL THEN 1 ELSE 0 END) AS number_of_book_return,
    -- Nombre total de livres rendus (compte seulement si return_id existe)
    SUM(bk.rental_price) AS total_revenue        -- Revenu total : somme des prix de location
FROM issued_status AS ist                        -- Table principale : les emprunts
JOIN employees AS e
    ON e.emp_id = ist.issued_emp_id             -- Relie l'emprunt à l'employé qui a traité
JOIN branch AS b
    ON e.branch_id = b.branch_id               -- Relie l'employé à sa branche
LEFT JOIN return_status AS rs
    ON rs.issued_id = ist.issued_id            -- Relie l'emprunt au retour s'il existe
JOIN books AS bk
    ON ist.issued_book_isbn = bk.isbn          -- Relie l'emprunt au livre pour récupérer le prix
GROUP BY b.branch_id, b.manager_id             -- Regroupe par branche et manager

ORDER BY b.branch_id;                           -- Tri par ID de branche


-- 2️⃣ Afficher les résultats pour vérifier
SELECT * FROM branch_reports;


-- Task 16: CTAS - Create a Table of Active Members
-- On crée une nouvelle table "active_members" qui contient
-- les membres ayant emprunté au moins un livre dans les 2 derniers mois.

CREATE TABLE active_members AS
SELECT *
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= (CURRENT_DATE - INTERVAL 2 MONTH)
);


-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues.
-- Display the employee name, number of books processed, and their branch.

-- Report: Number of books issued per employee and branch
SELECT 
    e.emp_name,         -- employee name
    b.branch_id,        -- branch ID
    b.manager_id,       -- branch manager
    b.manager_id ,      
    b.branch_address,  
    COUNT(ist.issued_id) AS no_book_issued  -- total books issued
FROM issued_status AS ist
JOIN employees AS e
    ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
    ON e.branch_id = b.branch_id
GROUP BY 
    e.emp_name, 
    b.branch_id, 
    b.manager_id
    












