USE cpss;

DROP TABLE IF EXISTS funding_source;

CREATE TABLE IF NOT EXISTS funding_source(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `funding_source` WRITE;
/*!40000 ALTER TABLE `funding_source` DISABLE KEYS */;
INSERT INTO `funding_source` VALUES (1,'Base'),(2,'P/FDS Waiver'),(3,'Consolidated Waiver '),(6,'OVR');
/*!40000 ALTER TABLE `funding_source` ENABLE KEYS */;
UNLOCK TABLES;

