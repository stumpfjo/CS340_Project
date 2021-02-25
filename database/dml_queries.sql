--  Database Manipulation queries for  Project Website
-- : character used to denote variables with data from backend

-- Add a new borrower from the add_borrowers page
INSERT INTO Borrowers (first_name, last_name, email, street_address, city_name, state, zip_code)
VALUES (:fnameInput, :lnameInput, :emailInput, :addrInput, :cityInput, :stateInput, :zipInput);

-- Find borrowers in the view borrowers table
-- Show all borrowers (default display)
SELECT * FROM Borrowers;
-- Exact Match First Name
SELECT * FROM Borrowers WHERE first_name = :fnameInput;
-- Partial Match First Name
SELECT * FROM Borrowers WHERE first_name LIKE '%:fnameInput%';
-- Exact Match Last Name
SELECT * FROM Borrowers WHERE last_name = :lnameInput;
-- Partial Match Last Name
SELECT * FROM Borrowers WHERE last_name LIKE '%:lnameInput%';
-- Zip Code search
SELECT * FROM Borrowers WHERE zip_code = :zipInput;
-- ID search
SELECT * FROM Borrowers WHERE borrower_id = :idInput;
-- These predicates can be combined algorithmically by the backend
-- one example:
SELECT * FROM Borrowers WHERE last_name = :lnameInput; AND first_name LIKE '%:fnameInput%';

-- Choose a specific borrower to update via the Update button on the view_borrowers page.
SELECT * FROM Borrowers WHERE borrower_id = :idInput;

-- Update borrowers from the update_borrwer page
UPDATE Borrowers
SET
  first_name = :fnameInput,
  last_name = :lnameInput,
  email = :emailInput,
  street_address = :addrInput,
  city_name = :cityInput,
  state = :stateInput,
  zip_code = :zipInput
WHERE borrower_id = :idInput;

-- View Checkouts for a borrower from the view_checkouts page.
SELECT
  b.first_name, b.last_name, t.title_text, i.item_id, i.due_date
FROM
  Titles AS t NATURAL JOIN Items as i NATURAL JOIN Borrowers as b
WHERE
  borrower_id = :idInput;

-- Return items that a borrower has brought back via the Return button on the view_checkouts page.
UPDATE Items
SET
  borrower_id = NULL,
  due_date = NULL
WHERE
  item_id = :itemInput;

-- Add Checkouts to a borrower from the add_checkouts page.
UPDATE Items
SET
  borrower_id = :borrowerInput,
  due_date = :dateInput
WHERE
  item_id = :itemInput;

-- Remove borrowers from the system vi the delete button on the view_borrowers page.
DELETE FROM Borrowers WHERE borrower_id = :idInput;

-- Add a new title from the add_titles page
INSERT INTO Titles (title_text, publication_year, edition, language, call_number)
VALUES (:titleInput, :yearInput, :editionInput, :langInput, :callNoInput);

--Display title info on the search_titles page
SELECT title_id, title_text, language, publication_year FROM Titles;

--Display only titles associated with items on the search_titles page
SELECT t.title_id, t.title_text, t.language, t.publication_year FROM Titles AS t NATURAL JOIN Items as i;

-- Add a copy of a title (item) to the library collection from the add_item page.
INSERT INTO items (title_id, borrower_id, due_date, cutter_number)
VALUES (:titleInput, NULL, NULL, :cutterInput);

--Display the details of a specific title using the View/Update Details button from the search_titles page.
SELECT
  title_id, title_text, publication_year, edition, language, call_number,
FROM
  Titles
WHERE
  title_id = :idInput;
SELECT
  creator_id, first_name, last_name
FROM
  Creators
WHERE creator_id IN (select creator_id FROM Title_Creators WHERE title_id = :idInput);
SELECT
  subject_id, subject_heading
FROM
  Subjects
WHERE subject_id IN (select subject_id FROM Title_Subjects WHERE title_id = :idInput);

-- Add a new creator from the add_creators page
INSERT INTO `Creators` (`first_name`, `last_name`)
VALUES (:fnameInput, :lnameInput);

-- Add a new subject from the add_subjects page
INSERT INTO `Subjects` (`subject_heading`)
VALUES (:subjectInput);

-- Display creators' first and last name in the view_creators page
SELECT first_name, last_name FROM Creators;

-- get all subjects to populate the subjects dropdown in view_subjects page
SELECT subject_heading FROM Subjects;

-- get all titles associated with selected subject in view_subjects page
SELECT Titles.title_text, Titles.language, Titles.publication_year FROM Titles
JOIN Title_Subjects ON Titles.title_id = Title_Subjects.title_id
JOIN Subjects ON Title_Subjects.subject_id = Subjects.subject_id
WHERE Subjects.subject_heading = :subjectInput;

-- display all creators associated with a title in update/details tab
SELECT Creators.first_name, Creators.last_name FROM Creators
JOIN Title_Creators ON Creators.creator_id = Title_Creators.creator_id
JOIN Titles ON Title_Creators.title_id = Titles.title_id
WHERE Titles.title_id = :titleIdInput;

-- display all subjects associated with a title in update/details tab
SELECT Subjects.subject_heading FROM Subjects
JOIN Title_Subjects ON Title_Subjects.subject_id = Subjects.subject_id
JOIN Titles ON Titles.title_id = Title_Subjects.title_id
WHERE Titles.title_id = :titleIdInput;

-- add creator/title relationship for a specific title in update/details tab
INSERT INTO `Title_Creators` (`title_id`, `creator_id`)
VALUES (:titleIdInput, :creatorIdInput);

-- add subject/title relationship for a specific title in update/details tab
INSERT INTO `Title_Subjects` (`title_id`, `subject_id`)
VAULES (:titleIdInput, :subjectInput);

-- remove creator/title relationship for a specific title in update/details tab
DELETE FROM Title_Creators
WHERE Title_Creators.title_id = :titleIdInput AND Title_Creators.creator_id = :creatorIdInput;

-- remove subject/title relationship for a specific title in update/details tab
DELETE FROM Title_Subjects
WHERE Title_Subjects.title_id = :titleIdInput AND Title_Subjects.subject_id = :subjectIdInput;

-- %(<identifier>)s used as parameter in following:

-- Select queries for searching titles
SELECT t.title_id, t.title_text, t.language, t.publication_year, IFNULL(co.checked_out,0) AS num_checked_out, IFNULL(os.on_shelf,0) AS num_on_shelf
FROM Titles AS t LEFT OUTER JOIN (select title_id, COUNT(*) AS checked_out FROM Items WHERE borrower_id IS NOT NULL GROUP BY title_id) AS co ON t.title_id = co.title_id LEFT OUTER JOIN (select title_id, COUNT(*) AS on_shelf FROM Items WHERE borrower_id IS NULL GROUP BY title_id) AS os ON t.title_id = os.title_id
WHERE title_text LIKE %(t_text)s;

SELECT t.title_id, t.title_text, t.language, t.publication_year, IFNULL(co.checked_out,0) AS num_checked_out, IFNULL(os.on_shelf,0) AS num_on_shelf
FROM Titles AS t LEFT OUTER JOIN (select title_id, COUNT(*) AS checked_out FROM Items WHERE borrower_id IS NOT NULL GROUP BY title_id) AS co ON t.title_id = co.title_id LEFT OUTER JOIN (select title_id, COUNT(*) AS on_shelf FROM Items WHERE borrower_id IS NULL GROUP BY title_id) AS os ON t.title_id = os.title_id
WHERE title_text LIKE %(t_text)s AND IFNULL(co.checked_out,0) + IFNULL(os.on_shelf,0) > 0;

SELECT t.title_id, t.title_text, t.language, t.publication_year, IFNULL(co.checked_out,0) AS num_checked_out, IFNULL(os.on_shelf,0) AS num_on_shelf
FROM Titles AS t LEFT OUTER JOIN (select title_id, COUNT(*) AS checked_out FROM Items WHERE borrower_id IS NOT NULL GROUP BY title_id) AS co ON t.title_id = co.title_id LEFT OUTER JOIN (select title_id, COUNT(*) AS on_shelf FROM Items WHERE borrower_id IS NULL GROUP BY title_id) AS os ON t.title_id = os.title_id
WHERE title_text LIKE %(t_text)s AND IFNULL(os.on_shelf,0) > 0;

SELECT t.title_id, t.title_text, t.language, t.publication_year, IFNULL(co.checked_out,0) AS num_checked_out, IFNULL(os.on_shelf,0) AS num_on_shelf
FROM Titles AS t LEFT OUTER JOIN (select title_id, COUNT(*) AS checked_out FROM Items WHERE borrower_id IS NOT NULL GROUP BY title_id) AS co ON t.title_id = co.title_id LEFT OUTER JOIN (select title_id, COUNT(*) AS on_shelf FROM Items WHERE borrower_id IS NULL GROUP BY title_id) AS os ON t.title_id = os.title_id
WHERE title_text = %(t_text)s;

SELECT t.title_id, t.title_text, t.language, t.publication_year, IFNULL(co.checked_out,0) AS num_checked_out, IFNULL(os.on_shelf,0) AS num_on_shelf
FROM Titles AS t LEFT OUTER JOIN (select title_id, COUNT(*) AS checked_out FROM Items WHERE borrower_id IS NOT NULL GROUP BY title_id) AS co ON t.title_id = co.title_id LEFT OUTER JOIN (select title_id, COUNT(*) AS on_shelf FROM Items WHERE borrower_id IS NULL GROUP BY title_id) AS os ON t.title_id = os.title_id
WHERE title_text = %(t_text)s AND IFNULL(co.checked_out,0) + IFNULL(os.on_shelf,0) > 0;

SELECT t.title_id, t.title_text, t.language, t.publication_year, IFNULL(co.checked_out,0) AS num_checked_out, IFNULL(os.on_shelf,0) AS num_on_shelf
FROM Titles AS t LEFT OUTER JOIN (select title_id, COUNT(*) AS checked_out FROM Items WHERE borrower_id IS NOT NULL GROUP BY title_id) AS co ON t.title_id = co.title_id LEFT OUTER JOIN (select title_id, COUNT(*) AS on_shelf FROM Items WHERE borrower_id IS NULL GROUP BY title_id) AS os ON t.title_id = os.title_id
WHERE title_text = %(t_text)s AND IFNULL(os.on_shelf,0) > 0;

-- Insert query for add_borrowers
INSERT INTO
  Borrowers (first_name, last_name, email, street_address, city_name, state, zip_code)
VALUES
  (%(fname)s, %(lname)s, %(email)s, %(saddr)s, %(city)s, %(state)s, %(zip)s);

-- Select queries used to implement borrower search
SELECT * FROM Borrowers;
SELECT * FROM Borrowers WHERE borrower_id = %(id)s;
SELECT * FROM Borrowers WHERE last_name = %(lname)s;
SELECT * FROM Borrowers WHERE last_name LIKE %(lname)s;

-- Select query used to subbort view_checkouts page
SELECT b.borrower_id, b.first_name, b.last_name, t.title_text, i.item_id, i.due_date
FROM Titles AS t NATURAL JOIN Items as i RIGHT OUTER JOIN Borrowers as b ON i.borrower_id = b.borrower_id
WHERE b.borrower_id = %(b_id)s;

-- Insert query used to add new titles
INSERT INTO Titles (title_text, publication_year, edition, language, call_number)
VALUES (%(t_text)s, %(p_year)s, %(ed)s, %(lang)s, %(c_num)s);

-- Insert query for adding new items
INSERT INTO Items (title_id, cutter_number) VALUES (%(t_id)s, %(c_num)s);
-- Select query to populate forms on add_items page
SELECT title_text, title_id FROM Titles WHERE title_id=%(t_id)s;

-- Queries used to populate fields on page for updating titles
SELECT * FROM Titles WHERE title_id = %(t_id)s;
SELECT tc.creator_catalog_id, t.title_id ,c.first_name, c.last_name FROM Titles as t NATURAL JOIN Title_Creators AS tc NATURAL JOIN Creators AS c WHERE title_id = %(t_id)s
SELECT ts.subject_catalog_id, t.title_id, s.subject_heading FROM Titles as t NATURAL JOIN Title_Subjects AS ts NATURAL JOIN Subjects AS s WHERE title_id = %(t_id)s
SELECT * FROM Creators
SELECT * FROM Subjects
