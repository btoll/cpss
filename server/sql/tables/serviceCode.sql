USE cpss;

DROP TABLE IF EXISTS `service_code` ;

CREATE TABLE IF NOT EXISTS `service_code` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

