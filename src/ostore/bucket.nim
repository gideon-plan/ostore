## bucket.nim -- Bucket operations.
{.experimental: "strict_funcs".}
import lattice, client

proc create_bucket*(config: S3Config, http_fn: HttpFn, name: string
                   ): Result[void, BridgeError] =
  let url = config.endpoint & "/" & name
  let r = http_fn("PUT", url, @[], "")
  if r.is_bad: return Result[void, BridgeError].bad(r.err)
  Result[void, BridgeError](ok: true)

proc delete_bucket*(config: S3Config, http_fn: HttpFn, name: string
                   ): Result[void, BridgeError] =
  let url = config.endpoint & "/" & name
  let r = http_fn("DELETE", url, @[], "")
  if r.is_bad: return Result[void, BridgeError].bad(r.err)
  Result[void, BridgeError](ok: true)
