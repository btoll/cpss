USE cpss;

DROP TABLE IF EXISTS `specialist` ;

CREATE TABLE IF NOT EXISTS `specialist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `firstname` varchar(100) DEFAULT NULL,
  `lastname` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `payrate` float DEFAULT 0.0,
  `authLevel` int DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `specialist` WRITE;
/*!40000 ALTER TABLE `specialist` DISABLE KEYS */;
INSERT INTO `specialist` VALUES
	(NULL,'ben','$2a$10$785qQeFrhYCa3msJxvIvHuRKTlnsvOcrG4hy2hODlYO7fnPGCE9/e','Ben','Toll','ben@example.com',90,1),
	(NULL,'pete','$2a$10$Gge5yYdrFZ/v2o8w.fcK5O.fjn1fmRPGwyIDUekjPnAIlIxwS8Fda','Pete','Toll','pete@example.com',0.22,2),
	(NULL,'molly','$2a$10$XxZRIOWUhFXJE6qc4xBMS.RgT6VhpQYzRbcaL8IlnEOQAmWwNjcFW','Molly','Toll','molly@example.com',1.17,2),
	(NULL,'leta','$2a$10$4HIZLPOuBl7xO7PaphtpvuGN4ymU2T//cnxsbZo7vNlfvB4HqPHMy','Leta','Deatrick','leta@example.com',1000,1);
/*!40000 ALTER TABLE `specialist` ENABLE KEYS */;
UNLOCK TABLES;

