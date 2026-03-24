## adapter.nim -- Limes Port adapter for S3 storage.
{.experimental: "strict_funcs".}

import lattice, client
type
  S3Adapter* = object
    config*: S3Config
    http_fn*: HttpFn
    bucket_prefix*: string
proc new_adapter*(config: S3Config, http_fn: HttpFn, prefix: string = "limes"): S3Adapter =
  S3Adapter(config: config, http_fn: http_fn, bucket_prefix: prefix)
proc store_vector*(a: S3Adapter, collection, id: string, data: string
                  ): Result[void, BridgeError] =
  let bucket = a.bucket_prefix & "-" & collection
  put_object(a.config, a.http_fn, bucket, id, data)
proc get_vector*(a: S3Adapter, collection, id: string): Result[string, BridgeError] =
  let bucket = a.bucket_prefix & "-" & collection
  get_object(a.config, a.http_fn, bucket, id)
