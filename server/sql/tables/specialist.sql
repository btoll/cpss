USE cpss;

DROP TABLE IF EXISTS `specialist` ;

CREATE TABLE IF NOT EXISTS `specialist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `lastname` varchar(70) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `payrate` double DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ;

