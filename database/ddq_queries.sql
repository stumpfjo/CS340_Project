--
-- Table structure for table `Titles`
--

DROP TABLE IF EXISTS `Titles`;
CREATE TABLE `Titles` (
  `title_id` int(11) NOT NULL AUTO_INCREMENT,
  `title_text` varchar(255) NOT NULL,
  `publication_year` year DEFAULT NULL,
  `edition` varchar(255) DEFAULT NULL,
  `language` varchar(255) DEFAULT NULL,
  `call_number` varchar(255) NOT NULL,
  PRIMARY KEY (`title_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1;
