USE cpss;

DROP TABLE IF EXISTS `authLevel` ;

CREATE TABLE IF NOT EXISTS `authLevel` (
  `id` int(2) NOT NULL  AUTO_INCREMENT,
  `level` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `authLevel` WRITE;
/*!40000 ALTER TABLE `authLevel` DISABLE KEYS */;
INSERT INTO `authLevel` VALUES
	(1,'Admin'),
	(2,'User');
/*!40000 ALTER TABLE `authLevel` ENABLE KEYS */;
UNLOCK TABLES;

