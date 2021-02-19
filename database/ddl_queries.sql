--
-- Drop tables if they already exist.
--

DROP TABLE IF EXISTS `Title_Creators`;
DROP TABLE IF EXISTS `Title_Subjects`;
DROP TABLE IF EXISTS `Items`;
DROP TABLE IF EXISTS `Titles`;
DROP TABLE IF EXISTS `Borrowers`;
DROP TABLE IF EXISTS `Creators`;
DROP TABLE IF EXISTS `Subjects`;

--
-- Table structure for table `Titles`
--

CREATE TABLE `Titles` (
  `title_id` int NOT NULL AUTO_INCREMENT,
  `title_text` varchar(255) NOT NULL,
  `publication_year` year DEFAULT NULL,
  `edition` varchar(255) DEFAULT NULL,
  `language` varchar(255) DEFAULT NULL,
  `call_number` varchar(255) NOT NULL,
  PRIMARY KEY (`title_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

--
-- Table structure for table `Borrowers`
--

CREATE TABLE `Borrowers` (
  `borrower_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `street_address` varchar(255) DEFAULT NULL,
  `city_name` varchar(255) DEFAULT NULL,
  `state` char(2) DEFAULT NULL,
  `zip_code` varchar(9) DEFAULT NULL,
  PRIMARY KEY (`borrower_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

--
-- Table structure for table `Items`
--

CREATE TABLE `Items` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `title_id` int NOT NULL,
  `borrower_id` int DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `cutter_number` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`item_id`),
  CONSTRAINT `item2title` FOREIGN KEY (`title_id`) REFERENCES `Titles` (`title_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `item2borrower` FOREIGN KEY (`borrower_id`) REFERENCES `Borrowers` (`borrower_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

--
-- Table structure for table `Creators`
--

CREATE TABLE `Creators` (
  `creator_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255),
  `last_name` varchar(255) NOT NULL,
  PRIMARY KEY (`creator_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

--
-- Table structure for table `Subjects`
--

CREATE TABLE `Subjects` (
  `subject_id` int NOT NULL AUTO_INCREMENT,
  `subject_heading` varchar(255) NOT NULL,
  PRIMARY KEY (`subject_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

--
-- Table structure for table `Title_Creators`
--

CREATE TABLE `Title_Creators` (
  `creator_catalog_id` int NOT NULL AUTO_INCREMENT,
  `title_id` int NOT NULL,
  `creator_id` int NOT NULL,
  PRIMARY KEY (`creator_catalog_id`),
  CONSTRAINT `Title_Creators_fk_title_id` FOREIGN KEY (`title_id`) REFERENCES `Titles` (`title_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Title_Creators_fk_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `Creators` (`creator_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

--
-- Table structure for table `Title_Subjects`
--

CREATE TABLE `Title_Subjects` (
  `subject_catalog_id` int NOT NULL AUTO_INCREMENT,
  `title_id` int NOT NULL,
  `subject_id` int NOT NULL,
  PRIMARY KEY (`subject_catalog_id`),
  CONSTRAINT `Title_Subjects_fk_title_id` FOREIGN KEY (`title_id`) REFERENCES `Titles` (`title_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Title_Subjects_fk_subject_id` FOREIGN KEY (`subject_id`) REFERENCES `Subjects` (`subject_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

--
-- Sample Data
--
INSERT INTO `Borrowers`
  (first_name, last_name, email, street_address, city_name, state, zip_code) VALUES
  ('John','Doe','john@example.com','123 Anystreet','Sometown','OR','98765'),
  ('Mary','Moe','mary@mail.com','567 Anystreet','Sometown','OR','98765'),
  ('July','Dooley','july@greatstuff.com','123 Avenue A','Sometown','OR','98765'),
  ('Anja','Ravendale','a_r@test.com','123 South Dr.','Sometown','OR','98765');

INSERT INTO Titles
  (title_text, publication_year, edition, language, call_number) VALUES
  ('Relational Database Design and Implementation', 2016, '4', 'English', '005.756'),
  ('Frankly, Fitz!', 1992, NULL, 'English', '976.3063092'),
  ('Akata Witch', 2011, '1st US', 'English', 'FIC'),
  ('Tacopedia', 2015, 'English', 'English', '641.840972'),
  ('Workbenches: from Design and Thoery to Construction & Use', 2015, 'Revised', 'English', '684.18'),
  ('Colonel Roosevelt', 2011, 'Trade Paperback', 'English', '973.911092');

INSERT INTO Items
  (title_id, borrower_id, due_date, cutter_number) VALUES
  (1, 1, '2021-04-01', 'H299'),
  (2, NULL, NULL, 'F557'),
  (3,NULL,NULL,NULL),
  (5,3, '2020-12-31', 'SCH411');

INSERT INTO `Creators`
  (`first_name`, `last_name`) VALUES
  ('Ernest', 'Hemingway'),
  ('Mark', 'Twain'),
  ('J.K.', 'Rowling'),
  ('Stephen', 'King'),
  ('James Edward', 'Fitzmorris'),
  ('Kenneth D.', 'Myers'),
  ('Nnedi', 'Okorafor'),
  ('Edmund', 'Morris');

INSERT INTO `Subjects`
  (`subject_heading`) VALUES
  ('Fantasy'),
  ('Science Fiction'),
  ('Action & Adventure'),
  ('Mystery'),
  ('Horror'),
  ('Romance'),
  ('Biography'),
  ('Textbook');

INSERT INTO `Title_Creators`
  (`title_id`, `creator_id`) VALUES
  ((SELECT title_id FROM `Titles` WHERE title_text = 'Frankly, Fitz!'),
    (SELECT creator_id FROM `Creators` WHERE first_name = 'James Edward' and last_name = 'Fitzmorris')),
  ((SELECT title_id FROM `Titles` WHERE title_text = 'Frankly, Fitz!'),
    (SELECT creator_id FROM `Creators` WHERE first_name = 'Kenneth D.' and last_name = 'Myers')),
  ((SELECT title_id FROM `Titles` WHERE title_text = 'Akata Witch'),
    (SELECT creator_id FROM `Creators` WHERE first_name = 'Nnedi' and last_name = 'Okorafor')),
  ((SELECT title_id FROM `Titles` WHERE title_text = 'Colonel Roosevelt'),
    (SELECT creator_id FROM `Creators` WHERE first_name = 'Edmund' and last_name = 'Morris'));

INSERT INTO `Title_Subjects`
  (`title_id`, `subject_id`) VALUES
  ((SELECT title_id FROM `Titles` WHERE title_text = 'Colonel Roosevelt'),
    (SELECT subject_id FROM `Subjects` WHERE subject_heading = 'Biography')),
  ((SELECT title_id FROM `Titles` WHERE title_text = 'Frankly, Fitz!'),
    (SELECT subject_id FROM `Subjects` WHERE subject_heading = 'Biography')),
  ((SELECT title_id FROM `Titles` WHERE title_text = 'Akata Witch'),
    (SELECT subject_id FROM `Subjects` WHERE subject_heading = 'Fantasy')),
  ((SELECT title_id FROM `Titles` WHERE title_text = 'Relational Database Design and Implementation'),
    (SELECT subject_id FROM `Subjects` WHERE subject_heading = 'Textbook'));
