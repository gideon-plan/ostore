{.experimental: "strict_funcs".}
import std/[unittest, times]
import basis/code/choice
import ostore/sigv4
import ostore/client
import ostore/multipart

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
  test "init and close":
    let cfg = default_config()
    let r = init_s3_client(cfg)
    check r.is_good
    var c = r.val
    c.close()

  test "config defaults":
    let cfg = default_config()
    check cfg.endpoint == "http://localhost:9000"
    check cfg.region == "us-east-1"

suite "multipart":
  test "new and add part":
    var mp = new_multipart("bucket", "key", "upload-123")
    mp.add_part("etag1")
    mp.add_part("etag2")
    check mp.parts.len == 2
