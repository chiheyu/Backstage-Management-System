<template>
  <view class="container">
    <view class="search-wrap">
      <view class="search-input-wrap">
        <uni-icons type="search" size="24" color="#999" class="search-icon"></uni-icons>
        <input 
          class="search-input" 
          :value="searchKey" 
          @input="handleInput" 
          placeholder="搜索配件..."
          confirm-type="search"
          @confirm="search"
          clearable
        />
      </view>
      <button class="search-btn" @tap="search">搜索</button>
      <button class="add-btn" @tap="openEditPopup(true)" v-if="isMerchant">
        <uni-icons type="plus" size="20" color="#fff"></uni-icons>
      </button>
    </view>

    <view class="cate-wrap">
      <view class="cate-list">
        <view 
          class="cate-item" 
          :class="{ active: activeCate === item.id }"
          v-for="item in categoryList" 
          :key="item.id"
          :data-id="item.id"
          @tap="changeCate"
        >
          {{ item.name }}
        </view>
      </view>
    </view>

    <view class="goods-list">
      <view 
        class="goods-item" 
        v-for="item in filterGoods" 
        :key="item.id"
        :data-id="item.id"
      >
        <view class="goods-img-wrap" @tap="!isMerchant && goDetail(item.id)">
          <image 
            :src="item.image" 
            mode="aspectFill" 
            class="goods-img"
            lazy-load
            @error="imgError(item.id)"
            fade-show
          ></image>
          <view class="stock-tag" v-if="item.stock <= 10 && item.stock > 0">库存紧张</view>
        </view>
        <view class="goods-info">
          <text class="goods-name">{{ item.name }}</text>
          <text class="goods-spec">{{ item.spec }}</text>
          <view class="price-bar">
            <view class="price-wrap">
              <text class="price-symbol">¥</text>
              <text class="price-num">{{ item.price }}</text>
              <text class="original-price" v-if="item.originalPrice">¥{{ item.originalPrice }}</text>
            </view>
            <view class="goods-actions" v-if="isMerchant">
              <button class="edit-btn" @tap.stop="openEditPopup(false, item)">编辑</button>
              <button class="delete-btn" @tap.stop="deleteGoods(item.id)">
                <uni-icons type="trash" size="18" color="#fff"></uni-icons>
              </button>
            </view>
            <button 
              class="cart-btn" 
              :data-goods="item" 
              @tap.stop="addCart" 
              v-else
              :disabled="item.stock <= 0"
            >
              <uni-icons type="shopping-cart" size="20" color="#fff" v-if="item.stock > 0"></uni-icons>
              {{ item.stock <= 0 ? '已售罄' : '加入购物' }}
            </button>
          </view>
        </view>
      </view>

      <view class="empty" v-if="filterGoods.length === 0">
        <uni-icons type="shop" size="80" color="#e5e5e5"></uni-icons>
        <text class="empty-text">{{ isMerchant ? '暂无商品数据' : '暂无相关配件' }}</text>
        <text class="empty-subtext" v-if="searchKey">换个关键词试试吧～</text>
        <button class="empty-refresh-btn" @tap="resetSearch" v-if="searchKey || activeCate !== 0">
          重置筛选
        </button>
        <button class="empty-add-btn" @tap="openEditPopup(true)" v-if="isMerchant && !searchKey && activeCate === 0">
          <uni-icons type="plus" size="20" color="#fff"></uni-icons>
          添加商品
        </button>
      </view>
    </view>

    <uni-popup ref="editPopup" type="center" :mask-click="false" background-color="transparent">
      <view class="edit-popup">
        <view class="popup-header">
          <text class="popup-title">{{ isAdd ? '新增商品' : '编辑商品' }}</text>
          <uni-icons type="close" size="24" color="#333" class="popup-close" @tap="closeEditPopup"></uni-icons>
        </view>
        <view class="popup-form">
          <view class="form-item">
            <text class="form-label">商品名称</text>
            <input 
              class="form-input" 
              v-model="editGoods.name" 
              placeholder="请输入商品名称"
              maxlength="50"
            />
          </view>
          <view class="form-item">
            <text class="form-label">商品规格</text>
            <input 
              class="form-input" 
              v-model="editGoods.spec" 
              placeholder="请输入商品规格"
              maxlength="100"
            />
          </view>
          <view class="form-row">
            <view class="form-item half">
              <text class="form-label">售价</text>
              <input 
                class="form-input" 
                v-model.number="editGoods.price" 
                placeholder="0.00"
                type="digit"
              />
            </view>
            <view class="form-item half">
              <text class="form-label">原价</text>
              <input 
                class="form-input" 
                v-model.number="editGoods.originalPrice" 
                placeholder="0.00"
                type="digit"
              />
            </view>
          </view>
          <view class="form-item">
            <text class="form-label">库存</text>
            <input 
              class="form-input" 
              v-model.number="editGoods.stock" 
              placeholder="0"
              type="number"
              min="0"
            />
          </view>
          <view class="form-item">
            <text class="form-label">图片地址</text>
            <input 
              class="form-input" 
              v-model="editGoods.image" 
              placeholder="请输入商品图片地址"
            />
          </view>
        </view>
        <view class="popup-footer">
          <button class="cancel-btn" @tap="closeEditPopup">取消</button>
          <button class="save-btn" @tap="saveGoods" :disabled="!validateForm()">保存</button>
        </view>
      </view>
    </uni-popup>
  </view>
</template>

<script>
export default {
  data() {
    return {
      searchKey: '',
      activeCate: 0,
      isMerchant: false,
      categoryList: [
        { id: 0, name: '全部' },
        { id: 1, name: '屏幕' },
        { id: 2, name: '电池' },
        { id: 3, name: '充电器' },
        { id: 4, name: '数据线' },
        { id: 5, name: '耳机' },
        { id: 6, name: '贴膜' }
      ],
      goodsList: [],
      filterGoods: [],
      defaultImage: '/static/images/accessory/default-accessory.png',
      searchTimer: null,
      showEditPopup: false,
      isAdd: false,
      editGoods: {
        id: '',
        name: '',
        spec: '',
        price: '',
        originalPrice: '',
        image: '',
        stock: ''
      },
      // 初始商品数据（作为兜底）
      initGoodsList: [
        {
          id: 1,
          name: '通用显示屏',
          spec: '高清IPS屏幕 | 全视角 | 适用于主流机型 | 全国联保',
          price: 399,
          originalPrice: 499,
          image: '/static/images/accessory/accessory2.png',
          stock: 50
        },
        {
          id: 2,
          name: '小米 14 大容量电池',
          spec: '5000mAh 高续航 | 适配小米14/14 Pro | 原装电芯',
          price: 219,
          originalPrice: 269,
          image: '/static/images/accessory/xiaomi-battery-mi14.png',
          stock: 60
        },
        {
          id: 3,
          name: '苹果 iPhone 15 充电器',
          spec: '20W PD快充 | 兼容iPhone 12-15系列 | 安全温控',
          price: 129,
          originalPrice: 149,
          image: '/static/images/accessory/apple-charger-iphone15.png',
          stock: 150
        },
        {
          id: 4,
          name: 'Type-C 快充数据线',
          spec: '1.5米编织款 | 6A大电流 | 全品牌兼容 | 快充',
          price: 29,
          originalPrice: 49,
          image: '/static/images/accessory/universal-cable-typec.png',
          stock: 300
        },
        {
          id: 5,
          name: '荣耀 Magic6 无线耳机',
          spec: '主动降噪 | 28小时续航 | 适配荣耀/华为 | 低延迟',
          price: 269,
          originalPrice: 329,
          image: '/static/images/accessory/honor-earphone-magic6.png',
          stock: 70
        },
        {
          id: 6,
          name: 'OPPO Find X7 屏幕总成',
          spec: 'AMOLED 120Hz高刷 | 原装品质 | 全国联保 | 触控灵敏',
          price: 459,
          originalPrice: 529,
          image: '/static/images/accessory/oppo-screen-findx7.png',
          stock: 40
        },
        {
          id: 7,
          name: 'vivo X100 充电套装',
          spec: '120W 超级闪充 | 含数据线+充电器 | 全兼容 | 快充',
          price: 159,
          originalPrice: 199,
          image: '/static/images/accessory/vivo-charger-x100.png',
          stock: 120
        },
        {
          id: 8,
          name: '红米 K70 钢化膜',
          spec: '高清防指纹 | 全屏覆盖 | 2片装 | 防摔 | 高透',
          price: 19,
          originalPrice: 29,
          image: '/static/images/accessory/redmi-film-k70.png',
          stock: 500
        },
        {
          id: 9,
          name: '电源适配器',
          spec: '65W快充 | 多品牌兼容 | 过流保护 | 便携设计',
          price: 89,
          originalPrice: 129,
          image: '/static/images/accessory/accessory1.png',
          stock: 100
        },
        {
          id: 10,
          name: '华为 nova 11 原装屏幕',
          spec: '适用于nova 11/11 Pro | 全新原装 | 全国联保',
          price: 399,
          originalPrice: 499,
          image: '/static/images/accessory/huawei-screen-nova11.png',
          stock: 99
        }
      ]
    }
  },
  onLoad() {
    // 首次加载初始化商品数据
    this.initGoodsData();
    // 首次校验身份
    this.checkUserRole();
    // 初始化筛选列表
    this.filterGoods = [...this.goodsList];
  },
  onShow() {
    // 每次进入页面都重新校验身份
    this.checkUserRole();
    // 重新初始化商品数据（确保商家/用户数据一致）
    this.initGoodsData();
    // 刷新筛选列表（保留当前筛选状态）
    this.changeCate({ currentTarget: { dataset: { id: this.activeCate } } });
  },
  onUnload() {
    clearTimeout(this.searchTimer);
  },
  methods: {
    // 初始化商品数据（优先读取本地存储）
    initGoodsData() {
      const localGoods = wx.getStorageSync('goodsList');
      this.goodsList = localGoods && localGoods.length > 0 ? localGoods : this.initGoodsList;
    },
    // 校验用户身份（核心优化：抽离为独立方法，便于多次调用）
    checkUserRole() {
      const userInfo = wx.getStorageSync('userInfo');
      // 强制更新身份状态
      this.isMerchant = userInfo?.role === 'merchant';
      // 触发视图更新（兼容低版本小程序）
      this.$forceUpdate();
    },
    handleInput(e) {
      this.searchKey = e.detail.value.trim();
      clearTimeout(this.searchTimer);
      this.searchTimer = setTimeout(() => {
        this.search();
      }, 500);
    },
    search() {
      if (!this.searchKey) {
        // 无搜索关键词时，保留分类筛选状态
        this.changeCate({ currentTarget: { dataset: { id: this.activeCate } } });
        return;
      }
      const keyword = this.searchKey.toLowerCase();
      const result = this.goodsList.filter(item => 
        item.name.toLowerCase().includes(keyword) || 
        item.spec.toLowerCase().includes(keyword)
      );
      this.filterGoods = result;
    },
    resetSearch() {
      this.searchKey = '';
      this.activeCate = 0;
      this.filterGoods = [...this.goodsList];
      wx.showToast({ title: '已重置筛选条件', icon: 'success', duration: 1000 });
    },
    changeCate(e) {
      const id = e.currentTarget.dataset.id;
      this.activeCate = id;
      
      if (id === 0) {
        this.filterGoods = [...this.goodsList];
      } else {
        const cateMap = {
          1: ['屏幕', '显示屏'],
          2: ['电池'],
          3: ['充电器', '电源适配器', '充电套装'],
          4: ['数据线'],
          5: ['耳机'],
          6: ['贴膜']
        };
        const result = this.goodsList.filter(item => 
          cateMap[id].some(key => item.name.includes(key))
        );
        this.filterGoods = result;
      }
      
      // 搜索状态下，分类筛选需结合搜索关键词
      if (this.searchKey) {
        const keyword = this.searchKey.toLowerCase();
        this.filterGoods = this.filterGoods.filter(item => 
          item.name.toLowerCase().includes(keyword) || 
          item.spec.toLowerCase().includes(keyword)
        );
      }
    },
    goDetail(id) {
      const url = `/pages/accessoryDetail/index?id=${id}`;
      wx.navigateTo({
        url,
        success: () => console.log('✅ 跳转成功'),
        fail: (err) => {
          console.error('❌ 跳转失败:', err);
          wx.showToast({ title: '页面跳转失败', icon: 'none' });
        }
      });
    },
    addCart(e) {
      const item = e.currentTarget.dataset.goods;
      if (item.stock <= 0) {
        wx.showToast({ title: '商品已售罄', icon: 'none' });
        return;
      }
      let cartList = wx.getStorageSync('cartList') || [];
      const existItem = cartList.find(cartItem => cartItem.id === item.id);
      if (existItem) {
        if (existItem.count >= item.stock) {
          wx.showToast({ title: '已达最大库存', icon: 'none' });
          return;
        }
        existItem.count++;
      } else {
        cartList.push({ ...item, count: 1 });
      }
      wx.setStorageSync('cartList', cartList);
      wx.showToast({ 
        title: '加入购物车成功', 
        icon: 'success',
        duration: 1500,
        mask: true
      });
    },
    imgError(id) {
      const index = this.goodsList.findIndex(item => item.id === id);
      if (index > -1) {
        this.goodsList[index].image = this.defaultImage;
        // 保留筛选/搜索状态
        this.search();
      }
    },
    openEditPopup(isAdd, item = {}) {
      this.isAdd = isAdd;
      if (isAdd) {
        this.editGoods = {
          id: Date.now(),
          name: '',
          spec: '',
          price: '',
          originalPrice: '',
          image: this.defaultImage, // 默认填充图片地址
          stock: 0
        };
      } else {
        this.editGoods = { ...item };
      }
      this.$refs.editPopup.open();
    },
    closeEditPopup() {
      this.$refs.editPopup.close();
    },
    validateForm() {
      // 商品名称（非空）
      if (!this.editGoods.name.trim()) {
        wx.showToast({ title: '请输入商品名称', icon: 'none' });
        return false;
      }
      // 商品规格（非空）
      if (!this.editGoods.spec.trim()) {
        wx.showToast({ title: '请输入商品规格', icon: 'none' });
        return false;
      }
      // 售价（大于0且为数字）
      if (!this.editGoods.price || this.editGoods.price <= 0 || isNaN(this.editGoods.price)) {
        wx.showToast({ title: '请输入有效的售价（大于0）', icon: 'none' });
        return false;
      }
      // 原价（可选，输入则需大于0且为数字）
      if (this.editGoods.originalPrice !== '' && (this.editGoods.originalPrice <= 0 || isNaN(this.editGoods.originalPrice))) {
        wx.showToast({ title: '请输入有效的原价（大于0）', icon: 'none' });
        return false;
      }
      // 库存（大于等于0且为数字）
      if (this.editGoods.stock === '' || this.editGoods.stock < 0 || isNaN(this.editGoods.stock)) {
        wx.showToast({ title: '请输入有效的库存（大于等于0）', icon: 'none' });
        return false;
      }
      // 图片地址（默认填充，避免空值）
      if (!this.editGoods.image) {
        this.editGoods.image = this.defaultImage;
      }
      return true;
    },
    saveGoods() {
      if (this.isAdd) {
        this.goodsList.push(this.editGoods);
        wx.showToast({ title: '新增商品成功', icon: 'success' });
      } else {
        const index = this.goodsList.findIndex(item => item.id === this.editGoods.id);
        if (index > -1) {
          this.goodsList[index] = this.editGoods;
          wx.showToast({ title: '编辑商品成功', icon: 'success' });
        }
      }
      
      // 同步到本地存储（数据持久化）
      wx.setStorageSync('goodsList', this.goodsList);
      
      // 更新筛选列表，保留当前筛选状态
      this.filterGoods = [...this.goodsList];
      this.changeCate({ currentTarget: { dataset: { id: this.activeCate } } });
      this.closeEditPopup();
    },
    deleteGoods(id) {
      wx.showModal({
        title: '确认删除',
        content: '是否确定删除该商品？删除后不可恢复',
        confirmText: '删除',
        cancelText: '取消',
        success: (res) => {
          if (res.confirm) {
            const index = this.goodsList.findIndex(item => item.id === id);
            if (index > -1) {
              this.goodsList.splice(index, 1);
              
              // 同步到本地存储
              wx.setStorageSync('goodsList', this.goodsList);
              
              // 更新筛选列表
              this.filterGoods = [...this.goodsList];
              this.changeCate({ currentTarget: { dataset: { id: this.activeCate } } });
              wx.showToast({ title: '删除商品成功', icon: 'success' });
            }
          }
        }
      });
    },
    switchTab(tab) {
      const pathMap = {
        home: '/pages/index/index',
        afterSale: '/pages/applyAfterSale/index',
        mall: '/pages/accessoryMall/index',
        cart: '/pages/cart/index',
        profile: '/pages/profile/index'
      };
      wx.switchTab({ url: pathMap[tab] });
    }
  }
}
</script>

<style scoped>
:root {
  --primary-color: #2f54eb;
  --light-primary: #f0f5ff;
  --price-color: #ff7300;
  --price-gradient: linear-gradient(90deg, #ff7300, #ff9500);
  --stock-color: #ff4d4f;
  --danger-color: #ff4d4f;
  --edit-color: #1890ff;
  --text-color: #333;
  --text-gray: #999;
  --text-light: #666;
  --bg-color: #f8f8f8;
  --white: #fff;
  --border-color: #eee;
  --radius-sm: 8rpx;
  --radius-md: 12rpx;
  --radius-lg: 16rpx;
  --radius-full: 999rpx;
  --shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
  --shadow-deep: 0 6rpx 16rpx rgba(0, 0, 0, 0.08);
  --transition: all 0.3s ease;
  --transition-fast: all 0.2s ease;
}

.container {
  min-height: 100vh;
  background: var(--bg-color);
  padding-bottom: 20rpx;
}

.search-wrap {
  display: flex;
  padding: 20rpx;
  background: var(--white);
}
.search-input-wrap {
  flex: 1;
  position: relative;
}
.search-icon {
  position: absolute;
  left: 28rpx;
  top: 50%;
  transform: translateY(-50%);
  z-index: 1;
}
.search-input {
  width: 100%;
  height: 72rpx;
  padding: 0 28rpx 0 68rpx;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-full);
  font-size: 28rpx;
  color: var(--text-color);
  background: var(--bg-color);
}
.search-btn {
  width: 130rpx;
  height: 72rpx;
  line-height: 72rpx;
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  margin-left: 15rpx;
  font-size: 28rpx;
  border: none;
}
.add-btn {
  width: 72rpx;
  height: 72rpx;
  line-height: 72rpx;
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  margin-left: 15rpx;
  font-size: 24rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
}

.cate-wrap {
  background: var(--white);
  padding: 10rpx 20rpx;
}
.cate-list {
  display: flex;
  overflow-x: auto;
  white-space: nowrap;
  padding: 10rpx 0;
  scrollbar-width: none;
}
.cate-list::-webkit-scrollbar {
  display: none;
}
.cate-item {
  padding: 16rpx 28rpx;
  margin-right: 20rpx;
  border-radius: var(--radius-full);
  background: var(--bg-color);
  font-size: 26rpx;
  color: var(--text-light);
}
.cate-item.active {
  background: var(--primary-color);
  color: var(--white);
}

.goods-list {
  padding: 20rpx;
}
.goods-item {
  display: flex;
  background: var(--white);
  border-radius: var(--radius-md);
  padding: 24rpx;
  margin-bottom: 20rpx;
  box-shadow: var(--shadow);
}
.goods-img-wrap {
  position: relative;
  margin-right: 24rpx;
}
.goods-img {
  width: 180rpx;
  height: 180rpx;
  border-radius: var(--radius-sm);
  background: var(--bg-color);
}
.stock-tag {
  position: absolute;
  top: -10rpx;
  right: -10rpx;
  font-size: 20rpx;
  color: var(--stock-color);
  background: #fff0f0;
  padding: 2rpx 10rpx;
  border-radius: var(--radius-full);
}
.goods-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
.goods-name {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--text-color);
  margin-bottom: 10rpx;
  line-height: 1.3;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.goods-spec {
  font-size: 24rpx;
  color: var(--text-gray);
  margin-bottom: 20rpx;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.price-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.price-wrap {
  display: flex;
  align-items: baseline;
  gap: 4rpx;
}
.price-symbol {
  font-size: 24rpx;
  color: var(--price-color);
}
.price-num {
  font-size: 36rpx;
  font-weight: bold;
  color: var(--price-color);
}
.original-price {
  font-size: 24rpx;
  color: var(--text-gray);
  text-decoration: line-through;
  margin-left: 8rpx;
}
.goods-actions {
  display: flex;
  gap: 10rpx;
}
.edit-btn {
  width: 120rpx;
  height: 64rpx;
  line-height: 64rpx;
  background: var(--edit-color);
  color: var(--white);
  border-radius: var(--radius-full);
  font-size: 24rpx;
  border: none;
}
.delete-btn {
  width: 64rpx;
  height: 64rpx;
  line-height: 64rpx;
  background: var(--danger-color);
  color: var(--white);
  border-radius: var(--radius-full);
  font-size: 24rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
}
.cart-btn {
  width: 160rpx;
  height: 64rpx;
  line-height: 64rpx;
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  font-size: 24rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6rpx;
}
.cart-btn:disabled {
  background: var(--text-gray);
}

.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 150rpx 0;
  text-align: center;
}
.empty-text {
  font-size: 32rpx;
  color: var(--text-gray);
  margin-top: 30rpx;
  font-weight: 500;
}
.empty-subtext {
  font-size: 26rpx;
  color: var(--text-light);
  margin-top: 15rpx;
}
.empty-refresh-btn {
  margin-top: 40rpx;
  padding: 16rpx 40rpx;
  background: var(--white);
  color: var(--primary-color);
  border: 1px solid var(--primary-color);
  border-radius: var(--radius-full);
  font-size: 26rpx;
}
.empty-add-btn {
  margin-top: 20rpx;
  padding: 16rpx 40rpx;
  background: var(--primary-color);
  color: var(--white);
  border: none;
  border-radius: var(--radius-full);
  font-size: 26rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6rpx;
}

.edit-popup {
  width: 650rpx;
  background: var(--white);
  border-radius: var(--radius-lg);
  padding: 30rpx;
  box-shadow: var(--shadow-deep);
}
.popup-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30rpx;
  padding-bottom: 20rpx;
  border-bottom: 1px solid var(--border-color);
}
.popup-title {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--text-color);
}
.popup-form {
  margin-bottom: 30rpx;
}
.form-item {
  margin-bottom: 25rpx;
}
.form-row {
  display: flex;
  gap: 20rpx;
}
.half {
  flex: 1;
}
.form-label {
  display: block;
  font-size: 28rpx;
  color: var(--text-color);
  margin-bottom: 10rpx;
  font-weight: 500;
}
.form-input {
  width: 100%;
  height: 70rpx;
  padding: 0 20rpx;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  font-size: 28rpx;
  color: var(--text-color);
  box-sizing: border-box;
}
.popup-footer {
  display: flex;
  gap: 20rpx;
}
.cancel-btn {
  flex: 1;
  height: 72rpx;
  line-height: 72rpx;
  background: var(--bg-color);
  color: var(--text-color);
  border-radius: var(--radius-full);
  font-size: 28rpx;
  border: none;
}
.save-btn {
  flex: 1;
  height: 72rpx;
  line-height: 72rpx;
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  font-size: 28rpx;
  border: none;
}
.save-btn:disabled {
  background: var(--text-gray);
}
</style>