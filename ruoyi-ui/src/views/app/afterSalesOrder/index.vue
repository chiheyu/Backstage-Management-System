<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="订单编号" prop="orderNo">
        <el-input v-model="queryParams.orderNo" placeholder="请输入订单编号" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="产品类型" prop="productType">
        <el-input v-model="queryParams.productType" placeholder="请输入产品类型" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="用户" prop="userName">
        <el-input v-model="queryParams.userName" placeholder="请输入用户昵称" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="商家" prop="merchantName">
        <el-input v-model="queryParams.merchantName" placeholder="请输入商家名称" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="订单状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择订单状态" clearable>
          <el-option v-for="item in statusOptions" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="创建时间">
        <el-date-picker v-model="dateRange" type="daterange" value-format="yyyy-MM-dd" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" />
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
      <el-table-column label="用户" align="center" prop="userName" />
      <el-table-column label="商家" align="center" prop="merchantName" />
      <el-table-column label="产品类型" align="center" prop="productType" />
      <el-table-column label="联系电话" align="center" prop="contactPhone" width="120" />
      <el-table-column label="状态" align="center" prop="status" width="120">
        <template slot-scope="scope">
          <el-tag :type="statusType(scope.row.status)">{{ statusLabel(scope.row.status) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="220" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-view" @click="handleDetail(scope.row)" v-hasPermi="['app:afterSalesOrder:query']">详情</el-button>
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleStatus(scope.row)" v-hasPermi="['app:afterSalesOrder:edit']">处理</el-button>
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

    <el-dialog :title="title" :visible.sync="open" width="760px" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="订单编号">{{ form.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">{{ statusLabel(form.status) }}</el-descriptions-item>
        <el-descriptions-item label="用户">{{ form.userName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="商家">{{ form.merchantName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="产品类型">{{ form.productType }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ form.contactPhone }}</el-descriptions-item>
        <el-descriptions-item label="联系人">{{ form.contactName }}</el-descriptions-item>
        <el-descriptions-item label="服务地址">{{ form.address }}</el-descriptions-item>
        <el-descriptions-item label="故障描述" :span="2">{{ form.faultDesc }}</el-descriptions-item>
        <el-descriptions-item label="处理备注" :span="2">{{ form.serviceRemark || '-' }}</el-descriptions-item>
      </el-descriptions>
      <div slot="footer" class="dialog-footer">
        <el-button @click="open = false">关 闭</el-button>
      </div>
    </el-dialog>

    <el-dialog title="处理售后订单" :visible.sync="statusOpen" width="600px" append-to-body>
      <el-form ref="statusForm" :model="statusForm" label-width="90px">
        <el-form-item label="订单编号">
          <el-input v-model="statusForm.orderNo" disabled />
        </el-form-item>
        <el-form-item label="目标状态">
          <el-select v-model="statusForm.status" placeholder="请选择目标状态">
            <el-option v-for="item in statusOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="处理备注">
          <el-input v-model="statusForm.serviceRemark" type="textarea" :rows="4" placeholder="请输入处理备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitStatus">确 定</el-button>
        <el-button @click="statusOpen = false">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { getAfterSalesOrder, listAfterSalesOrder, updateAfterSalesOrderStatus } from '@/api/app/afterSalesOrder'

export default {
  name: 'AppAfterSalesOrder',
  data() {
    return {
      loading: false,
      showSearch: true,
      total: 0,
      open: false,
      statusOpen: false,
      title: '',
      dateRange: [],
      orderList: [],
      form: {},
      statusForm: {
        orderId: undefined,
        orderNo: undefined,
        status: undefined,
        serviceRemark: undefined
      },
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        orderNo: undefined,
        productType: undefined,
        userName: undefined,
        merchantName: undefined,
        status: undefined
      },
      statusOptions: [
        { label: '待接单', value: '0' },
        { label: '已接单', value: '1' },
        { label: '维修中', value: '2' },
        { label: '已完成', value: '3' },
        { label: '已取消', value: '4' }
      ]
    }
  },
  created() {
    this.getList()
  },
  methods: {
    // 查询售后订单列表。
    getList() {
      this.loading = true
      listAfterSalesOrder(this.addDateRange(this.queryParams, this.dateRange)).then(response => {
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
    // 状态标签颜色。
    statusType(status) {
      if (status === '3') {
        return 'success'
      }
      if (status === '4') {
        return 'danger'
      }
      if (status === '2') {
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
      this.dateRange = []
      this.resetForm('queryForm')
      this.handleQuery()
    },
    // 查看详情。
    handleDetail(row) {
      getAfterSalesOrder(row.orderId).then(response => {
        this.form = response.data
        this.title = '售后订单详情'
        this.open = true
      })
    },
    // 打开状态处理弹窗。
    handleStatus(row) {
      this.statusForm = {
        orderId: row.orderId,
        orderNo: row.orderNo,
        status: row.status,
        serviceRemark: row.serviceRemark
      }
      this.statusOpen = true
    },
    // 提交状态更新。
    submitStatus() {
      updateAfterSalesOrderStatus({
        orderId: this.statusForm.orderId,
        status: this.statusForm.status,
        serviceRemark: this.statusForm.serviceRemark
      }).then(() => {
        this.$modal.msgSuccess('处理成功')
        this.statusOpen = false
        this.getList()
      })
    }
  }
}
</script>
