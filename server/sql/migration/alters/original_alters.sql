alter table appSpecialist drop column Full_Name;
alter table appSpecialist drop column SecGroup;
alter table appSpecialist drop column RatePercentage;
alter table appSpecialist drop column RateLevel;
alter table appSpecialist change column Rate payrate float default 0.0;
alter table appSpecialist change column SpecialistID id int(11) not null auto_increment;
alter table appSpecialist change column Username username varchar(255) not null;
alter table appSpecialist change column Last lastname varchar(100) not null;
alter table appSpecialist change column First firstname varchar(100) not null;
alter table appSpecialist change column Active active tinyint default 1;
alter table appSpecialist change column Email email varchar(100) not null;
alter table appSpecialist change column Password password varchar(255) not null;
alter table appSpecialist change column username username varchar(255) not null after id;
alter table appSpecialist change column password password varchar(255) not null after username;
alter table appSpecialist change column firstname firstname varchar(100) not null after password;
alter table appSpecialist change column lastname lastname varchar(100) not null after firstname;
alter table appSpecialist add authLevel int default 2;
update appSpecialist set payrate = ifnull(payrate, 0.0);
update appSpecialist set authLevel=1 where id in (1,117);
--insert into specialist (username,password,firstname,lastname,active,email,payrate,authLevel)  select username,password,firstname,lastname,active,email,payrate,authLevel from appSpecialist;

alter table appConsumer drop column OtherDescribe;
alter table appConsumer drop column RoomBoard;
alter table appConsumer drop column DischargeDate;
alter table appConsumer drop column AcctOnly;
alter table appConsumer drop column MDIDD;
alter table appConsumer drop column Other3rd;
alter table appConsumer drop column MedAsst;
alter table appConsumer drop column CoPay;
alter table appConsumer drop column unitsAllotment;
alter table appConsumer drop column FullName;
alter table appConsumer change column ConsumerID id int(11) not null auto_increment;
alter table appConsumer change column Active active tinyint default 1 after Last;

alter table appConsumer change column Last lastname varchar(100) default null;
alter table appConsumer change column First firstname varchar(100) default null after id;
alter table appConsumer drop column CountyCode;
alter table appConsumer change column ZipCode zip varchar(30) default null;
alter table appConsumer change column BSU bsu varchar(100) default null;
alter table appConsumer change column RecipientID recipientID varchar(100) default null;
alter table appConsumer change column DiaCode dia int(1) default null;
insert into consumer (firstname,lastname,active,zip,bsu,recipientID,dia) select firstname,lastname,active,zip,bsu,recipientID,dia from appConsumer;

update consumer set fundingSource=-1 where id > 41;
update consumer set other = ifnull(other, '');
update consumer set bsu = ifnull(bsu, '');
update consumer set recipientID = ifnull(recipientID, '');
update consumer set dia = ifnull(dia, -1);
update consumer set zip = ifnull(zip, '');
update consumer set lastname = ifnull(lastname, '');
update consumer set firstname = ifnull(firstname, '');

alter table appTimeEntry drop Custom, drop ConsumerSig, drop SpecialistSig, drop Comments, drop VoeI, drop Intake, drop Ass, drop Lao, drop RehabDev, drop RehabRev, drop DevOs, drop HouseKeep, drop CS, drop PlanI, drop MSE, drop IdSkill, drop IdSup, drop DocProg, drop TTAss, drop FuncAss, drop PE, drop HE, drop ST, drop SPP, drop Lhks, drop LGSS, drop Food, drop MM, drop ComSkill, drop DevUs, drop KG, drop Assert, drop Social, drop DevNSFP, drop StartTime, drop EndTime, drop goalId, drop Imp, drop ContractCODE, drop CountyAbbr, drop ConsumerName;

alter table appTimeEntry drop BSU;
alter table appTimeEntry drop ServiceCodeResult;
alter table appTimeEntry change column Hours hours float default 0.0;
alter table appTimeEntry change column Units units float default 0.0;
alter table appTimeEntry change column RenderDate serviceDate date;
--select distinct county as c from appTimeEntry order by c;
--select count(*) from appTimeEntry where county="Huntingdon/Mifflin/Juniata";
--select count(*) from appTimeEntry where county="CPSS";
--select count(*) from appTimeEntry where county="LE-W7060";
update appTimeEntry set County=22 where County in ("Dauphin", "Dauphijn", "Daupin", "D");
update appTimeEntry set County=21 where County="Cumberland";
update appTimeEntry set County=50 where County="Juniata";
update appTimeEntry set County=50 where County="Perry";
update appTimeEntry set County=38 where County in ("Lebanon","LE-W7060");
update appTimeEntry set County=31 where County="Huntingdon/Mifflin/Juniata"; -- Huntingdon

update appTimeEntry set county=1001 where county="CPSS";

update appTimeEntry set county = ifnull(county, -1);
update appTimeEntry set county=-1 where county="";
alter table appTimeEntry change column County county int default -1;
alter table appTimeEntry change column Description description tinyblob default '';
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
alter table appTimeEntry change column ServiceCode serviceCode int(11) default -1 after serviceDate;
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
update appTimeEntry set Status = ifnull(Status, -1);
alter table appTimeEntry change column Status status smallint(6) default -1;
update appTimeEntry set consumer = ifnull(consumer, -1);
insert into billsheet (specialist,consumer,hours,units,serviceDate,serviceCode,status,county,description) select specialist,consumer,hours,units,serviceDate,serviceCode,status,county,description from appTimeEntry;

update billsheet set recipientID = ifnull(recipientID, '');
update billsheet set recordNumber = ifnull(recordNumber, '');
update billsheet set confirmation = ifnull(confirmation, '');
update billsheet set hours = ifnull(hours, 0.0);
update billsheet set units = ifnull(units, 0.0);
update billsheet set description = ifnull(description, '');
