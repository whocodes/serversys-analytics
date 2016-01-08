SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";


/* needs more */
CREATE TABLE IF NOT EXISTS `stats` (
  `row` int(11) NOT NULL,
  `pid` int(11) NOT NULL,
  `sid` int(11) NOT NULL,
  `time` bigint(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `maptime` (
  `row` int(11) NOT NULL,
  `mid` int(11) NOT NULL,
  `sid` int(11) NOT NULL,
  `time` bigint(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


/* needs more */
ALTER TABLE `stats`
  ADD PRIMARY KEY (`row`), ADD KEY `row` (`row`), ADD KEY `pid` (`pid`), ADD KEY `sid` (`sid`), ADD KEY `time` (`time`), ADD INDEX(`row`), ADD INDEX(`pid`), ADD INDEX(`sid`), ADD INDEX(`time`);

ALTER TABLE `maptime`
  ADD PRIMARY KEY (`row`), ADD UNIQUE KEY `mid_sid` (`mid`, `sid`), ADD KEY `row` (`row`), ADD KEY `mid` (`mid`), ADD KEY `sid` (`sid`), ADD KEY `time` (`time`), ADD INDEX(`row`), ADD INDEX(`mid`), ADD INDEX(`sid`), ADD INDEX(`time`);

ALTER TABLE `stats`
  MODIFY `row` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `maptime`
  MODIFY `row` int(11) NOT NULL AUTO_INCREMENT;
