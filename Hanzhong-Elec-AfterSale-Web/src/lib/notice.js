import { reactive } from 'vue'

export const noticeStore = reactive({
  items: []
})

let noticeSeed = 0

export function pushNotice(message, tone = 'info', duration = 2600) {
  const id = ++noticeSeed
  noticeStore.items.push({ id, message, tone })
  window.setTimeout(() => {
    const index = noticeStore.items.findIndex(item => item.id === id)
    if (index >= 0) {
      noticeStore.items.splice(index, 1)
    }
  }, duration)
}
