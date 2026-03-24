## client.nim -- HTTP client for S3 API.
{.experimental: "strict_funcs".}

import lattice

type
  S3Config* = object
    endpoint*: string    ## e.g. "http://localhost:9000"
    region*: string
    access_key*: string
    secret_key*: string

  S3Object* = object
    key*: string
    size*: int
    etag*: string

  HttpFn* = proc(method_name, url: string, headers: seq[(string, string)],
                 body: string): Result[tuple[status: int, body: string], BridgeError] {.raises: [].}

proc default_config*(endpoint: string = "http://localhost:9000",
                     access_key: string = "", secret_key: string = ""): S3Config =
  S3Config(endpoint: endpoint, region: "us-east-1",
           access_key: access_key, secret_key: secret_key)

proc put_object*(config: S3Config, http_fn: HttpFn, bucket, key, data: string
                ): Result[void, BridgeError] =
  let url = config.endpoint & "/" & bucket & "/" & key
  let r = http_fn("PUT", url, @[], data)
  if r.is_bad: return Result[void, BridgeError].bad(r.err)
  if r.val.status >= 400:
    return Result[void, BridgeError].bad(BridgeError(msg: "PUT failed: " & $r.val.status))
  Result[void, BridgeError](ok: true)

proc get_object*(config: S3Config, http_fn: HttpFn, bucket, key: string
                ): Result[string, BridgeError] =
  let url = config.endpoint & "/" & bucket & "/" & key
  let r = http_fn("GET", url, @[], "")
  if r.is_bad: return Result[string, BridgeError].bad(r.err)
  if r.val.status >= 400:
    return Result[string, BridgeError].bad(BridgeError(msg: "GET failed: " & $r.val.status))
  Result[string, BridgeError].good(r.val.body)

proc delete_object*(config: S3Config, http_fn: HttpFn, bucket, key: string
                   ): Result[void, BridgeError] =
  let url = config.endpoint & "/" & bucket & "/" & key
  let r = http_fn("DELETE", url, @[], "")
  if r.is_bad: return Result[void, BridgeError].bad(r.err)
  Result[void, BridgeError](ok: true)

proc head_object*(config: S3Config, http_fn: HttpFn, bucket, key: string
                 ): Result[bool, BridgeError] =
  let url = config.endpoint & "/" & bucket & "/" & key
  let r = http_fn("HEAD", url, @[], "")
  if r.is_bad: return Result[bool, BridgeError].bad(r.err)
  Result[bool, BridgeError].good(r.val.status == 200)
