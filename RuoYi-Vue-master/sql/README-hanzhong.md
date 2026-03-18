# 汉中市电子产品售后服务系统落地说明

## 1. 数据准备
- 执行 `sql/hanzhong_after_sales.sql` 初始化业务表、角色、菜单和测试数据。
- 业务表包括：`app_user`、`app_merchant`、`app_after_sales_order`、`app_accessory`、`app_accessory_order`、`app_accessory_collection`。
- 初始化账号：
  - 管理员：复用若依默认 `admin`
  - 测试用户：`user1 / 123456`
  - 测试商家：`merchant1 / 123456`（默认待审核）

## 2. 后端配置
- 数据源：编辑 `ruoyi-admin/src/main/resources/application-druid.yml`，将数据库地址、用户名、密码替换为本地开发环境配置。
- 上传目录：编辑 `ruoyi-admin/src/main/resources/application.yml` 中的 `ruoyi.profile`，改为实际可写目录，禁止提交生产路径。
- Token 密钥：`application.yml` 中 `token.secret` 仅用于本地示例，部署前请改为环境变量或私有配置。
- 公共接口：`/app/common/**` 已开放匿名访问，用于商家简介与配件商城查询；管理端接口仍依赖角色权限和菜单权限。

## 3. 启动命令
- 后端开发启动：`cd RuoYi-Vue-master/RuoYi-Vue-master && mvn -pl ruoyi-admin -am spring-boot:run`
- 后端打包：`cd RuoYi-Vue-master/RuoYi-Vue-master && mvn clean package`
- Web 开发：`cd ruoyi-ui && npm install && npm run dev`
- Web 生产构建：`cd ruoyi-ui && npm run build:prod`
- uni-app 调试：使用 HBuilderX 导入 `RuoYi-App-master/`，按目标平台运行 H5 或微信小程序。

## 4. 权限与业务流
- App 注册登录复用若依 `sys_user + sys_role + JWT`，密码统一使用 BCrypt。
- 普通用户注册后写入 `user` 角色；商家注册后先写入普通用户角色，待管理员审核通过后切换为 `merchant`。
- 售后订单状态流转：`待接单 -> 已接单 -> 维修中 -> 已完成`，任一处理中节点允许取消。
- 配件下单在事务中同时完成订单创建、库存扣减、销量累加。

## 5. 移动端适配注意事项
- `RuoYi-App-master/config.js` 中 `baseUrl` 默认指向 `http://localhost:8080`，联调时按本机地址修改。
- 图片上传统一走 `uni.chooseImage + uni.uploadFile`，后端复用若依文件上传接口。
- 登录成功后需缓存 `token`、`role`、`userInfo`；首页和工作台按 `role` 渲染不同入口。
- 微信小程序与 H5 共用页面结构，底部导航采用统一 tabbar 骨架，避免运行时动态 tabbar 限制。

## 6. 建议验收顺序
- 用户注册登录 -> 提交售后申请 -> 查看我的订单。
- 管理员审核商家 -> 商家接单 -> 更新维修状态。
- 用户浏览配件商城 -> 收藏 -> 下单 -> 管理端查看配件订单。
