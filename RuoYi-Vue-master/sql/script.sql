-- 汉中售后一体化初始化脚本
-- 说明：
-- 1. 以当前实际数据库 ruoyi-data 的表结构为准整理。
-- 2. 本脚本包含：建库、建表、初始化 admin、普通用户、已审核商家、菜单角色与业务演示数据。
-- 3. 配件商品数据来源：sql/商品路径.docx，并统一归属给初始化商家账号。

DROP DATABASE IF EXISTS `ruoyi-data`;
CREATE DATABASE `ruoyi-data` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `ruoyi-data`;

SET NAMES utf8mb4;

create table app_accessory
(
    accessory_id   bigint auto_increment comment '主键'
        primary key,
    merchant_id    bigint                                null comment '归属商家 ID',
    category_name  varchar(50)                           not null comment '分类名称',
    accessory_name varchar(100)                          not null comment '配件名称',
    accessory_desc varchar(500)                          null comment '配件描述',
    cover_image    varchar(255)                          null comment '封面图',
    price          decimal(10, 2)                        not null comment '价格',
    stock          bigint      default 0                 not null comment '库存',
    sales_count    bigint      default 0                 not null comment '销量',
    status         char        default '0'               not null comment '状态：0上架 1下架',
    create_by      varchar(64) default ''                null comment '创建者',
    create_time    datetime    default CURRENT_TIMESTAMP null comment '创建时间',
    update_by      varchar(64) default ''                null comment '更新者',
    update_time    datetime                              null comment '更新时间',
    remark         varchar(500)                          null comment '备注'
)
    comment '配件表';

create index idx_app_accessory_category
    on app_accessory (category_name);

create index idx_app_accessory_merchant_id
    on app_accessory (merchant_id);

create index idx_app_accessory_price
    on app_accessory (price);

create index idx_app_accessory_status
    on app_accessory (status);

create table app_accessory_collection
(
    collection_id bigint auto_increment comment '主键'
        primary key,
    app_user_id   bigint                                not null comment '收藏用户',
    accessory_id  bigint                                not null comment '配件 ID',
    create_by     varchar(64) default ''                null comment '创建者',
    create_time   datetime    default CURRENT_TIMESTAMP null comment '创建时间',
    update_by     varchar(64) default ''                null comment '更新者',
    update_time   datetime                              null comment '更新时间',
    remark        varchar(500)                          null comment '备注',
    constraint uk_app_collection_user_accessory
        unique (app_user_id, accessory_id)
)
    comment '配件收藏表';

create index idx_app_collection_accessory_id
    on app_accessory_collection (accessory_id);

create index idx_app_collection_user_id
    on app_accessory_collection (app_user_id);

create table app_accessory_order
(
    accessory_order_id bigint auto_increment comment '主键'
        primary key,
    order_no           varchar(32)                           not null comment '订单号',
    accessory_id       bigint                                not null comment '配件 ID',
    app_user_id        bigint                                not null comment '下单用户',
    merchant_id        bigint                                null comment '归属商家 ID',
    quantity           bigint                                not null comment '数量',
    price              decimal(10, 2)                        not null comment '单价',
    total_amount       decimal(10, 2)                        not null comment '总金额',
    status             char        default '0'               not null comment '状态：0待处理 1已发货 2已完成 3已取消',
    receiver_name      varchar(30)                           not null comment '收货人',
    receiver_phone     varchar(11)                           not null comment '联系电话',
    receiver_address   varchar(255)                          not null comment '收货地址',
    order_remark       varchar(500)                          null comment '订单备注',
    create_by          varchar(64) default ''                null comment '创建者',
    create_time        datetime    default CURRENT_TIMESTAMP null comment '创建时间',
    update_by          varchar(64) default ''                null comment '更新者',
    update_time        datetime                              null comment '更新时间',
    remark             varchar(500)                          null comment '备注',
    constraint uk_app_accessory_order_no
        unique (order_no)
)
    comment '配件订单表';

create index idx_app_accessory_order_accessory_id
    on app_accessory_order (accessory_id);

create index idx_app_accessory_order_create_time
    on app_accessory_order (create_time);

create index idx_app_accessory_order_merchant_id
    on app_accessory_order (merchant_id);

create index idx_app_accessory_order_status
    on app_accessory_order (status);

create index idx_app_accessory_order_user_id
    on app_accessory_order (app_user_id);

create table app_after_sales_order
(
    order_id       bigint auto_increment comment '主键'
        primary key,
    order_no       varchar(32)                            not null comment '业务单号',
    app_user_id    bigint                                 not null comment '提交用户',
    merchant_id    bigint                                 null comment '接单商家',
    product_type   varchar(100)                           not null comment '产品类型',
    fault_desc     varchar(500)                           null comment '故障描述',
    fault_images   varchar(1000)                          null comment '故障图片，多图用逗号分隔',
    status         char         default '0'               not null comment '状态：0待接单 1已接单 2维修中 3已完成 4已取消',
    service_remark varchar(500)                           null comment '处理备注',
    contact_name   varchar(30)                            not null comment '联系人',
    contact_phone  varchar(11)                            not null comment '联系电话',
    address        varchar(255) default ''                null comment '服务地址',
    accept_time    datetime                               null comment '接单时间',
    finish_time    datetime                               null comment '完成时间',
    create_by      varchar(64)  default ''                null comment '创建者',
    create_time    datetime     default CURRENT_TIMESTAMP null comment '创建时间',
    update_by      varchar(64)  default ''                null comment '更新者',
    update_time    datetime                               null comment '更新时间',
    remark         varchar(500)                           null comment '备注',
    constraint uk_app_after_sales_order_no
        unique (order_no)
)
    comment '售后订单表';

create index idx_app_after_sales_create_time
    on app_after_sales_order (create_time);

create index idx_app_after_sales_merchant_id
    on app_after_sales_order (merchant_id);

create index idx_app_after_sales_status
    on app_after_sales_order (status);

create index idx_app_after_sales_user_id
    on app_after_sales_order (app_user_id);

create table app_merchant
(
    merchant_id   bigint auto_increment comment '主键'
        primary key,
    app_user_id   bigint                                 not null comment '关联 app_user.app_user_id',
    sys_user_id   bigint                                 not null comment '关联 sys_user.user_id',
    merchant_name varchar(100)                           not null comment '商家名称',
    contact_name  varchar(30)  default ''                null comment '联系人',
    contact_phone varchar(11)  default ''                null comment '联系电话',
    address       varchar(255) default ''                null comment '商家地址',
    service_scope varchar(255) default ''                null comment '服务范围',
    merchant_desc varchar(500)                           null comment '商家简介',
    city_name     varchar(50)  default '汉中市'          not null comment '所在城市',
    audit_status  char         default '0'               not null comment '审核状态：0待审核 1正常 2禁用',
    create_by     varchar(64)  default ''                null comment '创建者',
    create_time   datetime     default CURRENT_TIMESTAMP null comment '创建时间',
    update_by     varchar(64)  default ''                null comment '更新者',
    update_time   datetime                               null comment '更新时间',
    remark        varchar(500)                           null comment '备注'
)
    comment '商家信息表';

create index idx_app_merchant_audit_status
    on app_merchant (audit_status);

create index idx_app_merchant_city_name
    on app_merchant (city_name);

create index idx_app_merchant_sys_user_id
    on app_merchant (sys_user_id);

create table app_user
(
    app_user_id          bigint auto_increment comment '主键'
        primary key,
    sys_user_id          bigint                                not null comment '关联 sys_user.user_id',
    phone                varchar(11)                           not null comment '手机号',
    nick_name            varchar(30)                           not null comment '昵称',
    role_type            char        default '1'               not null comment '业务角色：0待审核商家 1用户 2商家',
    merchant_id          bigint                                null comment '关联商家 ID',
    status               char        default '0'               not null comment '状态：0正常 1停用',
    last_sms_code        varchar(6)                            null comment '最近一次模拟验证码',
    last_sms_expire_time datetime                              null comment '模拟验证码过期时间',
    create_by            varchar(64) default ''                null comment '创建者',
    create_time          datetime    default CURRENT_TIMESTAMP null comment '创建时间',
    update_by            varchar(64) default ''                null comment '更新者',
    update_time          datetime                              null comment '更新时间',
    remark               varchar(500)                          null comment '备注',
    constraint uk_app_user_phone
        unique (phone),
    constraint uk_app_user_sys_user
        unique (sys_user_id)
)
    comment 'App 用户扩展表';

create index idx_app_user_merchant_id
    on app_user (merchant_id);

create index idx_app_user_role_type
    on app_user (role_type);

create table gen_table
(
    table_id          bigint auto_increment comment '编号'
        primary key,
    table_name        varchar(200) default ''     null comment '表名称',
    table_comment     varchar(500) default ''     null comment '表描述',
    sub_table_name    varchar(64)                 null comment '关联子表的表名',
    sub_table_fk_name varchar(64)                 null comment '子表关联的外键名',
    class_name        varchar(100) default ''     null comment '实体类名称',
    tpl_category      varchar(200) default 'crud' null comment '使用的模板（crud单表操作 tree树表操作）',
    tpl_web_type      varchar(30)  default ''     null comment '前端模板类型（element-ui模版 element-plus模版）',
    package_name      varchar(100)                null comment '生成包路径',
    module_name       varchar(30)                 null comment '生成模块名',
    business_name     varchar(30)                 null comment '生成业务名',
    function_name     varchar(50)                 null comment '生成功能名',
    function_author   varchar(50)                 null comment '生成功能作者',
    gen_type          char         default '0'    null comment '生成代码方式（0zip压缩包 1自定义路径）',
    gen_path          varchar(200) default '/'    null comment '生成路径（不填默认项目路径）',
    options           varchar(1000)               null comment '其它生成选项',
    create_by         varchar(64)  default ''     null comment '创建者',
    create_time       datetime                    null comment '创建时间',
    update_by         varchar(64)  default ''     null comment '更新者',
    update_time       datetime                    null comment '更新时间',
    remark            varchar(500)                null comment '备注'
)
    comment '代码生成业务表';

create table gen_table_column
(
    column_id      bigint auto_increment comment '编号'
        primary key,
    table_id       bigint                    null comment '归属表编号',
    column_name    varchar(200)              null comment '列名称',
    column_comment varchar(500)              null comment '列描述',
    column_type    varchar(100)              null comment '列类型',
    java_type      varchar(500)              null comment 'JAVA类型',
    java_field     varchar(200)              null comment 'JAVA字段名',
    is_pk          char                      null comment '是否主键（1是）',
    is_increment   char                      null comment '是否自增（1是）',
    is_required    char                      null comment '是否必填（1是）',
    is_insert      char                      null comment '是否为插入字段（1是）',
    is_edit        char                      null comment '是否编辑字段（1是）',
    is_list        char                      null comment '是否列表字段（1是）',
    is_query       char                      null comment '是否查询字段（1是）',
    query_type     varchar(200) default 'EQ' null comment '查询方式（等于、不等于、大于、小于、范围）',
    html_type      varchar(200)              null comment '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
    dict_type      varchar(200) default ''   null comment '字典类型',
    sort           int                       null comment '排序',
    create_by      varchar(64)  default ''   null comment '创建者',
    create_time    datetime                  null comment '创建时间',
    update_by      varchar(64)  default ''   null comment '更新者',
    update_time    datetime                  null comment '更新时间'
)
    comment '代码生成业务表字段';

create table sys_config
(
    config_id    int auto_increment comment '参数主键'
        primary key,
    config_name  varchar(100) default ''  null comment '参数名称',
    config_key   varchar(100) default ''  null comment '参数键名',
    config_value varchar(500) default ''  null comment '参数键值',
    config_type  char         default 'N' null comment '系统内置（Y是 N否）',
    create_by    varchar(64)  default ''  null comment '创建者',
    create_time  datetime                 null comment '创建时间',
    update_by    varchar(64)  default ''  null comment '更新者',
    update_time  datetime                 null comment '更新时间',
    remark       varchar(500)             null comment '备注'
)
    comment '参数配置表';

create table sys_dept
(
    dept_id     bigint auto_increment comment '部门id'
        primary key,
    parent_id   bigint      default 0   null comment '父部门id',
    ancestors   varchar(50) default ''  null comment '祖级列表',
    dept_name   varchar(30) default ''  null comment '部门名称',
    order_num   int         default 0   null comment '显示顺序',
    leader      varchar(20)             null comment '负责人',
    phone       varchar(11)             null comment '联系电话',
    email       varchar(50)             null comment '邮箱',
    status      char        default '0' null comment '部门状态（0正常 1停用）',
    del_flag    char        default '0' null comment '删除标志（0代表存在 2代表删除）',
    create_by   varchar(64) default ''  null comment '创建者',
    create_time datetime                null comment '创建时间',
    update_by   varchar(64) default ''  null comment '更新者',
    update_time datetime                null comment '更新时间'
)
    comment '部门表';

create table sys_dict_data
(
    dict_code   bigint auto_increment comment '字典编码'
        primary key,
    dict_sort   int          default 0   null comment '字典排序',
    dict_label  varchar(100) default ''  null comment '字典标签',
    dict_value  varchar(100) default ''  null comment '字典键值',
    dict_type   varchar(100) default ''  null comment '字典类型',
    css_class   varchar(100)             null comment '样式属性（其他样式扩展）',
    list_class  varchar(100)             null comment '表格回显样式',
    is_default  char         default 'N' null comment '是否默认（Y是 N否）',
    status      char         default '0' null comment '状态（0正常 1停用）',
    create_by   varchar(64)  default ''  null comment '创建者',
    create_time datetime                 null comment '创建时间',
    update_by   varchar(64)  default ''  null comment '更新者',
    update_time datetime                 null comment '更新时间',
    remark      varchar(500)             null comment '备注'
)
    comment '字典数据表';

create table sys_dict_type
(
    dict_id     bigint auto_increment comment '字典主键'
        primary key,
    dict_name   varchar(100) default ''  null comment '字典名称',
    dict_type   varchar(100) default ''  null comment '字典类型',
    status      char         default '0' null comment '状态（0正常 1停用）',
    create_by   varchar(64)  default ''  null comment '创建者',
    create_time datetime                 null comment '创建时间',
    update_by   varchar(64)  default ''  null comment '更新者',
    update_time datetime                 null comment '更新时间',
    remark      varchar(500)             null comment '备注',
    constraint dict_type
        unique (dict_type)
)
    comment '字典类型表';

create table sys_job
(
    job_id          bigint auto_increment comment '任务ID',
    job_name        varchar(64)  default ''        not null comment '任务名称',
    job_group       varchar(64)  default 'DEFAULT' not null comment '任务组名',
    invoke_target   varchar(500)                   not null comment '调用目标字符串',
    cron_expression varchar(255) default ''        null comment 'cron执行表达式',
    misfire_policy  varchar(20)  default '3'       null comment '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
    concurrent      char         default '1'       null comment '是否并发执行（0允许 1禁止）',
    status          char         default '0'       null comment '状态（0正常 1暂停）',
    create_by       varchar(64)  default ''        null comment '创建者',
    create_time     datetime                       null comment '创建时间',
    update_by       varchar(64)  default ''        null comment '更新者',
    update_time     datetime                       null comment '更新时间',
    remark          varchar(500) default ''        null comment '备注信息',
    primary key (job_id, job_name, job_group)
)
    comment '定时任务调度表';

create table sys_job_log
(
    job_log_id     bigint auto_increment comment '任务日志ID'
        primary key,
    job_name       varchar(64)               not null comment '任务名称',
    job_group      varchar(64)               not null comment '任务组名',
    invoke_target  varchar(500)              not null comment '调用目标字符串',
    job_message    varchar(500)              null comment '日志信息',
    status         char          default '0' null comment '执行状态（0正常 1失败）',
    exception_info varchar(2000) default ''  null comment '异常信息',
    create_time    datetime                  null comment '创建时间'
)
    comment '定时任务调度日志表';

create table sys_logininfor
(
    info_id        bigint auto_increment comment '访问ID'
        primary key,
    user_name      varchar(50)  default ''  null comment '用户账号',
    ipaddr         varchar(128) default ''  null comment '登录IP地址',
    login_location varchar(255) default ''  null comment '登录地点',
    browser        varchar(50)  default ''  null comment '浏览器类型',
    os             varchar(50)  default ''  null comment '操作系统',
    status         char         default '0' null comment '登录状态（0成功 1失败）',
    msg            varchar(255) default ''  null comment '提示消息',
    login_time     datetime                 null comment '访问时间'
)
    comment '系统访问记录';

create index idx_sys_logininfor_lt
    on sys_logininfor (login_time);

create index idx_sys_logininfor_s
    on sys_logininfor (status);

create table sys_menu
(
    menu_id     bigint auto_increment comment '菜单ID'
        primary key,
    menu_name   varchar(50)              not null comment '菜单名称',
    parent_id   bigint       default 0   null comment '父菜单ID',
    order_num   int          default 0   null comment '显示顺序',
    path        varchar(200) default ''  null comment '路由地址',
    component   varchar(255)             null comment '组件路径',
    query       varchar(255)             null comment '路由参数',
    route_name  varchar(50)  default ''  null comment '路由名称',
    is_frame    int          default 1   null comment '是否为外链（0是 1否）',
    is_cache    int          default 0   null comment '是否缓存（0缓存 1不缓存）',
    menu_type   char         default ''  null comment '菜单类型（M目录 C菜单 F按钮）',
    visible     char         default '0' null comment '菜单状态（0显示 1隐藏）',
    status      char         default '0' null comment '菜单状态（0正常 1停用）',
    perms       varchar(100)             null comment '权限标识',
    icon        varchar(100) default '#' null comment '菜单图标',
    create_by   varchar(64)  default ''  null comment '创建者',
    create_time datetime                 null comment '创建时间',
    update_by   varchar(64)  default ''  null comment '更新者',
    update_time datetime                 null comment '更新时间',
    remark      varchar(500) default ''  null comment '备注'
)
    comment '菜单权限表';

create table sys_notice
(
    notice_id      int auto_increment comment '公告ID'
        primary key,
    notice_title   varchar(50)             not null comment '公告标题',
    notice_type    char                    not null comment '公告类型（1通知 2公告）',
    notice_content longblob                null comment '公告内容',
    status         char        default '0' null comment '公告状态（0正常 1关闭）',
    create_by      varchar(64) default ''  null comment '创建者',
    create_time    datetime                null comment '创建时间',
    update_by      varchar(64) default ''  null comment '更新者',
    update_time    datetime                null comment '更新时间',
    remark         varchar(255)            null comment '备注'
)
    comment '通知公告表';

create table sys_oper_log
(
    oper_id        bigint auto_increment comment '日志主键'
        primary key,
    title          varchar(50)   default '' null comment '模块标题',
    business_type  int           default 0  null comment '业务类型（0其它 1新增 2修改 3删除）',
    method         varchar(200)  default '' null comment '方法名称',
    request_method varchar(10)   default '' null comment '请求方式',
    operator_type  int           default 0  null comment '操作类别（0其它 1后台用户 2手机端用户）',
    oper_name      varchar(50)   default '' null comment '操作人员',
    dept_name      varchar(50)   default '' null comment '部门名称',
    oper_url       varchar(255)  default '' null comment '请求URL',
    oper_ip        varchar(128)  default '' null comment '主机地址',
    oper_location  varchar(255)  default '' null comment '操作地点',
    oper_param     varchar(2000) default '' null comment '请求参数',
    json_result    varchar(2000) default '' null comment '返回参数',
    status         int           default 0  null comment '操作状态（0正常 1异常）',
    error_msg      varchar(2000) default '' null comment '错误消息',
    oper_time      datetime                 null comment '操作时间',
    cost_time      bigint        default 0  null comment '消耗时间'
)
    comment '操作日志记录';

create index idx_sys_oper_log_bt
    on sys_oper_log (business_type);

create index idx_sys_oper_log_ot
    on sys_oper_log (oper_time);

create index idx_sys_oper_log_s
    on sys_oper_log (status);

create table sys_post
(
    post_id     bigint auto_increment comment '岗位ID'
        primary key,
    post_code   varchar(64)            not null comment '岗位编码',
    post_name   varchar(50)            not null comment '岗位名称',
    post_sort   int                    not null comment '显示顺序',
    status      char                   not null comment '状态（0正常 1停用）',
    create_by   varchar(64) default '' null comment '创建者',
    create_time datetime               null comment '创建时间',
    update_by   varchar(64) default '' null comment '更新者',
    update_time datetime               null comment '更新时间',
    remark      varchar(500)           null comment '备注'
)
    comment '岗位信息表';

create table sys_role
(
    role_id             bigint auto_increment comment '角色ID'
        primary key,
    role_name           varchar(30)             not null comment '角色名称',
    role_key            varchar(100)            not null comment '角色权限字符串',
    role_sort           int                     not null comment '显示顺序',
    data_scope          char        default '1' null comment '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
    menu_check_strictly tinyint(1)  default 1   null comment '菜单树选择项是否关联显示',
    dept_check_strictly tinyint(1)  default 1   null comment '部门树选择项是否关联显示',
    status              char                    not null comment '角色状态（0正常 1停用）',
    del_flag            char        default '0' null comment '删除标志（0代表存在 2代表删除）',
    create_by           varchar(64) default ''  null comment '创建者',
    create_time         datetime                null comment '创建时间',
    update_by           varchar(64) default ''  null comment '更新者',
    update_time         datetime                null comment '更新时间',
    remark              varchar(500)            null comment '备注'
)
    comment '角色信息表';

create table sys_role_dept
(
    role_id bigint not null comment '角色ID',
    dept_id bigint not null comment '部门ID',
    primary key (role_id, dept_id)
)
    comment '角色和部门关联表';

create table sys_role_menu
(
    role_id bigint not null comment '角色ID',
    menu_id bigint not null comment '菜单ID',
    primary key (role_id, menu_id)
)
    comment '角色和菜单关联表';

create table sys_user
(
    user_id         bigint auto_increment comment '用户ID'
        primary key,
    dept_id         bigint                    null comment '部门ID',
    user_name       varchar(30)               not null comment '用户账号',
    nick_name       varchar(30)               not null comment '用户昵称',
    user_type       varchar(2)   default '00' null comment '用户类型（00系统用户）',
    email           varchar(50)  default ''   null comment '用户邮箱',
    phonenumber     varchar(11)  default ''   null comment '手机号码',
    sex             char         default '0'  null comment '用户性别（0男 1女 2未知）',
    avatar          varchar(100) default ''   null comment '头像地址',
    password        varchar(100) default ''   null comment '密码',
    status          char         default '0'  null comment '账号状态（0正常 1停用）',
    del_flag        char         default '0'  null comment '删除标志（0代表存在 2代表删除）',
    login_ip        varchar(128) default ''   null comment '最后登录IP',
    login_date      datetime                  null comment '最后登录时间',
    pwd_update_date datetime                  null comment '密码最后更新时间',
    create_by       varchar(64)  default ''   null comment '创建者',
    create_time     datetime                  null comment '创建时间',
    update_by       varchar(64)  default ''   null comment '更新者',
    update_time     datetime                  null comment '更新时间',
    remark          varchar(500)              null comment '备注'
)
    comment '用户信息表';

create table sys_user_post
(
    user_id bigint not null comment '用户ID',
    post_id bigint not null comment '岗位ID',
    primary key (user_id, post_id)
)
    comment '用户与岗位关联表';

create table sys_user_role
(
    user_id bigint not null comment '用户ID',
    role_id bigint not null comment '角色ID',
    primary key (user_id, role_id)
)
    comment '用户和角色关联表';

INSERT INTO sys_dept (dept_id, parent_id, ancestors, dept_name, order_num, leader, phone, email, status, del_flag, create_by, create_time, update_by, update_time)
VALUES
(100, 0, '0', '若依科技', 0, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', NOW(), NULL, NULL),
(101, 100, '0,100', '深圳总公司', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', NOW(), NULL, NULL),
(102, 100, '0,100', '长沙分公司', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', NOW(), NULL, NULL),
(103, 101, '0,100,101', '研发部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', NOW(), NULL, NULL),
(104, 101, '0,100,101', '市场部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', NOW(), NULL, NULL),
(105, 101, '0,100,101', '测试部门', 3, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', NOW(), NULL, NULL),
(106, 101, '0,100,101', '财务部门', 4, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', NOW(), NULL, NULL),
(107, 101, '0,100,101', '运维部门', 5, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', NOW(), NULL, NULL),
(108, 102, '0,100,102', '市场部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', NOW(), NULL, NULL),
(109, 102, '0,100,102', '财务部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', NOW(), NULL, NULL);

INSERT INTO sys_role (role_id, role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, update_by, update_time, remark)
VALUES
(1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', NOW(), NULL, NULL, '超级管理员'),
(200, '售后普通用户', 'user', 3, '1', 1, 1, '0', '0', 'admin', NOW(), NULL, NULL, '汉中市电子产品售后系统-普通用户'),
(201, '售后商家', 'merchant', 4, '1', 1, 1, '0', '0', 'admin', NOW(), 'admin', NOW(), '汉中市电子产品售后系统-商家');

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES
(2000, '售后业务', 0, 8, 'app', NULL, '', '', 1, 0, 'M', '0', '0', '', 'guide', 'admin', NOW(), NULL, NULL, '汉中市电子产品售后业务根菜单'),
(2010, '商家管理', 2000, 1, 'merchant', 'app/merchant/index', '', '', 1, 0, 'C', '0', '0', 'app:merchant:list', 'peoples', 'admin', NOW(), NULL, NULL, '商家管理'),
(2011, '商家查询', 2010, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:merchant:query', '#', 'admin', NOW(), NULL, NULL, '商家查询按钮'),
(2012, '商家编辑', 2010, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:merchant:edit', '#', 'admin', NOW(), NULL, NULL, '商家编辑按钮'),
(2013, '商家审核', 2010, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:merchant:audit', '#', 'admin', NOW(), NULL, NULL, '商家审核按钮'),
(2020, '售后订单管理', 2000, 2, 'afterSalesOrder', 'app/afterSalesOrder/index', '', '', 1, 0, 'C', '0', '0', 'app:afterSalesOrder:list', 'example', 'admin', NOW(), NULL, NULL, '售后订单管理'),
(2021, '订单查询', 2020, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:afterSalesOrder:query', '#', 'admin', NOW(), NULL, NULL, '订单查询按钮'),
(2022, '订单编辑', 2020, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:afterSalesOrder:edit', '#', 'admin', NOW(), NULL, NULL, '订单编辑按钮'),
(2030, '配件管理', 2000, 3, 'accessory', 'app/accessory/index', '', '', 1, 0, 'C', '0', '0', 'app:accessory:list', 'shopping', 'admin', NOW(), NULL, NULL, '配件管理'),
(2031, '配件查询', 2030, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:accessory:query', '#', 'admin', NOW(), NULL, NULL, '配件查询按钮'),
(2032, '配件新增', 2030, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:accessory:add', '#', 'admin', NOW(), NULL, NULL, '配件新增按钮'),
(2033, '配件编辑', 2030, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:accessory:edit', '#', 'admin', NOW(), NULL, NULL, '配件编辑按钮'),
(2034, '配件删除', 2030, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:accessory:remove', '#', 'admin', NOW(), NULL, NULL, '配件删除按钮'),
(2040, '配件订单管理', 2000, 4, 'accessoryOrder', 'app/accessoryOrder/index', '', '', 1, 0, 'C', '0', '0', 'app:accessoryOrder:list', 'order', 'admin', NOW(), NULL, NULL, '配件订单管理'),
(2041, '配件订单查询', 2040, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'app:accessoryOrder:query', '#', 'admin', NOW(), NULL, NULL, '配件订单查询按钮');

INSERT INTO sys_role_menu (role_id, menu_id)
VALUES
(1, 2000), (1, 2010), (1, 2011), (1, 2012), (1, 2013), (1, 2020), (1, 2021), (1, 2022), (1, 2030), (1, 2031), (1, 2032), (1, 2033), (1, 2034), (1, 2040), (1, 2041),
(201, 2000), (201, 2020), (201, 2021), (201, 2022), (201, 2030), (201, 2031), (201, 2032), (201, 2033), (201, 2034), (201, 2040), (201, 2041);

INSERT INTO sys_user (user_id, dept_id, user_name, nick_name, user_type, email, phonenumber, sex, avatar, password, status, del_flag, login_ip, login_date, pwd_update_date, create_by, create_time, update_by, update_time, remark)
VALUES
(1, 103, 'admin', '若依', '00', 'ry@163.com', '15888888888', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', NOW(), NOW(), 'admin', NOW(), NULL, NULL, '管理员'),
(2000, 100, '18291107686', '测试普通用户', '00', 'user@hanzhong.local', '18291107686', '0', '', '$2a$10$5s2BL3EwQIu4f97u38aFe.VAXaiZwc8titAWJkQx3WFbDs7VnceVa', '0', '0', '127.0.0.1', NOW(), NOW(), 'admin', NOW(), NULL, NULL, '汉中市售后系统测试普通用户'),
(2001, 100, '18291107689', '测试商家账号', '00', 'merchant@hanzhong.local', '18291107689', '0', '', '$2a$10$5s2BL3EwQIu4f97u38aFe.VAXaiZwc8titAWJkQx3WFbDs7VnceVa', '0', '0', '127.0.0.1', NOW(), NOW(), 'admin', NOW(), NULL, NULL, '汉中市售后系统测试商家');

INSERT INTO sys_user_role (user_id, role_id)
VALUES
(1, 1),
(2000, 200),
(2001, 200),
(2001, 201);

INSERT INTO app_user (app_user_id, sys_user_id, phone, nick_name, role_type, merchant_id, status, last_sms_code, last_sms_expire_time, create_by, create_time, update_by, update_time, remark)
VALUES
(1, 2000, '18291107686', '测试普通用户', '1', NULL, '0', NULL, NULL, 'admin', NOW(), NULL, NULL, '普通测试用户'),
(2, 2001, '18291107689', '测试商家账号', '2', 1, '0', NULL, NULL, 'admin', NOW(), 'admin', NOW(), '已审核通过测试商家');

INSERT INTO app_merchant (merchant_id, app_user_id, sys_user_id, merchant_name, contact_name, contact_phone, address, service_scope, merchant_desc, city_name, audit_status, create_by, create_time, update_by, update_time, remark)
VALUES
(1, 2, 2001, '汉中诚信数码维修中心', '张师傅', '18291107689', '陕西省汉中市汉台区前进路 88 号', '手机、平板、笔记本、数码配件', '主营手机换屏、换电池、主板检测与数码产品售后。', '汉中市', '1', 'admin', NOW(), 'admin', NOW(), '已审核商家');

INSERT INTO app_accessory (accessory_id, merchant_id, category_name, accessory_name, accessory_desc, cover_image, price, stock, sales_count, status, create_by, create_time, remark)
VALUES
(1, 1, '手机配件', '电源适配器', '多口快充电源适配器，兼容手机、平板、笔记本设备，支持门店安装。', '/static/images/accessory/adapter.png', 69.00, 80, 1, '0', '18291107689', NOW(), '商品路径.docx导入'),
(2, 1, '手机配件', '手机显示屏', '高清原装手机屏幕，碎屏、花屏、漏液维修更换，支持到店安装。', '/static/images/accessory/phone_screen.png', 399.00, 30, 2, '0', '18291107689', NOW(), '商品路径.docx导入'),
(3, 1, '手机配件', '手机电池', '适配主流安卓机型的高容量电池，续航持久，支持门店安装。', '/static/images/accessory/battery.png', 129.00, 50, 3, '0', '18291107689', NOW(), '商品路径.docx导入'),
(4, 1, '手机配件', '尾插排线', '手机充电接口总成，解决接触不良、无法充电、不快充问题。', '/static/images/accessory/charging_port.png', 89.00, 60, 4, '0', '18291107689', NOW(), '商品路径.docx导入'),
(5, 1, '手机配件', '手机扬声器', '手机外放喇叭，修复无声、破音、杂音、音量小故障。', '/static/images/accessory/speaker.png', 79.00, 65, 5, '0', '18291107689', NOW(), '商品路径.docx导入'),
(6, 1, '电脑配件', '笔记本电池', '笔记本原装规格电池，解决鼓包、不存电、续航短问题。', '/static/images/accessory/laptop_battery.png', 299.00, 20, 6, '0', '18291107689', NOW(), '商品路径.docx导入'),
(7, 1, '电脑配件', '笔记本充电器', '大功率笔记本电源适配器，适配主流品牌电脑，充电稳定。', '/static/images/accessory/laptop_adapter.png', 169.00, 30, 7, '0', '18291107689', NOW(), '商品路径.docx导入'),
(8, 1, '电脑配件', '笔记本屏幕', '笔记本高清液晶显示屏，碎屏、暗屏、花屏专业更换。', '/static/images/accessory/laptop_screen.png', 499.00, 15, 8, '0', '18291107689', NOW(), '商品路径.docx导入'),
(9, 1, '电脑配件', '固态硬盘SSD', '高速固态硬盘，电脑升级提速，支持系统迁移安装。', '/static/images/accessory/ssd.png', 299.00, 25, 9, '0', '18291107689', NOW(), '商品路径.docx导入'),
(10, 1, '平板配件', '平板屏幕', '平板电脑高清屏幕总成，碎屏、触摸失灵维修。', '/static/images/accessory/tablet_screen.png', 359.00, 20, 10, '0', '18291107689', NOW(), '商品路径.docx导入'),
(11, 1, '平板配件', '平板电池', '平板大容量原装电池，解决耗电快、不充电、自动关机。', '/static/images/accessory/tablet_battery.png', 199.00, 25, 11, '0', '18291107689', NOW(), '商品路径.docx导入'),
(12, 1, '通用配件', 'Type-C数据线', '编织快充数据线，支持65W快充，兼容安卓、苹果、平板设备。', '/static/images/accessory/typec_cable.png', 39.00, 150, 12, '0', '18291107689', NOW(), '商品路径.docx导入'),
(13, 1, '通用配件', '无线充电器', '桌面无线快充底座，支持主流手机无线充电。', '/static/images/accessory/wireless_charger.png', 99.00, 45, 13, '0', '18291107689', NOW(), '商品路径.docx导入'),
(14, 1, '保护配件', '钢化膜', '高清防爆钢化膜，防指纹、防摔、防刮花。', '/static/images/accessory/glass.png', 29.00, 200, 14, '0', '18291107689', NOW(), '商品路径.docx导入'),
(15, 1, '保护配件', '手机壳', '全包防摔手机保护壳，软边硬背，有效防护机身。', '/static/images/accessory/case.png', 49.00, 120, 15, '0', '18291107689', NOW(), '商品路径.docx导入'),
(16, 1, '音频配件', '有线耳机', '半入耳式线控耳机，通话清晰，音质稳定。', '/static/images/accessory/earphone.png', 79.00, 80, 16, '0', '18291107689', NOW(), '商品路径.docx导入');

INSERT INTO app_after_sales_order (order_id, order_no, app_user_id, merchant_id, product_type, fault_desc, fault_images, status, service_remark, contact_name, contact_phone, address, accept_time, finish_time, create_by, create_time, update_by, update_time, remark)
VALUES
(1, 'AS202603270001', 1, NULL, '手机屏幕', '屏幕碎裂，先保留一条初始化售后单用于联调。', NULL, '0', NULL, '测试普通用户', '18291107686', '陕西省汉中市汉台区中山街 18 号', NULL, NULL, '18291107686', NOW(), NULL, NULL, '初始化测试售后单');

INSERT INTO app_accessory_order (accessory_order_id, order_no, accessory_id, app_user_id, merchant_id, quantity, price, total_amount, status, receiver_name, receiver_phone, receiver_address, order_remark, create_by, create_time, update_by, update_time, remark)
VALUES
(1, 'AO202603270001', 1, 1, 1, 1, 69.00, 69.00, '0', '测试普通用户', '18291107686', '陕西省汉中市汉台区中山街 18 号', '初始化测试配件订单', '18291107686', NOW(), NULL, NULL, '初始化测试配件订单');

INSERT INTO app_accessory_collection (collection_id, app_user_id, accessory_id, create_by, create_time, update_by, update_time, remark)
VALUES
(1, 1, 2, '18291107686', NOW(), NULL, NULL, '初始化测试收藏');
