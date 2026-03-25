## bucket.nim -- Bucket operations.
{.experimental: "strict_funcs".}
import basis/code/choice, client

proc create_bucket*(config: S3Config, http_fn: HttpFn, name: string
                   ): Choice[bool] =
  let url = config.endpoint & "/" & name
  let r = http_fn("PUT", url, @[], "")
  if r.is_bad: return bad[bool](r.err)
  good(true)

proc delete_bucket*(config: S3Config, http_fn: HttpFn, name: string
                   ): Choice[bool] =
  let url = config.endpoint & "/" & name
  let r = http_fn("DELETE", url, @[], "")
  if r.is_bad: return bad[bool](r.err)
  good(true)
