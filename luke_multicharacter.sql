ALTER TABLE `users`
  ADD COLUMN `firstname` varchar(16) NULL DEFAULT NULL,
  ADD COLUMN `lastname` varchar(16) NULL DEFAULT NULL,
  ADD COLUMN `sex` char NULL DEFAULT NULL,
  ADD COLUMN `dateofbirth` varchar(10) NULL DEFAULT NULL,
  ADD COLUMN `height` int NULL DEFAULT NULL,
  ADD COLUMN `weight` int NULL DEFAULT NULL;