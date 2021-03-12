-- MySQL dump 10.13  Distrib 8.0.23, for macos10.15 (x86_64)
--
-- Host: localhost    Database: cs340_project
-- ------------------------------------------------------
-- Server version	8.0.23

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Borrowers`
--

DROP TABLE IF EXISTS `Borrowers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Borrowers`
--

LOCK TABLES `Borrowers` WRITE;
/*!40000 ALTER TABLE `Borrowers` DISABLE KEYS */;
INSERT INTO `Borrowers` VALUES (1,'John','Doe','john@example.com','123 Anystreet','Sometown','OR','98765'),(2,'Mary','Moe','mary@mail.com','567 Anystreet','Sometown','OR','98765'),(3,'July','Dooley','july@greatstuff.com','123 Avenue A','Sometown','OR','98765'),(4,'Anja','Ravendale','a_r@test.com','123 South Dr.','Sometown','OR','98765'),(5,'Jon','Frosch','jon@test.com','123 Canal','New Orleans','LA','70119');
/*!40000 ALTER TABLE `Borrowers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Creators`
--

DROP TABLE IF EXISTS `Creators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Creators` (
  `creator_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) NOT NULL,
  PRIMARY KEY (`creator_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Creators`
--

LOCK TABLES `Creators` WRITE;
/*!40000 ALTER TABLE `Creators` DISABLE KEYS */;
INSERT INTO `Creators` VALUES (1,'Ernest','Hemingway'),(2,'Mark','Twain'),(3,'J.K.','Rowling'),(4,'Stephen','King'),(5,'James Edward','Fitzmorris'),(6,'Kenneth D.','Myers'),(7,'Nnedi','Okorafor'),(8,'Edmund','Morris'),(9,'Cixin','Liu'),(10,'Ken','Liu'),(11,'Joel','Martinsen'),(12,'Charles Henry','Edwards'),(13,'David','Penney'),(14,'Susan','Hanson'),(15,'Genevieve','Giuliano'),(16,'Agatha','Christie'),(17,'Ferdinand P','Beer'),(18,'E. Russell','Johnston, Jr.'),(19,'John T.','DeWolf'),(20,'David F.','Mazurek'),(21,'Lindsay','Ellis');
/*!40000 ALTER TABLE `Creators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Items`
--

DROP TABLE IF EXISTS `Items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Items` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `title_id` int NOT NULL,
  `borrower_id` int DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `cutter_number` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`item_id`),
  KEY `item2title` (`title_id`),
  KEY `item2borrower` (`borrower_id`),
  CONSTRAINT `item2borrower` FOREIGN KEY (`borrower_id`) REFERENCES `Borrowers` (`borrower_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `item2title` FOREIGN KEY (`title_id`) REFERENCES `Titles` (`title_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Items`
--

LOCK TABLES `Items` WRITE;
/*!40000 ALTER TABLE `Items` DISABLE KEYS */;
INSERT INTO `Items` VALUES (1,1,1,'2021-04-01','H299'),(2,2,NULL,NULL,'F557'),(3,3,4,'2021-03-26',NULL),(4,5,3,'2020-12-31','SCH411'),(5,22,2,'2021-03-26','R762'),(6,20,NULL,NULL,'EL47'),(7,20,4,'2021-03-26','EL47c2'),(8,20,NULL,NULL,'EL47c3'),(9,15,NULL,NULL,'C555'),(10,14,NULL,NULL,'C555'),(11,12,NULL,NULL,'C555'),(12,13,NULL,NULL,'C555'),(13,7,NULL,NULL,'L783'),(14,7,NULL,NULL,'L783'),(15,8,NULL,NULL,'L783'),(16,11,NULL,NULL,'G956'),(17,23,NULL,NULL,'T867'),(18,18,NULL,NULL,'R263'),(19,18,1,'2021-03-26','R263'),(20,18,NULL,NULL,'R263'),(21,16,NULL,NULL,'C555'),(22,17,NULL,NULL,'T649'),(23,6,NULL,NULL,'R781'),(24,10,NULL,NULL,'ED26'),(25,4,1,'2021-03-26','H758'),(26,4,NULL,NULL,'H758c2');
/*!40000 ALTER TABLE `Items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Subjects`
--

DROP TABLE IF EXISTS `Subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Subjects` (
  `subject_id` int NOT NULL AUTO_INCREMENT,
  `subject_heading` varchar(255) NOT NULL,
  PRIMARY KEY (`subject_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Subjects`
--

LOCK TABLES `Subjects` WRITE;
/*!40000 ALTER TABLE `Subjects` DISABLE KEYS */;
INSERT INTO `Subjects` VALUES (1,'Fantasy'),(2,'Science Fiction'),(3,'Action & Adventure'),(4,'Mystery'),(5,'Horror'),(6,'Romance'),(7,'Biography'),(8,'Textbook'),(9,'Translation'),(10,'Cities'),(11,'Transportation'),(12,'Strength of Materials'),(13,'Cookbook'),(14,'Travel'),(15,'Tacos');
/*!40000 ALTER TABLE `Subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Title_Creators`
--

DROP TABLE IF EXISTS `Title_Creators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Title_Creators` (
  `creator_catalog_id` int NOT NULL AUTO_INCREMENT,
  `title_id` int NOT NULL,
  `creator_id` int NOT NULL,
  PRIMARY KEY (`creator_catalog_id`),
  KEY `Title_Creators_fk_title_id` (`title_id`),
  KEY `Title_Creators_fk_creator_id` (`creator_id`),
  CONSTRAINT `Title_Creators_fk_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `Creators` (`creator_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Title_Creators_fk_title_id` FOREIGN KEY (`title_id`) REFERENCES `Titles` (`title_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Title_Creators`
--

LOCK TABLES `Title_Creators` WRITE;
/*!40000 ALTER TABLE `Title_Creators` DISABLE KEYS */;
INSERT INTO `Title_Creators` VALUES (1,2,5),(2,2,6),(3,3,7),(4,6,8),(5,7,9),(6,7,10),(7,8,9),(8,8,11),(9,9,9),(10,9,10),(11,10,12),(12,10,13),(13,11,14),(14,11,15),(15,12,16),(16,13,16),(17,14,16),(18,15,16),(19,16,16),(20,19,17),(21,19,18),(22,19,19),(23,19,20),(24,20,21);
/*!40000 ALTER TABLE `Title_Creators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Title_Subjects`
--

DROP TABLE IF EXISTS `Title_Subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Title_Subjects` (
  `subject_catalog_id` int NOT NULL AUTO_INCREMENT,
  `title_id` int NOT NULL,
  `subject_id` int NOT NULL,
  PRIMARY KEY (`subject_catalog_id`),
  KEY `Title_Subjects_fk_title_id` (`title_id`),
  KEY `Title_Subjects_fk_subject_id` (`subject_id`),
  CONSTRAINT `Title_Subjects_fk_subject_id` FOREIGN KEY (`subject_id`) REFERENCES `Subjects` (`subject_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Title_Subjects_fk_title_id` FOREIGN KEY (`title_id`) REFERENCES `Titles` (`title_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Title_Subjects`
--

LOCK TABLES `Title_Subjects` WRITE;
/*!40000 ALTER TABLE `Title_Subjects` DISABLE KEYS */;
INSERT INTO `Title_Subjects` VALUES (1,6,7),(2,2,7),(3,3,1),(4,1,8),(5,7,2),(6,7,9),(7,8,2),(8,8,9),(9,9,2),(10,9,9),(12,10,8),(13,11,8),(14,11,10),(15,11,11),(16,12,4),(17,13,4),(18,14,4),(19,15,4),(20,16,4),(21,17,1),(22,19,8),(23,19,12),(24,20,2),(25,21,12),(26,22,12),(27,4,13),(28,4,14),(29,4,15);
/*!40000 ALTER TABLE `Title_Subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Titles`
--

DROP TABLE IF EXISTS `Titles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Titles` (
  `title_id` int NOT NULL AUTO_INCREMENT,
  `title_text` varchar(255) NOT NULL,
  `publication_year` year DEFAULT NULL,
  `edition` varchar(255) DEFAULT NULL,
  `language` varchar(255) DEFAULT NULL,
  `call_number` varchar(255) NOT NULL,
  PRIMARY KEY (`title_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Titles`
--

LOCK TABLES `Titles` WRITE;
/*!40000 ALTER TABLE `Titles` DISABLE KEYS */;
INSERT INTO `Titles` VALUES (1,'Relational Database Design and Implementation',2016,'4','English','005.756'),(2,'Frankly, Fitz!',1992,NULL,'English','976.3063092'),(3,'Akata Witch',2011,'1st US','English','FIC'),(4,'Tacopedia',2015,'English','English','641.840972'),(5,'Workbenches: from Design and Thoery to Construction & Use',2015,'Revised','English','684.18'),(6,'Colonel Roosevelt',2011,'Trade Paperback','English','973.911092'),(7,'The Three Body Problem',2014,NULL,'English','FIC'),(8,'The Dark Forest',2015,NULL,'English','FIC'),(9,'Death\'s End',2016,NULL,'English','FIC'),(10,'Elementary Linear Algebra',1988,'1','English','512.5'),(11,'The Geography of Urban Transportation',2004,'Third','English','388.4'),(12,'Ordeal by Innocence',2002,'St. Martin\'s Paperbacks','English','FIC'),(13,'Poirot Loses a Client',1985,'Third Printing','English','FIC'),(14,'Hercule Poirot\'s Christmas',2000,'Berkley','English','FIC'),(15,'Cards on the Table',1985,'Fifth Printing','English','FIC'),(16,'Murder in Retrospect',1984,'Berkley','English','FIC'),(17,'The Hobbit',1978,'British Fourth','English','FIC'),(18,'Casi se muere',2000,NULL,'Spanish','FIC'),(19,'Mechanics of Materials',2009,'5th','English','620.112'),(20,'Axiom\'s End',2020,NULL,'English','FIC'),(21,'Mastering the Art of French Cooking',2004,'First Fortieth Anniversary','English','641.5944'),(22,'The Joy of Cooking',1946,'1943','English','641.5973'),(23,'Arizona State University: Visions of a New American University',2008,'First Printing','English','378.1');
/*!40000 ALTER TABLE `Titles` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-03-12 14:32:59
