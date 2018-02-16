USE cpss;

DROP TABLE IF EXISTS `billsheet` ;

CREATE TABLE IF NOT EXISTS `billsheet` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recipientID` varchar(100) DEFAULT NULL,
  `serviceDate` date DEFAULT NULL,
  `billedAmount` double DEFAULT 0,
  `consumer` mediumint DEFAULT -1,
  `status` smallint DEFAULT -1,
  `confirmation` varchar(100) DEFAULT NULL,
  `service` mediumint DEFAULT -1,
  `county` mediumint DEFAULT -1,
  `specialist` int DEFAULT -1,
  `recordNumber` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

