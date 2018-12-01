-- MariaDB [cpss]> select count(*) from appTimeEntry;
-- +----------+
-- | count(*) |
-- +----------+
-- |    26406 |
-- +----------+
-- 1 row in set (0.00 sec)

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
  `confirmation` varchar(50) DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
  /*-CONSTRAINT `fkspecialist` FOREIGN KEY (`specialist`) REFERENCES `specialist` (`id`),
  CONSTRAINT `fkconsumer` FOREIGN KEY (`consumer`) REFERENCES `consumer` (`id`),
  /*CONSTRAINT `fkservicecode` FOREIGN KEY (`serviceCode`) REFERENCES `service_code` (`id`),*/
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

alter table appTimeEntry drop Custom, drop ConsumerSig, drop SpecialistSig, drop Comments, drop VoeI, drop Intake, drop Ass, drop Lao, drop RehabDev, drop RehabRev, drop DevOs, drop HouseKeep, drop CS, drop PlanI, drop MSE, drop IdSkill, drop IdSup, drop DocProg, drop TTAss, drop FuncAss, drop PE, drop HE, drop ST, drop SPP, drop Lhks, drop LGSS, drop Food, drop MM, drop ComSkill, drop DevUs, drop KG, drop Assert, drop Social, drop DevNSFP, drop StartTime, drop EndTime, drop goalId, drop Imp, drop ContractCODE, drop CountyAbbr, drop ConsumerName, drop BSU, drop ServiceCodeResult;

update appTimeEntry set Hours = ifnull(Hours, 0);

update appTimeEntry set ServiceCode=4 where ServiceCode="W-1726";
update appTimeEntry set ServiceCode=3 where ServiceCode="H-2023";
update appTimeEntry set ServiceCode=2 where ServiceCode="W-9794";
update appTimeEntry set ServiceCode="W-7059" where ServiceCode="W7059";
update appTimeEntry set ServiceCode="079-F" where ServiceCode="079F";
update appTimeEntry set ServiceCode=1 where ServiceCode="7060";
update appTimeEntry set ServiceCode=45 where ServiceCode="W-7059";
update appTimeEntry set ServiceCode=44 where ServiceCode="TG";
update appTimeEntry set ServiceCode=43 where ServiceCode="JR";
update appTimeEntry set ServiceCode=42 where ServiceCode="EI-7253";
update appTimeEntry set ServiceCode=41 where ServiceCode="EI-7235 C#5";
update appTimeEntry set ServiceCode=40 where ServiceCode="EI-7235 C#4";
update appTimeEntry set ServiceCode=39 where ServiceCode="EI-7235 C#3";
update appTimeEntry set ServiceCode=38 where ServiceCode="EI-7235 C#2";
update appTimeEntry set ServiceCode=37 where ServiceCode="EI-7235 C#10";
update appTimeEntry set ServiceCode=36 where ServiceCode="EI-7235 C#1";
update appTimeEntry set ServiceCode=35 where ServiceCode="7283";
update appTimeEntry set ServiceCode=34 where ServiceCode="7235";
update appTimeEntry set ServiceCode=33 where ServiceCode="7068";
update appTimeEntry set ServiceCode=32 where ServiceCode="59822";
update appTimeEntry set ServiceCode=31 where ServiceCode="59815";
update appTimeEntry set ServiceCode=30 where ServiceCode="4505-T";
update appTimeEntry set ServiceCode=29 where ServiceCode="1820";
update appTimeEntry set ServiceCode=28 where ServiceCode="1727";
update appTimeEntry set ServiceCode=27 where ServiceCode="105";
update appTimeEntry set ServiceCode=26 where ServiceCode="104";
update appTimeEntry set ServiceCode=25 where ServiceCode="103";
update appTimeEntry set ServiceCode=24 where ServiceCode="102";
update appTimeEntry set ServiceCode=23 where ServiceCode="079-F";
update appTimeEntry set ServiceCode=22 where ServiceCode="079";
update appTimeEntry set ServiceCode=21 where ServiceCode="009";
update appTimeEntry set ServiceCode=19 where ServiceCode="007";
update appTimeEntry set ServiceCode=18 where ServiceCode="006";
update appTimeEntry set ServiceCode = ifnull(ServiceCode, -1);

update appTimeEntry set Status=10 where Status="Archived";
update appTimeEntry set Status=7 where Status="Audited";
update appTimeEntry set Status=3 where Status="Authorization Issues";
update appTimeEntry set Status=1 where Status="Billed";
update appTimeEntry set Status=11 where Status="Closed";
update appTimeEntry set Status=5 where Status="Denied";
update appTimeEntry set Status=8 where Status="Hold";
update appTimeEntry set Status=12 where Status="Open";
update appTimeEntry set Status=2 where Status="Paid";
update appTimeEntry set Status=4 where Status="Paid LESS";
update appTimeEntry set Status=6 where Status="Re-Bill";

update appTimeEntry set County=22 where County in ("Dauphin", "Dauphijn", "Daupin", "D");
update appTimeEntry set County=21 where County="Cumberland";
update appTimeEntry set County=50 where County="Juniata";
update appTimeEntry set County=50 where County="Perry";
update appTimeEntry set County=38 where County in ("Lebanon","LE-W7060");
update appTimeEntry set County=31 where County="Huntingdon/Mifflin/Juniata"; /* Huntingdon */
update appTimeEntry set County=1001 where County="CPSS";
update appTimeEntry set County = ifnull(County, 1002);
update appTimeEntry set County=1002 where County='';

insert into billsheet (specialist,consumer,units,serviceDate,serviceCode,status,confirmation,description) select specialistID,consumerID,Hours*4,RenderDate,ServiceCode,Status,Confirmation,Description from appTimeEntry;

update billsheet set units = ifnull(units, 0.0);
update billsheet set status = ifnull(status, 0);
update billsheet set confirmation = ifnull(confirmation, '');
update billsheet set serviceDate = ifnull(serviceDate, '');
update billsheet set serviceCode = ifnull(serviceCode, 0);
update billsheet set description = ifnull(description, '');

update billsheet join service_code sc on billsheet.serviceCode = sc.id set billsheet.billedAmount=billsheet.units*sc.unitRate;

-- MariaDB [cpss]> update billsheet join service_code sc on billsheet.serviceCode = sc.id set billsheet.billedAmount=billsheet.units*sc.unitRate;
-- Query OK, 26274 rows affected (0.08 sec)
-- Rows matched: 26388  Changed: 26274  Warnings: 0
