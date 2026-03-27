<template>
  <view class="container">
    <view class="search-wrap">
      <view class="search-input-wrap">
        <uni-icons type="search" size="24" color="#999" class="search-icon"></uni-icons>
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
    </view>

    <view v-if="isMerchant" class="merchant-hero">
      <view class="merchant-hero-main">
        <view class="merchant-hero-heading">
          <text class="merchant-hero-title">商品管理</text>
          <view class="merchant-add-btn" @tap="openCreateGoods">
            <uni-icons type="plus" size="22" color="#1236b6"></uni-icons>
          </view>
        </view>
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

    <view class="loading-wrap" v-if="loading">
      <uni-icons type="spinner-cycle" size="30" color="#2f54eb" class="loading-icon"></uni-icons>
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
            <view class="action-group action-group-right">
              <button
                class="detail-btn"
                @tap.stop="handleDetailAction(item)"
              >
                查看详情
              </button>
              <button
                v-if="isMerchant"
                class="icon-btn delete-icon-btn"
                @tap.stop="confirmDeleteGoods(item)"
              >
                <uni-icons type="trash" size="20" color="#ff4d4f"></uni-icons>
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
    </view>

    <view class="empty" v-else>
      <uni-icons type="shop" size="80" color="#e5e5e5"></uni-icons>
      <text class="empty-text">暂无相关配件</text>
      <text class="empty-subtext" v-if="searchKey">换个关键词试试吧</text>
      <button class="empty-refresh-btn" @tap="resetSearch" v-if="searchKey || activeCate !== allCategoryId">
        重置筛选
      </button>
    </view>

    <view v-if="isMerchant && showMerchantEditor" class="editor-mask" @tap="closeMerchantEditor">
      <view class="editor-popup" @tap.stop>
        <view class="editor-header">
          <text class="editor-title">{{ merchantEditorTitle }}</text>
          <text :class="['status-chip', merchantForm.status === '0' ? 'status-chip-on' : 'status-chip-off']">
            {{ merchantForm.status === '0' ? '上架中' : '已下架' }}
          </text>
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
          <button class="secondary-btn" @tap="toggleShelfStatus">
            {{ merchantForm.status === '0' ? '下架商品' : '重新上架' }}
          </button>
          <button class="primary-btn" @tap="saveMerchantGoods" :disabled="isSavingGoods">
            {{ isSavingGoods ? '保存中...' : '保存修改' }}
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
  createMerchantAccessory,
  deleteMerchantAccessory,
  getMerchantAccessoryList,
  getMerchantAccessoryDetail,
  updateMerchantAccessory,
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
      isSavingGoods: false,
      isUploadingImage: false,
      merchantForm: {
        accessoryId: '',
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
    merchantEditorTitle() {
      return this.merchantForm.accessoryId ? '商品编辑' : '新增商品'
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
    },
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
        categories.map((item) => ({
          id: item,
          name: item
        }))
      )
    },
    async fetchAllAccessories() {
      let pageNum = 1
      let total = 0
      let finished = false
      const list = []

      while (!finished) {
        const res = await (this.isMerchant ? getMerchantAccessoryList({
          pageNum,
          pageSize: PAGE_SIZE
        }) : getAccessoryList({
          pageNum,
          pageSize: PAGE_SIZE
        }))
        const rows = Array.isArray(res.rows) ? res.rows : []
        total = Number(res.total) || 0
        list.push(...rows)

        if (!rows.length || rows.length < PAGE_SIZE) {
          finished = true
        } else if (total > 0 && list.length >= total) {
          finished = true
        } else {
          pageNum += 1
        }
      }

      return list
    },
    async loadGoodsList() {
      if (this.loading) {
        return
      }

      this.loading = true
      uni.showLoading({
        title: '加载中',
        mask: true
      })

      try {
        const rows = await this.fetchAllAccessories()
        this.goodsList = rows
          .map((item) => normalizeAccessory(item))
          .filter((item) => !!item.id)
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
        const matchKeyword =
          !keyword ||
          [item.name, item.spec, item.desc]
            .filter(Boolean)
            .some((field) => String(field).toLowerCase().includes(keyword))

        return matchCategory && matchKeyword
      })
    },
    handleInput(e) {
      this.searchKey = (e.detail.value || '').trim()
      clearTimeout(this.searchTimer)
      this.searchTimer = setTimeout(() => {
        this.applyFilters()
      }, 300)
    },
    search() {
      this.applyFilters()
    },
    resetSearch() {
      this.searchKey = ''
      this.activeCate = ALL_CATEGORY_ID
      this.applyFilters()
      uni.showToast({
        title: '已重置筛选',
        icon: 'success'
      })
    },
    changeCate(e) {
      this.activeCate = e.currentTarget.dataset.id || ALL_CATEGORY_ID
      this.applyFilters()
    },
    goDetail(id) {
      if (!id) {
        return
      }

      uni.navigateTo({
        url: `/pages/accessoryDetail/index?id=${id}`,
        fail: () => {
          uni.showToast({
            title: '页面跳转失败',
            icon: 'none'
          })
        }
      })
    },
    handleGoodsClick(item) {
      if (!item || !item.id) {
        return
      }
      if (this.isMerchant) {
        this.openMerchantEditor(item.id)
        return
      }
      this.goDetail(item.id)
    },
    handleDetailAction(item) {
      if (!item || !item.id) {
        return
      }

      if (this.isMerchant) {
        this.openMerchantEditor(item.id)
        return
      }

      this.goDetail(item.id)
    },
    async openMerchantEditor(id) {
      try {
        const res = await getMerchantAccessoryDetail(id)
        const detail = normalizeAccessory(res.data || {})
        if (!detail.id) {
          uni.showToast({
            title: '未找到商品信息',
            icon: 'none'
          })
          return
        }

        this.merchantForm = {
          accessoryId: detail.accessoryId || detail.id,
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
        uni.showToast({
          title: (error && error.msg) || '加载商品失败',
          icon: 'none'
        })
      }
    },
    openCreateGoods() {
      if (!this.isMerchant) {
        return
      }

      this.merchantForm = {
        accessoryId: '',
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
    closeMerchantEditor() {
      this.showMerchantEditor = false
    },
    async chooseMerchantImage() {
      if (!this.isMerchant || this.isUploadingImage) {
        return
      }

      uni.chooseImage({
        count: 1,
        sizeType: ['compressed'],
        sourceType: ['album', 'camera'],
        success: async ({ tempFilePaths = [] }) => {
          const filePath = tempFilePaths[0]
          if (!filePath) {
            return
          }

          this.isUploadingImage = true
          try {
            const uploadRes = await uploadMerchantAccessoryImage(filePath)
            this.merchantForm.coverImage = uploadRes.url || this.merchantForm.coverImage
            uni.showToast({
              title: '图片上传成功',
              icon: 'success'
            })
          } catch (error) {
            uni.showToast({
              title: (error && error.msg) || '图片上传失败',
              icon: 'none'
            })
          } finally {
            this.isUploadingImage = false
          }
        }
      })
    },
    validateMerchantForm() {
      if (!this.merchantForm.accessoryName.trim()) {
        return '请输入商品名称'
      }
      if (!this.merchantForm.categoryName.trim()) {
        return '请输入商品类别'
      }
      if (!this.merchantForm.price || Number(this.merchantForm.price) <= 0) {
        return '请输入有效售价'
      }
      if (this.merchantForm.stock === '' || Number(this.merchantForm.stock) < 0) {
        return '请输入有效库存'
      }
      return ''
    },
    async saveMerchantGoods() {
      if (!this.isMerchant || this.isSavingGoods) {
        return
      }

      const validateMessage = this.validateMerchantForm()
      if (validateMessage) {
        uni.showToast({
          title: validateMessage,
          icon: 'none'
        })
        return
      }

      this.isSavingGoods = true
      try {
        const payload = {
          accessoryName: this.merchantForm.accessoryName.trim(),
          categoryName: this.merchantForm.categoryName.trim(),
          accessoryDesc: this.merchantForm.accessoryDesc.trim(),
          coverImage: this.merchantForm.coverImage.trim(),
          price: Number(this.merchantForm.price),
          stock: Number(this.merchantForm.stock),
          status: this.merchantForm.status
        }

        if (this.merchantForm.accessoryId) {
          await updateMerchantAccessory({
            accessoryId: this.merchantForm.accessoryId,
            ...payload
          })
        } else {
          await createMerchantAccessory(payload)
        }
        uni.showToast({
          title: this.merchantForm.accessoryId ? '保存成功' : '新增成功',
          icon: 'success'
        })
        this.showMerchantEditor = false
        await this.loadGoodsList()
      } catch (error) {
        uni.showToast({
          title: (error && error.msg) || '保存失败',
          icon: 'none'
        })
      } finally {
        this.isSavingGoods = false
      }
    },
    toggleShelfStatus() {
      if (!this.isMerchant) {
        return
      }
      this.merchantForm.status = this.merchantForm.status === '0' ? '1' : '0'
    },
    confirmDeleteGoods(item) {
      if (!this.isMerchant || !item || !item.id) {
        return
      }

      uni.showModal({
        title: '是否确认删除',
        content: `删除后将无法恢复，是否确认删除“${item.name}”？`,
        confirmColor: '#ff4d4f',
        success: async (res) => {
          if (!res.confirm) {
            return
          }

          try {
            await deleteMerchantAccessory(item.id)
            uni.showToast({
              title: '删除成功',
              icon: 'success'
            })
            if (this.showMerchantEditor && String(this.merchantForm.accessoryId) === String(item.id)) {
              this.closeMerchantEditor()
            }
            await this.loadGoodsList()
          } catch (error) {
            uni.showToast({
              title: (error && error.msg) || '删除失败',
              icon: 'none'
            })
          }
        }
      })
    },
    addCart(e) {
      const item = e.currentTarget.dataset.goods
      if (!item || !item.id) {
        return
      }

      if (item.stock <= 0) {
        uni.showToast({
          title: '商品已售罄',
          icon: 'none'
        })
        return
      }

      const cartList = getCartList()
      const existItem = cartList.find((cartItem) => cartItem.id === item.id)
      if (existItem) {
        if (existItem.count >= item.stock) {
          uni.showToast({
            title: '已达最大库存',
            icon: 'none'
          })
          return
        }
        existItem.count += 1
      } else {
        cartList.push({
          ...item,
          count: 1
        })
      }

      setCartList(cartList)
      uni.showToast({
        title: '加入购物车成功',
        icon: 'success',
        duration: 1500,
        mask: true
      })
    },
    imgError(id) {
      const index = this.goodsList.findIndex((item) => item.id === id)
      if (index > -1) {
        this.goodsList[index].image = this.defaultImage
        this.applyFilters()
      }
    }
  }
}
</script>

<style scoped>
:root {
  --primary-color: #2f54eb;
  --price-color: #ff7300;
  --stock-color: #ff4d4f;
  --text-color: #333;
  --text-gray: #999;
  --text-light: #666;
  --bg-color: #f8f8f8;
  --white: #fff;
  --border-color: #eee;
  --radius-sm: 8rpx;
  --radius-md: 12rpx;
  --radius-full: 999rpx;
  --shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
}

.container {
  min-height: 100vh;
  background: var(--bg-color);
  padding-bottom: 20rpx;
  overflow-x: hidden;
  box-sizing: border-box;
}

.search-wrap {
  display: flex;
  padding: 20rpx;
  background: var(--white);
  overflow: hidden;
  box-sizing: border-box;
}

.merchant-hero {
  margin: 20rpx;
  padding: 28rpx;
  border-radius: 20rpx;
  background: linear-gradient(135deg, #1236b6 0%, #2f54eb 55%, #5d7cff 100%);
  color: #fff;
  box-shadow: 0 10rpx 24rpx rgba(47, 84, 235, 0.18);
}

.merchant-hero-title {
  display: block;
  font-size: 38rpx;
  font-weight: 700;
  margin-bottom: 10rpx;
}

.merchant-hero-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20rpx;
}

.merchant-add-btn {
  width: 68rpx;
  height: 68rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.92);
  box-shadow: 0 8rpx 18rpx rgba(18, 54, 182, 0.18);
  flex-shrink: 0;
}

.merchant-hero-desc {
  display: block;
  font-size: 24rpx;
  line-height: 1.7;
  opacity: 0.9;
}

.merchant-summary {
  display: flex;
  gap: 16rpx;
  margin-top: 24rpx;
}

.merchant-stat {
  flex: 1;
  padding: 22rpx 18rpx;
  border-radius: 18rpx;
  background: rgba(255, 255, 255, 0.14);
  backdrop-filter: blur(10rpx);
}

.merchant-stat-label {
  display: block;
  font-size: 22rpx;
  opacity: 0.85;
  margin-bottom: 8rpx;
}

.merchant-stat-value {
  display: block;
  font-size: 34rpx;
  font-weight: 700;
}

.search-input-wrap {
  flex: 1;
  position: relative;
  min-width: 0;
  box-sizing: border-box;
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
  box-sizing: border-box;
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
  flex-shrink: 0;
  box-sizing: border-box;
}

.search-btn::after,
.cart-btn::after,
.empty-refresh-btn::after {
  border: none;
}

.cate-wrap {
  background: var(--white);
  padding: 10rpx 20rpx;
  overflow: hidden;
  box-sizing: border-box;
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

.loading-wrap,
.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 140rpx 40rpx;
  text-align: center;
}

.loading-icon {
  animation: spin 1s linear infinite;
}

.loading-text,
.empty-text {
  font-size: 30rpx;
  color: var(--text-gray);
  margin-top: 24rpx;
}

.empty-subtext {
  font-size: 26rpx;
  color: var(--text-light);
  margin-top: 12rpx;
}

.empty-refresh-btn {
  margin-top: 32rpx;
  padding: 16rpx 40rpx;
  background: var(--white);
  color: var(--primary-color);
  border: 1px solid var(--primary-color);
  border-radius: var(--radius-full);
  font-size: 26rpx;
}

.goods-list {
  padding: 20rpx;
  overflow-x: hidden;
  box-sizing: border-box;
}

.goods-item {
  display: flex;
  background: var(--white);
  border-radius: var(--radius-md);
  padding: 24rpx;
  margin-bottom: 20rpx;
  box-shadow: var(--shadow);
  overflow: hidden;
  box-sizing: border-box;
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
  min-width: 0;
}

.goods-name {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--text-color);
  margin-bottom: 10rpx;
  line-height: 1.3;
}

.goods-spec {
  font-size: 24rpx;
  color: var(--text-gray);
  margin-bottom: 8rpx;
  line-height: 1.4;
}

.goods-desc {
  font-size: 24rpx;
  color: var(--text-light);
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin-bottom: 20rpx;
}

.merchant-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 10rpx;
  margin-bottom: 20rpx;
}

.merchant-meta-item,
.merchant-status {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 40rpx;
  padding: 0 16rpx;
  border-radius: 999rpx;
  font-size: 22rpx;
}

.merchant-meta-item {
  background: #eef2ff;
  color: #3452d1;
}

.merchant-status-on {
  background: #edf9f0;
  color: #18a058;
}

.merchant-status-off {
  background: #fff1f0;
  color: #d4380d;
}

.price-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20rpx;
}

.price-wrap {
  display: flex;
  align-items: baseline;
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

.cart-btn {
  min-width: 170rpx;
  height: 64rpx;
  line-height: 64rpx;
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  font-size: 24rpx;
  border: none;
  flex-shrink: 0;
  box-sizing: border-box;
}

.detail-btn {
  min-width: 170rpx;
  height: 64rpx;
  line-height: 64rpx;
  background: #eef2ff;
  color: var(--primary-color);
  border-radius: var(--radius-full);
  font-size: 24rpx;
  border: none;
  flex-shrink: 0;
  box-sizing: border-box;
}

.detail-btn::after {
  border: none;
}

.action-group {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 14rpx;
  flex-shrink: 0;
}

.action-group-right {
  margin-left: auto;
}

.icon-btn {
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: 999rpx;
  padding: 0;
  flex-shrink: 0;
  box-sizing: border-box;
}

.icon-btn::after {
  border: none;
}

.delete-icon-btn {
  background: #fff1f0;
}

.cart-btn:disabled {
  background: var(--text-gray);
}

.editor-mask {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.42);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24rpx;
  z-index: 999;
  box-sizing: border-box;
}

.editor-popup {
  width: 100%;
  max-height: calc(100vh - 80rpx);
  overflow-y: auto;
  background: var(--white);
  border-radius: 24rpx;
  padding: 30rpx;
  box-sizing: border-box;
  box-shadow: 0 20rpx 40rpx rgba(0, 0, 0, 0.18);
}

.editor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}

.editor-title {
  font-size: 34rpx;
  font-weight: 700;
  color: var(--text-color);
}

.status-chip {
  padding: 8rpx 18rpx;
  border-radius: 999rpx;
  font-size: 22rpx;
}

.status-chip-on {
  background: #edf9f0;
  color: #18a058;
}

.status-chip-off {
  background: #fff1f0;
  color: #d4380d;
}

.editor-preview {
  margin-bottom: 24rpx;
}

.editor-preview-image {
  width: 100%;
  height: 280rpx;
  border-radius: 18rpx;
  background: #f5f5f5;
}

.form-item {
  margin-bottom: 24rpx;
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
  font-size: 26rpx;
  color: var(--text-light);
  margin-bottom: 12rpx;
}

.form-input,
.form-textarea {
  width: 100%;
  border: 1px solid var(--border-color);
  border-radius: 12rpx;
  box-sizing: border-box;
  background: #fafafa;
  color: var(--text-color);
  font-size: 28rpx;
}

.form-input {
  height: 84rpx;
  padding: 0 20rpx;
}

.form-textarea {
  min-height: 180rpx;
  padding: 20rpx;
}

.image-actions {
  margin-top: 16rpx;
}

.action-row {
  display: flex;
  gap: 20rpx;
  margin-top: 32rpx;
}

.primary-btn,
.secondary-btn {
  flex: 1;
  height: 84rpx;
  line-height: 84rpx;
  border: none;
  border-radius: 42rpx;
  font-size: 28rpx;
}

.primary-btn {
  background: var(--primary-color);
  color: var(--white);
}

.secondary-btn {
  background: #eef2ff;
  color: var(--primary-color);
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }

  100% {
    transform: rotate(360deg);
  }
}
</style>
