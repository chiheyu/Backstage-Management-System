<template>
  <view class="container">
    <view class="search-wrap">
      <view class="search-input-wrap">
        <!-- 替换uni-icons为原生搜索图标 -->
        <text class="search-icon">🔍</text>
        <input
          class="search-input"
          :value="searchKey"
          @input="handleInput"
          :placeholder="isMerchant ? '搜索商品名称或分类...' : '搜索配件...'"
          confirm-type="search"
          @confirm="search"
          clearable
        />
      </view>
      <button class="search-btn" @tap="search">搜索</button>
      <button v-if="isMerchant" class="add-goods-btn" @tap="openAddMerchantGoods">
        <!-- 替换uni-icons为原生+号 -->
        <text class="plus-icon">+</text>
        <text class="add-goods-text">新增商品</text>
      </button>
    </view>

    <view v-if="isMerchant" class="merchant-hero">
      <view class="merchant-hero-main">
        <text class="merchant-hero-title">商品管理</text>
      </view>
      <view class="merchant-summary">
        <view class="merchant-stat">
          <text class="merchant-stat-label">商品总数</text>
          <text class="merchant-stat-value">{{ merchantSummary.total }}</text>
        </view>
        <view class="merchant-stat">
          <text class="merchant-stat-label">上架商品</text>
          <text class="merchant-stat-value">{{ merchantSummary.onShelf }}</text>
        </view>
        <view class="merchant-stat">
          <text class="merchant-stat-label">低库存</text>
          <text class="merchant-stat-value">{{ merchantSummary.lowStock }}</text>
        </view>
      </view>
    </view>

    <view class="cate-wrap">
      <view class="cate-list">
        <view
          v-for="item in categoryList"
          :key="item.id"
          class="cate-item"
          :class="{ active: activeCate === item.id }"
          :data-id="item.id"
          @tap="changeCate"
        >
          {{ item.name }}
        </view>
      </view>
    </view>

    <!-- 替换loading的uni-icons为CSS加载动画 -->
    <view class="loading-wrap" v-if="loading">
      <view class="loading-icon"></view>
      <text class="loading-text">配件列表加载中...</text>
    </view>

    <view class="goods-list" v-else-if="filterGoods.length > 0">
      <view class="goods-item" v-for="item in filterGoods" :key="item.id">
        <view class="goods-img-wrap" @tap="handleGoodsClick(item)">
          <image
            :src="item.image"
            mode="aspectFill"
            class="goods-img"
            lazy-load
            @error="imgError(item.id)"
            show-menu-by-longpress="false"
          ></image>
          <view class="stock-tag" v-if="item.stock <= 10 && item.stock > 0">库存紧张</view>
        </view>
        <view class="goods-info">
          <text class="goods-name">{{ item.name }}</text>
          <text class="goods-spec">{{ item.spec }}</text>
          <text class="goods-desc">{{ item.desc }}</text>
          <view v-if="isMerchant" class="merchant-meta">
            <text class="merchant-meta-item">库存 {{ item.stock }}</text>
            <text class="merchant-meta-item">销量 {{ item.salesCount }}</text>
            <text :class="['merchant-status', item.status === '0' ? 'merchant-status-on' : 'merchant-status-off']">
              {{ item.status === '0' ? '上架中' : '已下架' }}
            </text>
          </view>
          <view class="price-bar">
            <view class="price-wrap">
              <text class="price-symbol">¥</text>
              <text class="price-num">{{ item.price }}</text>
            </view>
            <button
              v-if="isMerchant"
              class="detail-btn"
              @tap.stop="openMerchantEditor(item.id)"
            >
              查看详情
            </button>
            <button
              v-else
              class="cart-btn"
              :data-goods="item"
              @tap.stop="addCart"
              :disabled="item.stock <= 0"
            >
              {{ item.stock <= 0 ? '已售罄' : '加入购物车' }}
            </button>
          </view>
        </view>
      </view>
    </view>

    <!-- 替换空状态uni-icons为原生图标 -->
    <view class="empty" v-else>
      <text class="empty-icon">🛒</text>
      <text class="empty-text">暂无相关配件</text>
      <text class="empty-subtext" v-if="searchKey">换个关键词试试吧</text>
      <button class="empty-refresh-btn" @tap="resetSearch" v-if="searchKey || activeCate !== allCategoryId">
        重置筛选
      </button>
    </view>

    <view v-if="isMerchant && showMerchantEditor" class="editor-mask" @tap="closeMerchantEditor">
      <view class="editor-popup" @tap.stop>
        <view class="editor-header">
          <text class="editor-title">{{ isAddMode ? '新增商品' : '商品编辑' }}</text>
          <view v-if="!isAddMode" class="status-chip" :class="merchantForm.status === '0' ? 'status-chip-on' : 'status-chip-off'">
            {{ merchantForm.status === '0' ? '上架中' : '已下架' }}
          </view>
        </view>

        <view class="editor-preview">
          <image :src="editorPreviewImage" mode="aspectFill" class="editor-preview-image"></image>
        </view>

        <view class="form-item">
          <text class="form-label">商品名称</text>
          <input v-model="merchantForm.accessoryName" class="form-input" placeholder="请输入商品名称" maxlength="40" />
        </view>

        <view class="form-item">
          <text class="form-label">商品类别</text>
          <input v-model="merchantForm.categoryName" class="form-input" placeholder="请输入商品类别" maxlength="30" />
        </view>

        <view class="form-row">
          <view class="form-item half">
            <text class="form-label">售价</text>
            <input v-model="merchantForm.price" class="form-input" type="digit" placeholder="请输入售价" />
          </view>
          <view class="form-item half">
            <text class="form-label">库存</text>
            <input v-model="merchantForm.stock" class="form-input" type="number" placeholder="请输入库存" />
          </view>
        </view>

        <view class="form-item">
          <text class="form-label">图片地址</text>
          <input v-model="merchantForm.coverImage" class="form-input" placeholder="支持输入图片地址或选择上传" />
          <view class="image-actions">
            <button class="secondary-btn" @tap="chooseMerchantImage" :disabled="isUploadingImage">
              {{ isUploadingImage ? '上传中...' : '选择图片' }}
            </button>
          </view>
        </view>

        <view class="form-item">
          <text class="form-label">商品详情</text>
          <textarea
            v-model="merchantForm.accessoryDesc"
            class="form-textarea"
            placeholder="请输入商品详情"
            maxlength="300"
          ></textarea>
        </view>

        <view class="action-row">
          <button class="secondary-btn cancel-btn" @tap="closeMerchantEditor">
            取消
          </button>
          <button v-if="!isAddMode" class="secondary-btn" @tap="toggleShelfStatus">
            {{ merchantForm.status === '0' ? '下架商品' : '重新上架' }}
          </button>
          <button class="primary-btn" @tap="saveMerchantGoods" :disabled="isSavingGoods">
            {{ isSavingGoods ? '保存中...' : (isAddMode ? '确认新增' : '保存修改') }}
          </button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import { getAccessoryList, normalizeAccessory } from '@/api/accessory'
import { getCartList, setCartList } from '@/utils/cart'
import {
  getMerchantAccessoryList,
  getMerchantAccessoryDetail,
  updateMerchantAccessory,
  addMerchantAccessory,
  uploadMerchantAccessoryImage
} from '@/api/merchantAccessory'
import { syncRoleTabBar } from '@/utils/tabbar'

const ALL_CATEGORY_ID = 'all'
const PAGE_SIZE = 50

export default {
  data() {
    return {
      allCategoryId: ALL_CATEGORY_ID,
      isMerchant: false,
      searchKey: '',
      activeCate: ALL_CATEGORY_ID,
      categoryList: [{ id: ALL_CATEGORY_ID, name: '全部' }],
      goodsList: [],
      filterGoods: [],
      defaultImage: '/static/images/accessory/default-accessory.png',
      searchTimer: null,
      loading: false,
      showMerchantEditor: false,
      isAddMode: false,
      isSavingGoods: false,
      isUploadingImage: false,
      merchantForm: {
        accessoryId: '',
        merchantId: '',
        accessoryName: '',
        categoryName: '',
        accessoryDesc: '',
        coverImage: '',
        price: '',
        stock: '',
        status: '0'
      }
    }
  },
  computed: {
    merchantSummary() {
      return {
        total: this.goodsList.length,
        onShelf: this.goodsList.filter((item) => item.status === '0').length,
        lowStock: this.goodsList.filter((item) => item.stock > 0 && item.stock <= 10).length
      }
    },
    editorPreviewImage() {
      return this.merchantForm.coverImage || this.defaultImage
    }
  },
  onLoad() {
    this.checkUserRole()
    syncRoleTabBar(uni.getStorageSync('userInfo') || {})
    this.updateNavigationTitle()
    this.loadGoodsList()
  },
  onShow() {
    this.checkUserRole()
    syncRoleTabBar(uni.getStorageSync('userInfo') || {})
    this.updateNavigationTitle()
    if (!this.goodsList.length) {
      this.loadGoodsList()
      return
    }
    this.applyFilters()
  },
  onUnload() {
    clearTimeout(this.searchTimer)
  },
  methods: {
    checkUserRole() {
      const userInfo = uni.getStorageSync('userInfo') || {}
      this.isMerchant = userInfo.role === 'merchant' || userInfo.roleType === '2'
      if (this.isMerchant && userInfo.merchant) {
        this.merchantForm.merchantId = userInfo.merchant.merchantId || ''
      }
    },
    // 🔥 修复核心API拼写错误（原代码写错了）
    updateNavigationTitle() {
      uni.setNavigationBarTitle({
        title: this.isMerchant ? '商品管理' : '配件商城'
      })
    },
    buildCategoryList(list) {
      const categories = Array.from(
        new Set(
          list
            .map((item) => item.spec)
            .filter((item) => typeof item === 'string' && item.trim())
        )
      )
      return [{ id: ALL_CATEGORY_ID, name: '全部' }].concat(
        categories.map((item) => ({ id: item, name: item }))
      )
    },
    async fetchAllAccessories() {
      let pageNum = 1
      let total = 0
      let finished = false
      const list = []
      while (!finished) {
        const res = await (this.isMerchant ? getMerchantAccessoryList({
          pageNum, pageSize: PAGE_SIZE
        }) : getAccessoryList({
          pageNum, pageSize: PAGE_SIZE
        }))
        const rows = Array.isArray(res.rows) ? res.rows : []
        total = Number(res.total) || 0
        list.push(...rows)
        if (!rows.length || rows.length < PAGE_SIZE) finished = true
        else if (total > 0 && list.length >= total) finished = true
        else pageNum += 1
      }
      return list
    },
    async loadGoodsList() {
      if (this.loading) return
      this.loading = true
      uni.showLoading({ title: '加载中', mask: true })
      try {
        const rows = await this.fetchAllAccessories()
        this.goodsList = rows.map((item) => normalizeAccessory(item)).filter((item) => !!item.id)
        this.categoryList = this.buildCategoryList(this.goodsList)
        if (!this.categoryList.some((item) => item.id === this.activeCate)) {
          this.activeCate = ALL_CATEGORY_ID
        }
        this.applyFilters()
      } catch (error) {
        this.goodsList = []
        this.categoryList = [{ id: ALL_CATEGORY_ID, name: '全部' }]
        this.filterGoods = []
      } finally {
        this.loading = false
        uni.hideLoading()
      }
    },
    applyFilters() {
      const keyword = (this.searchKey || '').toLowerCase()
      this.filterGoods = this.goodsList.filter((item) => {
        const matchCategory = this.activeCate === ALL_CATEGORY_ID || item.spec === this.activeCate
        const matchKeyword = !keyword || [item.name, item.spec, item.desc].filter(Boolean).some((field) => 
          String(field).toLowerCase().includes(keyword)
        )
        return matchCategory && matchKeyword
      })
    },
    handleInput(e) {
      this.searchKey = (e.detail.value || '').trim()
      clearTimeout(this.searchTimer)
      this.searchTimer = setTimeout(() => this.applyFilters(), 300)
    },
    search() { this.applyFilters() },
    resetSearch() {
      this.searchKey = ''
      this.activeCate = ALL_CATEGORY_ID
      this.applyFilters()
      uni.showToast({ title: '已重置筛选', icon: 'success' })
    },
    changeCate(e) {
      this.activeCate = e.currentTarget.dataset.id || ALL_CATEGORY_ID
      this.applyFilters()
    },
    goDetail(id) {
      if (!id) return
      uni.navigateTo({
        url: `/pages/accessoryDetail/index?id=${id}`,
        fail: () => uni.showToast({ title: '页面跳转失败', icon: 'none' })
      })
    },
    handleGoodsClick(item) {
      if (!item || !item.id) return
      this.isMerchant ? this.openMerchantEditor(item.id) : this.goDetail(item.id)
    },
    openAddMerchantGoods() {
      this.isAddMode = true
      this.merchantForm = {
        accessoryId: '',
        merchantId: this.merchantForm.merchantId,
        accessoryName: '',
        categoryName: '',
        accessoryDesc: '',
        coverImage: '',
        price: '',
        stock: '',
        status: '0'
      }
      this.showMerchantEditor = true
    },
    async openMerchantEditor(id) {
      this.isAddMode = false
      try {
        const res = await getMerchantAccessoryDetail(id)
        const detail = normalizeAccessory(res.data || {})
        if (!detail.id) {
          uni.showToast({ title: '未找到商品信息', icon: 'none' })
          return
        }
        this.merchantForm = {
          accessoryId: detail.accessoryId || detail.id,
          merchantId: this.merchantForm.merchantId,
          accessoryName: detail.accessoryName || detail.name || '',
          categoryName: detail.categoryName || detail.spec || '',
          accessoryDesc: detail.accessoryDesc || detail.desc || '',
          coverImage: detail.coverImage || '',
          price: String(detail.price ?? ''),
          stock: String(detail.stock ?? ''),
          status: String(detail.status || '0')
        }
        this.showMerchantEditor = true
      } catch (error) {
        uni.showToast({ title: error?.msg || '加载商品失败', icon: 'none' })
      }
    },
    closeMerchantEditor() {
      this.showMerchantEditor = false
    },
    async chooseMerchantImage() {
      if (!this.isMerchant || this.isUploadingImage) return
      uni.chooseImage({
        count: 1, sizeType: ['compressed'], sourceType: ['album', 'camera'],
        success: async ({ tempFilePaths = [] }) => {
          const filePath = tempFilePaths[0]
          if (!filePath) return
          this.isUploadingImage = true
          try {
            const uploadRes = await uploadMerchantAccessoryImage(filePath)
            this.merchantForm.coverImage = uploadRes.url || this.merchantForm.coverImage
            uni.showToast({ title: '图片上传成功', icon: 'success' })
          } catch (error) {
            uni.showToast({ title: error?.msg || '图片上传失败', icon: 'none' })
          } finally {
            this.isUploadingImage = false
          }
        }
      })
    },
    validateMerchantForm() {
      if (!this.merchantForm.accessoryName.trim()) return '请输入商品名称'
      if (!this.merchantForm.categoryName.trim()) return '请输入商品类别'
      if (!this.merchantForm.price || Number(this.merchantForm.price) <= 0) return '请输入有效售价'
      if (this.merchantForm.stock === '' || Number(this.merchantForm.stock) < 0) return '请输入有效库存'
      return ''
    },
    async saveMerchantGoods() {
      if (!this.isMerchant || this.isSavingGoods) return
      const msg = this.validateMerchantForm()
      if (msg) {
        uni.showToast({ title: msg, icon: 'none' })
        return
      }
      this.isSavingGoods = true
      try {
        const params = {
          merchantId: this.merchantForm.merchantId,
          accessoryName: this.merchantForm.accessoryName.trim(),
          categoryName: this.merchantForm.categoryName.trim(),
          accessoryDesc: this.merchantForm.accessoryDesc.trim(),
          coverImage: this.merchantForm.coverImage.trim(),
          price: Number(this.merchantForm.price),
          stock: Number(this.merchantForm.stock),
          status: this.merchantForm.status
        }
        if (this.isAddMode) {
          await addMerchantAccessory(params)
          uni.showToast({ title: '新增商品成功', icon: 'success' })
        } else {
          await updateMerchantAccessory({ ...params, accessoryId: this.merchantForm.accessoryId })
          uni.showToast({ title: '保存成功', icon: 'success' })
        }
        this.showMerchantEditor = false
        await this.loadGoodsList()
      } catch (error) {
        uni.showToast({ title: error?.msg || '操作失败', icon: 'none' })
      } finally {
        this.isSavingGoods = false
      }
    },
    toggleShelfStatus() {
      if (!this.isMerchant || this.isAddMode) return
      this.merchantForm.status = this.merchantForm.status === '0' ? '1' : '0'
    },
    addCart(e) {
      const item = e.currentTarget.dataset.goods
      if (!item || !item.id) return
      if (item.stock <= 0) {
        uni.showToast({ title: '商品已售罄', icon: 'none' })
        return
      }
      const cartList = getCartList()
      const exist = cartList.find(i => i.id === item.id)
      if (exist) {
        if (exist.count >= item.stock) {
          uni.showToast({ title: '已达最大库存', icon: 'none' })
          return
        }
        exist.count++
      } else {
        cartList.push({ ...item, count: 1 })
      }
      setCartList(cartList)
      uni.showToast({ title: '加入购物车成功', icon: 'success', duration: 1500 })
    },
    imgError(id) {
      const idx = this.goodsList.findIndex(i => i.id === id)
      if (idx > -1) {
        this.goodsList[idx].image = this.defaultImage
        this.applyFilters()
      }
    }
  }
}
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  -webkit-tap-highlight-color: transparent;
}

page {
  background: #f6f7f9;
  height: 100%;
}

.container {
  min-height: 100vh;
  background: #f6f7f9;
  padding-bottom: 20rpx;
  overflow-x: hidden;
}

.search-wrap {
  display: flex;
  align-items: center;
  padding: 24rpx;
  background: #ffffff;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
  gap: 20rpx;
}

.search-input-wrap {
  flex: 1;
  position: relative;
  min-width: 0;
}

/* 原生搜索图标样式 */
.search-icon {
  position: absolute;
  left: 28rpx;
  top: 50%;
  transform: translateY(-50%);
  z-index: 1;
  font-size: 24rpx;
  color: #999;
}

.search-input {
  width: 100%;
  height: 76rpx;
  padding: 0 32rpx 0 72rpx;
  border: none;
  border-radius: 999rpx;
  font-size: 28rpx;
  color: #333333;
  background: #f6f7f9;
  transition: all 0.25s ease;
}

.search-input:focus {
  background: #ffffff;
  box-shadow: 0 0 0 2rpx #2f54eb, 0 0 0 6rpx rgba(47, 84, 235, 0.1);
}

.search-btn {
  width: 140rpx;
  height: 76rpx;
  line-height: 76rpx;
  background: #2f54eb;
  color: #ffffff;
  border-radius: 999rpx;
  font-size: 28rpx;
  border: none;
  flex-shrink: 0;
  transition: all 0.25s ease;
  box-shadow: 0 4rpx 12rpx rgba(47, 84, 235, 0.2);
}

.search-btn:active {
  transform: scale(0.96);
  opacity: 0.9;
  box-shadow: 0 2rpx 8rpx rgba(47, 84, 235, 0.15);
}

.add-goods-btn {
  display: flex;
  align-items: center;
  padding: 0 28rpx;
  height: 76rpx;
  background: #2f54eb;
  color: #ffffff;
  border: none;
  border-radius: 999rpx;
  font-size: 26rpx;
  font-weight: 500;
  flex-shrink: 0;
  transition: all 0.25s ease;
  box-shadow: 0 4rpx 12rpx rgba(47, 84, 235, 0.2);
}

/* 原生+号图标样式 */
.plus-icon {
  margin-right: 8rpx;
  font-size: 20rpx;
  color: #fff;
}

.add-goods-text {
  font-size: 26rpx;
  color: #ffffff;
  font-weight: 500;
}

.add-goods-btn:active {
  transform: scale(0.96);
  opacity: 0.9;
  box-shadow: 0 2rpx 8rpx rgba(47, 84, 235, 0.15);
}

.merchant-hero {
  margin: 24rpx;
  padding: 32rpx;
  border-radius: 28rpx;
  background: linear-gradient(135deg, #165dff, #4080ff);
  color: #ffffff;
  box-shadow: 0 8rpx 32rpx rgba(22, 93, 255, 0.2);
}

.merchant-hero-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 28rpx;
}

.merchant-hero-title {
  font-size: 48rpx;
  font-weight: 700;
}

.merchant-summary {
  display: flex;
  gap: 28rpx;
  margin-top: 20rpx;
}

.merchant-stat {
  flex: 1;
  padding: 32rpx 24rpx;
  border-radius: 24rpx;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10rpx);
  text-align: center;
  transition: all 0.25s ease;
}

.merchant-stat:active {
  transform: scale(0.96);
  background: rgba(255, 255, 255, 0.25);
}

.merchant-stat-label {
  display: block;
  font-size: 24rpx;
  opacity: 0.9;
  margin-bottom: 12rpx;
}

.merchant-stat-value {
  display: block;
  font-size: 40rpx;
  font-weight: 700;
}

.cate-wrap {
  background: #ffffff;
  padding: 16rpx 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
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
  padding: 24rpx 40rpx;
  margin-right: 20rpx;
  border-radius: 999rpx;
  background: #f6f7f9;
  font-size: 26rpx;
  color: #666666;
  transition: all 0.25s ease;
  font-weight: 500;
}

.cate-item.active {
  background: #2f54eb;
  color: #ffffff;
  transform: translateY(-2rpx);
  box-shadow: 0 6rpx 16rpx rgba(47, 84, 235, 0.25);
}

.loading-wrap,
.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 180rpx 40rpx;
  text-align: center;
}

/* CSS加载动画，替换uni-icons */
.loading-icon {
  width: 36rpx;
  height: 36rpx;
  border: 3rpx solid #2f54eb;
  border-top-color: transparent;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.loading-text,
.empty-text {
  font-size: 30rpx;
  color: #999999;
  margin-top: 28rpx;
  font-weight: 500;
}

/* 空状态图标样式 */
.empty-icon {
  font-size: 100rpx;
  color: #e5e5e5;
}

.empty-subtext {
  font-size: 26rpx;
  color: #666666;
  margin-top: 12rpx;
}

.empty-refresh-btn {
  margin-top: 36rpx;
  padding: 24rpx 52rpx;
  background: #ffffff;
  color: #2f54eb;
  border: 2rpx solid #2f54eb;
  border-radius: 999rpx;
  font-size: 26rpx;
  transition: all 0.25s ease;
}

.empty-refresh-btn:active {
  transform: scale(0.96);
  background: #f0f5ff;
}

.goods-list {
  padding: 24rpx;
  overflow-x: hidden;
}

.goods-item {
  display: flex;
  background: #ffffff;
  border-radius: 24rpx;
  padding: 36rpx;
  margin-bottom: 28rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.06);
  transition: all 0.25s ease;
  overflow: hidden;
}

.goods-item:active {
  transform: translateY(-8rpx);
  box-shadow: 0 12rpx 32rpx rgba(0, 0, 0, 0.08);
}

.goods-img-wrap {
  position: relative;
  margin-right: 36rpx;
  flex-shrink: 0;
}

.goods-img {
  width: 180rpx;
  height: 180rpx;
  border-radius: 20rpx;
  background: #f5f7fa;
  object-fit: cover;
}

.stock-tag {
  position: absolute;
  top: -10rpx;
  right: -10rpx;
  font-size: 20rpx;
  color: #ff4d4f;
  background: #fff0f0;
  padding: 8rpx 16rpx;
  border-radius: 999rpx;
  font-weight: 500;
  box-shadow: 0 2rpx 8rpx rgba(255, 77, 79, 0.15);
}

.goods-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-width: 0;
}

.goods-name {
  font-size: 32rpx;
  font-weight: 600;
  color: #1d2129;
  margin-bottom: 12rpx;
  line-height: 1.4;
}

.goods-spec {
  font-size: 24rpx;
  color: #86909c;
  margin-bottom: 8rpx;
  line-height: 1.4;
}

.goods-desc {
  font-size: 24rpx;
  color: #4e5969;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin-bottom: 24rpx;
}

.merchant-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
  margin-bottom: 24rpx;
}

.merchant-meta-item,
.merchant-status {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44rpx;
  padding: 0 20rpx;
  border-radius: 999rpx;
  font-size: 22rpx;
  font-weight: 500;
}

.merchant-meta-item {
  background: #eef2ff;
  color: #3452d1;
}

.merchant-status-on {
  background: #edf9f0;
  color: #00b42a;
}

.merchant-status-off {
  background: #fff1f0;
  color: #ff4d4f;
}

.price-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.price-wrap {
  display: flex;
  align-items: baseline;
}

.price-symbol {
  font-size: 24rpx;
  color: #ff7d00;
}

.price-num {
  font-size: 40rpx;
  font-weight: bold;
  color: #ff7d00;
}

.cart-btn {
  min-width: 180rpx;
  height: 76rpx;
  line-height: 76rpx;
  background: #2f54eb;
  color: #ffffff;
  border-radius: 999rpx;
  font-size: 24rpx;
  border: none;
  flex-shrink: 0;
  transition: all 0.25s ease;
  box-shadow: 0 4rpx 12rpx rgba(47, 84, 235, 0.15);
}

.detail-btn {
  min-width: 180rpx;
  height: 76rpx;
  line-height: 76rpx;
  background: #eef2ff;
  color: #2f54eb;
  border-radius: 999rpx;
  font-size: 24rpx;
  border: none;
  flex-shrink: 0;
  transition: all 0.25s ease;
}

.cart-btn:active,
.detail-btn:active {
  transform: scale(0.96);
}

.cart-btn:disabled {
  background: #c9cdd4;
  transform: none;
  box-shadow: none;
}

.editor-mask {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.65);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32rpx;
  z-index: 999;
  animation: maskFade 0.3s ease forwards;
}

.editor-popup {
  width: 100%;
  max-height: calc(100vh - 120rpx);
  overflow-y: auto;
  background: #ffffff;
  border-radius: 36rpx;
  padding: 48rpx;
  box-shadow: 0 20rpx 60rpx rgba(0, 0, 0, 0.25);
  animation: popupScale 0.3s ease forwards;
}

.editor-popup::-webkit-scrollbar {
  width: 6rpx;
}

.editor-popup::-webkit-scrollbar-thumb {
  background: #e5e6eb;
  border-radius: 3rpx;
}

.editor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40rpx;
}

.editor-title {
  font-size: 40rpx;
  font-weight: 700;
  color: #1d2129;
}

.status-chip {
  padding: 12rpx 28rpx;
  border-radius: 999rpx;
  font-size: 22rpx;
  font-weight: 500;
}

.status-chip-on {
  background: #edf9f0;
  color: #00b42a;
}

.status-chip-off {
  background: #fff1f0;
  color: #ff4d4f;
}

.editor-preview {
  margin-bottom: 40rpx;
}

.editor-preview-image {
  width: 100%;
  height: 320rpx;
  border-radius: 28rpx;
  background: #f5f7fa;
  object-fit: cover;
}

.form-item {
  margin-bottom: 36rpx;
}

.form-row {
  display: flex;
  gap: 32rpx;
}

.half {
  flex: 1;
}

.form-label {
  display: block;
  font-size: 26rpx;
  color: #4e5969;
  margin-bottom: 20rpx;
  font-weight: 500;
}

.form-input,
.form-textarea {
  width: 100%;
  border: none;
  border-radius: 24rpx;
  background: #f6f7f9;
  color: #1d2129;
  font-size: 28rpx;
  transition: all 0.25s ease;
}

.form-input:focus,
.form-textarea:focus {
  background: #ffffff;
  box-shadow: 0 0 0 2rpx #2f54eb, 0 0 0 6rpx rgba(47, 84, 235, 0.1);
}

.form-input {
  height: 92rpx;
  padding: 0 32rpx;
}

.form-textarea {
  min-height: 240rpx;
  padding: 32rpx;
}

.image-actions {
  margin-top: 24rpx;
}

.action-row {
  display: flex;
  gap: 32rpx;
  margin-top: 48rpx;
}

.primary-btn,
.secondary-btn {
  flex: 1;
  height: 92rpx;
  line-height: 92rpx;
  border: none;
  border-radius: 46rpx;
  font-size: 28rpx;
  transition: all 0.25s ease;
  font-weight: 500;
}

.primary-btn {
  background: #2f54eb;
  color: #ffffff;
  box-shadow: 0 6rpx 16rpx rgba(47, 84, 235, 0.2);
}

.secondary-btn {
  background: #eef2ff;
  color: #2f54eb;
}

.primary-btn:active,
.secondary-btn:active {
  transform: scale(0.96);
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@keyframes maskFade {
  0% { opacity: 0; }
  100% { opacity: 1; }
}

@keyframes popupScale {
  0% { transform: scale(0.9); opacity: 0; }
  100% { transform: scale(1); opacity: 1; }
}
</style>