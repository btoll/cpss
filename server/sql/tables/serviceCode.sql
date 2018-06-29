USE cpss;

DROP TABLE IF EXISTS `service_code` ;

CREATE TABLE IF NOT EXISTS `service_code` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
--  `serviceDefinition` text text,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `service_code` WRITE;
/*!40000 ALTER TABLE `service_code` DISABLE KEYS */;
--INSERT INTO `service_code` VALUES (1,'H2023','Employment seeking skills/Interviewing/Employment Application/Soft Skills'),(2,'W9794','Supportive employment/Onsite job coaching/Job oversight');
INSERT INTO `service_code` VALUES (NULL,'H2023'),(NULL,'W9794'),(NULL,'R2112');
/*!40000 ALTER TABLE `service_code` ENABLE KEYS */;
UNLOCK TABLES;

