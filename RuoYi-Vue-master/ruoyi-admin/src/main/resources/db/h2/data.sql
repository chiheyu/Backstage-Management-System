INSERT INTO `sys_dept` (`dept_id`, `parent_id`, `ancestors`, `dept_name`, `order_num`, `leader`, `phone`, `email`, `status`, `del_flag`, `create_by`, `create_time`)
VALUES
(100, 0, '0', '汉中售后管理中心', 1, '管理员', '09161234567', 'support@hanzhong.local', '0', '0', 'system', CURRENT_TIMESTAMP);

INSERT INTO `sys_role` (`role_id`, `role_name`, `role_key`, `role_sort`, `data_scope`, `menu_check_strictly`, `dept_check_strictly`, `status`, `del_flag`, `create_by`, `create_time`, `remark`)
VALUES
(1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'system', CURRENT_TIMESTAMP, '系统管理员'),
(200, '普通用户', 'user', 2, '1', 1, 1, '0', '0', 'system', CURRENT_TIMESTAMP, 'App普通用户'),
(201, '商家用户', 'merchant', 3, '1', 1, 1, '0', '0', 'system', CURRENT_TIMESTAMP, 'App商家用户');

INSERT INTO `sys_config` (`config_id`, `config_name`, `config_key`, `config_value`, `config_type`, `create_by`, `create_time`, `remark`)
VALUES
(1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', CURRENT_TIMESTAMP, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow'),
(2, '用户管理-账号初始密码', 'sys.user.initPassword', 'Abc123456', 'Y', 'admin', CURRENT_TIMESTAMP, '初始化密码 Abc123456'),
(3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', CURRENT_TIMESTAMP, '深色主题 theme-dark，浅色主题 theme-light'),
(4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', 'Y', 'admin', CURRENT_TIMESTAMP, '是否开启验证码功能'),
(5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', CURRENT_TIMESTAMP, '是否开启注册用户功能'),
(6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', CURRENT_TIMESTAMP, '设置登录IP黑名单限制'),
(7, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', 'admin', CURRENT_TIMESTAMP, '首次登录提示修改初始密码'),
(8, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', CURRENT_TIMESTAMP, '密码更新周期');

INSERT INTO `sys_dict_type` (`dict_id`, `dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
VALUES
(1, '用户性别', 'sys_user_sex', '0', 'admin', CURRENT_TIMESTAMP, '用户性别列表'),
(2, '菜单状态', 'sys_show_hide', '0', 'admin', CURRENT_TIMESTAMP, '菜单状态列表'),
(3, '系统开关', 'sys_normal_disable', '0', 'admin', CURRENT_TIMESTAMP, '系统开关列表'),
(4, '任务状态', 'sys_job_status', '0', 'admin', CURRENT_TIMESTAMP, '任务状态列表'),
(5, '任务分组', 'sys_job_group', '0', 'admin', CURRENT_TIMESTAMP, '任务分组列表'),
(6, '系统是否', 'sys_yes_no', '0', 'admin', CURRENT_TIMESTAMP, '系统是否列表'),
(7, '通知类型', 'sys_notice_type', '0', 'admin', CURRENT_TIMESTAMP, '通知类型列表'),
(8, '通知状态', 'sys_notice_status', '0', 'admin', CURRENT_TIMESTAMP, '通知状态列表'),
(9, '操作类型', 'sys_oper_type', '0', 'admin', CURRENT_TIMESTAMP, '操作类型列表'),
(10, '系统状态', 'sys_common_status', '0', 'admin', CURRENT_TIMESTAMP, '系统状态列表');

INSERT INTO `sys_dict_data` (`dict_code`, `dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `remark`)
VALUES
(1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', CURRENT_TIMESTAMP, '性别男'),
(2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', CURRENT_TIMESTAMP, '性别女'),
(3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', CURRENT_TIMESTAMP, '性别未知'),
(4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', CURRENT_TIMESTAMP, '显示菜单'),
(5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', CURRENT_TIMESTAMP, '隐藏菜单'),
(6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', CURRENT_TIMESTAMP, '正常状态'),
(7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', CURRENT_TIMESTAMP, '停用状态'),
(8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', CURRENT_TIMESTAMP, '正常状态'),
(9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', CURRENT_TIMESTAMP, '暂停状态'),
(10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', CURRENT_TIMESTAMP, '默认分组'),
(11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', CURRENT_TIMESTAMP, '系统分组'),
(12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', CURRENT_TIMESTAMP, '系统默认是'),
(13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', CURRENT_TIMESTAMP, '系统默认否'),
(14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', CURRENT_TIMESTAMP, '通知'),
(15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', CURRENT_TIMESTAMP, '公告'),
(16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', CURRENT_TIMESTAMP, '正常状态'),
(17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', CURRENT_TIMESTAMP, '关闭状态'),
(18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', CURRENT_TIMESTAMP, '其他操作'),
(19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', CURRENT_TIMESTAMP, '新增操作'),
(20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', CURRENT_TIMESTAMP, '修改操作'),
(21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', CURRENT_TIMESTAMP, '删除操作'),
(22, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', CURRENT_TIMESTAMP, '授权操作'),
(23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', CURRENT_TIMESTAMP, '导出操作'),
(24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', CURRENT_TIMESTAMP, '导入操作'),
(25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', CURRENT_TIMESTAMP, '强退操作'),
(26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', CURRENT_TIMESTAMP, '生成代码'),
(27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', CURRENT_TIMESTAMP, '清空数据'),
(28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', CURRENT_TIMESTAMP, '成功状态'),
(29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', CURRENT_TIMESTAMP, '失败状态');

INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query`, `route_name`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_by`, `create_time`, `remark`)
VALUES
(2000, '售后业务', 0, 8, 'app', NULL, '', '', 1, 0, 'M', '0', '0', '', 'guide', 'system', CURRENT_TIMESTAMP, '售后业务根菜单'),
(2010, '商家管理', 2000, 1, 'merchant', 'app/merchant/index', '', '', 1, 0, 'C', '0', '0', 'app:merchant:list', 'peoples', 'system', CURRENT_TIMESTAMP, '商家管理'),
(2011, '商家查询', 2010, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:merchant:query', '#', 'system', CURRENT_TIMESTAMP, '商家查询按钮'),
(2012, '商家编辑', 2010, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:merchant:edit', '#', 'system', CURRENT_TIMESTAMP, '商家编辑按钮'),
(2013, '商家审核', 2010, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:merchant:audit', '#', 'system', CURRENT_TIMESTAMP, '商家审核按钮'),
(2020, '售后订单管理', 2000, 2, 'afterSalesOrder', 'app/afterSalesOrder/index', '', '', 1, 0, 'C', '0', '0', 'app:afterSalesOrder:list', 'example', 'system', CURRENT_TIMESTAMP, '售后订单管理'),
(2021, '售后订单查询', 2020, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:afterSalesOrder:query', '#', 'system', CURRENT_TIMESTAMP, '售后订单查询按钮'),
(2022, '售后订单编辑', 2020, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:afterSalesOrder:edit', '#', 'system', CURRENT_TIMESTAMP, '售后订单编辑按钮'),
(2030, '配件管理', 2000, 3, 'accessory', 'app/accessory/index', '', '', 1, 0, 'C', '0', '0', 'app:accessory:list', 'shopping', 'system', CURRENT_TIMESTAMP, '配件管理'),
(2031, '配件查询', 2030, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:accessory:query', '#', 'system', CURRENT_TIMESTAMP, '配件查询按钮'),
(2032, '配件新增', 2030, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:accessory:add', '#', 'system', CURRENT_TIMESTAMP, '配件新增按钮'),
(2033, '配件编辑', 2030, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:accessory:edit', '#', 'system', CURRENT_TIMESTAMP, '配件编辑按钮'),
(2034, '配件删除', 2030, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:accessory:remove', '#', 'system', CURRENT_TIMESTAMP, '配件删除按钮'),
(2040, '配件订单管理', 2000, 4, 'accessoryOrder', 'app/accessoryOrder/index', '', '', 1, 0, 'C', '0', '0', 'app:accessoryOrder:list', 'order', 'system', CURRENT_TIMESTAMP, '配件订单管理'),
(2041, '配件订单查询', 2040, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:accessoryOrder:query', '#', 'system', CURRENT_TIMESTAMP, '配件订单查询按钮');

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
VALUES
(1, 2000), (1, 2010), (1, 2011), (1, 2012), (1, 2013),
(1, 2020), (1, 2021), (1, 2022),
(1, 2030), (1, 2031), (1, 2032), (1, 2033), (1, 2034),
(1, 2040), (1, 2041);

INSERT INTO `sys_user` (`user_id`, `dept_id`, `user_name`, `nick_name`, `user_type`, `email`, `phonenumber`, `sex`, `avatar`, `password`, `status`, `del_flag`, `login_ip`, `login_date`, `pwd_update_date`, `create_by`, `create_time`, `remark`)
VALUES
(1, 100, 'admin', '管理员', '00', 'admin@hanzhong.local', '19929403279', '1', '/profile/avatar/admin.png', '$2a$10$p6QsklIBMgCFCqs1S5wlW.0wCrc6iD2z7GyM6RJSZTiAtuZxN.AiO', '0', '0', '127.0.0.1', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, '后台管理员'),
(2000, 100, '19929403280', '李晨', '00', 'user1@hanzhong.local', '19929403280', '0', '/profile/avatar/user1.png', '$2a$10$p6QsklIBMgCFCqs1S5wlW.0wCrc6iD2z7GyM6RJSZTiAtuZxN.AiO', '0', '0', '127.0.0.1', DATEADD('DAY', -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP, 'system', DATEADD('DAY', -20, CURRENT_TIMESTAMP), '普通用户一'),
(2001, 100, '19929403281', '王敏', '00', 'user2@hanzhong.local', '19929403281', '1', '/profile/avatar/user2.png', '$2a$10$p6QsklIBMgCFCqs1S5wlW.0wCrc6iD2z7GyM6RJSZTiAtuZxN.AiO', '0', '0', '127.0.0.1', DATEADD('DAY', -2, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP, 'system', DATEADD('DAY', -18, CURRENT_TIMESTAMP), '普通用户二'),
(2100, 100, '19929403282', '赵师傅', '00', 'merchant1@hanzhong.local', '19929403282', '0', '/profile/avatar/merchant1.png', '$2a$10$p6QsklIBMgCFCqs1S5wlW.0wCrc6iD2z7GyM6RJSZTiAtuZxN.AiO', '0', '0', '127.0.0.1', DATEADD('DAY', -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP, 'system', DATEADD('DAY', -30, CURRENT_TIMESTAMP), '商家账号一'),
(2101, 100, '19929403283', '陈师傅', '00', 'merchant2@hanzhong.local', '19929403283', '0', '/profile/avatar/merchant2.png', '$2a$10$p6QsklIBMgCFCqs1S5wlW.0wCrc6iD2z7GyM6RJSZTiAtuZxN.AiO', '0', '0', '127.0.0.1', DATEADD('DAY', -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP, 'system', DATEADD('DAY', -28, CURRENT_TIMESTAMP), '商家账号二');

INSERT INTO `sys_user_role` (`user_id`, `role_id`)
VALUES
(1, 1),
(2000, 200),
(2001, 200),
(2100, 201),
(2101, 201);

INSERT INTO `app_user` (`app_user_id`, `sys_user_id`, `phone`, `nick_name`, `role_type`, `merchant_id`, `status`, `create_by`, `create_time`, `remark`)
VALUES
(1, 2000, '19929403280', '李晨', '1', NULL, '0', 'system', DATEADD('DAY', -20, CURRENT_TIMESTAMP), '普通用户一'),
(2, 2001, '19929403281', '王敏', '1', NULL, '0', 'system', DATEADD('DAY', -18, CURRENT_TIMESTAMP), '普通用户二'),
(3, 2100, '19929403282', '赵师傅', '2', 1, '0', 'system', DATEADD('DAY', -30, CURRENT_TIMESTAMP), '商家账号一'),
(4, 2101, '19929403283', '陈师傅', '2', 2, '0', 'system', DATEADD('DAY', -28, CURRENT_TIMESTAMP), '商家账号二');

INSERT INTO `app_merchant` (`merchant_id`, `app_user_id`, `sys_user_id`, `merchant_name`, `contact_name`, `contact_phone`, `address`, `service_scope`, `merchant_desc`, `city_name`, `audit_status`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES
(1, 3, 2100, '汉台极速数码服务中心', '赵师傅', '19929403282', '陕西省汉中市汉台区前进路88号', '手机、平板、数码配件、上门安装', '主营手机换屏、尾插维修、电池更换与数码配件销售，支持到店和同城服务。', '汉中市', '1', 'system', DATEADD('DAY', -30, CURRENT_TIMESTAMP), 'system', DATEADD('DAY', -1, CURRENT_TIMESTAMP), '已审核商家'),
(2, 4, 2101, '滨江电脑与平板维修店', '陈师傅', '19929403283', '陕西省汉中市汉台区滨江西路26号', '电脑、平板、SSD升级、办公外设', '主营笔记本维修、平板换屏、SSD升级和办公设备配件销售。', '汉中市', '1', 'system', DATEADD('DAY', -28, CURRENT_TIMESTAMP), 'system', DATEADD('DAY', -1, CURRENT_TIMESTAMP), '已审核商家');

INSERT INTO `app_accessory` (`accessory_id`, `merchant_id`, `category_name`, `accessory_name`, `accessory_desc`, `cover_image`, `price`, `stock`, `sales_count`, `status`, `create_by`, `create_time`, `remark`)
VALUES
(1, 1, '手机配件', '电源适配器', '多口快充电源适配器，兼容手机、平板、笔记本设备，支持门店安装。', 'static/images/accessory/adapter.png', 69.00, 80, 12, '0', '19929403282', DATEADD('DAY', -25, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(2, 1, '手机配件', '手机显示屏', '高清原装手机屏幕，碎屏、花屏、漏液维修更换，支持到店安装。', 'static/images/accessory/phone_screen.png', 399.00, 30, 8, '0', '19929403282', DATEADD('DAY', -25, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(3, 1, '手机配件', '手机电池', '适配主流安卓机型的高容量电池，续航持久，支持门店安装。', 'static/images/accessory/battery.png', 129.00, 50, 10, '0', '19929403282', DATEADD('DAY', -24, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(4, 1, '手机配件', '尾插排线', '手机充电接口总成，解决接触不良、无法充电、不快充问题。', 'static/images/accessory/charging_port.png', 89.00, 60, 6, '0', '19929403282', DATEADD('DAY', -24, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(5, 1, '手机配件', '手机扬声器', '手机外放喇叭，修复无声、破音、杂音、音量小故障。', 'static/images/accessory/speaker.png', 79.00, 65, 5, '0', '19929403282', DATEADD('DAY', -23, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(6, 1, '电脑配件', '笔记本电池', '笔记本原装规格电池，解决鼓包、不存电、续航短问题。', 'static/images/accessory/laptop_battery.png', 299.00, 20, 7, '0', '19929403282', DATEADD('DAY', -23, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(7, 1, '电脑配件', '笔记本充电器', '大功率笔记本电源适配器，适配主流品牌电脑，充电稳定。', 'static/images/accessory/laptop_adapter.png', 169.00, 30, 4, '0', '19929403282', DATEADD('DAY', -22, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(8, 1, '电脑配件', '笔记本屏幕', '笔记本高清液晶显示屏，碎屏、暗屏、花屏专业更换。', 'static/images/accessory/laptop_screen.png', 499.00, 15, 3, '0', '19929403282', DATEADD('DAY', -22, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(9, 2, '电脑配件', '固态硬盘SSD', '高速固态硬盘，电脑升级提速，支持系统迁移安装。', 'static/images/accessory/ssd.png', 299.00, 25, 9, '0', '19929403283', DATEADD('DAY', -21, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(10, 2, '平板配件', '平板屏幕', '平板电脑高清屏幕总成，碎屏、触摸失灵维修。', 'static/images/accessory/tablet_screen.png', 359.00, 20, 6, '0', '19929403283', DATEADD('DAY', -21, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(11, 2, '平板配件', '平板电池', '平板大容量原装电池，解决耗电快、不充电、自动关机。', 'static/images/accessory/tablet_battery.png', 199.00, 25, 5, '0', '19929403283', DATEADD('DAY', -20, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(12, 2, '通用配件', 'Type-C数据线', '编织快充数据线，支持65W快充，兼容安卓、苹果、平板设备。', 'static/images/accessory/typec_cable.png', 39.00, 150, 20, '0', '19929403283', DATEADD('DAY', -20, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(13, 2, '通用配件', '无线充电器', '桌面无线快充底座，支持主流手机无线充电。', 'static/images/accessory/wireless_charger.png', 99.00, 45, 9, '0', '19929403283', DATEADD('DAY', -19, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(14, 2, '保护配件', '钢化膜', '高清防爆钢化膜，防指纹、防摔、防刮花。', 'static/images/accessory/glass.png', 29.00, 200, 16, '0', '19929403283', DATEADD('DAY', -19, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(15, 2, '保护配件', '手机壳', '全包防摔手机保护壳，软边硬背，有效防护机身。', 'static/images/accessory/case.png', 49.00, 120, 14, '0', '19929403283', DATEADD('DAY', -18, CURRENT_TIMESTAMP), '商品路径.docx导入'),
(16, 2, '音频配件', '有线耳机', '半入耳式线控耳机，通话清晰，音质稳定。', 'static/images/accessory/earphone.png', 79.00, 80, 11, '0', '19929403283', DATEADD('DAY', -18, CURRENT_TIMESTAMP), '商品路径.docx导入');

INSERT INTO `app_accessory_order` (`accessory_order_id`, `order_no`, `accessory_id`, `app_user_id`, `merchant_id`, `quantity`, `price`, `total_amount`, `status`, `receiver_name`, `receiver_phone`, `receiver_address`, `order_remark`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES
(1, 'AO202603300001', 1, 1, 1, 1, 69.00, 69.00, '2', '李晨', '19929403280', '陕西省汉中市汉台区中山街18号', '门店自提', '19929403280', DATEADD('DAY', -6, CURRENT_TIMESTAMP), '19929403282', DATEADD('DAY', -5, CURRENT_TIMESTAMP), '已完成订单'),
(2, 'AO202603300002', 4, 1, 1, 2, 89.00, 178.00, '1', '李晨', '19929403280', '陕西省汉中市汉台区中山街18号', '尽快发货', '19929403280', DATEADD('DAY', -4, CURRENT_TIMESTAMP), '19929403282', DATEADD('DAY', -2, CURRENT_TIMESTAMP), '已发货订单'),
(3, 'AO202603300003', 12, 1, 2, 1, 39.00, 39.00, '0', '李晨', '19929403280', '陕西省汉中市汉台区中山街18号', '下班后收货', '19929403280', CURRENT_TIMESTAMP, NULL, NULL, '待处理订单'),
(4, 'AO202603300004', 15, 1, 2, 1, 49.00, 49.00, '3', '李晨', '19929403280', '陕西省汉中市汉台区中山街18号', '颜色改错后取消', '19929403280', DATEADD('DAY', -10, CURRENT_TIMESTAMP), '19929403280', DATEADD('DAY', -9, CURRENT_TIMESTAMP), '已取消订单'),
(5, 'AO202603300005', 6, 2, 1, 1, 299.00, 299.00, '2', '王敏', '19929403281', '陕西省汉中市南郑区大河坎镇66号', '用于更换旧电池', '19929403281', DATEADD('DAY', -3, CURRENT_TIMESTAMP), '19929403282', CURRENT_TIMESTAMP, '已完成订单'),
(6, 'AO202603300006', 8, 2, 1, 1, 499.00, 499.00, '0', '王敏', '19929403281', '陕西省汉中市南郑区大河坎镇66号', '需要安装指导', '19929403281', CURRENT_TIMESTAMP, NULL, NULL, '待处理订单'),
(7, 'AO202603300007', 10, 2, 2, 1, 359.00, 359.00, '2', '王敏', '19929403281', '陕西省汉中市南郑区大河坎镇66号', '平板换屏配件', '19929403281', DATEADD('DAY', -7, CURRENT_TIMESTAMP), '19929403283', DATEADD('DAY', -6, CURRENT_TIMESTAMP), '已完成订单'),
(8, 'AO202603300008', 16, 2, 2, 2, 79.00, 158.00, '2', '王敏', '19929403281', '陕西省汉中市南郑区大河坎镇66号', '耳机备用', '19929403281', DATEADD('DAY', -2, CURRENT_TIMESTAMP), '19929403283', DATEADD('DAY', -1, CURRENT_TIMESTAMP), '已完成订单');

INSERT INTO `app_merchant_review` (`review_id`, `merchant_id`, `accessory_order_id`, `app_user_id`, `rating`, `review_content`, `create_by`, `create_time`, `remark`)
VALUES
(1, 1, 1, 1, 5, '发货及时，适配器做工不错，商家沟通也很顺畅。', '19929403280', DATEADD('DAY', -5, CURRENT_TIMESTAMP), '订单评价'),
(2, 1, 5, 2, 4, '笔记本电池安装后续航明显恢复，整体体验很好。', '19929403281', CURRENT_TIMESTAMP, '订单评价'),
(3, 2, 7, 2, 5, '平板屏幕显示清晰，包装严实，售后响应快。', '19929403281', DATEADD('DAY', -6, CURRENT_TIMESTAMP), '订单评价'),
(4, 2, 8, 2, 5, '耳机音质稳定，第二次回购了，店铺服务很专业。', '19929403281', DATEADD('DAY', -1, CURRENT_TIMESTAMP), '订单评价');

INSERT INTO `app_accessory_collection` (`collection_id`, `app_user_id`, `accessory_id`, `create_by`, `create_time`, `remark`)
VALUES
(1, 1, 2, '19929403280', DATEADD('DAY', -5, CURRENT_TIMESTAMP), '收藏手机显示屏'),
(2, 1, 13, '19929403280', DATEADD('DAY', -2, CURRENT_TIMESTAMP), '收藏无线充电器'),
(3, 2, 6, '19929403281', DATEADD('DAY', -4, CURRENT_TIMESTAMP), '收藏笔记本电池'),
(4, 2, 15, '19929403281', DATEADD('DAY', -1, CURRENT_TIMESTAMP), '收藏手机壳');

INSERT INTO `app_after_sales_order` (`order_id`, `order_no`, `app_user_id`, `merchant_id`, `product_type`, `fault_desc`, `fault_images`, `status`, `service_remark`, `contact_name`, `contact_phone`, `address`, `accept_time`, `finish_time`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES
(1, 'AS202603300001', 1, NULL, '退款-手机显示屏', '收到配件后发现型号不匹配，需要退款处理。', '/static/images/after-sales/refund-screen-1.png', '0', NULL, '李晨', '19929403280', '陕西省汉中市汉台区中山街18号', NULL, NULL, '19929403280', DATEADD('DAY', -1, CURRENT_TIMESTAMP), NULL, NULL, '待商家接单'),
(2, 'AS202603300002', 1, 1, '换货-尾插排线', '安装后充电接触偶尔不稳，申请换货。', '/static/images/after-sales/replace-port-1.png', '1', '已联系用户，安排到店检测。', '李晨', '19929403280', '陕西省汉中市汉台区中山街18号', DATEADD('DAY', -3, CURRENT_TIMESTAMP), NULL, '19929403280', DATEADD('DAY', -4, CURRENT_TIMESTAMP), '19929403282', DATEADD('DAY', -3, CURRENT_TIMESTAMP), '商家已接单'),
(3, 'AS202603300003', 1, 1, '退款-手机电池', '更换后电量下降过快，正在维修中。', '/static/images/after-sales/refund-battery-1.png', '2', '已拆机检测，待更换新电芯。', '李晨', '19929403280', '陕西省汉中市汉台区中山街18号', DATEADD('DAY', -4, CURRENT_TIMESTAMP), NULL, '19929403280', DATEADD('DAY', -5, CURRENT_TIMESTAMP), '19929403282', DATEADD('DAY', -1, CURRENT_TIMESTAMP), '维修中'),
(4, 'AS202603300004', 1, 1, '换货-电源适配器', '适配器快充偶发断连，已更换完成。', '/static/images/after-sales/replace-adapter-1.png', '3', '已为用户更换新适配器并完成测试。', '李晨', '19929403280', '陕西省汉中市汉台区中山街18号', DATEADD('DAY', -7, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP, '19929403280', DATEADD('DAY', -8, CURRENT_TIMESTAMP), '19929403282', CURRENT_TIMESTAMP, '已完成售后'),
(5, 'AS202603300005', 2, NULL, '换货-Type-C数据线', '数据线收到后外皮破损，申请换货。', '/static/images/after-sales/replace-cable-1.png', '0', NULL, '王敏', '19929403281', '陕西省汉中市南郑区大河坎镇66号', NULL, NULL, '19929403281', CURRENT_TIMESTAMP, NULL, NULL, '待商家接单'),
(6, 'AS202603300006', 2, 2, '退款-平板屏幕', '平板屏幕到货后与设备颜色不一致，申请退款。', '/static/images/after-sales/refund-tablet-1.png', '1', '已确认问题，安排质检。', '王敏', '19929403281', '陕西省汉中市南郑区大河坎镇66号', DATEADD('DAY', -2, CURRENT_TIMESTAMP), NULL, '19929403281', DATEADD('DAY', -3, CURRENT_TIMESTAMP), '19929403283', DATEADD('DAY', -2, CURRENT_TIMESTAMP), '商家已接单'),
(7, 'AS202603300007', 2, 2, '换货-无线充电器', '无线充电器间歇性断充，商家已处理完成。', '/static/images/after-sales/replace-wireless-1.png', '3', '更换新品后测试正常。', '王敏', '19929403281', '陕西省汉中市南郑区大河坎镇66号', DATEADD('DAY', -5, CURRENT_TIMESTAMP), DATEADD('DAY', -3, CURRENT_TIMESTAMP), '19929403281', DATEADD('DAY', -6, CURRENT_TIMESTAMP), '19929403283', DATEADD('DAY', -3, CURRENT_TIMESTAMP), '已完成售后'),
(8, 'AS202603300008', 2, 2, '退款-手机壳', '用户下单后主动取消退款。', '/static/images/after-sales/refund-case-1.png', '4', '用户已确认取消，订单关闭。', '王敏', '19929403281', '陕西省汉中市南郑区大河坎镇66号', DATEADD('DAY', -6, CURRENT_TIMESTAMP), DATEADD('DAY', -5, CURRENT_TIMESTAMP), '19929403281', DATEADD('DAY', -7, CURRENT_TIMESTAMP), '19929403283', DATEADD('DAY', -5, CURRENT_TIMESTAMP), '已取消售后');
