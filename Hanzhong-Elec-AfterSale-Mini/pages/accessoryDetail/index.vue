<template>
  <view class="detail-page">
    <image 
      :src="currentGoods.image" 
      mode="aspectFill" 
      class="goods-img"
      lazy-load
      @error="imgError"
      placeholder-class="img-placeholder"
    ></image>

    <view class="goods-info">
      <text class="goods-name">{{ currentGoods.name }}</text>
      <text class="goods-spec">{{ currentGoods.spec }}</text>
      <view class="price-row">
        <view class="price-wrap">
          <text class="price">¥{{ currentGoods.price }}</text>
          <text class="original-price" v-if="currentGoods.originalPrice">¥{{ currentGoods.originalPrice }}</text>
        </view>
        <text class="stock stock-empty" v-if="currentGoods.stock <= 0">已售罄</text>
        <text class="stock" v-else>库存：{{ currentGoods.stock }}件</text>
      </view>
      
      <!-- 商家专属：编辑商品按钮 -->
      <button 
        v-if="isMerchant" 
        @tap="openEditModal" 
        class="edit-btn"
      >
        编辑商品信息
      </button>
    </view>

    <view class="goods-desc">
      <view class="desc-title">商品详情</view>
      <text class="desc-content">{{ currentGoods.desc }}</text>
    </view>
    
    <!-- 商家专属：商品编辑弹窗 -->
    <uni-popup 
      v-if="isMerchant && editModalShow" 
      ref="editModal" 
      type="center" 
      @close="editModalShow = false"
    >
      <view class="edit-modal">
        <view class="modal-title">编辑商品</view>
        
        <view class="form-item">
          <text class="form-label">商品名称</text>
          <input 
            v-model="editForm.name" 
            placeholder="请输入商品名称" 
            class="form-input"
          />
        </view>
        
        <view class="form-item">
          <text class="form-label">商品价格</text>
          <input 
            v-model="editForm.price" 
            type="number" 
            placeholder="请输入售价" 
            class="form-input"
          />
        </view>
        
        <view class="form-item">
          <text class="form-label">原价</text>
          <input 
            v-model="editForm.originalPrice" 
            type="number" 
            placeholder="请输入原价" 
            class="form-input"
          />
        </view>
        
        <view class="form-item">
          <text class="form-label">库存数量</text>
          <input 
            v-model="editForm.stock" 
            type="number" 
            placeholder="请输入库存" 
            class="form-input"
          />
        </view>
        
        <view class="form-item">
          <text class="form-label">商品规格</text>
          <input 
            v-model="editForm.spec" 
            placeholder="请输入商品规格" 
            class="form-input"
          />
        </view>
        
        <view class="form-item">
          <text class="form-label">商品描述</text>
          <textarea 
            v-model="editForm.desc" 
            placeholder="请输入商品详情描述" 
            class="form-textarea"
          ></textarea>
        </view>
        
        <view class="modal-btns">
          <button @tap="editModalShow = false" class="cancel-btn">取消</button>
          <button @tap="saveGoodsEdit" class="save-btn">保存修改</button>
        </view>
      </view>
    </uni-popup>
    
    <view class="bottom-bar">
      <view v-if="!isMerchant" class="user-bar">
        <button 
          @tap="addToCart" 
          class="cart-btn"
          :disabled="currentGoods.stock <= 0"
        >
          <text v-if="currentGoods.stock <= 0">已售罄</text>
          <text v-else>加入购物车</text>
        </button>
        <button @tap="goBack" class="back-btn">返回商城</button>
      </view>
      
      <view v-if="isMerchant" class="merchant-bar">
        <button @tap="deleteGoods" class="delete-btn">删除商品</button>
        <button @tap="goBack" class="back-btn">返回商品管理</button>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      goodsId: '',
      currentGoods: {
        id: '',
        name: '',
        spec: '',
        price: '',
        originalPrice: '',
        stock: 0,
        image: '',
        desc: ''
      },
      isMerchant: false,
      defaultImage: '/static/images/accessory/default-accessory.png',
      // 商家编辑相关
      editModalShow: false,
      editForm: {
        name: '',
        price: '',
        originalPrice: '',
        stock: '',
        spec: '',
        desc: ''
      }
    }
  },
  onLoad(options) {
    this.goodsId = options.id || 1;
    const baseGoods = {
      id: options.id || 1,
      name: options.name || '',
      price: options.price || 0,
      originalPrice: options.originalPrice || '',
      image: options.image || this.defaultImage,
      stock: options.stock || 0,
      spec: options.spec || ''
    };
    this.getGoodsDetail(baseGoods);
    const userInfo = wx.getStorageSync('userInfo');
    this.isMerchant = userInfo?.role === 'merchant';
  },
  methods: {
    getGoodsDetail(baseGoods) {
      const goodsData = {
        1: {
          id: 1,
          name: '通用显示屏',
          spec: '高清IPS屏幕 | 全视角 | 适用于主流机型 | 全国联保',
          price: 399,
          originalPrice: 499,
          stock: 50,
          image: '/static/images/accessory/accessory2.png',
          desc: '通用高清IPS显示屏，178°广视角，色彩还原准确，亮度均匀无漏光，适用于主流笔记本、一体机等设备，安装简单，提供180天全国联保服务，支持退换货。'
        },
        2: {
          id: 2,
          name: '小米 14 大容量电池',
          spec: '5000mAh 高续航 | 适配小米14/14 Pro | 原装电芯',
          price: 219,
          originalPrice: 269,
          stock: 60,
          image: '/static/images/accessory/xiaomi-battery-mi14.png',
          desc: '小米14专用原装电芯电池，容量升级至5000mAh，循环充放电次数≥800次，续航能力提升30%，支持67W超级快充，无记忆效应，随充随用，适配小米14/14 Pro机型，提供1年质保。'
        },
        3: {
          id: 3,
          name: '苹果 iPhone 15 充电器',
          spec: '20W PD快充 | 兼容iPhone 12-15系列 | 安全温控',
          price: 129,
          originalPrice: 149,
          stock: 150,
          image: '/static/images/accessory/apple-charger-iphone15.png',
          desc: '苹果20W PD快充充电器，官方同款芯片，智能温控保护，过充/过压/过流三重防护，充电10分钟续航4小时，兼容iPhone 12/13/14/15全系列机型，体积小巧便携，支持快充协议。'
        },
        4: {
          id: 4,
          name: 'Type-C 快充数据线',
          spec: '1.5米编织款 | 6A大电流 | 全品牌兼容 | 快充',
          price: 29,
          originalPrice: 49,
          stock: 300,
          image: '/static/images/accessory/universal-cable-typec.png',
          desc: '6A大电流快充数据线，1.5米加长款设计，编织外层防断耐磨，抗弯折次数≥20000次，支持66W超级快充与高速数据传输，兼容华为、小米、苹果、OPPO、vivo等所有Type-C接口设备，即插即用。'
        },
        5: {
          id: 5,
          name: '荣耀 Magic6 无线耳机',
          spec: '主动降噪 | 28小时续航 | 适配荣耀/华为 | 低延迟',
          price: 269,
          originalPrice: 329,
          stock: 70,
          image: '/static/images/accessory/honor-earphone-magic6.png',
          desc: '荣耀FreeBuds Pro 2无线蓝牙耳机，40dB深度主动降噪，通透模式无感切换，单次续航7小时，搭配充电盒续航28小时，低延迟模式适配游戏/影音，支持快充，适配荣耀Magic6/华为全系列机型。'
        },
        6: {
          id: 6,
          name: 'OPPO Find X7 屏幕总成',
          spec: 'AMOLED 120Hz高刷 | 原装品质 | 全国联保 | 触控灵敏',
          price: 459,
          originalPrice: 529,
          stock: 40,
          image: '/static/images/accessory/oppo-screen-findx7.png',
          desc: 'OPPO Find X7原装屏幕总成，120Hz高刷AMOLED柔性屏，2K分辨率，色彩鲜艳通透，178°广视角，触控响应速度≤1ms，支持屏下指纹解锁，适用于Find X7机型，提供180天全国联保。'
        },
        7: {
          id: 7,
          name: 'vivo X100 充电套装',
          spec: '120W 超级闪充 | 含数据线+充电器 | 全兼容 | 快充',
          price: 159,
          originalPrice: 199,
          stock: 120,
          image: '/static/images/accessory/vivo-charger-x100.png',
          desc: 'vivo 120W超级闪充套装，包含充电器+Type-C数据线，充电5分钟续航50%，18分钟充满整机，兼容vivo X100/X90/iQOO全系列机型，智能兼容66W/44W快充协议，多重安全防护，1年质保。'
        },
        8: {
          id: 8,
          name: '红米 K70 钢化膜',
          spec: '高清防指纹 | 全屏覆盖 | 2片装 | 防摔 | 高透',
          price: 19,
          originalPrice: 29,
          stock: 500,
          image: '/static/images/accessory/redmi-film-k70.png',
          desc: '红米K70专用钢化膜，9H硬度防刮防摔，高清高透率99%，等离子防指纹涂层，全屏覆盖无白边，贴合度高不影响触控，2片装更划算，附赠贴膜神器，新手也能轻松贴好，适配红米K70/K70 Pro机型。'
        },
        9: {
          id: 9,
          name: '电源适配器',
          spec: '65W快充 | 多品牌兼容 | 过流保护 | 便携设计',
          price: 89,
          originalPrice: 129,
          stock: 100,
          image: '/static/images/accessory/accessory1.png',
          desc: '65W大功率电源适配器，兼容笔记本、手机、平板等多设备使用，内置智能芯片，具备过流、过压、短路三重保护，发热低更安全，小巧便携设计，出差旅行更方便，提供1年质保服务。'
        },
        10: {
          id: 10,
          name: '华为 nova 11 原装屏幕',
          spec: '适用于nova 11/11 Pro | 全新原装 | 全国联保',
          price: 399,
          originalPrice: 499,
          stock: 99,
          image: '/static/images/accessory/huawei-screen-nova11.png',
          desc: '华为官方授权原装屏幕，采用全新OLED材质，色彩还原度高达98%，触控灵敏无延迟，支持指纹解锁，适用于nova 11/11 Pro机型，提供180天官方质保，安装简单易操作。'
        }
      };
      this.currentGoods = {
        ...baseGoods,
        ...goodsData[this.goodsId]
      };
    },
    imgError(e) {
      e.target.src = this.defaultImage;
    },
    addToCart() {
      if (this.isMerchant || this.currentGoods.stock <= 0) return;
      
      let cart = wx.getStorageSync('cartList') || [];
      const existIndex = cart.findIndex(item => item.id === this.currentGoods.id);
      
      if (existIndex > -1) {
        if (cart[existIndex].count >= this.currentGoods.stock) {
          wx.showToast({ title: '已达最大库存', icon: 'none', duration: 1500 });
          return;
        }
        cart[existIndex].count += 1;
      } else {
        cart.push({ ...this.currentGoods, count: 1 });
      }
      
      wx.setStorageSync('cartList', cart);
      wx.showToast({ 
        title: '加入购物车成功', 
        icon: 'success', 
        duration: 1500,
        mask: true 
      });
    },
    goBack() {
      wx.navigateBack({ delta: 1 });
    },
    // 商家功能：打开编辑弹窗
    openEditModal() {
      this.editForm = { ...this.currentGoods };
      this.editModalShow = true;
      this.$refs.editModal.open();
    },
    // 商家功能：保存商品修改
    saveGoodsEdit() {
      if (!this.editForm.name || !this.editForm.price) {
        wx.showToast({ title: '名称和价格不能为空', icon: 'none' });
        return;
      }
      
      // 更新当前商品数据
      this.currentGoods = { ...this.editForm };
      
      // 模拟更新本地存储的商品数据（实际项目应调用后端接口）
      let allGoods = wx.getStorageSync('allGoods') || {};
      allGoods[this.goodsId] = this.currentGoods;
      wx.setStorageSync('allGoods', allGoods);
      
      this.editModalShow = false;
      wx.showToast({ title: '商品修改成功', icon: 'success' });
    },
    // 商家功能：删除商品
    deleteGoods() {
      wx.showModal({
        title: '确认删除',
        content: '是否确定删除该商品？删除后不可恢复',
        confirmText: '删除',
        cancelText: '取消',
        success: (res) => {
          if (res.confirm) {
            // 模拟删除逻辑（实际项目应调用后端接口）
            let allGoods = wx.getStorageSync('allGoods') || {};
            delete allGoods[this.goodsId];
            wx.setStorageSync('allGoods', allGoods);
            
            wx.showToast({ title: '商品删除成功', icon: 'success' });
            setTimeout(() => {
              wx.navigateBack({ delta: 1 });
            }, 1500);
          }
        }
      });
    }
  }
}
</script>

<style scoped>
:root {
  --primary-color: #2f54eb;
  --light-primary: #f0f5ff;
  --price-color: #ff7300;
  --text-color: #333;
  --text-gray: #999;
  --text-light: #666;
  --bg-color: #f8f8f8;
  --white: #fff;
  --red: #ff4d4f;
  --border-color: #eee;
  --radius-sm: 8rpx;
  --radius-md: 12rpx;
  --radius-lg: 16rpx;
  --radius-full: 999rpx;
  --shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
  --shadow-deep: 0 6rpx 16rpx rgba(0, 0, 0, 0.08);
  --transition: all 0.3s ease;
}

.detail-page {
  min-height: 100vh;
  background: var(--bg-color);
}

.goods-img {
  width: 100%;
  height: 400rpx;
  border-radius: var(--radius-md) var(--radius-md) 0 0;
  background: var(--bg-color);
}
.img-placeholder {
  width: 100%;
  height: 400rpx;
  background-color: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
}

.goods-info {
  background: var(--white);
  padding: 30rpx;
  margin-bottom: 20rpx;
  box-shadow: var(--shadow);
  border-radius: var(--radius-md);
  margin: 0 16rpx 20rpx;
  transform: translateY(-10rpx);
  transition: var(--transition);
}
.goods-name {
  font-size: 36rpx;
  font-weight: bold;
  color: var(--text-color);
  display: block;
  margin-bottom: 15rpx;
  line-height: 1.3;
}
.goods-spec {
  font-size: 28rpx;
  color: var(--text-light);
  display: block;
  margin-bottom: 20rpx;
  line-height: 1.4;
}
.price-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.price-wrap {
  display: flex;
  align-items: baseline;
  gap: 12rpx;
}
.price {
  font-size: 40rpx;
  color: var(--price-color);
  font-weight: bold;
}
.original-price {
  font-size: 26rpx;
  color: var(--text-gray);
  text-decoration: line-through;
}
.stock {
  font-size: 26rpx;
  color: var(--text-gray);
}
.stock-empty {
  color: var(--red);
  font-weight: 500;
}
.edit-btn {
  width: 100%;
  height: 70rpx;
  line-height: 70rpx;
  background: var(--light-primary);
  color: var(--primary-color);
  border: 1px solid var(--primary-color);
  border-radius: var(--radius-md);
  font-size: 28rpx;
  margin-top: 20rpx;
}

.goods-desc {
  background: var(--white);
  padding: 30rpx;
  margin: 0 16rpx 100rpx;
  border-radius: var(--radius-md);
  box-shadow: var(--shadow);
}
.desc-title {
  font-size: 32rpx;
  font-weight: bold;
  color: var(--text-color);
  margin-bottom: 20rpx;
  padding-bottom: 10rpx;
  border-bottom: 1px solid var(--border-color);
}
.desc-content {
  font-size: 28rpx;
  color: var(--text-light);
  line-height: 1.8;
  text-align: justify;
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  height: 100rpx;
  background: var(--white);
  border-top: 1px solid var(--border-color);
  box-shadow: 0 -2rpx 10rpx rgba(0, 0, 0, 0.03);
  z-index: 99;
}
.user-bar {
  display: flex;
  width: 100%;
  height: 100%;
}
.cart-btn {
  flex: 1;
  height: 100%;
  line-height: 100rpx;
  background: var(--primary-color);
  color: var(--white);
  font-size: 32rpx;
  border: none;
  border-radius: 0;
  transition: var(--transition);
}
.cart-btn:disabled {
  background: var(--text-gray);
  color: var(--white);
}
.cart-btn:active:not(:disabled) {
  background: #1e42c8;
  transform: scale(0.98);
}
.back-btn {
  flex: 1;
  height: 100%;
  line-height: 100rpx;
  background: #f5f5f5;
  color: var(--primary-color);
  font-size: 32rpx;
  border: none;
  border-radius: 0;
  transition: var(--transition);
}
.back-btn:active {
  background: #e8e8e8;
  transform: scale(0.98);
}

.merchant-bar {
  display: flex;
  width: 100%;
  height: 100%;
  align-items: center;
}
.merchant-tip {
  flex: 1;
  text-align: center;
  font-size: 28rpx;
  color: var(--text-gray);
}
.delete-btn {
  flex: 1;
  height: 100%;
  line-height: 100rpx;
  background: var(--red);
  color: var(--white);
  font-size: 32rpx;
  border: none;
  border-radius: 0;
  transition: var(--transition);
}
.delete-btn:active {
  background: #d9363e;
  transform: scale(0.98);
}

/* 编辑弹窗样式 */
.edit-modal {
  width: 650rpx;
  background: var(--white);
  border-radius: var(--radius-md);
  padding: 30rpx;
}
.modal-title {
  font-size: 32rpx;
  font-weight: bold;
  color: var(--text-color);
  text-align: center;
  margin-bottom: 30rpx;
  padding-bottom: 20rpx;
  border-bottom: 1px solid var(--border-color);
}
.form-item {
  margin-bottom: 25rpx;
}
.form-label {
  font-size: 28rpx;
  color: var(--text-color);
  display: block;
  margin-bottom: 10rpx;
}
.form-input {
  width: 100%;
  height: 70rpx;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  padding: 0 20rpx;
  font-size: 28rpx;
}
.form-textarea {
  width: 100%;
  min-height: 150rpx;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  padding: 20rpx;
  font-size: 28rpx;
  resize: none;
}
.modal-btns {
  display: flex;
  gap: 20rpx;
  margin-top: 30rpx;
}
.cancel-btn {
  flex: 1;
  height: 70rpx;
  line-height: 70rpx;
  background: #f5f5f5;
  color: var(--text-color);
  border-radius: var(--radius-sm);
  font-size: 28rpx;
}
.save-btn {
  flex: 1;
  height: 70rpx;
  line-height: 70rpx;
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-sm);
  font-size: 28rpx;
}
</style>