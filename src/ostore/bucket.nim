## bucket.nim -- Bucket operations.
{.experimental: "strict_funcs".}

import basis/code/choice
import httpc/curl_client
import client

proc create_bucket*(c: S3Client, name: string): Choice[bool] =
  let url = c.config.endpoint & "/" & name
  let r = c.http.request(HttpRequest(url: url, meth: hmPut, follow_redirects: false))
  if r.is_bad: return bad[bool](r.err)
  good(true)

proc delete_bucket*(c: S3Client, name: string): Choice[bool] =
  let url = c.config.endpoint & "/" & name
  let r = c.http.request(HttpRequest(url: url, meth: hmDelete, follow_redirects: false))
  if r.is_bad: return bad[bool](r.err)
  good(true)
