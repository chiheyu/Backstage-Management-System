CREATE ALIAS IF NOT EXISTS DATE_FORMAT FOR "com.ruoyi.desktop.h2.H2Functions.dateFormat";

CREATE ALIAS IF NOT EXISTS FIND_IN_SET FOR "com.ruoyi.desktop.h2.H2Functions.findInSet";

DROP TABLE IF EXISTS app_merchant_review;

DROP TABLE IF EXISTS app_accessory_collection;

DROP TABLE IF EXISTS app_accessory_order;

DROP TABLE IF EXISTS app_after_sales_order;

DROP TABLE IF EXISTS app_accessory;

DROP TABLE IF EXISTS app_merchant;

DROP TABLE IF EXISTS app_user;

DROP TABLE IF EXISTS sys_role_menu;

DROP TABLE IF EXISTS sys_user_role;

DROP TABLE IF EXISTS sys_user_post;

DROP TABLE IF EXISTS sys_role_dept;

DROP TABLE IF EXISTS sys_oper_log;

DROP TABLE IF EXISTS sys_logininfor;

DROP TABLE IF EXISTS sys_job_log;

DROP TABLE IF EXISTS sys_job;

DROP TABLE IF EXISTS sys_dict_data;

DROP TABLE IF EXISTS sys_dict_type;

DROP TABLE IF EXISTS sys_config;

DROP TABLE IF EXISTS sys_menu;

DROP TABLE IF EXISTS sys_post;

DROP TABLE IF EXISTS sys_role;

DROP TABLE IF EXISTS sys_user;

DROP TABLE IF EXISTS sys_dept;

CREATE TABLE sys_dept (
  dept_id bigint NOT NULL AUTO_INCREMENT,
  parent_id bigint DEFAULT '0',
  ancestors varchar(50) DEFAULT '',
  dept_name varchar(30) DEFAULT '',
  order_num int DEFAULT '0',
  leader varchar(20) DEFAULT NULL,
  phone varchar(11) DEFAULT NULL,
  email varchar(50) DEFAULT NULL,
  status char(1) DEFAULT '0',
  del_flag char(1) DEFAULT '0',
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT NULL,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  PRIMARY KEY (dept_id)
);

CREATE TABLE sys_role (
  role_id bigint NOT NULL AUTO_INCREMENT,
  role_name varchar(30) NOT NULL,
  role_key varchar(100) NOT NULL,
  role_sort int NOT NULL,
  data_scope char(1) DEFAULT '1',
  menu_check_strictly tinyint DEFAULT '1',
  dept_check_strictly tinyint DEFAULT '1',
  status char(1) NOT NULL,
  del_flag char(1) DEFAULT '0',
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT NULL,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (role_id),
  UNIQUE KEY uk_sys_role_key (role_key)
);

CREATE TABLE sys_menu (
  menu_id bigint NOT NULL AUTO_INCREMENT,
  menu_name varchar(50) NOT NULL,
  parent_id bigint DEFAULT '0',
  order_num int DEFAULT '0',
  path varchar(200) DEFAULT '',
  component varchar(255) DEFAULT NULL,
  query varchar(255) DEFAULT NULL,
  route_name varchar(50) DEFAULT '',
  is_frame int DEFAULT '1',
  is_cache int DEFAULT '0',
  menu_type char(1) DEFAULT '',
  visible char(1) DEFAULT '0',
  status char(1) DEFAULT '0',
  perms varchar(100) DEFAULT NULL,
  icon varchar(100) DEFAULT '#',
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT NULL,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT '',
  PRIMARY KEY (menu_id)
);

CREATE TABLE sys_post (
  post_id bigint NOT NULL AUTO_INCREMENT,
  post_code varchar(64) NOT NULL,
  post_name varchar(50) NOT NULL,
  post_sort int NOT NULL,
  status char(1) NOT NULL,
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT NULL,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (post_id)
);

CREATE TABLE sys_user (
  user_id bigint NOT NULL AUTO_INCREMENT,
  dept_id bigint DEFAULT NULL,
  user_name varchar(30) NOT NULL,
  nick_name varchar(30) NOT NULL,
  user_type varchar(2) DEFAULT '00',
  email varchar(50) DEFAULT '',
  phonenumber varchar(11) DEFAULT '',
  sex char(1) DEFAULT '0',
  avatar varchar(100) DEFAULT '',
  password varchar(100) DEFAULT '',
  status char(1) DEFAULT '0',
  del_flag char(1) DEFAULT '0',
  login_ip varchar(128) DEFAULT '',
  login_date datetime DEFAULT NULL,
  pwd_update_date datetime DEFAULT NULL,
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT NULL,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (user_id),
  UNIQUE KEY uk_sys_user_name (user_name),
  KEY idx_sys_user_phone (phonenumber)
);

CREATE TABLE sys_config (
  config_id int NOT NULL AUTO_INCREMENT,
  config_name varchar(100) DEFAULT '',
  config_key varchar(100) DEFAULT '',
  config_value varchar(500) DEFAULT '',
  config_type char(1) DEFAULT 'N',
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT NULL,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (config_id),
  UNIQUE KEY uk_sys_config_key (config_key)
);

CREATE TABLE sys_dict_type (
  dict_id bigint NOT NULL AUTO_INCREMENT,
  dict_name varchar(100) DEFAULT '',
  dict_type varchar(100) DEFAULT '',
  status char(1) DEFAULT '0',
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT NULL,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (dict_id),
  UNIQUE KEY uk_sys_dict_type (dict_type)
);

CREATE TABLE sys_dict_data (
  dict_code bigint NOT NULL AUTO_INCREMENT,
  dict_sort int DEFAULT '0',
  dict_label varchar(100) DEFAULT '',
  dict_value varchar(100) DEFAULT '',
  dict_type varchar(100) DEFAULT '',
  css_class varchar(100) DEFAULT NULL,
  list_class varchar(100) DEFAULT NULL,
  is_default char(1) DEFAULT 'N',
  status char(1) DEFAULT '0',
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT NULL,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (dict_code)
);

CREATE TABLE sys_job (
  job_id bigint NOT NULL AUTO_INCREMENT,
  job_name varchar(64) NOT NULL DEFAULT '',
  job_group varchar(64) NOT NULL DEFAULT 'DEFAULT',
  invoke_target varchar(500) NOT NULL,
  cron_expression varchar(255) DEFAULT '',
  misfire_policy varchar(20) DEFAULT '3',
  concurrent char(1) DEFAULT '1',
  status char(1) DEFAULT '0',
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT NULL,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT '',
  PRIMARY KEY (job_id,job_name,job_group)
);

CREATE TABLE sys_job_log (
  job_log_id bigint NOT NULL AUTO_INCREMENT,
  job_name varchar(64) NOT NULL,
  job_group varchar(64) NOT NULL,
  invoke_target varchar(500) NOT NULL,
  job_message varchar(500) DEFAULT NULL,
  status char(1) DEFAULT '0',
  exception_info varchar(2000) DEFAULT '',
  create_time datetime DEFAULT NULL,
  PRIMARY KEY (job_log_id)
);

CREATE TABLE sys_logininfor (
  info_id bigint NOT NULL AUTO_INCREMENT,
  user_name varchar(50) DEFAULT '',
  ipaddr varchar(128) DEFAULT '',
  login_location varchar(255) DEFAULT '',
  browser varchar(50) DEFAULT '',
  os varchar(50) DEFAULT '',
  status char(1) DEFAULT '0',
  msg varchar(255) DEFAULT '',
  login_time datetime DEFAULT NULL,
  PRIMARY KEY (info_id),
  KEY idx_sys_logininfor_s (status),
  KEY idx_sys_logininfor_lt (login_time)
);

CREATE TABLE sys_oper_log (
  oper_id bigint NOT NULL AUTO_INCREMENT,
  title varchar(50) DEFAULT '',
  business_type int DEFAULT '0',
  method varchar(100) DEFAULT '',
  request_method varchar(10) DEFAULT '',
  operator_type int DEFAULT '0',
  oper_name varchar(50) DEFAULT '',
  dept_name varchar(50) DEFAULT '',
  oper_url varchar(255) DEFAULT '',
  oper_ip varchar(128) DEFAULT '',
  oper_location varchar(255) DEFAULT '',
  oper_param varchar(2000) DEFAULT '',
  json_result varchar(2000) DEFAULT '',
  status int DEFAULT '0',
  error_msg varchar(2000) DEFAULT '',
  oper_time datetime DEFAULT NULL,
  cost_time bigint DEFAULT '0',
  PRIMARY KEY (oper_id),
  KEY idx_sys_oper_log_bt (business_type),
  KEY idx_sys_oper_log_s (status),
  KEY idx_sys_oper_log_ot (oper_time)
);

CREATE TABLE sys_role_menu (
  role_id bigint NOT NULL,
  menu_id bigint NOT NULL,
  PRIMARY KEY (role_id,menu_id),
  KEY idx_sys_role_menu_menu (menu_id)
);

CREATE TABLE sys_user_role (
  user_id bigint NOT NULL,
  role_id bigint NOT NULL,
  PRIMARY KEY (user_id,role_id),
  KEY idx_sys_user_role_role (role_id)
);

CREATE TABLE sys_user_post (
  user_id bigint NOT NULL,
  post_id bigint NOT NULL,
  PRIMARY KEY (user_id,post_id)
);

CREATE TABLE sys_role_dept (
  role_id bigint NOT NULL,
  dept_id bigint NOT NULL,
  PRIMARY KEY (role_id,dept_id)
);

CREATE TABLE app_user (
  app_user_id bigint NOT NULL AUTO_INCREMENT,
  sys_user_id bigint NOT NULL,
  phone varchar(11) NOT NULL,
  nick_name varchar(30) NOT NULL,
  role_type char(1) NOT NULL DEFAULT '1',
  merchant_id bigint DEFAULT NULL,
  status char(1) NOT NULL DEFAULT '0',
  last_sms_code varchar(6) DEFAULT NULL,
  last_sms_expire_time datetime DEFAULT NULL,
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT CURRENT_TIMESTAMP,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (app_user_id),
  UNIQUE KEY uk_app_user_phone (phone),
  UNIQUE KEY uk_app_user_sys_user (sys_user_id),
  KEY idx_app_user_role_type (role_type),
  KEY idx_app_user_merchant_id (merchant_id)
);

CREATE TABLE app_merchant (
  merchant_id bigint NOT NULL AUTO_INCREMENT,
  app_user_id bigint NOT NULL,
  sys_user_id bigint NOT NULL,
  merchant_name varchar(100) NOT NULL,
  contact_name varchar(30) DEFAULT '',
  contact_phone varchar(11) DEFAULT '',
  address varchar(255) DEFAULT '',
  service_scope varchar(255) DEFAULT '',
  merchant_desc varchar(500) DEFAULT NULL,
  city_name varchar(50) NOT NULL DEFAULT '汉中市',
  audit_status char(1) NOT NULL DEFAULT '0',
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT CURRENT_TIMESTAMP,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (merchant_id),
  KEY idx_app_merchant_audit_status (audit_status),
  KEY idx_app_merchant_city_name (city_name),
  KEY idx_app_merchant_sys_user_id (sys_user_id)
);

CREATE TABLE app_accessory (
  accessory_id bigint NOT NULL AUTO_INCREMENT,
  merchant_id bigint DEFAULT NULL,
  category_name varchar(50) NOT NULL,
  accessory_name varchar(100) NOT NULL,
  accessory_desc varchar(500) DEFAULT NULL,
  cover_image varchar(255) DEFAULT NULL,
  price decimal(10,2) NOT NULL,
  stock bigint NOT NULL DEFAULT '0',
  sales_count bigint NOT NULL DEFAULT '0',
  status char(1) NOT NULL DEFAULT '0',
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT CURRENT_TIMESTAMP,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (accessory_id),
  KEY idx_app_accessory_merchant_id (merchant_id),
  KEY idx_app_accessory_category (category_name),
  KEY idx_app_accessory_status (status),
  KEY idx_app_accessory_price (price)
);

CREATE TABLE app_after_sales_order (
  order_id bigint NOT NULL AUTO_INCREMENT,
  order_no varchar(32) NOT NULL,
  app_user_id bigint NOT NULL,
  merchant_id bigint DEFAULT NULL,
  product_type varchar(100) NOT NULL,
  fault_desc varchar(500) DEFAULT NULL,
  fault_images varchar(1000) DEFAULT NULL,
  status char(1) NOT NULL DEFAULT '0',
  service_remark varchar(500) DEFAULT NULL,
  contact_name varchar(30) NOT NULL,
  contact_phone varchar(11) NOT NULL,
  address varchar(255) DEFAULT '',
  accept_time datetime DEFAULT NULL,
  finish_time datetime DEFAULT NULL,
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT CURRENT_TIMESTAMP,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (order_id),
  UNIQUE KEY uk_app_after_sales_order_no (order_no),
  KEY idx_app_after_sales_user_id (app_user_id),
  KEY idx_app_after_sales_merchant_id (merchant_id),
  KEY idx_app_after_sales_status (status),
  KEY idx_app_after_sales_create_time (create_time)
);

CREATE TABLE app_accessory_order (
  accessory_order_id bigint NOT NULL AUTO_INCREMENT,
  order_no varchar(32) NOT NULL,
  accessory_id bigint NOT NULL,
  app_user_id bigint NOT NULL,
  merchant_id bigint DEFAULT NULL,
  quantity bigint NOT NULL,
  price decimal(10,2) NOT NULL,
  total_amount decimal(10,2) NOT NULL,
  status char(1) NOT NULL DEFAULT '0',
  receiver_name varchar(30) NOT NULL,
  receiver_phone varchar(11) NOT NULL,
  receiver_address varchar(255) NOT NULL,
  order_remark varchar(500) DEFAULT NULL,
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT CURRENT_TIMESTAMP,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (accessory_order_id),
  UNIQUE KEY uk_app_accessory_order_no (order_no),
  KEY idx_app_accessory_order_user_id (app_user_id),
  KEY idx_app_accessory_order_merchant_id (merchant_id),
  KEY idx_app_accessory_order_accessory_id (accessory_id),
  KEY idx_app_accessory_order_status (status),
  KEY idx_app_accessory_order_create_time (create_time)
);

CREATE TABLE app_accessory_collection (
  collection_id bigint NOT NULL AUTO_INCREMENT,
  app_user_id bigint NOT NULL,
  accessory_id bigint NOT NULL,
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT CURRENT_TIMESTAMP,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (collection_id),
  UNIQUE KEY uk_app_collection_user_accessory (app_user_id,accessory_id),
  KEY idx_app_collection_user_id (app_user_id),
  KEY idx_app_collection_accessory_id (accessory_id)
);

CREATE TABLE app_merchant_review (
  review_id bigint NOT NULL AUTO_INCREMENT,
  merchant_id bigint NOT NULL,
  accessory_order_id bigint NOT NULL,
  app_user_id bigint NOT NULL,
  rating int NOT NULL DEFAULT '5',
  review_content varchar(500) NOT NULL,
  create_by varchar(64) DEFAULT '',
  create_time datetime DEFAULT CURRENT_TIMESTAMP,
  update_by varchar(64) DEFAULT '',
  update_time datetime DEFAULT NULL,
  remark varchar(500) DEFAULT NULL,
  PRIMARY KEY (review_id),
  UNIQUE KEY uk_app_merchant_review_order_id (accessory_order_id),
  KEY idx_app_merchant_review_merchant_id (merchant_id),
  KEY idx_app_merchant_review_app_user_id (app_user_id)
);
