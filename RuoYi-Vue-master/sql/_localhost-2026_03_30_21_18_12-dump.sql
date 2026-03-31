-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: ruoyi-data
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `app_accessory`
--

DROP TABLE IF EXISTS `app_accessory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_accessory` (
  `accessory_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint DEFAULT NULL COMMENT '归属商家 ID',
  `category_name` varchar(50) NOT NULL COMMENT '分类名称',
  `accessory_name` varchar(100) NOT NULL COMMENT '配件名称',
  `accessory_desc` varchar(500) DEFAULT NULL COMMENT '配件描述',
  `cover_image` varchar(255) DEFAULT NULL COMMENT '封面图',
  `price` decimal(10,2) NOT NULL COMMENT '价格',
  `stock` bigint NOT NULL DEFAULT '0' COMMENT '库存',
  `sales_count` bigint NOT NULL DEFAULT '0' COMMENT '销量',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态：0上架 1下架',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`accessory_id`),
  KEY `idx_app_accessory_category` (`category_name`),
  KEY `idx_app_accessory_status` (`status`),
  KEY `idx_app_accessory_price` (`price`),
  KEY `idx_app_accessory_merchant_id` (`merchant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='配件表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_accessory`
--

LOCK TABLES `app_accessory` WRITE;
/*!40000 ALTER TABLE `app_accessory` DISABLE KEYS */;
INSERT INTO `app_accessory` VALUES (1,7,'手机配件','手机电池','适配主流安卓机型的高容量电池，支持门店安装。','/profile/upload/2026/03/07/battery.png',129.00,49,6,'0','admin','2026-03-07 17:29:53','18291107686','2026-03-24 20:16:09','测试配件'),(2,7,'手机配件','手机屏幕','适配常见机型的原装品质屏幕总成，可提供安装服务。','/profile/upload/2026/03/07/screen.png',399.00,17,5,'0','admin','2026-03-07 17:29:53','18291107686','2026-03-24 17:37:53','测试配件'),(3,7,'电脑配件','笔记本风扇','适用于多型号笔记本的散热风扇组件。','/profile/upload/2026/03/07/fan.png',89.00,29,2,'0','admin','2026-03-07 17:29:53','18291107689','2026-03-30 19:57:13','下架测试配件');
/*!40000 ALTER TABLE `app_accessory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_accessory_collection`
--

DROP TABLE IF EXISTS `app_accessory_collection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_accessory_collection` (
  `collection_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_user_id` bigint NOT NULL COMMENT '收藏用户',
  `accessory_id` bigint NOT NULL COMMENT '配件 ID',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`collection_id`),
  UNIQUE KEY `uk_app_collection_user_accessory` (`app_user_id`,`accessory_id`),
  KEY `idx_app_collection_user_id` (`app_user_id`),
  KEY `idx_app_collection_accessory_id` (`accessory_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='配件收藏表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_accessory_collection`
--

LOCK TABLES `app_accessory_collection` WRITE;
/*!40000 ALTER TABLE `app_accessory_collection` DISABLE KEYS */;
INSERT INTO `app_accessory_collection` VALUES (1,1,2,'user1','2026-03-07 17:29:53','',NULL,'测试收藏');
/*!40000 ALTER TABLE `app_accessory_collection` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_accessory_order`
--

DROP TABLE IF EXISTS `app_accessory_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_accessory_order` (
  `accessory_order_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` varchar(32) NOT NULL COMMENT '订单号',
  `accessory_id` bigint NOT NULL COMMENT '配件 ID',
  `app_user_id` bigint NOT NULL COMMENT '下单用户',
  `merchant_id` bigint DEFAULT NULL COMMENT '归属商家 ID',
  `quantity` bigint NOT NULL COMMENT '数量',
  `price` decimal(10,2) NOT NULL COMMENT '单价',
  `total_amount` decimal(10,2) NOT NULL COMMENT '总金额',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态：0待处理 1已发货 2已完成 3已取消',
  `receiver_name` varchar(30) NOT NULL COMMENT '收货人',
  `receiver_phone` varchar(11) NOT NULL COMMENT '联系电话',
  `receiver_address` varchar(255) NOT NULL COMMENT '收货地址',
  `order_remark` varchar(500) DEFAULT NULL COMMENT '订单备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`accessory_order_id`),
  UNIQUE KEY `uk_app_accessory_order_no` (`order_no`),
  KEY `idx_app_accessory_order_user_id` (`app_user_id`),
  KEY `idx_app_accessory_order_accessory_id` (`accessory_id`),
  KEY `idx_app_accessory_order_status` (`status`),
  KEY `idx_app_accessory_order_create_time` (`create_time`),
  KEY `idx_app_accessory_order_merchant_id` (`merchant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='配件订单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_accessory_order`
--

LOCK TABLES `app_accessory_order` WRITE;
/*!40000 ALTER TABLE `app_accessory_order` DISABLE KEYS */;
INSERT INTO `app_accessory_order` VALUES (1,'AO202603070001',1,1,7,1,129.00,129.00,'2','李先生','13800001111','陕西省汉中市汉台区中山街 18 号','测试订单','user1','2026-03-07 17:29:53','18291107689','2026-03-24 20:16:50','初始配件订单'),(2,'AO202603241503350888',2,17,7,2,399.00,798.00,'2','贺宇','18291107686','陕西省延安市 桃园小区','','18291117686','2026-03-24 15:03:35','18291107689','2026-03-24 18:57:49',NULL),(3,'AO202603241737533646',2,10,7,1,399.00,399.00,'2','贺宇','18291107686','陕西省延安市 桃园小区','','18291107686','2026-03-24 17:37:53','18291107689','2026-03-24 18:57:42',NULL),(4,'AO202603241953215992',3,10,NULL,1,89.00,89.00,'2','贺宇','18291107686','陕西省延安市 桃园小区','','18291107686','2026-03-24 19:53:21','18291107689','2026-03-24 19:53:52',NULL),(5,'AO202603242016093907',1,10,NULL,1,129.00,129.00,'2','贺宇','18291107686','陕西省延安市 桃园小区','','18291107686','2026-03-24 20:16:09','18291107689','2026-03-24 20:16:38',NULL);
/*!40000 ALTER TABLE `app_accessory_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_after_sales_order`
--

DROP TABLE IF EXISTS `app_after_sales_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_after_sales_order` (
  `order_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` varchar(32) NOT NULL COMMENT '业务单号',
  `app_user_id` bigint NOT NULL COMMENT '提交用户',
  `merchant_id` bigint DEFAULT NULL COMMENT '接单商家',
  `product_type` varchar(100) NOT NULL COMMENT '产品类型',
  `fault_desc` varchar(500) DEFAULT NULL COMMENT '故障描述',
  `fault_images` varchar(1000) DEFAULT NULL COMMENT '故障图片，多图用逗号分隔',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态：0待接单 1已接单 2维修中 3已完成 4已取消',
  `service_remark` varchar(500) DEFAULT NULL COMMENT '处理备注',
  `contact_name` varchar(30) NOT NULL COMMENT '联系人',
  `contact_phone` varchar(11) NOT NULL COMMENT '联系电话',
  `address` varchar(255) DEFAULT '' COMMENT '服务地址',
  `accept_time` datetime DEFAULT NULL COMMENT '接单时间',
  `finish_time` datetime DEFAULT NULL COMMENT '完成时间',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `uk_app_after_sales_order_no` (`order_no`),
  KEY `idx_app_after_sales_user_id` (`app_user_id`),
  KEY `idx_app_after_sales_merchant_id` (`merchant_id`),
  KEY `idx_app_after_sales_status` (`status`),
  KEY `idx_app_after_sales_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='售后订单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_after_sales_order`
--

LOCK TABLES `app_after_sales_order` WRITE;
/*!40000 ALTER TABLE `app_after_sales_order` DISABLE KEYS */;
INSERT INTO `app_after_sales_order` VALUES (1,'AS202603070001',1,7,'手机','开机后黑屏，偶发重启。','/profile/upload/2026/03/07/after-sales-1.png','3','维修完成','李先生','13800001111','陕西省汉中市汉台区中山街 18 号','2026-03-24 15:49:10','2026-03-24 16:14:55','user1','2026-03-07 17:29:53','18291107689','2026-03-24 16:14:55','初始待接单订单'),(2,'AS202603241933329340',10,7,'手机屏幕 / AO202603241737533646','不行','','3','维修完成','贺宇','18291107686','陕西省延安市 桃园小区','2026-03-24 19:35:37','2026-03-24 19:39:32','18291107686','2026-03-24 19:33:32','18291107689','2026-03-24 19:39:31',NULL),(3,'AS202603241954271433',10,7,'笔记本风扇 / AO202603241953215992','不行','','3','维修已完成','贺宇','18291107686','陕西省延安市 桃园小区','2026-03-24 19:54:57','2026-03-24 20:02:22','18291107686','2026-03-24 19:54:27','18291107689','2026-03-24 20:02:22',NULL),(4,'AS202603242019049843',10,7,'手机电池 / AO202603242016093907','不行','','3','可以了','贺宇','18291107686','陕西省延安市 桃园小区','2026-03-24 20:19:56','2026-03-24 20:20:09','18291107686','2026-03-24 20:19:04','18291107689','2026-03-24 20:20:08',NULL),(5,'AS202603301146052978',10,7,'手机电池 / AO202603242016093907','不行','','3','完成','贺宇','18291107686','陕西省延安市 桃园小区','2026-03-30 11:46:42','2026-03-30 12:48:25','18291107686','2026-03-30 11:46:05','18291107689','2026-03-30 12:48:25',NULL),(6,'AS202603301441253202',10,7,'退货 / 手机电池 / AO202603242016093907','不行','','3','已同意售后申请','贺宇','18291107686','陕西省延安市 桃园小区','2026-03-30 16:54:28','2026-03-30 20:34:20','18291107686','2026-03-30 14:41:25','18291107689','2026-03-30 20:34:20',NULL);
/*!40000 ALTER TABLE `app_after_sales_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_merchant`
--

DROP TABLE IF EXISTS `app_merchant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_merchant` (
  `merchant_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_user_id` bigint NOT NULL COMMENT '关联 app_user.app_user_id',
  `sys_user_id` bigint NOT NULL COMMENT '关联 sys_user.user_id',
  `merchant_name` varchar(100) NOT NULL COMMENT '商家名称',
  `contact_name` varchar(30) DEFAULT '' COMMENT '联系人',
  `contact_phone` varchar(11) DEFAULT '' COMMENT '联系电话',
  `address` varchar(255) DEFAULT '' COMMENT '商家地址',
  `service_scope` varchar(255) DEFAULT '' COMMENT '服务范围',
  `merchant_desc` varchar(500) DEFAULT NULL COMMENT '商家简介',
  `city_name` varchar(50) NOT NULL DEFAULT '汉中市' COMMENT '所在城市',
  `audit_status` char(1) NOT NULL DEFAULT '0' COMMENT '审核状态：0待审核 1正常 2禁用',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`merchant_id`),
  KEY `idx_app_merchant_audit_status` (`audit_status`),
  KEY `idx_app_merchant_city_name` (`city_name`),
  KEY `idx_app_merchant_sys_user_id` (`sys_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_merchant`
--

LOCK TABLES `app_merchant` WRITE;
/*!40000 ALTER TABLE `app_merchant` DISABLE KEYS */;
INSERT INTO `app_merchant` VALUES (1,2,2001,'汉中诚信数码维修中心','张师傅','13800002222','陕西省汉中市汉台区前进路 88 号','手机、平板、笔记本、数码配件','主营手机换屏、换电池、主板检测与数码产品售后。','汉中市','0','admin','2026-03-07 17:29:53','',NULL,'待审核商家'),(6,11,2010,'星空','liubei','19531975805','','',NULL,'汉中市','0','','2026-03-23 21:46:06','',NULL,NULL),(7,18,2017,'xk','hdaha','18291107689','','',NULL,'汉中市','1','18291107689','2026-03-24 15:05:07','admin','2026-03-25 13:19:45',''),(8,21,2020,'哈克电话卡','打卡机打开','13366669999','电话卡回答','',NULL,'汉中市','1','13366669999','2026-03-30 21:02:53','',NULL,NULL),(9,22,2021,'等哈看动画啊','打哈哈','18292227686','','',NULL,'汉中市','1','18292227686','2026-03-30 21:10:02','',NULL,NULL);
/*!40000 ALTER TABLE `app_merchant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_merchant_review`
--

DROP TABLE IF EXISTS `app_merchant_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_merchant_review` (
  `review_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint NOT NULL COMMENT '商家 ID',
  `accessory_order_id` bigint NOT NULL COMMENT '配件订单 ID',
  `app_user_id` bigint NOT NULL COMMENT '评价用户',
  `rating` int NOT NULL DEFAULT '5' COMMENT '评分',
  `review_content` varchar(500) NOT NULL COMMENT '评价内容',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `uk_app_merchant_review_order_id` (`accessory_order_id`),
  KEY `idx_app_merchant_review_merchant_id` (`merchant_id`),
  KEY `idx_app_merchant_review_app_user_id` (`app_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家评价表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_merchant_review`
--

LOCK TABLES `app_merchant_review` WRITE;
/*!40000 ALTER TABLE `app_merchant_review` DISABLE KEYS */;
INSERT INTO `app_merchant_review` VALUES (1,7,5,10,4,'非常不错','18291107686','2026-03-30 16:09:06','',NULL,NULL);
/*!40000 ALTER TABLE `app_merchant_review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_user`
--

DROP TABLE IF EXISTS `app_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_user` (
  `app_user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `sys_user_id` bigint NOT NULL COMMENT '关联 sys_user.user_id',
  `phone` varchar(11) NOT NULL COMMENT '手机号',
  `nick_name` varchar(30) NOT NULL COMMENT '昵称',
  `role_type` char(1) NOT NULL DEFAULT '1' COMMENT '业务角色：0待审核商家 1用户 2商家',
  `merchant_id` bigint DEFAULT NULL COMMENT '关联商家 ID',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '状态：0正常 1停用',
  `last_sms_code` varchar(6) DEFAULT NULL COMMENT '最近一次模拟验证码',
  `last_sms_expire_time` datetime DEFAULT NULL COMMENT '模拟验证码过期时间',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`app_user_id`),
  UNIQUE KEY `uk_app_user_phone` (`phone`),
  UNIQUE KEY `uk_app_user_sys_user` (`sys_user_id`),
  KEY `idx_app_user_role_type` (`role_type`),
  KEY `idx_app_user_merchant_id` (`merchant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='App 用户扩展表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_user`
--

LOCK TABLES `app_user` WRITE;
/*!40000 ALTER TABLE `app_user` DISABLE KEYS */;
INSERT INTO `app_user` VALUES (1,2000,'13800001111','测试用户1','1',NULL,'0',NULL,NULL,'admin','2026-03-07 17:29:53','',NULL,'普通测试用户'),(2,2001,'13800002222','测试商家账号','0',1,'0',NULL,NULL,'admin','2026-03-07 17:29:53','',NULL,'待审核测试商家'),(10,2009,'18291107686','chiheyu','1',NULL,'0',NULL,NULL,'','2026-03-23 21:44:24','',NULL,NULL),(11,2010,'19531975805','liubei','0',6,'0',NULL,NULL,'','2026-03-23 21:46:06','','2026-03-23 21:46:06',NULL),(12,2011,'19939214568','liubei','1',NULL,'0',NULL,NULL,'','2026-03-23 21:47:02','',NULL,NULL),(13,2012,'19929403282','hdjad','1',NULL,'0',NULL,NULL,'','2026-03-23 21:58:32','',NULL,NULL),(14,2013,'18822993366','dajdjb','1',NULL,'0',NULL,NULL,'','2026-03-23 22:01:56','',NULL,NULL),(15,2014,'18291107687','hdadja','1',NULL,'0',NULL,NULL,'','2026-03-24 14:24:23','',NULL,NULL),(16,2015,'18391107686','dhahd','1',NULL,'0',NULL,NULL,'','2026-03-24 14:33:23','',NULL,NULL),(17,2016,'18291117686','hdaj','1',NULL,'0',NULL,NULL,'18291117686','2026-03-24 14:46:03','',NULL,NULL),(18,2017,'18291107689','hdaha','2',7,'0',NULL,NULL,'18291107689','2026-03-24 15:05:07','admin','2026-03-25 13:19:46',NULL),(21,2020,'13366669999','哈哈大','2',8,'0',NULL,NULL,'13366669999','2026-03-30 21:02:53','13366669999','2026-03-30 21:02:53',NULL),(22,2021,'18292227686','打哈哈','2',9,'0',NULL,NULL,'18292227686','2026-03-30 21:10:02','18292227686','2026-03-30 21:10:02',NULL);
/*!40000 ALTER TABLE `app_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_table`
--

DROP TABLE IF EXISTS `gen_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table` (
  `table_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `tpl_web_type` varchar(30) DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
  `package_name` varchar(100) DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) DEFAULT NULL COMMENT '生成功能作者',
  `gen_type` char(1) DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='代码生成业务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table`
--

LOCK TABLES `gen_table` WRITE;
/*!40000 ALTER TABLE `gen_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_table_column`
--

DROP TABLE IF EXISTS `gen_table_column`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table_column` (
  `column_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) DEFAULT '' COMMENT '字典类型',
  `sort` int DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='代码生成业务表字段';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table_column`
--

LOCK TABLES `gen_table_column` WRITE;
/*!40000 ALTER TABLE `gen_table_column` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table_column` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_config`
--

DROP TABLE IF EXISTS `sys_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_config` (
  `config_id` int NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='参数配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_config`
--

LOCK TABLES `sys_config` WRITE;
/*!40000 ALTER TABLE `sys_config` DISABLE KEYS */;
INSERT INTO `sys_config` VALUES (1,'主框架页-默认皮肤样式名称','sys.index.skinName','skin-blue','Y','admin','2025-12-17 21:52:37','',NULL,'蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow'),(2,'用户管理-账号初始密码','sys.user.initPassword','123456','Y','admin','2025-12-17 21:52:37','',NULL,'初始化密码 123456'),(3,'主框架页-侧边栏主题','sys.index.sideTheme','theme-dark','Y','admin','2025-12-17 21:52:37','',NULL,'深色主题theme-dark，浅色主题theme-light'),(4,'账号自助-验证码开关','sys.account.captchaEnabled','true','Y','admin','2025-12-17 21:52:37','',NULL,'是否开启验证码功能（true开启，false关闭）'),(5,'账号自助-是否开启用户注册功能','sys.account.registerUser','false','Y','admin','2025-12-17 21:52:37','',NULL,'是否开启注册用户功能（true开启，false关闭）'),(6,'用户登录-黑名单列表','sys.login.blackIPList','','Y','admin','2025-12-17 21:52:37','',NULL,'设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）'),(7,'用户管理-初始密码修改策略','sys.account.initPasswordModify','1','Y','admin','2025-12-17 21:52:37','',NULL,'0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框'),(8,'用户管理-账号密码更新周期','sys.account.passwordValidateDays','0','Y','admin','2025-12-17 21:52:37','',NULL,'密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');
/*!40000 ALTER TABLE `sys_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dept`
--

DROP TABLE IF EXISTS `sys_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dept` (
  `dept_id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint DEFAULT '0' COMMENT '父部门id',
  `ancestors` varchar(50) DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) DEFAULT '' COMMENT '部门名称',
  `order_num` int DEFAULT '0' COMMENT '显示顺序',
  `leader` varchar(20) DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
  `status` char(1) DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`)
) ENGINE=InnoDB AUTO_INCREMENT=200 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='部门表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dept`
--

LOCK TABLES `sys_dept` WRITE;
/*!40000 ALTER TABLE `sys_dept` DISABLE KEYS */;
INSERT INTO `sys_dept` VALUES (100,0,'0','若依科技',0,'若依','15888888888','ry@qq.com','0','0','admin','2025-12-17 21:52:36','',NULL),(101,100,'0,100','深圳总公司',1,'若依','15888888888','ry@qq.com','0','0','admin','2025-12-17 21:52:36','',NULL),(102,100,'0,100','长沙分公司',2,'若依','15888888888','ry@qq.com','0','0','admin','2025-12-17 21:52:36','',NULL),(103,101,'0,100,101','研发部门',1,'若依','15888888888','ry@qq.com','0','0','admin','2025-12-17 21:52:36','',NULL),(104,101,'0,100,101','市场部门',2,'若依','15888888888','ry@qq.com','0','0','admin','2025-12-17 21:52:36','',NULL),(105,101,'0,100,101','测试部门',3,'若依','15888888888','ry@qq.com','0','0','admin','2025-12-17 21:52:36','',NULL),(106,101,'0,100,101','财务部门',4,'若依','15888888888','ry@qq.com','0','0','admin','2025-12-17 21:52:36','',NULL),(107,101,'0,100,101','运维部门',5,'若依','15888888888','ry@qq.com','0','0','admin','2025-12-17 21:52:36','',NULL),(108,102,'0,100,102','市场部门',1,'若依','15888888888','ry@qq.com','0','0','admin','2025-12-17 21:52:36','',NULL),(109,102,'0,100,102','财务部门',2,'若依','15888888888','ry@qq.com','0','0','admin','2025-12-17 21:52:36','',NULL);
/*!40000 ALTER TABLE `sys_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_data`
--

DROP TABLE IF EXISTS `sys_dict_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_data` (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int DEFAULT '0' COMMENT '字典排序',
  `dict_label` varchar(100) DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_data`
--

LOCK TABLES `sys_dict_data` WRITE;
/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;
INSERT INTO `sys_dict_data` VALUES (1,1,'男','0','sys_user_sex','','','Y','0','admin','2025-12-17 21:52:36','',NULL,'性别男'),(2,2,'女','1','sys_user_sex','','','N','0','admin','2025-12-17 21:52:36','',NULL,'性别女'),(3,3,'未知','2','sys_user_sex','','','N','0','admin','2025-12-17 21:52:36','',NULL,'性别未知'),(4,1,'显示','0','sys_show_hide','','primary','Y','0','admin','2025-12-17 21:52:36','',NULL,'显示菜单'),(5,2,'隐藏','1','sys_show_hide','','danger','N','0','admin','2025-12-17 21:52:36','',NULL,'隐藏菜单'),(6,1,'正常','0','sys_normal_disable','','primary','Y','0','admin','2025-12-17 21:52:36','',NULL,'正常状态'),(7,2,'停用','1','sys_normal_disable','','danger','N','0','admin','2025-12-17 21:52:36','',NULL,'停用状态'),(8,1,'正常','0','sys_job_status','','primary','Y','0','admin','2025-12-17 21:52:36','',NULL,'正常状态'),(9,2,'暂停','1','sys_job_status','','danger','N','0','admin','2025-12-17 21:52:36','',NULL,'停用状态'),(10,1,'默认','DEFAULT','sys_job_group','','','Y','0','admin','2025-12-17 21:52:36','',NULL,'默认分组'),(11,2,'系统','SYSTEM','sys_job_group','','','N','0','admin','2025-12-17 21:52:36','',NULL,'系统分组'),(12,1,'是','Y','sys_yes_no','','primary','Y','0','admin','2025-12-17 21:52:36','',NULL,'系统默认是'),(13,2,'否','N','sys_yes_no','','danger','N','0','admin','2025-12-17 21:52:36','',NULL,'系统默认否'),(14,1,'通知','1','sys_notice_type','','warning','Y','0','admin','2025-12-17 21:52:36','',NULL,'通知'),(15,2,'公告','2','sys_notice_type','','success','N','0','admin','2025-12-17 21:52:36','',NULL,'公告'),(16,1,'正常','0','sys_notice_status','','primary','Y','0','admin','2025-12-17 21:52:36','',NULL,'正常状态'),(17,2,'关闭','1','sys_notice_status','','danger','N','0','admin','2025-12-17 21:52:36','',NULL,'关闭状态'),(18,99,'其他','0','sys_oper_type','','info','N','0','admin','2025-12-17 21:52:36','',NULL,'其他操作'),(19,1,'新增','1','sys_oper_type','','info','N','0','admin','2025-12-17 21:52:36','',NULL,'新增操作'),(20,2,'修改','2','sys_oper_type','','info','N','0','admin','2025-12-17 21:52:36','',NULL,'修改操作'),(21,3,'删除','3','sys_oper_type','','danger','N','0','admin','2025-12-17 21:52:36','',NULL,'删除操作'),(22,4,'授权','4','sys_oper_type','','primary','N','0','admin','2025-12-17 21:52:36','',NULL,'授权操作'),(23,5,'导出','5','sys_oper_type','','warning','N','0','admin','2025-12-17 21:52:37','',NULL,'导出操作'),(24,6,'导入','6','sys_oper_type','','warning','N','0','admin','2025-12-17 21:52:37','',NULL,'导入操作'),(25,7,'强退','7','sys_oper_type','','danger','N','0','admin','2025-12-17 21:52:37','',NULL,'强退操作'),(26,8,'生成代码','8','sys_oper_type','','warning','N','0','admin','2025-12-17 21:52:37','',NULL,'生成操作'),(27,9,'清空数据','9','sys_oper_type','','danger','N','0','admin','2025-12-17 21:52:37','',NULL,'清空操作'),(28,1,'成功','0','sys_common_status','','primary','N','0','admin','2025-12-17 21:52:37','',NULL,'正常状态'),(29,2,'失败','1','sys_common_status','','danger','N','0','admin','2025-12-17 21:52:37','',NULL,'停用状态');
/*!40000 ALTER TABLE `sys_dict_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_type`
--

DROP TABLE IF EXISTS `sys_dict_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_type` (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) DEFAULT '' COMMENT '字典类型',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`),
  UNIQUE KEY `dict_type` (`dict_type`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_type`
--

LOCK TABLES `sys_dict_type` WRITE;
/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` VALUES (1,'用户性别','sys_user_sex','0','admin','2025-12-17 21:52:36','',NULL,'用户性别列表'),(2,'菜单状态','sys_show_hide','0','admin','2025-12-17 21:52:36','',NULL,'菜单状态列表'),(3,'系统开关','sys_normal_disable','0','admin','2025-12-17 21:52:36','',NULL,'系统开关列表'),(4,'任务状态','sys_job_status','0','admin','2025-12-17 21:52:36','',NULL,'任务状态列表'),(5,'任务分组','sys_job_group','0','admin','2025-12-17 21:52:36','',NULL,'任务分组列表'),(6,'系统是否','sys_yes_no','0','admin','2025-12-17 21:52:36','',NULL,'系统是否列表'),(7,'通知类型','sys_notice_type','0','admin','2025-12-17 21:52:36','',NULL,'通知类型列表'),(8,'通知状态','sys_notice_status','0','admin','2025-12-17 21:52:36','',NULL,'通知状态列表'),(9,'操作类型','sys_oper_type','0','admin','2025-12-17 21:52:36','',NULL,'操作类型列表'),(10,'系统状态','sys_common_status','0','admin','2025-12-17 21:52:36','',NULL,'登录状态列表');
/*!40000 ALTER TABLE `sys_dict_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_job`
--

DROP TABLE IF EXISTS `sys_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_job` (
  `job_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
  `invoke_target` varchar(500) NOT NULL COMMENT '调用目标字符串',
  `cron_expression` varchar(255) DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1暂停）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`,`job_name`,`job_group`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='定时任务调度表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_job`
--

LOCK TABLES `sys_job` WRITE;
/*!40000 ALTER TABLE `sys_job` DISABLE KEYS */;
INSERT INTO `sys_job` VALUES (1,'系统默认（无参）','DEFAULT','ryTask.ryNoParams','0/10 * * * * ?','3','1','1','admin','2025-12-17 21:52:37','',NULL,''),(2,'系统默认（有参）','DEFAULT','ryTask.ryParams(\'ry\')','0/15 * * * * ?','3','1','1','admin','2025-12-17 21:52:37','',NULL,''),(3,'系统默认（多参）','DEFAULT','ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)','0/20 * * * * ?','3','1','1','admin','2025-12-17 21:52:37','',NULL,'');
/*!40000 ALTER TABLE `sys_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_job_log`
--

DROP TABLE IF EXISTS `sys_job_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_job_log` (
  `job_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) NOT NULL COMMENT '任务组名',
  `invoke_target` varchar(500) NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) DEFAULT NULL COMMENT '日志信息',
  `status` char(1) DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) DEFAULT '' COMMENT '异常信息',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='定时任务调度日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_job_log`
--

LOCK TABLES `sys_job_log` WRITE;
/*!40000 ALTER TABLE `sys_job_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_job_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_logininfor`
--

DROP TABLE IF EXISTS `sys_logininfor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_logininfor` (
  `info_id` bigint NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) DEFAULT '' COMMENT '操作系统',
  `status` char(1) DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) DEFAULT '' COMMENT '提示消息',
  `login_time` datetime DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`),
  KEY `idx_sys_logininfor_s` (`status`),
  KEY `idx_sys_logininfor_lt` (`login_time`)
) ENGINE=InnoDB AUTO_INCREMENT=264 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统访问记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_logininfor`
--

LOCK TABLES `sys_logininfor` WRITE;
/*!40000 ALTER TABLE `sys_logininfor` DISABLE KEYS */;
INSERT INTO `sys_logininfor` VALUES (100,'admin','127.0.0.1','内网IP','Edge 143','Windows >=10','0','登录成功','2025-12-17 21:54:05'),(101,'admin','127.0.0.1','内网IP','Edge 143','Windows >=10','0','登录成功','2025-12-17 21:58:15'),(102,'admin','127.0.0.1','内网IP','Edge 143','Windows >=10','0','登录成功','2026-01-06 12:03:02'),(103,'admin','127.0.0.1','内网IP','Edge 143','Windows >=10','0','登录成功','2026-01-11 20:10:21'),(104,'admin','127.0.0.1','内网IP','Edge 144','Windows >=10','1','验证码错误','2026-01-18 16:03:34'),(105,'admin','127.0.0.1','内网IP','Edge 144','Windows >=10','0','登录成功','2026-01-18 16:03:41'),(106,'admin','127.0.0.1','内网IP','Edge 144','Windows >=10','0','登录成功','2026-02-12 10:27:49'),(107,'admin','127.0.0.1','内网IP','Edge 144','Windows >=10','0','登录成功','2026-02-12 11:19:22'),(108,'admin','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','登录成功','2026-02-21 14:58:57'),(109,'admin','127.0.0.1','内网IP','Edge 145','Windows >=10','0','登录成功','2026-03-05 10:25:40'),(110,'admin','127.0.0.1','内网IP','Edge 145','Windows >=10','0','登录成功','2026-03-06 10:28:05'),(111,'user1','127.0.0.1','内网IP','WindowsPowerShell 5.1.26100.7705','Windows 10.0','0','App 登录成功','2026-03-07 17:25:28'),(112,'admin','127.0.0.1','内网IP','Edge 145','Windows >=10','1','验证码已失效','2026-03-07 17:29:47'),(113,'admin','127.0.0.1','内网IP','Edge 145','Windows >=10','0','登录成功','2026-03-07 17:51:17'),(114,'admin','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','登录成功','2026-03-07 17:57:17'),(115,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','登录成功','2026-03-18 17:54:55'),(116,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-23 21:44:54'),(117,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-23 21:45:29'),(118,'19531975805','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-23 21:48:21'),(119,'19531975805','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-23 21:57:30'),(120,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-23 21:57:44'),(121,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-23 21:57:56'),(122,'19929403282','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-23 21:58:48'),(123,'19929403282','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-23 21:58:59'),(124,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','登录成功','2026-03-23 22:00:20'),(125,'18822993366','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-23 22:02:10'),(126,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 14:08:23'),(127,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','登录成功','2026-03-24 14:09:08'),(128,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 14:23:11'),(129,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 14:33:40'),(130,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','1','验证码已失效','2026-03-24 14:38:31'),(131,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','登录成功','2026-03-24 14:38:35'),(132,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','退出成功','2026-03-24 14:40:17'),(133,'common','127.0.0.1','内网IP','Edge 146','Windows >=10','1','验证码错误','2026-03-24 14:40:29'),(134,'common','127.0.0.1','内网IP','Edge 146','Windows >=10','1','用户不存在/密码错误','2026-03-24 14:40:34'),(135,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','登录成功','2026-03-24 14:40:44'),(136,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','退出成功','2026-03-24 14:41:20'),(137,'merchant','127.0.0.1','内网IP','Edge 146','Windows >=10','1','用户不存在/密码错误','2026-03-24 14:41:28'),(138,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','登录成功','2026-03-24 14:41:43'),(139,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 14:45:27'),(140,'18291117686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 14:46:03'),(141,'18291117686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 15:04:09'),(142,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 15:04:21'),(143,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 15:04:33'),(144,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 15:05:07'),(145,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','退出成功','2026-03-24 15:06:18'),(146,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','登录成功','2026-03-24 15:06:29'),(147,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 15:47:06'),(148,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 17:36:51'),(149,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 17:37:04'),(150,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 17:40:02'),(151,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 17:40:17'),(152,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 17:44:18'),(153,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 17:44:33'),(154,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 18:22:50'),(155,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 18:49:22'),(156,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 18:49:33'),(157,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 18:57:56'),(158,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 18:58:09'),(159,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 19:01:57'),(160,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 19:02:12'),(161,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 19:02:27'),(162,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 19:11:06'),(163,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 19:11:22'),(164,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 19:35:08'),(165,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 19:35:24'),(166,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 19:52:50'),(167,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 19:53:00'),(168,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 19:53:27'),(169,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 19:53:41'),(170,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 19:53:56'),(171,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 19:54:10'),(172,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 19:54:37'),(173,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 19:54:50'),(174,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 20:02:31'),(175,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 20:02:44'),(176,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 20:15:48'),(177,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 20:16:17'),(178,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 20:16:30'),(179,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 20:18:31'),(180,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 20:18:48'),(181,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 20:19:16'),(182,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 20:19:48'),(183,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-24 20:20:35'),(184,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-24 20:20:50'),(185,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-25 12:43:25'),(186,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-25 13:13:07'),(187,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-25 13:13:22'),(188,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','登录成功','2026-03-25 13:19:03'),(189,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-25 14:15:52'),(190,'18291107686','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-26 13:21:08'),(191,'18291107686','127.0.0.1','内网IP','Edge 146','Windows >=10','0','退出成功','2026-03-26 13:22:59'),(192,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-26 13:23:13'),(193,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-26 13:25:43'),(194,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','登录成功','2026-03-27 13:43:55'),(195,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-27 16:21:31'),(196,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-27 16:31:41'),(197,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-27 16:31:54'),(198,'18291107686','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-27 16:35:07'),(199,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-27 16:39:02'),(200,'18291107686','127.0.0.1','内网IP','Edge 146','Windows >=10','0','退出成功','2026-03-27 16:55:23'),(201,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-27 16:55:31'),(202,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-27 17:42:45'),(203,'admin','127.0.0.1','内网IP','Edge 146','Windows >=10','0','登录成功','2026-03-27 20:08:14'),(204,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-27 21:57:53'),(205,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-29 13:22:06'),(206,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-29 13:25:23'),(207,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-29 13:25:57'),(208,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-29 13:26:13'),(209,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-29 15:42:42'),(210,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-30 11:28:54'),(211,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 11:31:38'),(212,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 11:45:33'),(213,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 11:45:47'),(214,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 11:46:12'),(215,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 11:46:25'),(216,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 12:47:41'),(217,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 13:00:40'),(218,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 13:01:11'),(219,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 13:03:52'),(220,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 13:04:07'),(221,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 13:10:41'),(222,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 13:10:58'),(223,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 13:20:12'),(224,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 13:20:27'),(225,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 13:33:06'),(226,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 13:33:19'),(227,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 14:06:25'),(228,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 14:06:36'),(229,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 14:33:58'),(230,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 14:34:13'),(231,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 14:41:32'),(232,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 14:41:46'),(233,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 14:48:47'),(234,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 14:49:02'),(235,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 15:02:01'),(236,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 15:02:16'),(237,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 15:30:16'),(238,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 15:30:25'),(239,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 16:08:46'),(240,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 16:09:19'),(241,'18291107689','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 16:09:36'),(242,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-30 16:53:49'),(243,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 退出成功','2026-03-30 17:12:25'),(244,'18291107686','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-30 17:12:39'),(245,'18291107686','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 退出成功','2026-03-30 17:17:06'),(246,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-30 17:17:37'),(247,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 退出成功','2026-03-30 17:19:11'),(248,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-30 17:19:31'),(249,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 退出成功','2026-03-30 17:19:56'),(250,'18291107686','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-30 17:20:14'),(251,'18291107686','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 退出成功','2026-03-30 17:53:33'),(252,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-30 17:53:53'),(253,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-30 18:59:07'),(254,'18291107686','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-30 20:33:00'),(255,'18291107686','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 退出成功','2026-03-30 20:33:10'),(256,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-30 20:33:28'),(257,'18291107689','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 退出成功','2026-03-30 20:34:35'),(258,'13366669999','127.0.0.1','内网IP','Edge 146','Windows >=10','0','App 登录成功','2026-03-30 21:02:59'),(259,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 21:07:30'),(260,'18291107686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 21:07:38'),(261,'13366669999','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 21:08:16'),(262,'13366669999','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 退出成功','2026-03-30 21:08:26'),(263,'18292227686','127.0.0.1','内网IP','WeChat 8.0.5','iOS 15.0','0','App 登录成功','2026-03-30 21:10:02');
/*!40000 ALTER TABLE `sys_logininfor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_menu`
--

DROP TABLE IF EXISTS `sys_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) NOT NULL COMMENT '菜单名称',
  `parent_id` bigint DEFAULT '0' COMMENT '父菜单ID',
  `order_num` int DEFAULT '0' COMMENT '显示顺序',
  `path` varchar(200) DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) DEFAULT '' COMMENT '路由名称',
  `is_frame` int DEFAULT '1' COMMENT '是否为外链（0是 1否）',
  `is_cache` int DEFAULT '0' COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2042 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='菜单权限表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES (1,'系统管理',0,1,'system',NULL,'','',1,0,'M','0','0','','system','admin','2025-12-17 21:52:36','',NULL,'系统管理目录'),(2,'系统监控',0,2,'monitor',NULL,'','',1,0,'M','0','0','','monitor','admin','2025-12-17 21:52:36','',NULL,'系统监控目录'),(3,'系统工具',0,3,'tool',NULL,'','',1,0,'M','0','0','','tool','admin','2025-12-17 21:52:36','',NULL,'系统工具目录'),(4,'若依官网',0,4,'http://ruoyi.vip',NULL,'','',0,0,'M','0','0','','guide','admin','2025-12-17 21:52:36','',NULL,'若依官网地址'),(100,'用户管理',1,1,'user','system/user/index','','',1,0,'C','0','0','system:user:list','user','admin','2025-12-17 21:52:36','',NULL,'用户管理菜单'),(101,'角色管理',1,2,'role','system/role/index','','',1,0,'C','0','0','system:role:list','peoples','admin','2025-12-17 21:52:36','',NULL,'角色管理菜单'),(102,'菜单管理',1,3,'menu','system/menu/index','','',1,0,'C','0','0','system:menu:list','tree-table','admin','2025-12-17 21:52:36','',NULL,'菜单管理菜单'),(103,'部门管理',1,4,'dept','system/dept/index','','',1,0,'C','0','0','system:dept:list','tree','admin','2025-12-17 21:52:36','',NULL,'部门管理菜单'),(104,'岗位管理',1,5,'post','system/post/index','','',1,0,'C','0','0','system:post:list','post','admin','2025-12-17 21:52:36','',NULL,'岗位管理菜单'),(105,'字典管理',1,6,'dict','system/dict/index','','',1,0,'C','0','0','system:dict:list','dict','admin','2025-12-17 21:52:36','',NULL,'字典管理菜单'),(106,'参数设置',1,7,'config','system/config/index','','',1,0,'C','0','0','system:config:list','edit','admin','2025-12-17 21:52:36','',NULL,'参数设置菜单'),(107,'通知公告',1,8,'notice','system/notice/index','','',1,0,'C','0','0','system:notice:list','message','admin','2025-12-17 21:52:36','',NULL,'通知公告菜单'),(108,'日志管理',1,9,'log','','','',1,0,'M','0','0','','log','admin','2025-12-17 21:52:36','',NULL,'日志管理菜单'),(109,'在线用户',2,1,'online','monitor/online/index','','',1,0,'C','0','0','monitor:online:list','online','admin','2025-12-17 21:52:36','',NULL,'在线用户菜单'),(110,'定时任务',2,2,'job','monitor/job/index','','',1,0,'C','0','0','monitor:job:list','job','admin','2025-12-17 21:52:36','',NULL,'定时任务菜单'),(111,'数据监控',2,3,'druid','monitor/druid/index','','',1,0,'C','0','0','monitor:druid:list','druid','admin','2025-12-17 21:52:36','',NULL,'数据监控菜单'),(112,'服务监控',2,4,'server','monitor/server/index','','',1,0,'C','0','0','monitor:server:list','server','admin','2025-12-17 21:52:36','',NULL,'服务监控菜单'),(113,'缓存监控',2,5,'cache','monitor/cache/index','','',1,0,'C','0','0','monitor:cache:list','redis','admin','2025-12-17 21:52:36','',NULL,'缓存监控菜单'),(114,'缓存列表',2,6,'cacheList','monitor/cache/list','','',1,0,'C','0','0','monitor:cache:list','redis-list','admin','2025-12-17 21:52:36','',NULL,'缓存列表菜单'),(115,'表单构建',3,1,'build','tool/build/index','','',1,0,'C','0','0','tool:build:list','build','admin','2025-12-17 21:52:36','',NULL,'表单构建菜单'),(116,'代码生成',3,2,'gen','tool/gen/index','','',1,0,'C','0','0','tool:gen:list','code','admin','2025-12-17 21:52:36','',NULL,'代码生成菜单'),(117,'系统接口',3,3,'swagger','tool/swagger/index','','',1,0,'C','0','0','tool:swagger:list','swagger','admin','2025-12-17 21:52:36','',NULL,'系统接口菜单'),(500,'操作日志',108,1,'operlog','monitor/operlog/index','','',1,0,'C','0','0','monitor:operlog:list','form','admin','2025-12-17 21:52:36','',NULL,'操作日志菜单'),(501,'登录日志',108,2,'logininfor','monitor/logininfor/index','','',1,0,'C','0','0','monitor:logininfor:list','logininfor','admin','2025-12-17 21:52:36','',NULL,'登录日志菜单'),(1000,'用户查询',100,1,'','','','',1,0,'F','0','0','system:user:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1001,'用户新增',100,2,'','','','',1,0,'F','0','0','system:user:add','#','admin','2025-12-17 21:52:36','',NULL,''),(1002,'用户修改',100,3,'','','','',1,0,'F','0','0','system:user:edit','#','admin','2025-12-17 21:52:36','',NULL,''),(1003,'用户删除',100,4,'','','','',1,0,'F','0','0','system:user:remove','#','admin','2025-12-17 21:52:36','',NULL,''),(1004,'用户导出',100,5,'','','','',1,0,'F','0','0','system:user:export','#','admin','2025-12-17 21:52:36','',NULL,''),(1005,'用户导入',100,6,'','','','',1,0,'F','0','0','system:user:import','#','admin','2025-12-17 21:52:36','',NULL,''),(1006,'重置密码',100,7,'','','','',1,0,'F','0','0','system:user:resetPwd','#','admin','2025-12-17 21:52:36','',NULL,''),(1007,'角色查询',101,1,'','','','',1,0,'F','0','0','system:role:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1008,'角色新增',101,2,'','','','',1,0,'F','0','0','system:role:add','#','admin','2025-12-17 21:52:36','',NULL,''),(1009,'角色修改',101,3,'','','','',1,0,'F','0','0','system:role:edit','#','admin','2025-12-17 21:52:36','',NULL,''),(1010,'角色删除',101,4,'','','','',1,0,'F','0','0','system:role:remove','#','admin','2025-12-17 21:52:36','',NULL,''),(1011,'角色导出',101,5,'','','','',1,0,'F','0','0','system:role:export','#','admin','2025-12-17 21:52:36','',NULL,''),(1012,'菜单查询',102,1,'','','','',1,0,'F','0','0','system:menu:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1013,'菜单新增',102,2,'','','','',1,0,'F','0','0','system:menu:add','#','admin','2025-12-17 21:52:36','',NULL,''),(1014,'菜单修改',102,3,'','','','',1,0,'F','0','0','system:menu:edit','#','admin','2025-12-17 21:52:36','',NULL,''),(1015,'菜单删除',102,4,'','','','',1,0,'F','0','0','system:menu:remove','#','admin','2025-12-17 21:52:36','',NULL,''),(1016,'部门查询',103,1,'','','','',1,0,'F','0','0','system:dept:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1017,'部门新增',103,2,'','','','',1,0,'F','0','0','system:dept:add','#','admin','2025-12-17 21:52:36','',NULL,''),(1018,'部门修改',103,3,'','','','',1,0,'F','0','0','system:dept:edit','#','admin','2025-12-17 21:52:36','',NULL,''),(1019,'部门删除',103,4,'','','','',1,0,'F','0','0','system:dept:remove','#','admin','2025-12-17 21:52:36','',NULL,''),(1020,'岗位查询',104,1,'','','','',1,0,'F','0','0','system:post:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1021,'岗位新增',104,2,'','','','',1,0,'F','0','0','system:post:add','#','admin','2025-12-17 21:52:36','',NULL,''),(1022,'岗位修改',104,3,'','','','',1,0,'F','0','0','system:post:edit','#','admin','2025-12-17 21:52:36','',NULL,''),(1023,'岗位删除',104,4,'','','','',1,0,'F','0','0','system:post:remove','#','admin','2025-12-17 21:52:36','',NULL,''),(1024,'岗位导出',104,5,'','','','',1,0,'F','0','0','system:post:export','#','admin','2025-12-17 21:52:36','',NULL,''),(1025,'字典查询',105,1,'#','','','',1,0,'F','0','0','system:dict:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1026,'字典新增',105,2,'#','','','',1,0,'F','0','0','system:dict:add','#','admin','2025-12-17 21:52:36','',NULL,''),(1027,'字典修改',105,3,'#','','','',1,0,'F','0','0','system:dict:edit','#','admin','2025-12-17 21:52:36','',NULL,''),(1028,'字典删除',105,4,'#','','','',1,0,'F','0','0','system:dict:remove','#','admin','2025-12-17 21:52:36','',NULL,''),(1029,'字典导出',105,5,'#','','','',1,0,'F','0','0','system:dict:export','#','admin','2025-12-17 21:52:36','',NULL,''),(1030,'参数查询',106,1,'#','','','',1,0,'F','0','0','system:config:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1031,'参数新增',106,2,'#','','','',1,0,'F','0','0','system:config:add','#','admin','2025-12-17 21:52:36','',NULL,''),(1032,'参数修改',106,3,'#','','','',1,0,'F','0','0','system:config:edit','#','admin','2025-12-17 21:52:36','',NULL,''),(1033,'参数删除',106,4,'#','','','',1,0,'F','0','0','system:config:remove','#','admin','2025-12-17 21:52:36','',NULL,''),(1034,'参数导出',106,5,'#','','','',1,0,'F','0','0','system:config:export','#','admin','2025-12-17 21:52:36','',NULL,''),(1035,'公告查询',107,1,'#','','','',1,0,'F','0','0','system:notice:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1036,'公告新增',107,2,'#','','','',1,0,'F','0','0','system:notice:add','#','admin','2025-12-17 21:52:36','',NULL,''),(1037,'公告修改',107,3,'#','','','',1,0,'F','0','0','system:notice:edit','#','admin','2025-12-17 21:52:36','',NULL,''),(1038,'公告删除',107,4,'#','','','',1,0,'F','0','0','system:notice:remove','#','admin','2025-12-17 21:52:36','',NULL,''),(1039,'操作查询',500,1,'#','','','',1,0,'F','0','0','monitor:operlog:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1040,'操作删除',500,2,'#','','','',1,0,'F','0','0','monitor:operlog:remove','#','admin','2025-12-17 21:52:36','',NULL,''),(1041,'日志导出',500,3,'#','','','',1,0,'F','0','0','monitor:operlog:export','#','admin','2025-12-17 21:52:36','',NULL,''),(1042,'登录查询',501,1,'#','','','',1,0,'F','0','0','monitor:logininfor:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1043,'登录删除',501,2,'#','','','',1,0,'F','0','0','monitor:logininfor:remove','#','admin','2025-12-17 21:52:36','',NULL,''),(1044,'日志导出',501,3,'#','','','',1,0,'F','0','0','monitor:logininfor:export','#','admin','2025-12-17 21:52:36','',NULL,''),(1045,'账户解锁',501,4,'#','','','',1,0,'F','0','0','monitor:logininfor:unlock','#','admin','2025-12-17 21:52:36','',NULL,''),(1046,'在线查询',109,1,'#','','','',1,0,'F','0','0','monitor:online:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1047,'批量强退',109,2,'#','','','',1,0,'F','0','0','monitor:online:batchLogout','#','admin','2025-12-17 21:52:36','',NULL,''),(1048,'单条强退',109,3,'#','','','',1,0,'F','0','0','monitor:online:forceLogout','#','admin','2025-12-17 21:52:36','',NULL,''),(1049,'任务查询',110,1,'#','','','',1,0,'F','0','0','monitor:job:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1050,'任务新增',110,2,'#','','','',1,0,'F','0','0','monitor:job:add','#','admin','2025-12-17 21:52:36','',NULL,''),(1051,'任务修改',110,3,'#','','','',1,0,'F','0','0','monitor:job:edit','#','admin','2025-12-17 21:52:36','',NULL,''),(1052,'任务删除',110,4,'#','','','',1,0,'F','0','0','monitor:job:remove','#','admin','2025-12-17 21:52:36','',NULL,''),(1053,'状态修改',110,5,'#','','','',1,0,'F','0','0','monitor:job:changeStatus','#','admin','2025-12-17 21:52:36','',NULL,''),(1054,'任务导出',110,6,'#','','','',1,0,'F','0','0','monitor:job:export','#','admin','2025-12-17 21:52:36','',NULL,''),(1055,'生成查询',116,1,'#','','','',1,0,'F','0','0','tool:gen:query','#','admin','2025-12-17 21:52:36','',NULL,''),(1056,'生成修改',116,2,'#','','','',1,0,'F','0','0','tool:gen:edit','#','admin','2025-12-17 21:52:36','',NULL,''),(1057,'生成删除',116,3,'#','','','',1,0,'F','0','0','tool:gen:remove','#','admin','2025-12-17 21:52:36','',NULL,''),(1058,'导入代码',116,4,'#','','','',1,0,'F','0','0','tool:gen:import','#','admin','2025-12-17 21:52:36','',NULL,''),(1059,'预览代码',116,5,'#','','','',1,0,'F','0','0','tool:gen:preview','#','admin','2025-12-17 21:52:36','',NULL,''),(1060,'生成代码',116,6,'#','','','',1,0,'F','0','0','tool:gen:code','#','admin','2025-12-17 21:52:36','',NULL,''),(2000,'售后业务',0,8,'app',NULL,'','',1,0,'M','0','0','','guide','admin','2026-03-07 17:29:53','',NULL,'汉中市电子产品售后业务根菜单'),(2010,'商家管理',2000,1,'merchant','app/merchant/index','','',1,0,'C','0','0','app:merchant:list','peoples','admin','2026-03-07 17:29:53','',NULL,'商家管理'),(2011,'商家查询',2010,1,'#','','','',1,0,'F','0','0','app:merchant:query','#','admin','2026-03-07 17:29:53','',NULL,'商家查询按钮'),(2012,'商家编辑',2010,2,'#','','','',1,0,'F','0','0','app:merchant:edit','#','admin','2026-03-07 17:29:53','',NULL,'商家编辑按钮'),(2013,'商家审核',2010,3,'#','','','',1,0,'F','0','0','app:merchant:audit','#','admin','2026-03-07 17:29:53','',NULL,'商家审核按钮'),(2020,'售后订单管理',2000,2,'afterSalesOrder','app/afterSalesOrder/index','','',1,0,'C','0','0','app:afterSalesOrder:list','example','admin','2026-03-07 17:29:53','',NULL,'售后订单管理'),(2021,'订单查询',2020,1,'#','','','',1,0,'F','0','0','app:afterSalesOrder:query','#','admin','2026-03-07 17:29:53','',NULL,'订单查询按钮'),(2022,'订单编辑',2020,2,'#','','','',1,0,'F','0','0','app:afterSalesOrder:edit','#','admin','2026-03-07 17:29:53','',NULL,'订单编辑按钮'),(2030,'配件管理',2000,3,'accessory','app/accessory/index','','',1,0,'C','0','0','app:accessory:list','shopping','admin','2026-03-07 17:29:53','',NULL,'配件管理'),(2031,'配件查询',2030,1,'#','','','',1,0,'F','0','0','app:accessory:query','#','admin','2026-03-07 17:29:53','',NULL,'配件查询按钮'),(2032,'配件新增',2030,2,'#','','','',1,0,'F','0','0','app:accessory:add','#','admin','2026-03-07 17:29:53','',NULL,'配件新增按钮'),(2033,'配件编辑',2030,3,'#','','','',1,0,'F','0','0','app:accessory:edit','#','admin','2026-03-07 17:29:53','',NULL,'配件编辑按钮'),(2034,'配件删除',2030,4,'#','','','',1,0,'F','0','0','app:accessory:remove','#','admin','2026-03-07 17:29:53','',NULL,'配件删除按钮'),(2040,'配件订单管理',2000,4,'accessoryOrder','app/accessoryOrder/index','','',1,0,'C','0','0','app:accessoryOrder:list','order','admin','2026-03-07 17:29:53','',NULL,'配件订单管理'),(2041,'配件订单查询',2040,1,'#','','','',1,0,'F','0','0','app:accessoryOrder:query','#','admin','2026-03-07 17:29:53','',NULL,'配件订单查询按钮');
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_notice`
--

DROP TABLE IF EXISTS `sys_notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_notice` (
  `notice_id` int NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(50) NOT NULL COMMENT '公告标题',
  `notice_type` char(1) NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob COMMENT '公告内容',
  `status` char(1) DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='通知公告表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_notice`
--

LOCK TABLES `sys_notice` WRITE;
/*!40000 ALTER TABLE `sys_notice` DISABLE KEYS */;
INSERT INTO `sys_notice` VALUES (1,'温馨提醒：2018-07-01 若依新版本发布啦','2',_binary '新版本内容','0','admin','2025-12-17 21:52:37','',NULL,'管理员'),(2,'维护通知：2018-07-01 若依系统凌晨维护','1',_binary '维护内容','0','admin','2025-12-17 21:52:37','',NULL,'管理员');
/*!40000 ALTER TABLE `sys_notice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_oper_log`
--

DROP TABLE IF EXISTS `sys_oper_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_oper_log` (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) DEFAULT '' COMMENT '模块标题',
  `business_type` int DEFAULT '0' COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) DEFAULT '' COMMENT '请求方式',
  `operator_type` int DEFAULT '0' COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) DEFAULT '' COMMENT '返回参数',
  `status` int DEFAULT '0' COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint DEFAULT '0' COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`),
  KEY `idx_sys_oper_log_bt` (`business_type`),
  KEY `idx_sys_oper_log_s` (`status`),
  KEY `idx_sys_oper_log_ot` (`oper_time`)
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='操作日志记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_oper_log`
--

LOCK TABLES `sys_oper_log` WRITE;
/*!40000 ALTER TABLE `sys_oper_log` DISABLE KEYS */;
INSERT INTO `sys_oper_log` VALUES (100,'配件管理',1,'com.ruoyi.web.controller.app.AppAdminController.addAccessory()','POST',1,'admin','研发部门','/app/admin/accessory','127.0.0.1','内网IP','{\"accessoryId\":4,\"accessoryName\":\"笔记本电源\",\"categoryName\":\"笔记本\",\"createBy\":\"admin\",\"params\":{},\"price\":50,\"salesCount\":0,\"status\":\"0\",\"stock\":30} ','{\"msg\":\"操作成功\",\"code\":200}',0,NULL,'2026-03-18 18:16:50',50),(101,'配件管理',3,'com.ruoyi.web.controller.app.AppAdminController.removeAccessory()','DELETE',1,'admin','研发部门','/app/admin/accessory/4','127.0.0.1','内网IP','4 ','{\"msg\":\"操作成功\",\"code\":200}',0,NULL,'2026-03-18 18:16:59',50),(102,'用户管理',3,'com.ruoyi.web.controller.system.SysUserController.remove()','DELETE',1,'admin','研发部门','/system/user/2011','127.0.0.1','内网IP','[2011] ','{\"msg\":\"操作成功\",\"code\":200}',0,NULL,'2026-03-24 14:39:15',76),(103,'用户管理',3,'com.ruoyi.web.controller.system.SysUserController.remove()','DELETE',1,'admin','研发部门','/system/user/2012','127.0.0.1','内网IP','[2012] ','{\"msg\":\"操作成功\",\"code\":200}',0,NULL,'2026-03-24 14:39:19',36),(104,'用户管理',3,'com.ruoyi.web.controller.system.SysUserController.remove()','DELETE',1,'admin','研发部门','/system/user/2013','127.0.0.1','内网IP','[2013] ','{\"msg\":\"操作成功\",\"code\":200}',0,NULL,'2026-03-24 14:39:21',28),(105,'用户管理',3,'com.ruoyi.web.controller.system.SysUserController.remove()','DELETE',1,'admin','研发部门','/system/user/2014','127.0.0.1','内网IP','[2014] ','{\"msg\":\"操作成功\",\"code\":200}',0,NULL,'2026-03-24 14:39:24',39),(106,'用户管理',3,'com.ruoyi.web.controller.system.SysUserController.remove()','DELETE',1,'admin','研发部门','/system/user/2015','127.0.0.1','内网IP','[2015] ','{\"msg\":\"操作成功\",\"code\":200}',0,NULL,'2026-03-24 14:39:26',35),(107,'角色管理',2,'com.ruoyi.web.controller.system.SysRoleController.edit()','PUT',1,'admin','研发部门','/system/role','127.0.0.1','内网IP','{\"admin\":false,\"createTime\":\"2026-03-07 17:29:53\",\"dataScope\":\"1\",\"delFlag\":\"0\",\"deptCheckStrictly\":true,\"flag\":false,\"menuCheckStrictly\":true,\"menuIds\":[2000,2020,2021,2022,2030,2031,2032,2033,2034,2040,2041],\"params\":{},\"remark\":\"汉中市电子产品售后系统-商家\",\"roleId\":201,\"roleKey\":\"merchant\",\"roleName\":\"售后商家\",\"roleSort\":4,\"status\":\"0\",\"updateBy\":\"admin\"} ','{\"msg\":\"操作成功\",\"code\":200}',0,NULL,'2026-03-24 14:39:58',57),(108,'商家管理',2,'com.ruoyi.web.controller.app.AppAdminController.auditMerchant()','PUT',1,'admin','研发部门','/app/admin/merchant/audit','127.0.0.1','内网IP','{\"auditRemark\":\"\",\"auditStatus\":\"1\",\"merchantId\":7} ','{\"msg\":\"操作成功\",\"code\":200}',0,NULL,'2026-03-24 15:06:51',104),(109,'商家管理',2,'com.ruoyi.web.controller.app.AppAdminController.auditMerchant()','PUT',1,'admin','研发部门','/app/admin/merchant/audit','127.0.0.1','内网IP','{\"auditRemark\":\"\",\"auditStatus\":\"1\",\"merchantId\":7} ','{\"msg\":\"操作成功\",\"code\":200}',0,NULL,'2026-03-25 13:19:46',124);
/*!40000 ALTER TABLE `sys_oper_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_post`
--

DROP TABLE IF EXISTS `sys_post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_post` (
  `post_id` bigint NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) NOT NULL COMMENT '岗位名称',
  `post_sort` int NOT NULL COMMENT '显示顺序',
  `status` char(1) NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='岗位信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_post`
--

LOCK TABLES `sys_post` WRITE;
/*!40000 ALTER TABLE `sys_post` DISABLE KEYS */;
INSERT INTO `sys_post` VALUES (1,'ceo','董事长',1,'0','admin','2025-12-17 21:52:36','',NULL,''),(2,'se','项目经理',2,'0','admin','2025-12-17 21:52:36','',NULL,''),(3,'hr','人力资源',3,'0','admin','2025-12-17 21:52:36','',NULL,''),(4,'user','普通员工',4,'0','admin','2025-12-17 21:52:36','',NULL,'');
/*!40000 ALTER TABLE `sys_post` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role`
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) DEFAULT '1' COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) DEFAULT '1' COMMENT '部门树选择项是否关联显示',
  `status` char(1) NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=202 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES (1,'超级管理员','admin',1,'1',1,1,'0','0','admin','2025-12-17 21:52:36','',NULL,'超级管理员'),(2,'普通角色','common',2,'2',1,1,'0','0','admin','2025-12-17 21:52:36','',NULL,'普通角色'),(200,'售后普通用户','user',3,'1',1,1,'0','0','admin','2026-03-07 17:29:53','',NULL,'汉中市电子产品售后系统-普通用户'),(201,'售后商家','merchant',4,'1',1,1,'0','0','admin','2026-03-07 17:29:53','admin','2026-03-24 14:39:58','汉中市电子产品售后系统-商家');
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_dept`
--

DROP TABLE IF EXISTS `sys_role_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_dept` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`,`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色和部门关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_dept`
--

LOCK TABLES `sys_role_dept` WRITE;
/*!40000 ALTER TABLE `sys_role_dept` DISABLE KEYS */;
INSERT INTO `sys_role_dept` VALUES (2,100),(2,101),(2,105);
/*!40000 ALTER TABLE `sys_role_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_menu`
--

DROP TABLE IF EXISTS `sys_role_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menu` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色和菜单关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_menu`
--

LOCK TABLES `sys_role_menu` WRITE;
/*!40000 ALTER TABLE `sys_role_menu` DISABLE KEYS */;
INSERT INTO `sys_role_menu` VALUES (1,2000),(1,2010),(1,2011),(1,2012),(1,2013),(1,2020),(1,2021),(1,2022),(1,2030),(1,2031),(1,2032),(1,2033),(1,2034),(1,2040),(1,2041),(2,1),(2,2),(2,3),(2,4),(2,100),(2,101),(2,102),(2,103),(2,104),(2,105),(2,106),(2,107),(2,108),(2,109),(2,110),(2,111),(2,112),(2,113),(2,114),(2,115),(2,116),(2,117),(2,500),(2,501),(2,1000),(2,1001),(2,1002),(2,1003),(2,1004),(2,1005),(2,1006),(2,1007),(2,1008),(2,1009),(2,1010),(2,1011),(2,1012),(2,1013),(2,1014),(2,1015),(2,1016),(2,1017),(2,1018),(2,1019),(2,1020),(2,1021),(2,1022),(2,1023),(2,1024),(2,1025),(2,1026),(2,1027),(2,1028),(2,1029),(2,1030),(2,1031),(2,1032),(2,1033),(2,1034),(2,1035),(2,1036),(2,1037),(2,1038),(2,1039),(2,1040),(2,1041),(2,1042),(2,1043),(2,1044),(2,1045),(2,1046),(2,1047),(2,1048),(2,1049),(2,1050),(2,1051),(2,1052),(2,1053),(2,1054),(2,1055),(2,1056),(2,1057),(2,1058),(2,1059),(2,1060),(201,2000),(201,2020),(201,2021),(201,2022),(201,2030),(201,2031),(201,2032),(201,2033),(201,2034),(201,2040),(201,2041);
/*!40000 ALTER TABLE `sys_role_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) DEFAULT '' COMMENT '手机号码',
  `sex` char(1) DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) DEFAULT '' COMMENT '密码',
  `status` char(1) DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime DEFAULT NULL COMMENT '密码最后更新时间',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2022 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES (1,103,'admin','若依','00','ry@163.com','15888888888','1','','$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','0','0','127.0.0.1','2026-03-27 20:08:10','2025-12-17 21:52:36','admin','2025-12-17 21:52:36','',NULL,'管理员'),(2,105,'ry','若依','00','ry@qq.com','15666666666','1','','$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','0','0','127.0.0.1','2025-12-17 21:52:36','2025-12-17 21:52:36','admin','2025-12-17 21:52:36','',NULL,'测试员'),(2000,100,'user1','测试用户1','00','user1@hanzhong.local','13800001111','0','','$2a$10$5s2BL3EwQIu4f97u38aFe.VAXaiZwc8titAWJkQx3WFbDs7VnceVa','0','0','127.0.0.1','2026-03-07 17:29:53','2026-03-07 17:29:53','admin','2026-03-07 17:29:53','',NULL,'汉中市售后系统测试用户'),(2001,100,'merchant1','测试商家账号','00','merchant1@hanzhong.local','13800002222','0','','$2a$10$5s2BL3EwQIu4f97u38aFe.VAXaiZwc8titAWJkQx3WFbDs7VnceVa','0','0','127.0.0.1','2026-03-07 17:29:53','2026-03-07 17:29:53','admin','2026-03-07 17:29:53','',NULL,'汉中市售后系统测试商家'),(2009,NULL,'18291107686','chiheyu','00','','18291107686','0','','$2a$10$D9Og9LF1z.8qSyC4hntfkePShLZLKPbIG5SbXJYqlZ7UPUmDp82Pu','0','0','',NULL,'2026-03-23 21:44:24','','2026-03-23 21:44:24','',NULL,NULL),(2010,NULL,'19531975805','liubei','00','','19531975805','0','','$2a$10$FqpodOktTejBViBg0BijDekeanOy0XrwS6x4qxpJLaBCdJKbZql3W','0','0','',NULL,'2026-03-23 21:46:07','','2026-03-23 21:46:06','',NULL,NULL),(2011,NULL,'19939214568','liubei','00','','19939214568','0','','$2a$10$xzdQ/N9zdiEQyO0fbuKrPeTG9Hveziah2fdZSevnsF7bu2oUP6jbq','0','2','',NULL,'2026-03-23 21:47:02','','2026-03-23 21:47:02','',NULL,NULL),(2012,NULL,'19929403282','hdjad','00','','19929403282','0','','$2a$10$0j/3zvTHy0Gu2JkfGmMR8OhTWK2RKCyAjE3IbDs6vaVOCkAtwAjUO','0','2','',NULL,'2026-03-23 21:58:32','','2026-03-23 21:58:32','',NULL,NULL),(2013,NULL,'18822993366','dajdjb','00','','18822993366','0','','$2a$10$yYMYRcCflCABXcc/IGyOjeNNN5sRUTVtyzNUe8ut38sfQ2GnAK0u.','0','2','',NULL,'2026-03-23 22:01:56','','2026-03-23 22:01:56','',NULL,NULL),(2014,NULL,'18291107687','hdadja','00','','18291107687','0','','$2a$10$3HuZAmaXTul9vEd9GN6jpefceOaKsWPHNfKG.E0e0PXIIjhKyGTmO','0','2','',NULL,'2026-03-24 14:24:23','','2026-03-24 14:24:23','',NULL,NULL),(2015,NULL,'18391107686','dhahd','00','','18391107686','0','','$2a$10$yxgLVmakocUGdyD89MIlwuhLhScYY/VFYKd/Q9d0aFd0yW4bHPUeC','0','2','',NULL,'2026-03-24 14:33:24','','2026-03-24 14:33:23','',NULL,NULL),(2016,NULL,'18291117686','hdaj','00','','18291117686','0','','$2a$10$EsFVjSPDXmWRl14eg6rB7OwYjy8r30eK5YuWeXD4Bg4lW88Rq4PpG','0','0','',NULL,'2026-03-24 14:46:03','','2026-03-24 14:46:03','',NULL,NULL),(2017,NULL,'18291107689','hdaha','00','','18291107689','0','','$2a$10$CgJe5fxsGrlxHJhRCj/Uou0a0neKT.79Z9j1bQPl3Q5SQyC.2TNXe','0','0','',NULL,'2026-03-24 15:05:07','','2026-03-24 15:05:07','','2026-03-25 13:19:46',NULL),(2020,NULL,'13366669999','哈哈大','00','','13366669999','0','','$2a$10$DFrU9KXhvD3IYPNtqbG7Zuq9v0F7yD/SN1LhIBNK3o5wRAFnOZFre','0','0','',NULL,'2026-03-30 21:02:53','','2026-03-30 21:02:53','',NULL,NULL),(2021,NULL,'18292227686','打哈哈','00','','18292227686','0','','$2a$10$oCDmj2zWU6g//ulpGBguU.OLvc14pYxA5vE3ssxMFaIWqIcrd.npW','0','0','',NULL,'2026-03-30 21:10:02','','2026-03-30 21:10:02','',NULL,NULL);
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_post`
--

DROP TABLE IF EXISTS `sys_user_post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_post` (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `post_id` bigint NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`,`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户与岗位关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_post`
--

LOCK TABLES `sys_user_post` WRITE;
/*!40000 ALTER TABLE `sys_user_post` DISABLE KEYS */;
INSERT INTO `sys_user_post` VALUES (1,1),(2,2);
/*!40000 ALTER TABLE `sys_user_post` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_role`
--

DROP TABLE IF EXISTS `sys_user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_role` (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户和角色关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_role`
--

LOCK TABLES `sys_user_role` WRITE;
/*!40000 ALTER TABLE `sys_user_role` DISABLE KEYS */;
INSERT INTO `sys_user_role` VALUES (1,1),(2,2),(2000,200),(2001,200),(2009,200),(2010,200),(2016,200),(2017,201),(2020,201),(2021,201);
/*!40000 ALTER TABLE `sys_user_role` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-30 21:18:13
