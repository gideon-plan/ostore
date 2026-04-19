## client.nim -- HTTP client for S3 API.
##
## Uses httpc/curl_client for HTTP operations.
{.experimental: "strict_funcs".}

import basis/code/choice
import httpc/curl_client

type
  BridgeError* = object of CatchableError

  S3Config* = object
    endpoint*: string    ## e.g. "http://localhost:9000"
    region*: string
    access_key*: string
    secret_key*: string

  S3Object* = object
    key*: string
    size*: int
    etag*: string

  S3Client* = object
    config*: S3Config
    http*: CurlClient

proc default_config*(endpoint: string = "http://localhost:9000",
                     access_key: string = "", secret_key: string = ""): S3Config =
  S3Config(endpoint: endpoint, region: "us-east-1",
           access_key: access_key, secret_key: secret_key)

proc init_s3_client*(config: S3Config): Choice[S3Client] =
  let cc = init_curl_client()
  if cc.is_bad: return bad[S3Client]("ostore", "failed to init curl")
  good(S3Client(config: config, http: cc.val))

proc close*(c: var S3Client) =
  c.http.close()

proc to_method(s: string): HttpMethod =
  case s
  of "GET": HttpMethod.Get
  of "PUT": HttpMethod.Put
  of "DELETE": HttpMethod.Delete
  of "POST": HttpMethod.Post
  of "HEAD": HttpMethod.Head
  of "PATCH": HttpMethod.Patch
  else: HttpMethod.Get

proc s3_request(c: S3Client, meth_name, url: string,
                headers: seq[(string, string)] = @[],
                body: string = ""): Choice[HttpResponse] =
  c.http.request(HttpRequest(
    url: url,
    meth: to_method(meth_name),
    headers: headers,
    body: body,
    follow_redirects: false,
  ))

proc put_object*(c: S3Client, bucket, key, data: string): Choice[bool] =
  let url = c.config.endpoint & "/" & bucket & "/" & key
  let r = s3_request(c, "PUT", url, body = data)
  if r.is_bad: return bad[bool](r.err)
  if r.val.status >= 400:
    return bad[bool]("ostore", "PUT failed: " & $r.val.status)
  good(true)

proc get_object*(c: S3Client, bucket, key: string): Choice[string] =
  let url = c.config.endpoint & "/" & bucket & "/" & key
  let r = s3_request(c, "GET", url)
  if r.is_bad: return bad[string](r.err)
  if r.val.status >= 400:
    return bad[string]("ostore", "GET failed: " & $r.val.status)
  good(r.val.body)

proc delete_object*(c: S3Client, bucket, key: string): Choice[bool] =
  let url = c.config.endpoint & "/" & bucket & "/" & key
  let r = s3_request(c, "DELETE", url)
  if r.is_bad: return bad[bool](r.err)
  good(true)

proc head_object*(c: S3Client, bucket, key: string): Choice[bool] =
  let url = c.config.endpoint & "/" & bucket & "/" & key
  let r = s3_request(c, "HEAD", url)
  if r.is_bad: return bad[bool](r.err)
  good(r.val.status == 200)
