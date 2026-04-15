# 汉中电子售后小程序

这是当前项目的 Uni-app 小程序端，面向普通用户与商家用户，复用同一套后端接口。

## 目录说明

- `pages/`：页面入口
- `components/`：通用组件
- `api/`：接口封装
- `store/`：状态管理
- `static/`：静态资源
- `utils/`：工具方法
- `config.js`：后端地址配置
- `unpackage/`：构建产物，不提交、不手改

## 本地开发

推荐使用 `HBuilderX` 打开 `Hanzhong-Elec-AfterSale-Mini` 目录运行。

如果联调当前桌面版后端，请检查 [config.js](/e:/Backstage-Management-System/Hanzhong-Elec-AfterSale-Mini/config.js) 中的 `baseUrl`，当前默认值为：

```js
http://localhost:18080
```

如果是同机联调，这个地址可以直接使用。

## 常见联调场景

连接本机桌面版后端：

```text
http://127.0.0.1:18080
```

连接局域网内另一台电脑：

```text
http://目标电脑IP:18080
```

如果小程序端无法访问接口，请优先检查：

- 桌面版是否已经双击 `start-app.bat` 启动
- `config.js` 中的 `baseUrl` 是否指向正确地址
- 微信开发者工具或真机调试是否允许访问该域名/IP

## 提交约定

- 只提交源码和必要配置
- 不提交 `unpackage/`
- 不提交个人私有调试配置

## 说明

这个目录保留的是项目当前实际业务代码，不再使用若依原始模板说明。
