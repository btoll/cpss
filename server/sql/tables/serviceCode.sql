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
INSERT INTO `service_code` VALUES (1,'W-7060'),(2,'W-9794'),(3,'H-2023'),(4,'W-1726'),(5,'OVR SE-000'),(6,'OVR SE-000U'),(7,'OVR SE-001'),(8,'OVR SE-001E	'),(9,'OVR SE-002'),(10,'OVR SE-003	'),(11,'OVR SE-004'),(12,'OVR SE-005'),(13,'OVR SE-009'),(14,'OVR SE-010'),(15,'OVR SE-011'),(16,'OVR SE-100'),(17,'OVR SE006');
/*!40000 ALTER TABLE `service_code` ENABLE KEYS */;
UNLOCK TABLES;

