USE cpss;

DROP TABLE IF EXISTS `service_code` ;

CREATE TABLE IF NOT EXISTS `service_code` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `service_code` WRITE;
/*!40000 ALTER TABLE `service_code` DISABLE KEYS */;
INSERT INTO `service_code` VALUES (1,'Foo'),(2,'Bar');
/*!40000 ALTER TABLE `service_code` ENABLE KEYS */;
UNLOCK TABLES;

