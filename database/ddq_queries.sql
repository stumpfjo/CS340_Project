--
-- Table structure for table `Titles`
--

DROP TABLE IF EXISTS `Titles`;
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

DROP TABLE IF EXISTS `Borrowers`;
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
