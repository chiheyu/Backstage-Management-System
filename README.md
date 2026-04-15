# Backstage-Management-System 工作区说明

这是一个包含后端、Web 前端、小程序端和 Windows 桌面版打包脚本的综合工作区。

## 目录结构

- `RuoYi-Vue-master/`：Spring Boot 后端源码
- `Hanzhong-Elec-AfterSale-Web/`：Vue 3 + Vite Web 前端源码
- `Hanzhong-Elec-AfterSale-Mini/`：Uni-app 小程序源码
- `desktop-package/`：Windows 绿色桌面版打包脚本与说明

## 仓库保留策略

远程仓库按以下原则保留内容：

- 保留全部源代码
- 忽略本地构建产物与运行缓存
- 不提交 `desktop-package/dist/` 中的运行包目录
- 桌面运行包通过 Release 附件或单独发版包分发

桌面运行包本地打包输出路径：

```text
desktop-package/dist/Hanzhong-AfterSale-Desktop
```

## 快速开始

后端开发：

```powershell
cd E:\Backstage-Management-System\RuoYi-Vue-master
mvn -pl ruoyi-admin -am spring-boot:run
```

Web 前端开发：

```powershell
cd E:\Backstage-Management-System\Hanzhong-Elec-AfterSale-Web
npm install
npm run dev
```

桌面版本地打包：

```text
cd E:\Backstage-Management-System
.\desktop-package\build-standalone.ps1
```

## 说明文档

- Web 端说明见 [Hanzhong-Elec-AfterSale-Web/README.md](/e:/Backstage-Management-System/Hanzhong-Elec-AfterSale-Web/README.md)
- 后端说明见 [RuoYi-Vue-master/README.md](/e:/Backstage-Management-System/RuoYi-Vue-master/README.md)
- 小程序说明见 [Hanzhong-Elec-AfterSale-Mini/README.md](/e:/Backstage-Management-System/Hanzhong-Elec-AfterSale-Mini/README.md)
- 桌面打包说明见 [desktop-package/README.md](/e:/Backstage-Management-System/desktop-package/README.md)
