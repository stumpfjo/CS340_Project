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
