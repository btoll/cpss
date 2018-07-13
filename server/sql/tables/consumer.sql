USE cpss;

DROP TABLE IF EXISTS `consumer` ;

CREATE TABLE IF NOT EXISTS `consumer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(100) DEFAULT NULL,
  `lastname` varchar(100) DEFAULT NULL,
  `active` tinyint DEFAULT 1,
  `county` mediumint DEFAULT -1,
  `fundingSource` int(11) DEFAULT NULL,
  `zip` varchar(30) DEFAULT NULL,
  `bsu` varchar(100) DEFAULT NULL,
  `recipientID` varchar(100) DEFAULT NULL,
  `dia` int(1) DEFAULT NULL,
  `other` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
  /*CONSTRAINT `fkactive` FOREIGN KEY (`active`) REFERENCES `active` (`active_id`),*/
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

LOCK TABLES `consumer` WRITE;
/*!40000 ALTER TABLE `consumer` DISABLE KEYS */;
INSERT INTO `consumer` VALUES (1,'Jordan','Leiby',1,21,3,'17011','2110005874 ','5900005090',2,'other'),(2,'Patrick','Lauer',1,21,2,'17050','2110080156','4201281286',1,''),(3,'David','Martin',1,21,3,'17013','2110005972 ','7501076694',2,''),(5,'Sandra','Uhler',1,21,3,'17013','2120004223','0027556794',3,''),(6,'Snezhana','Zheleva',1,21,2,'17011','2110081605 ','1001904224',3,''),(7,'Anna','Coyne',1,21,2,'17110','2120080029 ','3301153858',2,''),(8,'Theresa','Coyne',1,21,2,'17055','2120010131','8401078368',2,''),(9,'Garrett','Fischer',1,21,1,'17055','2110008421 ','0015102056',2,''),(10,'Clarence','Gardner',1,21,2,'17013','2110013185 ','2501699850',2,''),(11,'Jonathan','Kellenberger',1,21,2,'17055','5020080570 ','4801407885',2,''),(12,'Ryan','Kelly',1,21,3,'17055','2110008499 ','9401461752',2,''),(13,'Lashay','Jones',1,21,2,'17013','2110013185','2501699850',2,''),(14,'Lonie','Witmer',1,21,2,'17019','2110081450 ','1201253794',6,''),(15,'Charles','Able',1,22,3,'17109','2220032765 ','2801228921',3,''),(16,'Lauran','Donofrio',1,22,2,'17036','2220014234','0302164728',2,''),(17,'Green','Davon',1,22,3,'17109','2220035530','9202477767',3,''),(18,'Justin','Hoover',1,22,2,'17036','2220019568 ','0901555201',2,''),(19,'John','Johnson',1,22,3,'17057','2210011599 ','570005240 ',3,''),(20,'Annaliese','Nezovich',1,22,2,'17057','2220016093 ',' 7501524214',2,''),(21,'Melissa','Reed-Evans',1,22,2,'17110','2210021776','4401448354 ',2,''),(22,'Angela','Piscitelli',1,22,3,'17109','2220046913','9302000576',2,''),(23,'Mark','Adamiak',1,22,2,'17101','2220046977 ','0010199305',2,''),(24,'Michael','Chambers',1,22,3,'17028','2210020757 ','9901332677',1,''),(25,'David','Gantz',1,22,3,'17057','2220038937 ','0401297197',3,''),(26,'Shantar','Lafleur',1,22,2,'17111','2210028290 ','4201923416',3,''),(27,'Ramon','Maldonado',1,22,1,'17113','130124454','1301244545',3,''),(28,'Janelle','Longenecker',1,22,2,'17033','3810090712','6101311535',3,''),(29,'Latrina','Kilpatrick',1,22,1,'17821','2220033057 ','4202289007',2,''),(30,'Jacob','Gorse',1,22,2,'17101','2220011117','7301162447',2,''),(31,'Lewis','Minium',1,22,3,'17109','2220014434 ','7500057760',2,''),(32,'William','Napier',1,22,2,'17104','2220017736 ','1101189353',2,''),(33,'Rachel','Pelsang',1,22,2,'17101','2220044868','8501711801',2,''),(34,'Brittany','Rigilano',1,22,2,'17036','2220027067 ','0303744296',3,''),(35,'Oscar','Sherrick',1,22,1,'17109','2210003771','1101580569',2,''),(36,'Brielle','Taylor',1,22,3,'17104','2210018520','2701199883',1,''),(37,'Antonuan','Thomas',1,22,2,'17110','2220047536','0027174788',2,''),(38,'Kendall','Thomas',1,22,3,'17036','2220035084 ','8102657726',3,''),(39,'Typeacha','Thompson',1,22,2,'17110','2210016630 ','2500092610',2,''),(40,'Alison','Youngling',1,22,3,'17112','2220048692','0704633734',2,''),(41,'Michelle','Lisenby',1,22,2,'17033','211871','6000088010',2,'');
/*!40000 ALTER TABLE `consumer` ENABLE KEYS */;
UNLOCK TABLES;

