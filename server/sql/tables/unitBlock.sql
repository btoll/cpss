USE cpss;

DROP TABLE IF EXISTS `unit_block` ;

CREATE TABLE IF NOT EXISTS `unit_block` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `consumer` int(11) NOT NULL,
  `serviceCode` int(11) NOT NULL,
  `units` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
--  CONSTRAINT `fkconsumer` FOREIGN KEY (`consumer`) REFERENCES `consumer` (`id`)
--  CONSTRAINT `fkserviceCode` FOREIGN KEY (`serviceCode`) REFERENCES `service_code` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `unit_block` WRITE;
/*!40000 ALTER TABLE `unit_block` DISABLE KEYS */;
INSERT INTO `unit_block` VALUES
	(NULL, 1, 1, 111),
	(NULL, 1, 2, 222),
	(NULL, 1, 3, 333),
	(NULL, 2, 2, 123),
	(NULL, 2, 3, 456);
/*!40000 ALTER TABLE `unit_block` ENABLE KEYS */;
UNLOCK TABLES;

