USE cpss;

DROP TABLE IF EXISTS `pay_history` ;

CREATE TABLE IF NOT EXISTS `pay_history` (
  `id` int(2) NOT NULL  AUTO_INCREMENT,
  `specialist` int DEFAULT -1,
  `changeDate` date DEFAULT NULL,
  `payrate` float DEFAULT 0.0,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
--  CONSTRAINT `fkspecialist` FOREIGN KEY (`specialist`) REFERENCES `specialist` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `pay_history` WRITE;
/*!40000 ALTER TABLE `pay_history` DISABLE KEYS */;
INSERT INTO `pay_history` VALUES
	(NULL,1,'1992-05-04',90),
	(NULL,2,'1992-05-04',0.22),
	(NULL,3,'1992-05-04',1.17),
	(NULL,4,'1992-05-04',1000);
/*!40000 ALTER TABLE `pay_history` ENABLE KEYS */;
UNLOCK TABLES;

