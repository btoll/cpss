USE cpss;

DROP TABLE IF EXISTS `active` ;

CREATE TABLE IF NOT EXISTS `active` (
  `id` tinyint DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `active` WRITE;
/*!40000 ALTER TABLE `active` DISABLE KEYS */;
INSERT INTO `active` VALUES (0),(1);
/*!40000 ALTER TABLE `active` ENABLE KEYS */;
UNLOCK TABLES;

/*select hour.* from hour inner join consumer on consumer.id = hour.consumer inner join active on consumer.active = active.active where active.id = 1;*/

