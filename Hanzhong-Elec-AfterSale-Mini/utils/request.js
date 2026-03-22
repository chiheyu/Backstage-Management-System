// utils/request.js
// 🔥 关键配置：替换为后端服务器的局域网IP（必改！）
// 查看后端IP方法：cmd输入ipconfig → 找到IPv4地址（如192.168.1.100）
const baseUrl = "http://192.168.43.172:8080";

/**
 * 通用请求方法（适配若依后端 + @InnerAuth 权限）
 * @param {String} url 接口路径（如 /auth/login）
 * @param {String} method 请求方式 GET/POST/PUT/DELETE
 * @param {Object} data 请求参数
 * @returns Promise
 */
export const request = (url, method = "GET", data = {}) => {
  // 1. 获取本地Token（uni-app适配正确）
  const token = uni.getStorageSync("token") || "";
  console.log("【请求Token】：", token);

  return new Promise((resolve, reject) => {
    // 2. 发起请求（uni.request适配正确）
    uni.request({
      url: baseUrl + url,
      // 🔥 优化1：method空值容错，避免toUpperCase()报错
      method: (method || "GET").toUpperCase(), 
      data: data,
      header: {
        "Content-Type": "application/json",
        // 🔥 核心适配：@InnerAuth 内部访问权限校验
        "X-Real-IP": "127.0.0.1",
        "X-Forwarded-For": "127.0.0.1",
        "Authorization": token ? `Bearer ${token}` : "",
        // 可选：添加网关标识
        "Gateway-Request": "true"
      },
      // 🔥 优化2：添加请求超时时间，避免无限等待（10秒）
      timeout: 10000,
      // 3. 处理若依后端返回格式（优化逻辑）
      success: (res) => {
        console.log("【接口返回】：", res.data);
        
        // 🔥 优化3：兼容非JSON格式返回（避免后端500返回页面等异常）
        if (typeof res.data !== 'object') {
          uni.showToast({ title: "后端返回格式错误", icon: "none" });
          reject("返回格式非JSON");
          return;
        }
        
        // 若依后端返回格式：{code:200, msg:"", data:{}}
        // 情况1：成功（code=200）
        if (res.data.code === 200) {
          resolve(res.data);
        } 
        // 情况2：Token过期/未登录（若依返回code=401）
        else if (res.data.code === 401) {
          uni.showToast({ title: "登录已过期，请重新登录", icon: "none" });
          // 清除无效Token，跳转到登录页
          uni.removeStorageSync("token");
          uni.removeStorageSync("userInfo");
          uni.navigateTo({ url: "/pages/profile/login" });
          reject("Token无效/过期");
        } 
        // 情况3：无权限（@InnerAuth拦截，code=403）
        else if (res.data.code === 403) {
          uni.showToast({ title: "没有内部访问权限", icon: "none" });
          reject("无内部访问权限");
        }
        // 情况4：其他错误（如参数错误、注册失败等）
        else {
          uni.showToast({ 
            title: res.data.msg || "操作失败", 
            icon: "none",
            duration: 2000 
          });
          reject({
            code: res.data.code,
            msg: res.data.msg
          });
        }
      },
      // 4. 网络错误处理（优化提示文案）
      fail: (err) => {
        let errMsg = "";
        if (err.errMsg.includes("connect fail") || err.errMsg.includes("timeout")) {
          errMsg = `后端服务未启动或IP错误：${baseUrl}`;
        } else if (err.statusCode === 404) {
          errMsg = "接口不存在：" + url;
        } else if (err.statusCode === 500) {
          errMsg = "后端接口报错，请查看控制台";
        } else {
          errMsg = "网络错误：" + err.errMsg;
        }
        
        uni.showToast({ 
          title: errMsg, 
          icon: "none",
          duration: 3000 
        });
        reject(err);
      },
      complete: (res) => {
        console.log("【请求完成】：", res);
      }
    });
  });
};

// 快捷方法（简化前端调用）
export const get = (url, data) => request(url, "GET", data);
export const post = (url, data) => request(url, "POST", data);
export const put = (url, data) => request(url, "PUT", data);
export const del = (url, data) => request(url, "DELETE", data);