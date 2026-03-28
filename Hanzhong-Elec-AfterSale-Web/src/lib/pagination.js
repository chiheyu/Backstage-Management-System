function defaultNormalize(item) {
  return item
}

function dedupeRows(rows, dedupeKey) {
  if (!dedupeKey) {
    return rows
  }

  return Array.from(
    new Map(
      rows.map(item => [String(item?.[dedupeKey] ?? ''), item])
    ).values()
  )
}

export async function fetchAllPagedResult(fetchPage, options = {}) {
  const {
    params = {},
    pageSize = 50,
    normalize = defaultNormalize,
    dedupeKey = ''
  } = options

  let pageNum = 1
  let total = 0
  const rows = []

  while (true) {
    const payload = await fetchPage({
      ...params,
      pageNum,
      pageSize
    })
    const pageRows = Array.isArray(payload?.rows) ? payload.rows : []

    rows.push(...pageRows.map(normalize))
    total = Number(payload?.total || total || 0)

    if (!pageRows.length || pageRows.length < pageSize || (total > 0 && rows.length >= total)) {
      break
    }

    pageNum += 1
  }

  return {
    total,
    rows: dedupeRows(rows, dedupeKey)
  }
}

export async function fetchAllPagedRows(fetchPage, options = {}) {
  const result = await fetchAllPagedResult(fetchPage, options)
  return result.rows
}
