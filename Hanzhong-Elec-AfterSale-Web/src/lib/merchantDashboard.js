import { merchantApi } from './api'

export const merchantFeatureSupport = Object.freeze({
  afterSales: true,
  accessoryOrders: true,
  accessoryCatalog: true
})

function toTotal(payload) {
  return Number(payload?.total || 0)
}

export async function fetchMerchantDashboardSummary() {
  const [
    merchant,
    pendingAfterSalesPayload,
    acceptedAfterSalesPayload,
    repairingAfterSalesPayload,
    completedAfterSalesPayload,
    pendingAccessoryOrdersPayload,
    shippedAccessoryOrdersPayload,
    completedAccessoryOrdersPayload,
    canceledAccessoryOrdersPayload
  ] = await Promise.all([
    merchantApi.currentInfo(),
    merchantApi.listPendingOrders({ pageNum: 1, pageSize: 1 }),
    merchantApi.listOrders({ status: '1', pageNum: 1, pageSize: 1 }),
    merchantApi.listOrders({ status: '2', pageNum: 1, pageSize: 1 }),
    merchantApi.listOrders({ status: '3', pageNum: 1, pageSize: 1 }),
    merchantApi.listPendingAccessoryOrders({ pageNum: 1, pageSize: 1 }),
    merchantApi.listAccessoryOrders({ status: '1', pageNum: 1, pageSize: 1 }),
    merchantApi.listAccessoryOrders({ status: '2', pageNum: 1, pageSize: 1 }),
    merchantApi.listAccessoryOrders({ status: '3', pageNum: 1, pageSize: 1 })
  ])

  const acceptedAfterSales = toTotal(acceptedAfterSalesPayload)
  const repairingAfterSales = toTotal(repairingAfterSalesPayload)
  const completedAfterSales = toTotal(completedAfterSalesPayload)
  const pendingAccessoryOrders = toTotal(pendingAccessoryOrdersPayload)
  const shippedAccessoryOrders = toTotal(shippedAccessoryOrdersPayload)
  const completedAccessoryOrders = toTotal(completedAccessoryOrdersPayload)
  const canceledAccessoryOrders = toTotal(canceledAccessoryOrdersPayload)

  return {
    merchant,
    featureSupport: merchantFeatureSupport,
    counts: {
      pendingAfterSales: toTotal(pendingAfterSalesPayload),
      acceptedAfterSales,
      repairingAfterSales,
      activeAfterSales: acceptedAfterSales + repairingAfterSales,
      completedAfterSales,
      pendingAccessoryOrders,
      shippedAccessoryOrders,
      activeAccessoryOrders: pendingAccessoryOrders + shippedAccessoryOrders,
      completedAccessoryOrders,
      canceledAccessoryOrders
    }
  }
}
