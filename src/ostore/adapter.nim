## adapter.nim -- Limes Port adapter for S3 storage.
{.experimental: "strict_funcs".}

import basis/code/choice, client

type
  S3Adapter* = object
    client*: S3Client
    bucket_prefix*: string

proc new_adapter*(client: S3Client, prefix: string = "limes"): S3Adapter =
  S3Adapter(client: client, bucket_prefix: prefix)

proc store_vector*(a: S3Adapter, collection, id: string, data: string): Choice[bool] =
  let bucket = a.bucket_prefix & "-" & collection
  a.client.put_object(bucket, id, data)

proc get_vector*(a: S3Adapter, collection, id: string): Choice[string] =
  let bucket = a.bucket_prefix & "-" & collection
  a.client.get_object(bucket, id)
