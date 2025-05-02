CREATE TABLE IF NOT EXISTS `mri_qshops` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` text DEFAULT  NULL,
  `jobname` text DEFAULT  NULL,
  `interaction` text DEFAULT  NULL,
  `blipdata` longtext DEFAULT NULL,
  `menucoords` longtext DEFAULT NULL,
  `storagecoords` longtext DEFAULT NULL,
  `shopcoords` longtext DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;