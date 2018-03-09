USE cpss;

DROP TABLE IF EXISTS `auth_level` ;

CREATE TABLE IF NOT EXISTS `auth_level` (
  `id` int(2) NOT NULL  AUTO_INCREMENT,
  `level` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `auth_level` WRITE;
/*!40000 ALTER TABLE `auth_level` DISABLE KEYS */;
INSERT INTO `auth_level` VALUES
	(1,'Admin'),
	(2,'User');
/*!40000 ALTER TABLE `auth_level` ENABLE KEYS */;
UNLOCK TABLES;

