-- 汉中市电子产品售后服务系统初始化脚本
-- 使用前提：已先导入 RuoYi 官方基础库结构与基础数据

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS app_accessory_collection;
DROP TABLE IF EXISTS app_accessory_order;
DROP TABLE IF EXISTS app_after_sales_order;
DROP TABLE IF EXISTS app_accessory;
DROP TABLE IF EXISTS app_merchant;
DROP TABLE IF EXISTS app_user;

CREATE TABLE app_user (
  app_user_id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  sys_user_id bigint(20) NOT NULL COMMENT '关联 sys_user.user_id',
  phone varchar(11) NOT NULL COMMENT '手机号',
  nick_name varchar(30) NOT NULL COMMENT '昵称',
  role_type char(1) NOT NULL DEFAULT '1' COMMENT '业务角色：0待审核商家 1用户 2商家',
  merchant_id bigint(20) DEFAULT NULL COMMENT '关联商家 ID',
  status char(1) NOT NULL DEFAULT '0' COMMENT '状态：0正常 1停用',
  last_sms_code varchar(6) DEFAULT NULL COMMENT '最近一次模拟验证码',
  last_sms_expire_time datetime DEFAULT NULL COMMENT '模拟验证码过期时间',
  create_by varchar(64) DEFAULT '' COMMENT '创建者',
  create_time datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by varchar(64) DEFAULT '' COMMENT '更新者',
  update_time datetime DEFAULT NULL COMMENT '更新时间',
  remark varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (app_user_id),
  UNIQUE KEY uk_app_user_phone (phone),
  UNIQUE KEY uk_app_user_sys_user (sys_user_id),
  KEY idx_app_user_role_type (role_type),
  KEY idx_app_user_merchant_id (merchant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='App 用户扩展表';

CREATE TABLE app_merchant (
  merchant_id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  app_user_id bigint(20) NOT NULL COMMENT '关联 app_user.app_user_id',
  sys_user_id bigint(20) NOT NULL COMMENT '关联 sys_user.user_id',
  merchant_name varchar(100) NOT NULL COMMENT '商家名称',
  contact_name varchar(30) DEFAULT '' COMMENT '联系人',
  contact_phone varchar(11) DEFAULT '' COMMENT '联系电话',
  address varchar(255) DEFAULT '' COMMENT '商家地址',
  service_scope varchar(255) DEFAULT '' COMMENT '服务范围',
  merchant_desc varchar(500) DEFAULT NULL COMMENT '商家简介',
  city_name varchar(50) NOT NULL DEFAULT '汉中市' COMMENT '所在城市',
  audit_status char(1) NOT NULL DEFAULT '0' COMMENT '审核状态：0待审核 1正常 2禁用',
  create_by varchar(64) DEFAULT '' COMMENT '创建者',
  create_time datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by varchar(64) DEFAULT '' COMMENT '更新者',
  update_time datetime DEFAULT NULL COMMENT '更新时间',
  remark varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (merchant_id),
  KEY idx_app_merchant_audit_status (audit_status),
  KEY idx_app_merchant_city_name (city_name),
  KEY idx_app_merchant_sys_user_id (sys_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家信息表';

CREATE TABLE app_after_sales_order (
  order_id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  order_no varchar(32) NOT NULL COMMENT '业务单号',
  app_user_id bigint(20) NOT NULL COMMENT '提交用户',
  merchant_id bigint(20) DEFAULT NULL COMMENT '接单商家',
  product_type varchar(100) NOT NULL COMMENT '产品类型',
  fault_desc varchar(500) DEFAULT NULL COMMENT '故障描述',
  fault_images varchar(1000) DEFAULT NULL COMMENT '故障图片，多图用逗号分隔',
  status char(1) NOT NULL DEFAULT '0' COMMENT '状态：0待接单 1已接单 2维修中 3已完成 4已取消',
  service_remark varchar(500) DEFAULT NULL COMMENT '处理备注',
  contact_name varchar(30) NOT NULL COMMENT '联系人',
  contact_phone varchar(11) NOT NULL COMMENT '联系电话',
  address varchar(255) DEFAULT '' COMMENT '服务地址',
  accept_time datetime DEFAULT NULL COMMENT '接单时间',
  finish_time datetime DEFAULT NULL COMMENT '完成时间',
  create_by varchar(64) DEFAULT '' COMMENT '创建者',
  create_time datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by varchar(64) DEFAULT '' COMMENT '更新者',
  update_time datetime DEFAULT NULL COMMENT '更新时间',
  remark varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (order_id),
  UNIQUE KEY uk_app_after_sales_order_no (order_no),
  KEY idx_app_after_sales_user_id (app_user_id),
  KEY idx_app_after_sales_merchant_id (merchant_id),
  KEY idx_app_after_sales_status (status),
  KEY idx_app_after_sales_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='售后订单表';

CREATE TABLE app_accessory (
  accessory_id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  category_name varchar(50) NOT NULL COMMENT '分类名称',
  accessory_name varchar(100) NOT NULL COMMENT '配件名称',
  accessory_desc varchar(500) DEFAULT NULL COMMENT '配件描述',
  cover_image varchar(255) DEFAULT NULL COMMENT '封面图',
  price decimal(10,2) NOT NULL COMMENT '价格',
  stock bigint(20) NOT NULL DEFAULT '0' COMMENT '库存',
  sales_count bigint(20) NOT NULL DEFAULT '0' COMMENT '销量',
  status char(1) NOT NULL DEFAULT '0' COMMENT '状态：0上架 1下架',
  create_by varchar(64) DEFAULT '' COMMENT '创建者',
  create_time datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by varchar(64) DEFAULT '' COMMENT '更新者',
  update_time datetime DEFAULT NULL COMMENT '更新时间',
  remark varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (accessory_id),
  KEY idx_app_accessory_category (category_name),
  KEY idx_app_accessory_status (status),
  KEY idx_app_accessory_price (price)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='配件表';

CREATE TABLE app_accessory_order (
  accessory_order_id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  order_no varchar(32) NOT NULL COMMENT '订单号',
  accessory_id bigint(20) NOT NULL COMMENT '配件 ID',
  app_user_id bigint(20) NOT NULL COMMENT '下单用户',
  quantity bigint(20) NOT NULL COMMENT '数量',
  price decimal(10,2) NOT NULL COMMENT '单价',
  total_amount decimal(10,2) NOT NULL COMMENT '总金额',
  status char(1) NOT NULL DEFAULT '0' COMMENT '状态：0待处理 1已发货 2已完成 3已取消',
  receiver_name varchar(30) NOT NULL COMMENT '收货人',
  receiver_phone varchar(11) NOT NULL COMMENT '联系电话',
  receiver_address varchar(255) NOT NULL COMMENT '收货地址',
  order_remark varchar(500) DEFAULT NULL COMMENT '订单备注',
  create_by varchar(64) DEFAULT '' COMMENT '创建者',
  create_time datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by varchar(64) DEFAULT '' COMMENT '更新者',
  update_time datetime DEFAULT NULL COMMENT '更新时间',
  remark varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (accessory_order_id),
  UNIQUE KEY uk_app_accessory_order_no (order_no),
  KEY idx_app_accessory_order_user_id (app_user_id),
  KEY idx_app_accessory_order_accessory_id (accessory_id),
  KEY idx_app_accessory_order_status (status),
  KEY idx_app_accessory_order_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='配件订单表';

CREATE TABLE app_accessory_collection (
  collection_id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  app_user_id bigint(20) NOT NULL COMMENT '收藏用户',
  accessory_id bigint(20) NOT NULL COMMENT '配件 ID',
  create_by varchar(64) DEFAULT '' COMMENT '创建者',
  create_time datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by varchar(64) DEFAULT '' COMMENT '更新者',
  update_time datetime DEFAULT NULL COMMENT '更新时间',
  remark varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (collection_id),
  UNIQUE KEY uk_app_collection_user_accessory (app_user_id, accessory_id),
  KEY idx_app_collection_user_id (app_user_id),
  KEY idx_app_collection_accessory_id (accessory_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='配件收藏表';

DELETE FROM sys_role_menu WHERE role_id IN (200, 201) OR menu_id BETWEEN 2000 AND 2099;
DELETE FROM sys_user_role WHERE role_id IN (200, 201) OR user_id IN (2000, 2001);
DELETE FROM sys_user WHERE user_id IN (2000, 2001);
DELETE FROM sys_role WHERE role_id IN (200, 201);
DELETE FROM sys_menu WHERE menu_id BETWEEN 2000 AND 2099;

INSERT INTO sys_role (role_id, role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
VALUES
(200, '售后普通用户', 'user', 3, '1', 1, 1, '0', '0', 'admin', NOW(), '汉中市电子产品售后系统-普通用户'),
(201, '售后商家', 'merchant', 4, '1', 1, 1, '0', '0', 'admin', NOW(), '汉中市电子产品售后系统-商家');

INSERT INTO sys_menu (menu_id, parent_id, menu_name, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
VALUES
(2000, 0, '售后业务', 8, 'app', NULL, '', 1, 0, 'M', '0', '0', '', 'guide', 'admin', NOW(), '汉中市电子产品售后业务根菜单'),
(2010, 2000, '商家管理', 1, 'merchant', 'app/merchant/index', '', 1, 0, 'C', '0', '0', 'app:merchant:list', 'peoples', 'admin', NOW(), '商家管理'),
(2011, 2010, '商家查询', 1, '#', '', '', 1, 0, 'F', '0', '0', 'app:merchant:query', '#', 'admin', NOW(), '商家查询按钮'),
(2012, 2010, '商家编辑', 2, '#', '', '', 1, 0, 'F', '0', '0', 'app:merchant:edit', '#', 'admin', NOW(), '商家编辑按钮'),
(2013, 2010, '商家审核', 3, '#', '', '', 1, 0, 'F', '0', '0', 'app:merchant:audit', '#', 'admin', NOW(), '商家审核按钮'),
(2020, 2000, '售后订单管理', 2, 'afterSalesOrder', 'app/afterSalesOrder/index', '', 1, 0, 'C', '0', '0', 'app:afterSalesOrder:list', 'example', 'admin', NOW(), '售后订单管理'),
(2021, 2020, '订单查询', 1, '#', '', '', 1, 0, 'F', '0', '0', 'app:afterSalesOrder:query', '#', 'admin', NOW(), '订单查询按钮'),
(2022, 2020, '订单编辑', 2, '#', '', '', 1, 0, 'F', '0', '0', 'app:afterSalesOrder:edit', '#', 'admin', NOW(), '订单编辑按钮'),
(2030, 2000, '配件管理', 3, 'accessory', 'app/accessory/index', '', 1, 0, 'C', '0', '0', 'app:accessory:list', 'shopping', 'admin', NOW(), '配件管理'),
(2031, 2030, '配件查询', 1, '#', '', '', 1, 0, 'F', '0', '0', 'app:accessory:query', '#', 'admin', NOW(), '配件查询按钮'),
(2032, 2030, '配件新增', 2, '#', '', '', 1, 0, 'F', '0', '0', 'app:accessory:add', '#', 'admin', NOW(), '配件新增按钮'),
(2033, 2030, '配件编辑', 3, '#', '', '', 1, 0, 'F', '0', '0', 'app:accessory:edit', '#', 'admin', NOW(), '配件编辑按钮'),
(2034, 2030, '配件删除', 4, '#', '', '', 1, 0, 'F', '0', '0', 'app:accessory:remove', '#', 'admin', NOW(), '配件删除按钮'),
(2040, 2000, '配件订单管理', 4, 'accessoryOrder', 'app/accessoryOrder/index', '', 1, 0, 'C', '0', '0', 'app:accessoryOrder:list', 'order', 'admin', NOW(), '配件订单管理'),
(2041, 2040, '配件订单查询', 1, '#', '', '', 1, 0, 'F', '0', '0', 'app:accessoryOrder:query', '#', 'admin', NOW(), '配件订单查询按钮');

INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 1, menu_id FROM sys_menu WHERE menu_id BETWEEN 2000 AND 2041;

INSERT INTO sys_user (user_id, dept_id, user_name, nick_name, user_type, email, phonenumber, sex, avatar, password, status, del_flag, login_ip, login_date, pwd_update_date, create_by, create_time, remark)
VALUES
(2000, 100, 'user1', '测试用户1', '00', 'user1@hanzhong.local', '13800001111', '0', '', '$2a$10$5s2BL3EwQIu4f97u38aFe.VAXaiZwc8titAWJkQx3WFbDs7VnceVa', '0', '0', '127.0.0.1', NOW(), NOW(), 'admin', NOW(), '汉中市售后系统测试用户'),
(2001, 100, 'merchant1', '测试商家账号', '00', 'merchant1@hanzhong.local', '13800002222', '0', '', '$2a$10$5s2BL3EwQIu4f97u38aFe.VAXaiZwc8titAWJkQx3WFbDs7VnceVa', '0', '0', '127.0.0.1', NOW(), NOW(), 'admin', NOW(), '汉中市售后系统测试商家');

INSERT INTO sys_user_role (user_id, role_id)
VALUES
(2000, 200),
(2001, 200);

INSERT INTO app_user (app_user_id, sys_user_id, phone, nick_name, role_type, merchant_id, status, create_by, create_time, remark)
VALUES
(1, 2000, '13800001111', '测试用户1', '1', NULL, '0', 'admin', NOW(), '普通测试用户'),
(2, 2001, '13800002222', '测试商家账号', '0', 1, '0', 'admin', NOW(), '待审核测试商家');

INSERT INTO app_merchant (merchant_id, app_user_id, sys_user_id, merchant_name, contact_name, contact_phone, address, service_scope, merchant_desc, city_name, audit_status, create_by, create_time, remark)
VALUES
(1, 2, 2001, '汉中诚信数码维修中心', '张师傅', '13800002222', '陕西省汉中市汉台区前进路 88 号', '手机、平板、笔记本、数码配件', '主营手机换屏、换电池、主板检测与数码产品售后。', '汉中市', '0', 'admin', NOW(), '待审核商家');

INSERT INTO app_accessory (accessory_id, category_name, accessory_name, accessory_desc, cover_image, price, stock, sales_count, status, create_by, create_time, remark)
VALUES
(1, '手机配件', '手机电池', '适配主流安卓机型的高容量电池，支持门店安装。', '/profile/upload/2026/03/07/battery.png', 129.00, 50, 5, '0', 'admin', NOW(), '测试配件'),
(2, '手机配件', '手机屏幕', '适配常见机型的原装品质屏幕总成，可提供安装服务。', '/profile/upload/2026/03/07/screen.png', 399.00, 20, 2, '0', 'admin', NOW(), '测试配件'),
(3, '电脑配件', '笔记本风扇', '适用于多型号笔记本的散热风扇组件。', '/profile/upload/2026/03/07/fan.png', 89.00, 30, 1, '1', 'admin', NOW(), '下架测试配件');

INSERT INTO app_after_sales_order (order_id, order_no, app_user_id, merchant_id, product_type, fault_desc, fault_images, status, service_remark, contact_name, contact_phone, address, create_by, create_time, remark)
VALUES
(1, 'AS202603070001', 1, NULL, '手机', '开机后黑屏，偶发重启。', '/profile/upload/2026/03/07/after-sales-1.png', '0', NULL, '李先生', '13800001111', '陕西省汉中市汉台区中山街 18 号', 'user1', NOW(), '初始待接单订单');

INSERT INTO app_accessory_order (accessory_order_id, order_no, accessory_id, app_user_id, quantity, price, total_amount, status, receiver_name, receiver_phone, receiver_address, order_remark, create_by, create_time, remark)
VALUES
(1, 'AO202603070001', 1, 1, 1, 129.00, 129.00, '0', '李先生', '13800001111', '陕西省汉中市汉台区中山街 18 号', '测试订单', 'user1', NOW(), '初始配件订单');

INSERT INTO app_accessory_collection (collection_id, app_user_id, accessory_id, create_by, create_time, remark)
VALUES
(1, 1, 2, 'user1', NOW(), '测试收藏');

SET FOREIGN_KEY_CHECKS = 1;
