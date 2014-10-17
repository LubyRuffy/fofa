/*
 Navicat Premium Data Transfer

 Source Server         : fofa_db
 Source Server Type    : MySQL
 Source Server Version : 50620
 Source Host           : 127.0.0.1
 Source Database       : webdb

 Target Server Type    : MySQL
 Target Server Version : 50620
 File Encoding         : utf-8

 Date: 10/17/2014 19:03:39 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `active_admin_comments`
-- ----------------------------
DROP TABLE IF EXISTS `active_admin_comments`;
CREATE TABLE `active_admin_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `namespace` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `body` text COLLATE utf8_bin,
  `resource_id` varchar(255) COLLATE utf8_bin NOT NULL,
  `resource_type` varchar(255) COLLATE utf8_bin NOT NULL,
  `author_id` int(11) DEFAULT NULL,
  `author_type` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_active_admin_comments_on_author_type_and_author_id` (`author_type`,`author_id`) COMMENT '(null)',
  KEY `index_active_admin_comments_on_namespace` (`namespace`) COMMENT '(null)',
  KEY `index_active_admin_comments_on_resource_type_and_resource_id` (`resource_type`,`resource_id`) COMMENT '(null)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin ROW_FORMAT=COMPACT;

-- ----------------------------
--  Table structure for `analysis_info`
-- ----------------------------
DROP TABLE IF EXISTS `analysis_info`;
CREATE TABLE `analysis_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `server_info` text COLLATE utf8_unicode_ci,
  `cms_info` text COLLATE utf8_unicode_ci,
  `cloudsec_info` text COLLATE utf8_unicode_ci,
  `writedate` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `writedate` (`writedate`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=58 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
--  Table structure for `apicall`
-- ----------------------------
DROP TABLE IF EXISTS `apicall`;
CREATE TABLE `apicall` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `query` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=467 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
--  Table structure for `category`
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `published` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
--  Table structure for `category_rule`
-- ----------------------------
DROP TABLE IF EXISTS `category_rule`;
CREATE TABLE `category_rule` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rule_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_rule_on_category_rule` (`category_id`,`rule_id`)
) ENGINE=InnoDB AUTO_INCREMENT=532 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
--  Table structure for `charts`
-- ----------------------------
DROP TABLE IF EXISTS `charts`;
CREATE TABLE `charts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rule_id` int(11) DEFAULT NULL,
  `value` int(11) DEFAULT NULL,
  `writedate` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16824 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
--  Table structure for `error_host`
-- ----------------------------
DROP TABLE IF EXISTS `error_host`;
CREATE TABLE `error_host` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lastupdatetime` datetime DEFAULT NULL,
  `reason` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `host` (`host`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=2998979 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
--  Table structure for `exploits`
-- ----------------------------
DROP TABLE IF EXISTS `exploits`;
CREATE TABLE `exploits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `author` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `product` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `homepage` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `references` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fofaquery` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_exploits_on_filename` (`filename`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
--  Table structure for `icp`
-- ----------------------------
DROP TABLE IF EXISTS `icp`;
CREATE TABLE `icp` (
  `ID` int(11) NOT NULL DEFAULT '0' COMMENT 'ç¼–å·',
  `DWMC` varchar(255) DEFAULT NULL COMMENT 'å•ä½åç§°',
  `ZTID` bigint(18) DEFAULT NULL COMMENT 'ä¸»ä½“ç¼–å·',
  `DWXZ` varchar(512) DEFAULT NULL COMMENT 'å•ä½æ€§è´¨',
  `ZT_BAXH` varchar(255) DEFAULT NULL COMMENT 'ä¸»ä½“å¤‡æ¡ˆå·',
  `WZID` bigint(18) DEFAULT NULL COMMENT 'ç½‘ç«™ç¼–å·',
  `WZMC` varchar(255) DEFAULT NULL COMMENT 'ç½‘ç«™åç§°',
  `WZFZR` varchar(255) DEFAULT NULL COMMENT 'ç½‘ç«™è´Ÿè´£äºº',
  `SITE_URL` varchar(512) DEFAULT NULL COMMENT 'ç½‘ç«™åœ°å€',
  `YM` varchar(255) DEFAULT NULL COMMENT 'åŸŸå',
  `WZ_BAXH` varchar(255) DEFAULT NULL COMMENT 'ç½‘ç«™å¤‡æ¡ˆå·',
  `SHSJ` date DEFAULT NULL COMMENT 'å®¡æ ¸æ—¶é—´',
  `NRLX` varchar(512) DEFAULT NULL COMMENT 'å†…å®¹ç±»åž‹',
  `ZJLX` varchar(255) DEFAULT NULL COMMENT 'è¯ä»¶ç±»åž‹',
  `ZJHM` varchar(255) DEFAULT NULL COMMENT 'è¯ä»¶å·ç ',
  `SHENGID` varchar(255) DEFAULT NULL COMMENT 'çœ',
  `SHIID` varchar(255) DEFAULT NULL COMMENT 'å¸‚',
  `XIANID` varchar(255) DEFAULT NULL COMMENT 'åŽ¿',
  `XXDZ` varchar(512) DEFAULT NULL COMMENT 'è¯¦ç»†åœ°å€',
  `YMID` varchar(255) DEFAULT NULL COMMENT 'åŸŸåç¼–å·',
  PRIMARY KEY (`ID`),
  KEY `YM` (`YM`),
  KEY `DWMC` (`DWMC`) USING BTREE,
  KEY `ZJHM` (`ZJHM`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `rootdomain`
-- ----------------------------
DROP TABLE IF EXISTS `rootdomain`;
CREATE TABLE `rootdomain` (
  `did` bigint(20) NOT NULL AUTO_INCREMENT,
  `domain` varchar(255) NOT NULL,
  `telephone` varchar(50) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `whois` text,
  `whois_com` varchar(255) DEFAULT NULL,
  `ns_info` text,
  `lastchecktime` datetime DEFAULT NULL,
  PRIMARY KEY (`did`),
  KEY `idx_rootdomain_1` (`domain`),
  KEY `idx_2` (`email`),
  KEY `idx_3` (`whois_com`)
) ENGINE=InnoDB AUTO_INCREMENT=17549101 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
--  Table structure for `rule`
-- ----------------------------
DROP TABLE IF EXISTS `rule`;
CREATE TABLE `rule` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `producturl` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rule` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `published` tinyint(1) DEFAULT NULL,
  `from_rule_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_rule_on_product_and_rule` (`product`(50),`rule`,`user_id`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=523 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
--  Table structure for `schema_migrations`
-- ----------------------------
DROP TABLE IF EXISTS `schema_migrations`;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
--  Table structure for `sph_counter`
-- ----------------------------
DROP TABLE IF EXISTS `sph_counter`;
CREATE TABLE `sph_counter` (
  `counter_id` int(11) NOT NULL AUTO_INCREMENT,
  `max_id` bigint(20) NOT NULL,
  `min_id` int(11) NOT NULL DEFAULT '1',
  `index_name` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `last_updated` datetime NOT NULL,
  PRIMARY KEY (`counter_id`),
  KEY `index_name` (`index_name`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
--  Table structure for `subdomain`
-- ----------------------------
DROP TABLE IF EXISTS `subdomain`;
CREATE TABLE `subdomain` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `host` varchar(255) NOT NULL,
  `subdomain` varchar(255) DEFAULT NULL COMMENT '比如www',
  `domain` varchar(255) DEFAULT NULL,
  `reverse_domain` varchar(255) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `header` text,
  `title` varchar(255) DEFAULT NULL,
  `pr` varchar(255) DEFAULT NULL,
  `lastupdatetime` timestamp NULL DEFAULT NULL COMMENT 'last update time',
  `lastchecktime` timestamp NULL DEFAULT NULL,
  `memo` varchar(255) DEFAULT NULL COMMENT 'comment',
  `body` text,
  `app` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `host` (`host`) USING BTREE,
  KEY `updatetime` (`lastupdatetime`) USING BTREE,
  KEY `reverse_domain` (`reverse_domain`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=56448061 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `user`
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `avatar_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `avatar_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `avatar_file_size` int(11) DEFAULT NULL,
  `avatar_updated_at` datetime DEFAULT NULL,
  `isadmin` tinyint(1) DEFAULT NULL,
  `key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_user_on_email` (`email`) USING BTREE,
  UNIQUE KEY `index_user_on_reset_password_token` (`reset_password_token`) USING BTREE,
  UNIQUE KEY `index_user_on_username` (`username`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=548 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
--  Table structure for `userhost`
-- ----------------------------
DROP TABLE IF EXISTS `userhost`;
CREATE TABLE `userhost` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `clientip` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `writetime` datetime DEFAULT NULL,
  `processed` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=197022 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
