<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="订单编号" prop="orderNo">
        <el-input v-model="queryParams.orderNo" placeholder="请输入订单编号" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="订单状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择订单状态" clearable>
          <el-option v-for="item in statusOptions" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="下单用户" prop="userName">
        <el-input v-model="queryParams.userName" placeholder="请输入下单用户" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="orderList">
      <el-table-column label="订单编号" align="center" prop="orderNo" width="160" />
      <el-table-column label="配件名称" align="center" prop="accessoryName" :show-overflow-tooltip="true" />
      <el-table-column label="下单用户" align="center" prop="userName" />
      <el-table-column label="数量" align="center" prop="quantity" width="80" />
      <el-table-column label="单价" align="center" prop="price" width="100" />
      <el-table-column label="总金额" align="center" prop="totalAmount" width="100" />
      <el-table-column label="状态" align="center" prop="status" width="100">
        <template slot-scope="scope">
          <el-tag :type="statusType(scope.row.status)">{{ statusLabel(scope.row.status) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="120">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-view" @click="handleDetail(scope.row)" v-hasPermi="['app:accessoryOrder:query']">详情</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />

    <el-dialog title="配件订单详情" :visible.sync="open" width="720px" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="订单编号">{{ form.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">{{ statusLabel(form.status) }}</el-descriptions-item>
        <el-descriptions-item label="配件名称">{{ form.accessoryName }}</el-descriptions-item>
        <el-descriptions-item label="下单用户">{{ form.userName }}</el-descriptions-item>
        <el-descriptions-item label="数量">{{ form.quantity }}</el-descriptions-item>
        <el-descriptions-item label="单价">{{ form.price }}</el-descriptions-item>
        <el-descriptions-item label="总金额">{{ form.totalAmount }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ form.receiverPhone }}</el-descriptions-item>
        <el-descriptions-item label="收货人">{{ form.receiverName }}</el-descriptions-item>
        <el-descriptions-item label="收货地址">{{ form.receiverAddress }}</el-descriptions-item>
        <el-descriptions-item label="订单备注" :span="2">{{ form.orderRemark || '-' }}</el-descriptions-item>
      </el-descriptions>
      <div slot="footer" class="dialog-footer">
        <el-button @click="open = false">关 闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { getAccessoryOrder, listAccessoryOrder } from '@/api/app/accessoryOrder'

export default {
  name: 'AppAccessoryOrder',
  data() {
    return {
      loading: false,
      showSearch: true,
      total: 0,
      open: false,
      orderList: [],
      form: {},
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        orderNo: undefined,
        userName: undefined,
        status: undefined
      },
      statusOptions: [
        { label: '待处理', value: '0' },
        { label: '已发货', value: '1' },
        { label: '已完成', value: '2' },
        { label: '已取消', value: '3' }
      ]
    }
  },
  created() {
    this.getList()
  },
  methods: {
    // 查询配件订单列表。
    getList() {
      this.loading = true
      listAccessoryOrder(this.queryParams).then(response => {
        this.orderList = response.rows
        this.total = response.total
        this.loading = false
      }).catch(() => {
        this.loading = false
      })
    },
    // 状态文案。
    statusLabel(status) {
      return (this.statusOptions.find(item => item.value === status) || {}).label || '未知'
    },
    // 状态颜色。
    statusType(status) {
      if (status === '2') {
        return 'success'
      }
      if (status === '3') {
        return 'danger'
      }
      if (status === '1') {
        return 'warning'
      }
      return 'info'
    },
    // 搜索。
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    // 重置搜索。
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    },
    // 查看详情。
    handleDetail(row) {
      getAccessoryOrder(row.accessoryOrderId).then(response => {
        this.form = response.data
        this.open = true
      })
    }
  }
}
</script>
