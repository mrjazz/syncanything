-- phpMyAdmin SQL Dump
-- version 2.11.1
-- http://www.phpmyadmin.net
--
-- ����: localhost
-- ��� ���������: ��� 18 2010 �., 00:15
-- ����� �������: 5.0.77
-- ����� PHP: 5.3.2

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- ��: `sync_any_db`
--

-- --------------------------------------------------------

--
-- ��������� ������� `clients`
--

DROP TABLE IF EXISTS `clients`;
CREATE TABLE IF NOT EXISTS `clients` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `client_hash` varchar(255) default NULL,
  `client` varchar(255) default NULL,
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `deleted` tinyint(4) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- ���� ����� ������� `clients`
--

-- --------------------------------------------------------

--
-- ��������� ������� `entities`
--

DROP TABLE IF EXISTS `entities`;
CREATE TABLE IF NOT EXISTS `entities` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `transaction_id` int(11) default NULL,
  `path` text,
  `size` int(11) default NULL,
  `filedate` datetime default NULL,
  `hash` varchar(255) default NULL,
  `stored` text,
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `deleted` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- ���� ����� ������� `entities`
--

-- --------------------------------------------------------

--
-- ��������� ������� `logs`
--

DROP TABLE IF EXISTS `logs`;
CREATE TABLE IF NOT EXISTS `logs` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `client_id` int(11) default NULL,
  `level` int(11) default NULL,
  `details` text,
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `deleted` tinyint(4) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- ���� ����� ������� `logs`
--


-- --------------------------------------------------------

--
-- ��������� ������� `transactions`
--

DROP TABLE IF EXISTS `transactions`;
CREATE TABLE IF NOT EXISTS `transactions` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `entity_id` int(11) default NULL,
  `client_id` int(11) default NULL,
  `ticket` varchar(255) default NULL,
  `started` datetime default NULL,
  `finished` datetime default NULL,
  `action` int(11) default NULL,
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `deleted` tinyint(4) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- ���� ����� ������� `transactions`
--

-- --------------------------------------------------------

--
-- ��������� ������� `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(255) default NULL,
  `last_name` varchar(255) default NULL,
  `password` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `plan` varchar(25) default NULL,
  `created` datetime default NULL,
  `modified` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- ���� ����� ������� `users`
--

INSERT INTO `users` (`id`, `first_name`, `last_name`, `password`, `email`, `plan`, `created`, `modified`) VALUES
(1, 'George', 'Cloony', 'hash_password', 'cloony@mail.hollywood.com', 'free', '2010-09-17 19:11:51', '2010-09-17 19:11:52');
