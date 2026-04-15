# 汉中电子售后后端

这是项目的 Spring Boot 后端，基于若依 `RuoYi-Vue 3.9.0` 改造，承载后台管理、App 接口、桌面版运行入口，以及 H2 / MySQL 两套运行模式。

## 模块说明

- `ruoyi-admin/`：启动入口与控制器
- `ruoyi-framework/`：安全、资源映射、配置扩展
- `ruoyi-system/`：业务域、Mapper、服务实现
- `ruoyi-common/`：通用工具与基础能力
- `ruoyi-quartz/`：定时任务模块
- `ruoyi-generator/`：代码生成模块
- `sql/`：数据库初始化脚本

## 开发命令

启动后端：

```powershell
cd E:\Backstage-Management-System\RuoYi-Vue-master
mvn -pl ruoyi-admin -am spring-boot:run
```

打包后端：

```powershell
mvn clean package
```

执行测试：

```powershell
mvn test
```

## 运行模式

源码开发常用：

- 默认 Spring Boot 开发模式

桌面版常用：

- `standalone`：内嵌 H2 持久化数据库
- `standalone-mysql`：绿色 MySQL 备用模式

相关配置位于：

- `ruoyi-admin/src/main/resources/application-standalone.yml`
- `ruoyi-admin/src/main/resources/application-standalone-mysql.yml`

## 说明

- Web 打包产物会同步到 `ruoyi-admin/src/main/resources/static/`
- 远程仓库不保留 `target/` 等构建结果
- Windows 桌面绿色运行包见工作区 `desktop-package/`
