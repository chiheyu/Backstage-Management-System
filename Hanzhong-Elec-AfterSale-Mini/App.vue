<script>
import config from './config'
import store from '@/store'

export default {
  // 生命周期：小程序初始化完成时触发
  onLaunch() {
    console.log('App Launch')
    this.initApp()
  },

  // 小程序显示时触发
  onShow() {
    console.log('App Show')
  },

  // 小程序隐藏时触发
  onHide() {
    console.log('App Hide')
  },

  methods: {
    // 初始化应用
    initApp() {
      // 初始化配置
      this.initConfig()
      // 此处可以根据课程设计需求添加登录检查，暂时保留框架
    },

    // 初始化全局配置
    initConfig() {
      this.globalData.config = config
    }
  },

  // 全局数据
  globalData: {
    config: null
  }
}
</script>

<style lang="scss">
  /* 保留全局样式：页面基础样式 */
  page {
    background-color: #f5f5f5;
    font-size: 28rpx;
    color: #333;
  }

  /* 引入全局 scss 样式文件 */
  @import '@/static/scss/index.scss'
</style>