import { merchantApi } from './api'

export const merchantFeatureSupport = Object.freeze({
  afterSales: true,
  accessoryOrders: false,
  accessoryCatalog: false
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
    completedAfterSalesPayload
  ] = await Promise.all([
    merchantApi.currentInfo(),
    merchantApi.listPendingOrders({ pageNum: 1, pageSize: 1 }),
    merchantApi.listOrders({ status: '1', pageNum: 1, pageSize: 1 }),
    merchantApi.listOrders({ status: '2', pageNum: 1, pageSize: 1 }),
    merchantApi.listOrders({ status: '3', pageNum: 1, pageSize: 1 })
  ])

  const acceptedAfterSales = toTotal(acceptedAfterSalesPayload)
  const repairingAfterSales = toTotal(repairingAfterSalesPayload)
  const completedAfterSales = toTotal(completedAfterSalesPayload)

  return {
    merchant,
    featureSupport: merchantFeatureSupport,
    counts: {
      pendingAfterSales: toTotal(pendingAfterSalesPayload),
      acceptedAfterSales,
      repairingAfterSales,
      activeAfterSales: acceptedAfterSales + repairingAfterSales,
      completedAfterSales
    }
  }
}
