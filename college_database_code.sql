use collegemange1;
select * from  books;

-- 1 List all students with books they have issued

SELECT s.stu_id, s.stu_name, b.book_name, i.isu_date
FROM student s
JOIN issues i ON s.stu_id = i.isu_stu_id
JOIN books b ON i.isu_book_id = b.book_id;

-- 2 students who have NOT issued any books

SELECT s.stu_id, s.stu_name
FROM student s
LEFT JOIN issues i ON s.stu_id = i.isu_stu_id
WHERE i.isu_stu_id IS NULL;

-- 3 List all books with their authors and issue status 

SELECT b.book_id, b.book_name, b.athr_name, 
       CASE 
           WHEN i.isu_id IS NOT NULL THEN 'Issued' 
           ELSE 'Available' 
       END AS status
FROM books b
LEFT JOIN issues i ON b.book_id = i.isu_book_id;

-- 4 which students issued books from which branch 

SELECT s.stu_name, b.book_name, br.brn_name, i.isu_date
FROM student s
JOIN issues i ON s.stu_id = i.isu_stu_id
JOIN books b ON i.isu_book_id = b.book_id
JOIN branch br ON b.book_brn_id = br.brn_id;

-- 5 books that have never been issued 

SELECT b.book_id, b.book_name, b.athr_name
FROM books b
LEFT JOIN issues i ON b.book_id = i.isu_book_id
WHERE i.isu_book_id IS NULL;

-- 6 the latest book issued by each student

SELECT s.stu_id, s.stu_name, b.book_name, i.isu_date
FROM student s
JOIN issues i ON s.stu_id = i.isu_stu_id
JOIN books b ON i.isu_book_id = b.book_id
WHERE i.isu_date = (
    SELECT MAX(isu_date) FROM issues WHERE isu_stu_id = s.stu_id
);


-- 7 students who have issued books but don’t have a login account


SELECT DISTINCT s.stu_id, s.stu_name
FROM student s
JOIN issues i ON s.stu_id = i.isu_stu_id
LEFT JOIN login l ON s.stu_id = l.lgn_usr_id
WHERE l.lgn_usr_id IS NULL;

-- 8 which book is issued the most

SELECT b.book_name, COUNT(i.isu_id) AS total_issues
FROM issues i
JOIN books b ON i.isu_book_id = b.book_id
GROUP BY b.book_name
ORDER BY total_issues DESC
LIMIT 1;

-- 9 the first book issued by each student


 WITH FirstIssued AS (
    SELECT s.stu_id, s.stu_name, b.book_name, i.isu_date,
           ROW_NUMBER() OVER (PARTITION BY s.stu_id ORDER BY i.isu_date ASC) AS rn
    FROM student s
    JOIN issues i ON s.stu_id = i.isu_stu_id
    JOIN books b ON i.isu_book_id = b.book_id
)
SELECT stu_id, stu_name, book_name, isu_date
FROM FirstIssued
WHERE rn = 1;

-- 10 the most popular book per branch

WITH BookPopularity AS (
SELECT br.brn_name, b.book_name, COUNT(i.isu_id) AS total_issues,
	RANK() OVER (PARTITION BY br.brn_name ORDER BY COUNT(i.isu_id) DESC) AS ranks
    FROM books b
    JOIN branch br ON b.book_brn_id = br.brn_id
    JOIN issues i ON b.book_id = i.isu_book_id
    GROUP BY br.brn_name, b.book_name
)

SELECT brn_name, book_name, total_issues
FROM BookPopularity
WHERE ranks = 1;

-- 11 the last 3 books issued by each student

WITH LastThreeBooks AS (
    SELECT s.stu_id, s.stu_name, b.book_name, i.isu_date,
           ROW_NUMBER() OVER (PARTITION BY s.stu_id ORDER BY i.isu_date DESC) AS rn
    FROM student s
    JOIN issues i ON s.stu_id = i.isu_stu_id
    JOIN books b ON i.isu_book_id = b.book_id
)
SELECT stu_id, stu_name, book_name, isu_date
FROM LastThreeBooks
WHERE rn <= 3;

--  12 students who have issued books

SELECT s.stu_id, s.stu_name, COUNT(i.isu_id) AS books_issued
FROM student s
JOIN issues i ON s.stu_id = i.isu_stu_id
GROUP BY s.stu_id, s.stu_name
ORDER BY books_issued DESC;

-- 13 books that have never been issued but are expensive (price > 500)

SELECT b.book_id, b.book_name, b.book_price
FROM books b
LEFT JOIN issues i ON b.book_id = i.isu_book_id
WHERE i.isu_id IS NULL AND b.book_price > 500;

-- 14 the least expensive book

SELECT book_name, book_price
FROM books
ORDER BY book_price ASC
LIMIT 1;

-- 14 Find the average price of all books

SELECT AVG(book_price) AS avg_price
 FROM books;
 
 -- 15 books that are priced above the average price
 
 SELECT book_name, book_price
FROM books
WHERE book_price > (SELECT AVG(book_price) FROM books)
order by book_price desc;



