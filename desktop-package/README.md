# 汉中售后桌面版打包说明

`desktop-package/` 只保留桌面版打包脚本、模板和说明文档，不再把运行产物提交到仓库。

## 当前策略

仓库保留：

- `build-standalone.ps1`
- `build-single-exe.ps1`
- `templates/`
- `mysql-template/`
- 本说明文档

仓库忽略：

- `desktop-package/dist/` 下的所有内容

也就是说：

- 源码进 Git
- 桌面运行包不进 Git
- 最终发版通过 `Release` 附件、压缩包或私有制品库分发

## 本地打包

在工作区根目录执行：

```powershell
cd E:\Backstage-Management-System
.\desktop-package\build-standalone.ps1
```

输出目录：

```text
E:\Backstage-Management-System\desktop-package\dist\Hanzhong-AfterSale-Desktop
```

如果需要生成单文件发版包，再执行：

```powershell
.\desktop-package\build-single-exe.ps1
```

## 推荐发版方式

推荐把以下内容作为 Release 附件上传，而不是提交到仓库：

1. `Hanzhong-AfterSale-Desktop.zip`
2. `Hanzhong-AfterSale-Desktop-SFX.exe`

推荐流程：

1. 在本地执行 `build-standalone.ps1`
2. 手工验证桌面版可启动、可登录、核心流程可用
3. 压缩 `dist/Hanzhong-AfterSale-Desktop`
4. 上传压缩包或单文件 EXE 到 Release

## 为什么这样做

这样做有几个直接好处：

- 仓库体积更小
- 提交历史不会被大体积 JRE 和 Jar 污染
- 代码审查更聚焦源码变化
- 运行包与源码可以分开管理版本

## 目录作用

- `templates/`：桌面版启动与停止脚本模板
- `mysql-template/`：绿色 MySQL 备用模板
- `build-standalone.ps1`：生成绿色目录版
- `build-single-exe.ps1`：生成单文件发版包

## 提交约定

提交前请确认：

- 不要把 `desktop-package/dist/` 中的运行产物加入版本库
- 如需发版，请把构建结果挂到 Release，而不是直接 `git add`
