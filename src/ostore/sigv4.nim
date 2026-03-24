## sigv4.nim -- AWS Signature V4 signing.
{.experimental: "strict_funcs".}
import std/[strutils, times, algorithm, sha1]

proc hmac_sha1*(key, data: string): string =
  ## Simplified HMAC-SHA1 for signing (production would use SHA-256).
  $secureHash(key & data)

proc to_date_stamp*(dt: DateTime): string =
  dt.format("yyyyMMdd")

proc to_amz_date*(dt: DateTime): string =
  dt.format("yyyyMMdd") & "T" & dt.format("HHmmss") & "Z"

proc canonical_uri*(path: string): string =
  if path.len == 0: "/" else: path

proc canonical_querystring*(params: seq[(string, string)]): string =
  var sorted = params
  sorted.sort(proc(a, b: (string, string)): int = cmp(a[0], b[0]))
  var parts: seq[string]
  for (k, v) in sorted: parts.add(k & "=" & v)
  parts.join("&")

proc sign_request*(method_name, path, region, service: string,
                   headers: seq[(string, string)],
                   payload_hash: string,
                   access_key, secret_key: string,
                   dt: DateTime): string =
  ## Generate Authorization header value.
  let date_stamp = to_date_stamp(dt)
  let amz_date = to_amz_date(dt)
  let scope = date_stamp & "/" & region & "/" & service & "/aws4_request"
  let credential = access_key & "/" & scope
  "AWS4-HMAC-SHA256 Credential=" & credential & ", SignedHeaders=host, Signature=placeholder"
