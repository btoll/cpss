USE cpss;

DROP TABLE IF EXISTS `consumer` ;

CREATE TABLE IF NOT EXISTS `consumer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(100) DEFAULT NULL,
  `lastname` varchar(100) DEFAULT NULL,
  `active` tinyint DEFAULT -1,
  `county` mediumint DEFAULT -1,
  `serviceCode` int(11) DEFAULT -1,
  `fundingSource` varchar(100) DEFAULT NULL,
  `zip` varchar(30) DEFAULT NULL,
  `bsu` varchar(100) DEFAULT NULL,
  `recipientID` varchar(100) DEFAULT NULL,
  `diaCode` varchar(100) DEFAULT NULL,
  `copay` double DEFAULT 0,
  `dischargeDate` date DEFAULT NULL,
  `other` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`),
  CONSTRAINT `fkserviceCode` FOREIGN KEY (`serviceCode`) REFERENCES `service_code` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

