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
/*INSERT INTO `specialist` VALUES
	(NULL,'ben','$2a$10$785qQeFrhYCa3msJxvIvHuRKTlnsvOcrG4hy2hODlYO7fnPGCE9/e','Ben','Toll','ben@example.com',90,1),
	(NULL,'pete','$2a$10$Gge5yYdrFZ/v2o8w.fcK5O.fjn1fmRPGwyIDUekjPnAIlIxwS8Fda','Pete','Toll','pete@example.com',0.22,2),
	(NULL,'molly','$2a$10$XxZRIOWUhFXJE6qc4xBMS.RgT6VhpQYzRbcaL8IlnEOQAmWwNjcFW','Molly','Toll','molly@example.com',1.17,2),
	(NULL,'leta','$2a$10$4HIZLPOuBl7xO7PaphtpvuGN4ymU2T//cnxsbZo7vNlfvB4HqPHMy','Leta','Deatrick','leta@example.com',1000,1);
*/
INSERT INTO `specialist` VALUES (1,'ben','$2a$10$785qQeFrhYCa3msJxvIvHuRKTlnsvOcrG4hy2hODlYO7fnPGCE9/e','Ben','Toll','ben@example.com',90,1),(2,'pete','$2a$10$Gge5yYdrFZ/v2o8w.fcK5O.fjn1fmRPGwyIDUekjPnAIlIxwS8Fda','Pete','Toll','pete@example.com',0.22,2),(3,'molly','$2a$10$XxZRIOWUhFXJE6qc4xBMS.RgT6VhpQYzRbcaL8IlnEOQAmWwNjcFW','Molly','Toll','molly@example.com',1.17,2),(4,'leta','$2a$10$4HIZLPOuBl7xO7PaphtpvuGN4ymU2T//cnxsbZo7vNlfvB4HqPHMy','Leta','Deatrick','leta@example.com',1000,1),(5,'jodi','$2a$10$MzhJyFESyZG1dQRFTBmlJeyuluIbLDI8jf1i2L2MgtMrn60rlQGYK','Jodi - Empowering Vision','Perez','jperezcpss@gmail.com',20,2),(6,'paul','$2a$10$44nNDUfLZjdAB6UB7141/.dQMBPwEsRNW9abPO2A2AWpVA8nCiJ5S','Paul','Whitman','Paulcpss@gmail.com',12.5,2),(7,'maribel','$2a$10$xd8prJjIrziA6uymJEvOL.1PLYArLnVJ91rz1EUo.Td8anTUQ8BsO','Maribel','Cintron','Maribelcpss@gmail.com',14,2),(8,'lora','$2a$10$Z6cBXwOZzXzPLSgFHg71Eubzd8W4gUNePxrtRyz8Tk69CoUapiWwe','Lora','Crowder','Loracpss@gmail.com',13,2),(9,'raphael','$2a$10$FZr9NcAyIxeT3ZLuSPaKC.BEwbpoRM.Efw8cKj8NPLR/1RpIPjpA2','Raphael','LaRocca','Raphaelcpss@gmail.com',12,2),(10,'marie','$2a$10$0zwl6weFa7B9cTZmOMJs5O/aFWlHcMdEBSJwca0XVoAhtOkyXbqxG','Marie','Maloney','MarieMcpss@mail.com',13,2),(11,'isela','$2a$10$oB/CE.OhYDOAmKoRUmong.q8nQOsV1pl2jVwOHzMWVEXoMLKbDkkO','Isela','Mendez','Iselacpss@gmail.com',12,2),(12,'alfred','$2a$10$dttp1lDOJ88ap4a/89s3beF5wxBuWynEEy.t1fOR2BHnvgw4aAGeO','Alfred','Moten','Alfredcpss@gmail.com',13,2),(13,'shapre','$2a$10$Hm0exURqQNmRLES5Zw7WIeUSgdYCpsRlbfkqrzBvIajxbT5cRi13O','Shapre','Ranson','Shaprecpss@gmail.com',13,2),(14,'lisa','$2a$10$YJZCq1nGUDnceoVLHQaM7.ymSNuYUn5vA7dxFROn8lMX8/oRjlfze','Lisa','Shelly','Lisascpss@gmail.com',12,2),(15,'eyrania','$2a$10$h3vKBZnDpa93kIkUOcoY/OUdeGIKDOwqnl3qizw88EH6q.2Jq.DyG','Eyrania','Smith-Lewis','Goldiecpss@gmail.com',14,2),(16,'elsie','$2a$10$WeryLB7fLez0JhqWvYB7M.I6wBiEjlG6baupArfcjYs4eJL/ZSyvu','Elsie','Thames','Elsiecpss@gmail.com',14,2),(17,'kwjalyn','$2a$10$6DGImSdA7.FmIq0qM4b2J.XfHHRDT/6qrHR.bn8SyR4kJ0hm/Tq6.','Kwjalyn - Exquisite Service','Perez','Kwjalyncpss@gmail.com',12,2),(18,'heather','$2a$10$lk/HShrt.ozD1/OzRejo7.J24m3HAIRLVVI/2bCvZzVkSSIAvmMQS','Heather ','Umpleby','Heathercpss@gmail.com',15,2),(19,'seihrahbi','$2a$10$xBt44qEy1YXLwiTVYWpw4e6B6/jnDlawHSfs.BpoAuxlb.Gsd7k3W','Seihrahbi','Walker','Seihrahbicpss@gmail.com',14,2),(20,'cheri','$2a$10$CgHxOAZzHYxfSB7sy7ijFeog2EAmqsNZo2gYuTvVeyM8u649gRgsq','Cheri','White','Chericpss@gmail.com',13,2),(21,'aaron','$2a$10$Lr45XXZxj6nPSn1Gy4cW3OWTTSDx2PDIcX8mCDJu7OtNcBRGcEhI2','Aaron','Alton','Aaronacpss@gmail.com',14,2),(22,'jasmine','$2a$10$bjn6lcqe/4D4oENEAl0APeYqFUawrYRaLEMZ9skgADfJjOUi/e0sK','Jasmine','Baity','Jasminecpss@gmail.com',12,2),(23,'laci','$2a$10$GmUpyV7H52YU1MNCroj9zuN3AMOcV1cFHg24pJubkezjSH4/grPcO','Laci','Chambers','Lacicpss@gmail.com',12,2),(24,'Yaqinah','$2a$10$Xwc.IkJ72EBx3JnSqshbDOrUs5Uh6TIFNDBaLM3ip//F3adr6Tkle','Yaqinah - Divinty, Inc.','Abdur-Rahman','Yaqinahcpss@gmail.com',14,2),(25,'tyquann','$2a$10$MOTwi9LjPfKhXSOwTuIOR.kGNB54sOckUI7aLnGQOKH/D5ub0HgAC','Tyquann - TMB Services','Brown','Tyquanncpss@gmail.com',13,2),(26,'jessica','$2a$10$ocb6yiBgzEur.iFCPEH3deZXxKhJvE.iRSXXA8PKTv0woLDlwbwbi','Jessica - J & B Services','Baer','JBcpss@gmail.com',13,2),(27,'terrell','$2a$10$KmZI68MxuZoCBE123lrRfeFpXPbf6FRbC2jxLXzhQ25JIxFzQW9vy','Terrell - TAC Services','Chisholm','Terrellcpss@gmail.com',13,2),(28,'steve','$2a$10$xZfva7EEUmvXLkBxBB1eTOg10TU5InLRjSpvUELgB7XNNimeveTUG','Steve - JTC Services','Mack','smackcpss@gmail.com',14,2);
/*!40000 ALTER TABLE `specialist` ENABLE KEYS */;
UNLOCK TABLES;

