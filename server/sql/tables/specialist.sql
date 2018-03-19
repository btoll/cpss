USE cpss;

DROP TABLE IF EXISTS `specialist` ;

CREATE TABLE IF NOT EXISTS `specialist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `firstname` varchar(100) DEFAULT NULL,
  `lastname` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `payrate` double DEFAULT 0,
  `authLevel` int DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `specialist` WRITE;
/*!40000 ALTER TABLE `specialist` DISABLE KEYS */;
INSERT INTO `specialist` VALUES
	(null,'ben','bcade5095df6aac49c938e70b94def2a4321a7b445614766ab51d5bf217bdd5e','Ben','Toll','ben@example.com',90,1);
/*!40000 ALTER TABLE `specialist` ENABLE KEYS */;
UNLOCK TABLES;

