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
        <view class="goods-img-wrap" @tap="goDetail(item.id)">
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
          <view class="price-bar">
            <view class="price-wrap">
              <text class="price-symbol">¥</text>
              <text class="price-num">{{ item.price }}</text>
            </view>
            <button
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

    <view class="empty" v-else>
      <uni-icons type="shop" size="80" color="#e5e5e5"></uni-icons>
      <text class="empty-text">暂无相关配件</text>
      <text class="empty-subtext" v-if="searchKey">换个关键词试试吧</text>
      <button class="empty-refresh-btn" @tap="resetSearch" v-if="searchKey || activeCate !== allCategoryId">
        重置筛选
      </button>
    </view>
  </view>
</template>

<script>
import { getAccessoryList, normalizeAccessory } from '@/api/accessory'
import { getCartList, setCartList } from '@/utils/cart'

const ALL_CATEGORY_ID = 'all'
const PAGE_SIZE = 50

export default {
  data() {
    return {
      allCategoryId: ALL_CATEGORY_ID,
      searchKey: '',
      activeCate: ALL_CATEGORY_ID,
      categoryList: [{ id: ALL_CATEGORY_ID, name: '全部' }],
      goodsList: [],
      filterGoods: [],
      defaultImage: '/static/images/accessory/default-accessory.png',
      searchTimer: null,
      loading: false
    }
  },
  onLoad() {
    this.loadGoodsList()
  },
  onShow() {
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
        const res = await getAccessoryList({
          pageNum,
          pageSize: PAGE_SIZE
        })
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

.cart-btn:disabled {
  background: var(--text-gray);
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
