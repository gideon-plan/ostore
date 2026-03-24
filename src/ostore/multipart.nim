## multipart.nim -- Multipart upload for large objects.
{.experimental: "strict_funcs".}
import lattice
type
  MultipartUpload* = object
    bucket*: string
    key*: string
    upload_id*: string
    parts*: seq[string]  ## ETags of uploaded parts
  InitFn* = proc(bucket, key: string): Result[string, BridgeError] {.raises: [].}
  UploadPartFn* = proc(bucket, key, upload_id: string, part_num: int, data: string): Result[string, BridgeError] {.raises: [].}
  CompleteFn* = proc(bucket, key, upload_id: string, etags: seq[string]): Result[void, BridgeError] {.raises: [].}
proc new_multipart*(bucket, key, upload_id: string): MultipartUpload =
  MultipartUpload(bucket: bucket, key: key, upload_id: upload_id)
proc add_part*(mp: var MultipartUpload, etag: string) =
  mp.parts.add(etag)
