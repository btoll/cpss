USE cpss;

DROP TABLE IF EXISTS `billsheet` ;

CREATE TABLE IF NOT EXISTS `billsheet` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `specialist` int DEFAULT -1,
  `consumer` int DEFAULT -1,
  `units` float DEFAULT 0.0,
  `serviceDate` date NOT NULL,
  `serviceCode` int DEFAULT -1,
  `status` smallint DEFAULT -1,
  `billedAmount` float DEFAULT 0.0,
  `confirmation` varchar(100) DEFAULT NULL,
  `description` tinyblob DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`),
  CONSTRAINT `fkspecialist` FOREIGN KEY (`specialist`) REFERENCES `specialist` (`id`),
  CONSTRAINT `fkconsumer` FOREIGN KEY (`consumer`) REFERENCES `consumer` (`id`)
  /*CONSTRAINT `fkservicecode` FOREIGN KEY (`serviceCode`) REFERENCES `service_code` (`id`),*/
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

