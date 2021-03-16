--  Database Manipulation queries for  Project Website
-- %(<var_name>)s used to denote variables with data from backend

-- Add a new borrower from the add_borrowers page using data from the interface
INSERT INTO Borrowers (
    first_name,
    last_name,
    email,
    street_address,
    city_name,
    state,
    zip_code)
  VALUES (
    %(fname)s,
    %(lname)s,
    %(email)s,
    %(saddr)s,
    %(city)s,
    %(state)s,
    %(zip)s);

-- Update borrowers from the update_borrwer page with new information from the interface
UPDATE Borrowers SET
    first_name = %(f_name)s,
    last_name = %(l_name)s,
    email = %(email)s,
    street_address = %(saddr)s,
    city_name = %(city)s,
    state = %(state)s,
    zip_code = %(zip)s
  WHERE borrower_id = %(b_id)s;

-- Select a single Borrower's information, used to support Borrower update and checkout/returns, and for search by borrower id
SELECT * FROM Borrowers WHERE borrower_id = %(b_id)s;

-- Find all borrowers in the view borrowers table. used to populate dropdowns to select borrowers for updating as well as for checkouts/returns as well as for default disp
SELECT * FROM Borrowers;

-- Queries to support various search options on view_borrowers
-- search by exact last name
SELECT * FROM Borrowers WHERE last_name = %(lname)s;
-- search by partial match last name (%(lname)s has '%' appended and prepended by backend code)
SELECT * FROM Borrowers WHERE last_name LIKE %(lname)s;

-- Queries to implement returs from view_checkouts
-- Return an Item when a Borrower brings it back
UPDATE Items SET
    borrower_id = NULL,
    due_date = NULL
  WHERE item_id = %(i_id)s;

-- Retrieve Items currently checked out to a Borrower
SELECT
    b.borrower_id,
    t.title_text,
    i.item_id,
    i.due_date
  FROM Titles AS t
    NATURAL JOIN Items as i
    RIGHT OUTER JOIN Borrowers as b ON i.borrower_id = b.borrower_id
  WHERE b.borrower_id = %(b_id)s;

-- Queries to implement chaecking out Items to borrowers
-- Check out an item to a borrower:
UPDATE Items SET
    borrower_id = %(b_id)s,
    due_date = %(d_date)s
  WHERE item_id = %(i_id)s;

-- Display Items that are 'On-Shelf' (available for checkout)
SELECT
    i.item_id,
    t.title_text,
    t.call_number,
    i.cutter_number
  FROM Items AS i
    NATURAL JOIN Titles as t
  WHERE i.borrower_id IS NULL;

-- Queries to support weed_items (deletion from Items table)
-- Weed an Item from the library collection:
DELETE FROM Items WHERE item_id = %(i_id)s;
-- Search queries for Items that can be deleted variables after 'LIKE' operator have '%' appended and prepended by code
-- search by title:
SELECT DISTINCT
    i.item_id,
    i.cutter_number,
    t.title_text,
    t.call_number
  FROM Items AS i NATURAL JOIN
    Titles AS t
  WHERE t.title_text LIKE %(t_text)s
  ORDER BY t.title_text;
-- search by creator
SELECT DISTINCT
    i.item_id,
    i.cutter_number,
    t.title_text,
    t.call_number
  FROM Items AS i
    NATURAL JOIN Titles AS t
    NATURAL JOIN Title_Creators as tc
    NATURAL JOIN Creators as c
  WHERE c.last_name LIKE %(l_name)s
  ORDER BY t.title_text;
-- search by subject
SELECT DISTINCT
    i.item_id,
    i.cutter_number,
    t.title_text,
    t.call_number
  FROM Items AS i
    NATURAL JOIN Titles AS t
    NATURAL JOIN Title_Subjects as ts
    NATURAL JOIN Subjects as s
  WHERE s.subject_heading LIKE %(s_head)s
  ORDER BY t.title_text;

-- Add a new subject_heading
INSERT INTO Subjects (subject_heading) VALUES (%(subject)s);

--Queries to implement view_subjects interface
--populate the filter dropdown
SELECT * FROM Subjects;
--select matching titles to the filter
SELECT * FROM Titles JOIN Title_Subjects ON Titles.title_id = Title_Subjects.title_id WHERE subject_id = %(s_id)s;

-- Add a new Title to the systems
INSERT INTO Titles (
    title_text,
    publication_year,
    edition,
    language,
    call_number)
  VALUES (
    %(t_text)s,
    %(p_year)s,
    %(ed)s,
    %(lang)s,
    %(c_num)s);

--Queries for searching the Titles table variables used with 'LIKE' operator have '%' appended and prepended by code:
-- Search by exact Title match:
SELECT
    t.title_id,
    t.title_text,
    t.language,
    t.publication_year,
    IFNULL(co.checked_out,0) AS num_checked_out,
    IFNULL(os.on_shelf,0) AS num_on_shelf
  FROM Titles AS t
    LEFT OUTER JOIN (
      SELECT
          title_id,
          COUNT(*) AS checked_out
        FROM Items
        WHERE borrower_id IS NOT NULL
        GROUP BY title_id) AS co
      ON t.title_id = co.title_id
    LEFT OUTER JOIN (
      SELECT
          title_id,
          COUNT(*) AS on_shelf
        FROM Items
        WHERE borrower_id IS NULL
        GROUP BY title_id) AS os
      ON t.title_id = os.title_id
  WHERE title_text = %(t_text)s;
--Search by partial title matche
SELECT
    t.title_id,
    t.title_text,
    t.language,
    t.publication_year,
    IFNULL(co.checked_out,0) AS num_checked_out,
    IFNULL(os.on_shelf,0) AS num_on_shelf
  FROM Titles AS t
    LEFT OUTER JOIN (
      SELECT
          title_id,
          COUNT(*) AS checked_out
        FROM Items
        WHERE borrower_id IS NOT NULL
        GROUP BY title_id) AS co
      ON t.title_id = co.title_id
    LEFT OUTER JOIN (
      SELECT
          title_id,
          COUNT(*) AS on_shelf
        FROM Items
        WHERE borrower_id IS NULL
        GROUP BY title_id) AS os
      ON t.title_id = os.title_id
  WHERE title_text LIKE %(t_text)s;
-- Qualify exact title search by whether a corresponding Item exists
SELECT
    t.title_id,
    t.title_text,
    t.language,
    t.publication_year,
    IFNULL(co.checked_out,0) AS num_checked_out,
    IFNULL(os.on_shelf,0) AS num_on_shelf
  FROM Titles AS t
    LEFT OUTER JOIN (
      SELECT
          title_id,
          COUNT(*) AS checked_out
        FROM Items
        WHERE borrower_id IS NOT NULL
        GROUP BY title_id) AS co
      ON t.title_id = co.title_id
    LEFT OUTER JOIN (
      SELECT
          title_id,
          COUNT(*) AS on_shelf
        FROM Items
        WHERE borrower_id IS NULL
        GROUP BY title_id) AS os
      ON t.title_id = os.title_id
  WHERE title_text = %(t_text)s
    AND IFNULL(co.checked_out,0) + IFNULL(os.on_shelf,0) > 0;
-- Qualify partial title search by whether a corresponding Item exists
SELECT
    t.title_id,
    t.title_text,
    t.language,
    t.publication_year,
    IFNULL(co.checked_out,0) AS num_checked_out,
    IFNULL(os.on_shelf,0) AS num_on_shelf
  FROM Titles AS t
    LEFT OUTER JOIN (
      SELECT
          title_id,
          COUNT(*) AS checked_out
        FROM Items
        WHERE borrower_id IS NOT NULL
        GROUP BY title_id) AS co
      ON t.title_id = co.title_id
    LEFT OUTER JOIN (
      SELECT
          title_id,
          COUNT(*) AS on_shelf
        FROM Items
        WHERE borrower_id IS NULL
        GROUP BY title_id) AS os
      ON t.title_id = os.title_id
  WHERE title_text LIKE %(t_text)s
    AND IFNULL(co.checked_out,0) + IFNULL(os.on_shelf,0) > 0;
-- Qualify exact title search by whether a corresponding item is available for checkout
SELECT
    t.title_id,
    t.title_text,
    t.language,
    t.publication_year,
    IFNULL(co.checked_out,0) AS num_checked_out,
    IFNULL(os.on_shelf,0) AS num_on_shelf
  FROM Titles AS t
    LEFT OUTER JOIN (
      SELECT
          title_id,
          COUNT(*) AS checked_out
        FROM Items
        WHERE borrower_id IS NOT NULL
        GROUP BY title_id) AS co
      ON t.title_id = co.title_id
    LEFT OUTER JOIN (
      SELECT
          title_id,
          COUNT(*) AS on_shelf
        FROM Items
        WHERE borrower_id IS NULL
        GROUP BY title_id) AS os
      ON t.title_id = os.title_id
  WHERE title_text = %(t_text)s
    AND IFNULL(os.on_shelf,0) > 0;
-- Qualify partial title search by whether a corresponding item is available for checkout
SELECT
    t.title_id,
    t.title_text,
    t.language,
    t.publication_year,
    IFNULL(co.checked_out,0) AS num_checked_out,
    IFNULL(os.on_shelf,0) AS num_on_shelf
  FROM Titles AS t
    LEFT OUTER JOIN (
      SELECT
          title_id,
          COUNT(*) AS checked_out
        FROM Items
        WHERE borrower_id IS NOT NULL
        GROUP BY title_id) AS co
      ON t.title_id = co.title_id
    LEFT OUTER JOIN (
      SELECT
          title_id,
          COUNT(*) AS on_shelf
        FROM Items
        WHERE borrower_id IS NULL
        GROUP BY title_id) AS os
      ON t.title_id = os.title_id
  WHERE title_text LIKE %(t_text)s
    AND IFNULL(os.on_shelf,0) > 0;

-- Queries to implement the update_title page
-- update a title with new info from the interface
UPDATE Titles SET
    title_text = %(t_text)s,
    publication_year = %(p_year)s,
    edition = %(edition)s,
    language = %(lang)s,
    call_number = %(c_num)s
  WHERE title_id = %(t_id)s;
-- Get curent info about a title to prefill form
SELECT * FROM Titles WHERE title_id = %(t_id)s;
-- Get creators associated with a title:
SELECT
    tc.creator_catalog_id,
    t.title_id,
    c.first_name,
    c.last_name
  FROM Titles as t
    NATURAL JOIN Title_Creators AS tc
    NATURAL JOIN Creators AS c
  WHERE title_id = %(t_id)s;
--Get subjects associated with a title:
SELECT
    ts.subject_catalog_id,
    t.title_id,
    s.subject_heading
  FROM Titles as t
    NATURAL JOIN Title_Subjects AS ts
    NATURAL JOIN Subjects AS s
  WHERE title_id = %(t_id)s;
--populate a  list of creators to associate
SELECT * FROM Creators;
--populate a  list of creators to associate
SELECT * FROM Subjects;
--populate a dropdown list so we can switch which title we are working with
SELECT title_text, title_id FROM Titles ORDER BY title_text;
--Delete from the m:m relationship Title_Creators
DELETE FROM Title_Creators WHERE creator_catalog_id = %(creator_catalog_id)s;
--Delete from the m:m relationship Title_Subjects
DELETE FROM Title_Subjects WHERE subject_catalog_id = %(subject_catalog_id)s;
--Create to the m:m relationship Title_Creators
INSERT INTO Title_Creators (title_id, creator_id) VALUES (%(title_id)s, %(creator_id)s);
--Get into about an added Title-Creator link
SELECT * FROM Creators WHERE creator_id = %(creator_id)s;
--Create to the m:m relationship Title_Subjects
INSERT INTO Title_Subjects (title_id, subject_id) VALUES (%(title_id)s, %(subject_id)s);
--Get into about an added Title-Subject link
SELECT * FROM Subjects WHERE subject_id = %(subject_id)s;

-- Queries to support adding additional copies (Items) linke to a Title
-- add an Item
INSERT INTO Items (title_id, cutter_number) VALUES (%(t_id)s, %(c_num)s);
-- return info about an Item
SELECT
    i.cutter_number,
    t.title_text,
    t.call_number
  FROM Items AS i
    NATURAL JOIN Titles AS t
  WHERE i.item_id = %(i_id)s;
-- Get info about the current title being worked with
SELECT title_text, title_id FROM Titles WHERE title_id=%(t_id)s;
--Populate a dropdown for switching titles
SELECT title_text, title_id FROM Titles ORDER BY title_text;
-- Show current Items associated with the current title
SELECT
    i.cutter_number,
    t.title_text,
    t.call_number
  FROM Items AS i
    NATURAL JOIN Titles AS t
  WHERE t.title_id = %(t_id)s;

-- Add a new creator
INSERT INTO Creators (first_name, last_name) VALUES (%(fname)s, %(lname)s);

--Searching for creators:
--search by last name exact match:
SELECT * FROM Creators WHERE last_name = %(lname)s;
--search by last name partial match %(lname)s has '%' appended and prepended by code:
SELECT * FROM Creators WHERE last_name LIKE %(lname)s;
