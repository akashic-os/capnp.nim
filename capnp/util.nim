import endians

type CapnpFormatError* = object of Exception

type CapnpScalar* = uint8 | uint16 | uint32 | uint64 | int8 | int16 | int32 | int64 | float32 | float64

proc convertEndian*(size: static[int], dst: pointer, src: pointer, endian=littleEndian) {.inline.} =
  when size == 1:
    copyMem(dst, src, 1)
  else:
    case endian:
    of bigEndian:
      when size == 2:
        bigEndian16(dst, src)
      elif size == 4:
        bigEndian32(dst, src)
      elif size == 8:
        bigEndian64(dst, src)
      else:
        {.error: "Unsupported size".}
    of littleEndian:
      when size == 2:
        littleEndian16(dst, src)
      elif size == 4:
        littleEndian32(dst, src)
      elif size == 8:
        littleEndian64(dst, src)
      else:
        {.error: "Unsupported size".}

proc unpack*[T](v: string, offset: int, t: typedesc[T], endian=littleEndian): T {.inline.} =
  if not (offset < v.len and offset + sizeof(t) <= v.len and offset >= 0):
    raise newException(CapnpFormatError, "bad offset")
  convertEndian(sizeof(T), addr result, unsafeAddr v[offset])

proc extractBits*(v: uint64|uint32|uint16|uint8, k: Natural, bits: int): int {.inline.} =
  assert k + bits <= sizeof(v) * 8
  return cast[int]((v shr k) and ((1 shl bits) - 1).uint64)