# 汉中电子售后 Web 前端

这是项目的网页前端，基于 `Vue 3 + Vite + Vue Router`，承担普通用户商城、购物车、地址管理、售后申请，以及商家工作台等页面。

## 目录说明

- `src/views/`：页面级视图
- `src/components/`：通用组件
- `src/lib/`：接口、会话、本地存储和业务工具
- `public/`：公开静态资源
- `dist/`：构建产物，不提交

## 开发命令

安装依赖：

```powershell
cd E:\Backstage-Management-System\Hanzhong-Elec-AfterSale-Web
npm install
```

启动开发环境：

```powershell
npm run dev
```

生产构建：

```powershell
npm run build
```

## 后端接口

默认通过 `VITE_API_BASE_URL` 或内置兜底地址访问后端。

联调当前桌面版时，后端地址通常为：

```text
http://127.0.0.1:18080
```

## 与后端的关系

- Web 前端源码以本目录为准
- 构建后的静态文件会被同步到后端 `ruoyi-admin` 的静态资源目录
- 远程仓库不保留 `dist/`，需要时通过 `npm run build` 重新生成

## 当前约定

- 购物车、地址簿等前端本地数据按登录用户隔离存储
- 普通用户与商家用户共用同一套后端接口体系
- H2 桌面版与源码开发环境保持兼容
