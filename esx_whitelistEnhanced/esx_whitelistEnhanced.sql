USE `essentialmode`;

CREATE TABLE `whitelist` (
	`identifier` varchar(70) NOT NULL,
	`last_connection` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`ban_reason` text,
	`ban_until` timestamp NULL DEFAULT NULL,
	`vip` int(11) NOT NULL DEFAULT '0',

	PRIMARY KEY (`identifier`)
);