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

--
-- Table structure for table `Subjects`
--

--
-- Table structure for table `Title_Creators`
--

--
-- Table structure for table `Title_Subjects`
--

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

INSERT INTO items
  (title_id, borrower_id, due_date, cutter_number) VALUES
  (1, 1, '2021-04-01', 'H299'),
  (2, NULL, NULL, 'F557'),
  (3,NULL,NULL,NULL),
  (5,3, '2020-12-31', 'SCH411');
