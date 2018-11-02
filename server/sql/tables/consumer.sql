use cpss;

DROP TABLE IF EXISTS `consumer` ;

CREATE TABLE IF NOT EXISTS `consumer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(30) DEFAULT NULL,
  `lastname` varchar(30) DEFAULT NULL,
  `active` tinyint DEFAULT 1,
  `county` mediumint DEFAULT -1,
  `fundingSource` int(11) DEFAULT NULL,
  `bsu` varchar(30) DEFAULT NULL,
  `recipientID` varchar(30) DEFAULT NULL,
  `dia` int(1) DEFAULT NULL,
  `other` tinyblob DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
  /*CONSTRAINT `fkactive` FOREIGN KEY (`active`) REFERENCES `active` (`active_id`),*/
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

