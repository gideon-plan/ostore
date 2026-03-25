## client.nim -- HTTP client for S3 API.
{.experimental: "strict_funcs".}

import basis/code/choice

type
  BridgeError* = object of CatchableError


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
                 body: string): Choice[tuple[status: int, body: string]] {.raises: [].}

proc default_config*(endpoint: string = "http://localhost:9000",
                     access_key: string = "", secret_key: string = ""): S3Config =
  S3Config(endpoint: endpoint, region: "us-east-1",
           access_key: access_key, secret_key: secret_key)

proc put_object*(config: S3Config, http_fn: HttpFn, bucket, key, data: string
                ): Choice[bool] =
  let url = config.endpoint & "/" & bucket & "/" & key
  let r = http_fn("PUT", url, @[], data)
  if r.is_bad: return bad[bool](r.err)
  if r.val.status >= 400:
    return bad[bool]("ostore", "PUT failed: " & $r.val.status)
  good(true)

proc get_object*(config: S3Config, http_fn: HttpFn, bucket, key: string
                ): Choice[string] =
  let url = config.endpoint & "/" & bucket & "/" & key
  let r = http_fn("GET", url, @[], "")
  if r.is_bad: return bad[string](r.err)
  if r.val.status >= 400:
    return bad[string]("ostore", "GET failed: " & $r.val.status)
  good(r.val.body)

proc delete_object*(config: S3Config, http_fn: HttpFn, bucket, key: string
                   ): Choice[bool] =
  let url = config.endpoint & "/" & bucket & "/" & key
  let r = http_fn("DELETE", url, @[], "")
  if r.is_bad: return bad[bool](r.err)
  good(true)

proc head_object*(config: S3Config, http_fn: HttpFn, bucket, key: string
                 ): Choice[bool] =
  let url = config.endpoint & "/" & bucket & "/" & key
  let r = http_fn("HEAD", url, @[], "")
  if r.is_bad: return bad[bool](r.err)
  good(r.val.status == 200)
