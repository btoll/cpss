USE cpss;

DROP TABLE IF EXISTS `billsheet` ;

CREATE TABLE IF NOT EXISTS `billsheet` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `specialist` int DEFAULT -1,
  `consumer` int DEFAULT -1,
  `hours` float DEFAULT 0.0,
  `units` float DEFAULT 0.0,
  `serviceDate` date DEFAULT NULL,
  `serviceCode` mediumint DEFAULT -1,
  `contractType` varchar(100) DEFAULT NULL,
  `recipientID` varchar(100) DEFAULT NULL,
  `recordNumber` varchar(100) DEFAULT NULL,
  `status` smallint DEFAULT -1,
  `billedCode` varchar(100) DEFAULT NULL,
  `billedAmount` float DEFAULT 0.0,
  `county` int DEFAULT -1,
  `confirmation` varchar(100) DEFAULT NULL,
  `description` tinyblob DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`),
  CONSTRAINT `fkspecialist` FOREIGN KEY (`specialist`) REFERENCES `specialist` (`id`),
  CONSTRAINT `fkconsumer` FOREIGN KEY (`consumer`) REFERENCES `consumer` (`id`),
  /*CONSTRAINT `fkservicecode` FOREIGN KEY (`serviceCode`) REFERENCES `service_code` (`id`),*/
  CONSTRAINT `fkcounty` FOREIGN KEY (`county`) REFERENCES `county` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

