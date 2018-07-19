-- MariaDB [cpss]> select count(*) from appSpecialist;
-- +----------+
-- | count(*) |
-- +----------+
-- |      150 |
-- +----------+
-- 1 row in set (0.00 sec)
--
-- MariaDB [cpss]> select count(*) from appSpecialist where Rate=0;
-- +----------+
-- | count(*) |
-- +----------+
-- |      131 |
-- +----------+
-- 1 row in set (0.00 sec)

USE cpss;

DROP TABLE IF EXISTS `specialist` ;

CREATE TABLE IF NOT EXISTS `specialist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(30) NOT NULL,
  `password` varchar(255) NOT NULL,
  `firstname` varchar(30) DEFAULT NULL,
  `lastname` varchar(30) DEFAULT NULL,
  `active` tinyint DEFAULT 1,
  `email` varchar(50) DEFAULT NULL,
  `payrate` float DEFAULT 0.0,
  `authLevel` int DEFAULT 2,
  PRIMARY KEY (`id`),
  KEY `ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;

alter table appSpecialist drop column Full_Name;
alter table appSpecialist drop column RateLevel;
alter table appSpecialist drop column RatePercentage;

insert into specialist (id,username,password,firstname,lastname,active,email,payrate) select SpecialistID,Username,Password,First,Last,Active,Email,Rate from appSpecialist;

-- MariaDB [cpss]> select SpecialistID from appSpecialist where SecGroup in ("Admin","1");
-- +--------------+
-- | SpecialistID |
-- +--------------+
-- |            1 |
-- |           54 |
-- |           55 |
-- |          117 |
-- +--------------+
-- 4 rows in set (0.00 sec)

update specialist join appSpecialist appspec on appspec.SpecialistID = specialist.id set specialist.authLevel=1 where specialist.id in ( select SpecialistID from appSpecialist where SecGroup in ("Admin","1") );
update specialist set payrate = ifnull(payrate, 0.0);

