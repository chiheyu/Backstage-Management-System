import { reactive } from 'vue'

export const noticeStore = reactive({
  items: []
})

let noticeSeed = 0
let lastNotice = {
  message: '',
  tone: '',
  time: 0
}

export function pushNotice(message, tone = 'info', duration = 2600) {
  const normalizedMessage = String(message || '').trim()
  const now = Date.now()

  if (
    normalizedMessage &&
    normalizedMessage === lastNotice.message &&
    tone === lastNotice.tone &&
    now - lastNotice.time < 1600
  ) {
    return
  }

  lastNotice = {
    message: normalizedMessage,
    tone,
    time: now
  }

  const id = ++noticeSeed
  noticeStore.items.push({ id, message: normalizedMessage, tone })
  window.setTimeout(() => {
    const index = noticeStore.items.findIndex(item => item.id === id)
    if (index >= 0) {
      noticeStore.items.splice(index, 1)
    }
  }, duration)
}
