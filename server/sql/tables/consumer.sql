USE cpss;

DROP TABLE IF EXISTS `consumer` ;

CREATE TABLE IF NOT EXISTS `consumer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(100) DEFAULT NULL,
  `lastname` varchar(100) DEFAULT NULL,
  `active` tinyint DEFAULT 1,
  `county` mediumint DEFAULT -1,
  `fundingSource` int(11) DEFAULT NULL,
  `zip` varchar(30) DEFAULT NULL,
  `bsu` varchar(100) DEFAULT NULL,
  `recipientID` varchar(100) DEFAULT NULL,
  `dia` varchar(100) DEFAULT NULL,
  `other` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
  /*CONSTRAINT `fkactive` FOREIGN KEY (`active`) REFERENCES `active` (`active_id`),*/
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `consumer` WRITE;
/*!40000 ALTER TABLE `consumer` DISABLE KEYS */;
INSERT INTO `consumer` VALUES (1,'Rickety','Cricket',1,21,2,'17011','bsu','foo','1','other'),(2,'Malcolm','X',1,53,1,'16720','bsuuu','recpi','1','other2');
/*!40000 ALTER TABLE `consumer` ENABLE KEYS */;
UNLOCK TABLES;

