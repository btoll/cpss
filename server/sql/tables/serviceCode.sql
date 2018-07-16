USE cpss;

DROP TABLE IF EXISTS `service_code` ;

CREATE TABLE IF NOT EXISTS `service_code` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
--  `serviceDefinition` text text,
  `unitRate` float DEFAULT 0.0,
  `description` tinyblob DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `service_code` WRITE;
/*!40000 ALTER TABLE `service_code` DISABLE KEYS */;
INSERT INTO `service_code` VALUES (1,'W-7060',8.08,''),(2,'W-9794',17.75,''),(3,'H-2023',17.75,''),(4,'W-1726',6.33,''),(5,'OVR SE-000',0,''),(6,'OVR SE-000U',0,''),(7,'OVR SE-001',0,''),(8,'OVR SE-001E	',0,''),(9,'OVR SE-002',0,''),(10,'OVR SE-003	',0,''),(11,'OVR SE-004',0,''),(12,'OVR SE-005',0,''),(13,'OVR SE-009',0,''),(14,'OVR SE-010',0,''),(15,'OVR SE-011',0,''),(16,'OVR SE-100',0,''),(17,'OVR SE006',0,''),(18,'006',0,''),(19,'007',0,''),(20,'008',0,''),(21,'009',0,''),(22,'079',0,''),(23,'079-F',0,''),(24,'102',0,''),(25,'103',0,''),(26,'104',0,''),(27,'105',0,''),(28,'1727',0,''),(29,'1820',0,''),(30,'4505-T',0,''),(31,'59815',0,''),(32,'59822',0,''),(33,'7068',0,''),(34,'7235',0,''),(35,'7283',0,''),(36,'EI-7235 C#1',0,''),(37,'EI-7235 C#10',0,''),(38,'EI-7235 C#2',0,''),(39,'EI-7235 C#3',0,''),(40,'EI-7235 C#4',0,''),(41,'EI-7235 C#5',0,''),(42,'EI-7253',0,''),(43,'JR',0,''),(44,'TG',0,''),(45,'W-7059',0,'');
/*!40000 ALTER TABLE `service_code` ENABLE KEYS */;
UNLOCK TABLES;

