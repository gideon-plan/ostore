{.experimental: "strict_funcs".}
import std/[unittest, strutils, tables, times]
import ostore
suite "sigv4":
  test "date stamp format":
    let dt = dateTime(2026, mMar, 24, 12, 0, 0, zone = utc())
    check to_date_stamp(dt) == "20260324"
  test "amz date format":
    let dt = dateTime(2026, mMar, 24, 12, 30, 45, zone = utc())
    check to_amz_date(dt) == "20260324T123045Z"
  test "canonical uri":
    check canonical_uri("") == "/"
    check canonical_uri("/bucket/key") == "/bucket/key"
  test "canonical querystring":
    check canonical_querystring(@[("b", "2"), ("a", "1")]) == "a=1&b=2"
suite "client":
  test "put object":
    let mock_http: HttpFn = proc(m, u: string, h: seq[(string, string)], b: string): Result[tuple[status: int, body: string], BridgeError] {.raises: [].} =
      Result[tuple[status: int, body: string], BridgeError].good((status: 200, body: ""))
    let cfg = default_config()
    let r = put_object(cfg, mock_http, "bucket", "key", "data")
    check r.is_good
  test "get object":
    let mock_http: HttpFn = proc(m, u: string, h: seq[(string, string)], b: string): Result[tuple[status: int, body: string], BridgeError] {.raises: [].} =
      Result[tuple[status: int, body: string], BridgeError].good((status: 200, body: "content"))
    let cfg = default_config()
    let r = get_object(cfg, mock_http, "bucket", "key")
    check r.is_good
    check r.val == "content"
  test "put failure":
    let mock_http: HttpFn = proc(m, u: string, h: seq[(string, string)], b: string): Result[tuple[status: int, body: string], BridgeError] {.raises: [].} =
      Result[tuple[status: int, body: string], BridgeError].good((status: 403, body: ""))
    let r = put_object(default_config(), mock_http, "b", "k", "d")
    check r.is_bad
suite "adapter":
  test "store and get vector":
    var stored: Table[string, string]
    let mock_http: HttpFn = proc(m, u: string, h: seq[(string, string)], b: string): Result[tuple[status: int, body: string], BridgeError] {.raises: [].} =
      if m == "PUT": stored[u] = b
      Result[tuple[status: int, body: string], BridgeError].good((status: 200, body: stored.getOrDefault(u, "")))
    let a = new_adapter(default_config(), mock_http)
    let r = a.store_vector("col1", "vec_0", "[1.0, 2.0]")
    check r.is_good
