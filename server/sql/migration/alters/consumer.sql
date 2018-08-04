-- MariaDB [cpss]> select count(*) from appConsumer;
-- +----------+
-- | count(*) |
-- +----------+
-- |      485 |
-- +----------+
-- 1 row in set (0.00 sec)
--
-- MariaDB [cpss]> select count(*) from appConsumer where RecipientID is not null;
-- +----------+
-- | count(*) |
-- +----------+
-- |      277 |
-- +----------+
-- 1 row in set (0.00 sec)
--
-- MariaDB [cpss]> select count(*) from appConsumer where BSU is not null;
-- +----------+
-- | count(*) |
-- +----------+
-- |      277 |
-- +----------+
-- 1 row in set (0.00 sec)
--
-- MariaDB [cpss]> select count(*) from appConsumer where DiaCode is not null;
-- +----------+
-- | count(*) |
-- +----------+
-- |      277 |
-- +----------+
-- 1 row in set (0.00 sec)
--
-- MariaDB [cpss]> select count(*) from appConsumer where Active=1;
-- +----------+
-- | count(*) |
-- +----------+
-- |       93 |
-- +----------+
--1 row in set (0.00 sec)
--
-- MariaDB [cpss]> select count(*) from appConsumer where ConsumerID is not null;
-- +----------+
-- | count(*) |
-- +----------+
-- |      485 |
-- +----------+
-- 1 row in set (0.00 sec)
--
-- MariaDB [cpssbiz_app]> select count(*) from appConsumer where OtherDescribe is not null;
-- +----------+
-- | count(*) |
-- +----------+
-- |      234 |
-- +----------+
-- 1 row in set (0.00 sec)

-- ^^ blank rows OtherDescribe



USE cpss;

DROP TABLE IF EXISTS `consumer` ;

CREATE TABLE IF NOT EXISTS `consumer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(30) DEFAULT NULL,
  `lastname` varchar(30) DEFAULT NULL,
  `active` tinyint DEFAULT 1,
  `county` mediumint DEFAULT -1,
  `fundingSource` int(11) DEFAULT NULL,
  `zip` varchar(30) DEFAULT NULL,
  `bsu` varchar(30) DEFAULT NULL,
  `recipientID` varchar(30) DEFAULT NULL,
  `dia` int(1) DEFAULT NULL,
  `other` tinyblob DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
  /*CONSTRAINT `fkactive` FOREIGN KEY (`active`) REFERENCES `active` (`active_id`),*/
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

alter table appConsumer drop column AcctOnly;
alter table appConsumer drop column CoPay;
alter table appConsumer drop column CountyCode;
alter table appConsumer drop column DischargeDate;
alter table appConsumer drop column FullName;
alter table appConsumer drop column MDIDD;
alter table appConsumer drop column MedAsst;
alter table appConsumer drop column Other3rd;
alter table appConsumer drop column RoomBoard;
alter table appConsumer drop column unitsAllotment;

insert into consumer (id,firstname,lastname,active,zip,bsu,recipientID,dia,other) select ConsumerID,First,Last,Active,ZipCode,BSU,RecipientID,DiaCode,OtherDescribe from appConsumer;

update consumer set bsu = ifnull(bsu, '');
update consumer set dia = ifnull(dia, -1);
update consumer set firstname = ifnull(firstname, '');
update consumer set fundingSource=-1;
update consumer set lastname = ifnull(lastname, '');
update consumer set other = ifnull(other, '');
update consumer set recipientID = ifnull(recipientID, '');
update consumer set zip = ifnull(zip, '');

-- MariaDB [cpss]> select distinct CountyName from appConsumer;
-- +----------------------------+
-- | CountyName                 |
-- +----------------------------+
-- | Cumberland                 |
-- | Perry                      |
-- | Dauphin                    |
-- | Unknown                    |
-- | Lancaster                  |
-- | York                       |
-- | Adams                      |
-- |                            |
-- | Lebanon                    |
-- | Juniata                    |
-- | CPSS                       |
-- | X                          |
-- | C                          |
-- | D                          |
-- | Dauphijn                   |
-- | LE-W7060                   |
-- | Huntingdon/Mifflin/Juniata |
-- +----------------------------+
-- 17 rows in set (0.00 sec)

-- MariaDB [cpss]> select ConsumerID from appConsumer where CountyName in ("Unknown","CPSS","X","");
-- +------------+
-- | ConsumerID |
-- +------------+
-- |        145 |
-- |        150 |
-- |        172 |
-- |        177 |
-- |        198 |
-- |        208 |
-- |        234 |
-- |        235 |
-- |        236 |
-- |        237 |
-- |        271 |
-- |        285 |
-- |        291 |
-- |        310 |
-- |        363 |
-- |        387 |
-- |        368 |
-- |        369 |
-- |        370 |
-- |        373 |
-- |        391 |
-- |        392 |
-- |        411 |
-- |        431 |
-- |        445 |
-- |        446 |
-- |        447 |
-- |        448 |
-- |        468 |
-- |        486 |
-- |        487 |
-- |        518 |
-- |        524 |
-- |        525 |
-- +------------+
-- 34 rows in set (0.00 sec)

update consumer join appConsumer ac on ac.ConsumerID = consumer.id set consumer.county=21 where consumer.id in ( select ConsumerID from appConsumer where CountyName in ("Cumberland","C") );
update consumer join appConsumer ac on ac.ConsumerID = consumer.id set consumer.county=50 where consumer.id in ( select ConsumerID from appConsumer where CountyName="Perry" );
update consumer join appConsumer ac on ac.ConsumerID = consumer.id set consumer.county=22 where consumer.id in ( select ConsumerID from appConsumer where CountyName in ("Dauphin","D","Dauphijn") );
update consumer join appConsumer ac on ac.ConsumerID = consumer.id set consumer.county=36 where consumer.id in ( select ConsumerID from appConsumer where CountyName="Lancaster" );
update consumer join appConsumer ac on ac.ConsumerID = consumer.id set consumer.county=67 where consumer.id in ( select ConsumerID from appConsumer where CountyName="York" );
update consumer join appConsumer ac on ac.ConsumerID = consumer.id set consumer.county=1 where consumer.id in ( select ConsumerID from appConsumer where CountyName="Adams" );
update consumer join appConsumer ac on ac.ConsumerID = consumer.id set consumer.county=38 where consumer.id in ( select ConsumerID from appConsumer where CountyName in ("Lebanon","LE-W7060") );
update consumer join appConsumer ac on ac.ConsumerID = consumer.id set consumer.county=31 where consumer.id in ( select ConsumerID from appConsumer where CountyName="Huntingdon/Mifflin/Juniata" );

-- MariaDB [cpss]> select distinct DiaCode from appConsumer;
-- +------------------+
-- | DiaCode          |
-- +------------------+
-- |                  |
-- | NULL             |
-- | 3180             |
-- | 317              |
-- | F70              |
-- | 3182             |
-- | 319              |
-- | F71              |
-- | BiPolar Disorder |
-- | F73              |
-- | 3181             |
-- | 313.81, 314.01   |
-- | MH               |
-- | 319 Unspecified  |
-- | 318.81; 314.01   |
-- | 317 Mild         |
-- | F-71             |
-- | F-70             |
-- | F-79             |
-- | F72              |
-- | F79              |
-- +------------------+
-- 21 rows in set (0.00 sec)

update consumer join appConsumer ac on ac.ConsumerID = consumer.id set consumer.dia=2 where consumer.id in ( select ConsumerID from appConsumer where DiaCode in ("F70","F-70") );
update consumer join appConsumer ac on ac.ConsumerID = consumer.id set consumer.dia=3 where consumer.id in ( select ConsumerID from appConsumer where DiaCode in ("F71","F-71") );
update consumer join appConsumer ac on ac.ConsumerID = consumer.id set consumer.dia=1 where consumer.id in ( select ConsumerID from appConsumer where DiaCode in ("F79","F-79") );
update consumer join appConsumer ac on ac.ConsumerID = consumer.id set consumer.dia=6 where consumer.id in ( select ConsumerID from appConsumer where DiaCode="F72" );

update consumer set fundingSource=-1 WHERE id in (select ConsumerID from appConsumer where BillingType="");
update consumer set fundingSource=1 where id in (select ConsumerID from appConsumer where BillingType in ("Base", "Base Funded"));
update consumer set fundingSource=2 where id in (select ConsumerID from appConsumer where BillingType in ("P/FDS W","P/FDS","P/FDS Waiver","PFDS Waiver"," PDF Wavier","PF/DSW","PF/DF"));
update consumer set fundingSource=3 where id in (select ConsumerID from appConsumer where BillingType in ("Consolidated Waiver","Consolidated Wavier","Consolidated Waver","Consolidated W","Waiver","Consol. Waiver","C/W","Con W","Consoliidate Waiver","Cons. Wavier"));
update consumer set fundingSource=7 WHERE id in (select ConsumerID from appConsumer where BillingType="B");
update consumer set fundingSource=8 WHERE id in (select ConsumerID from appConsumer where BillingType="W");
update consumer set fundingSource=9 WHERE id in (select ConsumerID from appConsumer where BillingType="079");
update consumer set fundingSource=10 where id in (select ConsumerID from appConsumer where BillingType="Admin");
update consumer set fundingSource=11 where id in (select ConsumerID from appConsumer where BillingType="NO");
update consumer set fundingSource=12 where id in (select ConsumerID from appConsumer where BillingType="X");
update consumer set fundingSource=13 where id in (select ConsumerID from appConsumer where BillingType="103");
update consumer set fundingSource=14 where id in (select ConsumerID from appConsumer where BillingType="105");
update consumer set fundingSource=15 where id in (select ConsumerID from appConsumer where BillingType="PATH");
update consumer set fundingSource=16 where id in (select ConsumerID from appConsumer where BillingType="104");
update consumer set fundingSource=17 where id in (select ConsumerID from appConsumer where BillingType="PATH ILR");
update consumer set fundingSource=29 where id in (select ConsumerID from appConsumer where BillingType in ("7060", "W-7060"));
update consumer set fundingSource=30 where id in (select ConsumerID from appConsumer where BillingType in ("079F", "079-F"));
update consumer set fundingSource=31 where id in (select ConsumerID from appConsumer where BillingType in ("EI 7235", "EI-7235"));
update consumer set fundingSource=32 WHERE id in (select ConsumerID from appConsumer where BillingType="7235");

--MariaDB [cpss]> select id from consumer where fundingSource=-1;
--+-----+
--| id  |
--+-----+
--| 310 |
--| 387 |
--| 391 |
--| 392 |
--| 411 |
--| 431 |
--| 432 |
--| 433 |
--| 435 |
--| 436 |
--| 439 |
--| 444 |
--| 445 |
--| 446 |
--| 447 |
--| 448 |
--| 451 |
--| 464 |
--| 466 |
--| 467 |
--| 468 |
--| 473 |
--| 482 |
--| 483 |
--| 485 |
--| 486 |
--| 487 |
--| 493 |
--| 494 |
--| 504 |
--| 510 |
--| 512 |
--| 514 |
--| 515 |
--| 518 |
--| 519 |
--| 524 |
--| 525 |
--| 535 |
--| 539 |
--| 540 |
--+-----+
--41 rows in set (0.00 sec)

