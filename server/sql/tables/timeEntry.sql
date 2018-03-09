USE cpss;

DROP TABLE IF EXISTS `time_entry` ;

CREATE TABLE IF NOT EXISTS `time_entry` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `specialist` int(11) DEFAULT -1,
  `consumer` int(11) DEFAULT -1,
  `serviceDate` date DEFAULT NULL,
  `serviceCode` int(11) DEFAULT -1,
  `hours` float DEFAULT 0.0,
  `description` tinyblob DEFAULT NULL,
  `county` int(11) DEFAULT -1,
  `contractType` varchar(100) DEFAULT NULL,
  `billingCode` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`),
  CONSTRAINT `fkspecialist` FOREIGN KEY (`specialist`) REFERENCES `specialist` (`id`),
  CONSTRAINT `fkconsumer` FOREIGN KEY (`consumer`) REFERENCES `consumer` (`id`),
  /*CONSTRAINT `fkservicecode` FOREIGN KEY (`serviceCode`) REFERENCES `service_code` (`id`),*/
  CONSTRAINT `fkcounty` FOREIGN KEY (`county`) REFERENCES `county` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

