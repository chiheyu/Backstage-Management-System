# Repository Guidelines

## 项目结构与模块组织
此目录是一个工作区，不是单一应用仓库。后端主工程位于 `RuoYi-Vue-master/RuoYi-Vue-master/`，采用多模块 Maven 结构：`ruoyi-admin` 为启动入口，`ruoyi-framework` 负责安全与配置，`ruoyi-system` 承载业务与 MyBatis，`ruoyi-common` 放通用能力，`ruoyi-quartz` 和 `ruoyi-generator` 分别处理定时任务与代码生成。独立 Web 前端在 `ruoyi-ui/`，核心代码位于 `src/`、静态资源在 `public/`。移动端位于 `RuoYi-App-master/`，主要目录为 `pages/`、`components/`、`api/`、`static/`；`unpackage/` 为构建产物，不要手改。

## 构建、测试与开发命令
- 后端启动：`cd RuoYi-Vue-master/RuoYi-Vue-master && mvn -pl ruoyi-admin -am spring-boot:run`
- 后端打包：`cd RuoYi-Vue-master/RuoYi-Vue-master && mvn clean package`
- 后端测试：`cd RuoYi-Vue-master/RuoYi-Vue-master && mvn test`
- Web 前端开发：`cd ruoyi-ui && npm install && npm run dev`
- Web 前端构建：`cd ruoyi-ui && npm run build:prod`
- 移动端调试：在 `RuoYi-App-master/` 中使用 HBuilderX 或 uni-app 工具链运行 H5 / App 预览

## 编码风格与命名约定
Java 代码保持 4 空格缩进，遵循现有 Spring Boot + MyBatis 风格：类名使用 `PascalCase`，方法和字段使用 `camelCase`，包名保持 `com.ruoyi.*` 小写；控制器、服务、实现类分别以 `Controller`、`Service`、`ServiceImpl` 结尾。`ruoyi-ui/.editorconfig` 指定前端使用 2 空格缩进、`LF` 换行、UTF-8 编码；Vue 组件文件名优先使用 `PascalCase`，视图按业务放在 `src/views/`。

## 测试指南
当前仓库未见已提交的前端测试或后端测试目录。修改后端逻辑时，优先在对应模块新增 `src/test/java` 下的 `*Test.java`。前端和 UniApp 变更至少提供手工验证步骤，重点覆盖登录、权限、菜单、上传和移动端页面流程。

## 提交与 Pull Request 规范
实际 Git 历史位于 `RuoYi-Vue-master/` 和 `ruoyi-ui/`，现有提交较少，示例为 `初始版本`。后续提交建议使用简短、祈使式主题，必要时加作用域，例如：`system: 修复角色数据权限过滤`。PR 需说明影响的子项目与模块、配置或数据库变更、验证步骤；涉及 Web 或移动端界面时附截图。

## 配置与安全提示
提交前检查 `ruoyi-admin/src/main/resources/application.yml`、`application-druid.yml` 与 `RuoYi-App-master/config.js`。不要提交真实数据库凭据、JWT 密钥、上传路径或环境专用接口地址。
