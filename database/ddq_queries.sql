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
  `cutter_number` varchar(255) NOT NULL,
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
