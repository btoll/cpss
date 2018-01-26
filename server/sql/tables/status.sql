USE cpss;

DROP TABLE IF EXISTS `status` ;

CREATE TABLE IF NOT EXISTS `status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ;

LOCK TABLES `status` WRITE;
/*!40000 ALTER TABLE `status` DISABLE KEYS */;
INSERT INTO `status` VALUES
	(NULL,'Billed'),
	(NULL,'Paid'),
	(NULL,'Authorization Issues'),
	(NULL,'Paid Less'),
	(NULL,'Denied'),
	(NULL,'Re-billed'),
	(NULL,'Audited'),
	(NULL,'Hold');
/*!40000 ALTER TABLE `status` ENABLE KEYS */;
UNLOCK TABLES;

