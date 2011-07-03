#!/bin/bash
ME="$(dirname "$(readlink -f "$0")")"
mkdir -p "${ME}/../Bindings/Linux"
patch -s -p0 -o "${ME}/../Bindings/Linux/videodev2.h" "/usr/include/linux/videodev2.h" "${ME}/videodev2.h.diff"
(
cat <<EOF
#include <bindings.cmacros.h>
#include "videodev2.h"
BC_INLINE4(v4l2_fourcc,__u8,__u8,__u8,__u8,__u32)
BC_INLINE1(V4L2_FIELD_HAS_TOP,enum v4l2_field,int)
BC_INLINE1(V4L2_FIELD_HAS_BOTTOM,enum v4l2_field,int)
BC_INLINE1(V4L2_FIELD_HAS_BOTH,enum v4l2_field,int)
BC_INLINE1(V4L2_CTRL_ID2CLASS,__u32,__u32)
BC_INLINE1(V4L2_CTRL_DRIVER_PRIV,__u32,__u32)
EOF
) > "${ME}/../Bindings/Linux/videodev2_cinline.c"
(
( cat <<EOF
{-# LANGUAGE ForeignFunctionInterface, MultiParamTypeClasses, TypeSynonymInstances #-}
-- ...edit the generating script instead of this machine-generated file...
#include <bindings.dsl.h>
#include <sys/time.h>
#include "videodev2.h"
-- | Bindings for Video For Linux Two (v4l2), wrapping:
--   <file:///usr/include/linux/videodev2.h>
--   Upstream documentation at:
--   <http://linuxtv.org/downloads/v4l-dvb-apis/>
module Bindings.Linux.VideoDev2 where
import System.Posix.IOCtl
#strict_import
#starttype struct timeval
#field tv_sec , CLong
#field tv_usec , CLong
#stoptype
#synonym_t v4l2_std_id , Word64
#cinline v4l2_fourcc , Word8 -> Word8 -> Word8 -> Word8 -> IO Word32
#cinline V4L_FIELD_HAS_TOP , <v4l2_field> -> IO CInt
#cinline V4L_FIELD_HAS_BOTTOM , <v4l2_field> -> IO CInt
#cinline V4L_FIELD_HAS_BOTH , <v4l2_field> -> IO CInt
#cinline V4L2_CTRL_ID2CLASS , Word32 -> IO Word32
#cinline V4L2_CTRL_DRIVER_PRIV , Word32 -> IO Word32
EOF
cat "${ME}/../Bindings/Linux/videodev2.h" |
tr '\n' '?' |
sed 's|\\?||g' |
sed 's|/\*|\n/\*|g' |
sed 's|\*/|\*/\n|g' |
sed 's|^/\*.*\*/$||g' |
tr '?' '\n' |
tr '\t' ' ' |
tr -s ' \n' |
grep -v '^#if' |
grep -v '^#else' |
grep -v '^#endif' |
grep -v '^#include' |
grep -v '^typedef' |
sed 's|^#define \([A-Z0-9_]*\) _IO[RW]*([^,]*, \([0-9]*\), struct \([A-Z0-9a-z_]*\))$|#opaque_t \1\ninstance IOControl C'"'"'\1 C'"'"'\3 where ioctlReq _ = \2|g' |
sed 's|^#define \([A-Z0-9_]*\) _IO[RW]*([^,]*, \([0-9]*\), enum \([A-Z0-9a-z_]*\))$|#opaque_t \1\ninstance IOControl C'"'"'\1 C'"'"'\3 where ioctlReq _ = \2|g' |
sed 's|^#define \([A-Z0-9_]*\) _IO[RW]*([^,]*, \([0-9]*\), \(v4l2_std_id\))$|#opaque_t \1\ninstance IOControl C'"'"'\1 C'"'"'\3 where ioctlReq _ = \2|g' |
sed 's|^#define \([A-Z0-9_]*\) _IO[RW]*([^,]*, \([0-9]*\), int)$|#opaque_t \1\ninstance IOControl C'"'"'\1 CInt where ioctlReq _ = \2|g' |
sed 's|^#define \([A-Z0-9_]*\) _IO[RW]*([^,]*, \([0-9]*\))$|#opaque_t \1\ninstance IOControl C'"'"'\1 CInt where ioctlReq _ = \2|g' |
sed 's|^enum \([a-z0-9_]*\).*$|#integral_t enum \1|g' |
sed 's|^ \([A-Z0-9a-z_]*\) = .*$|#num \1|g' |
sed 's|^#define \([A-Z0-9a-z_]*\)(.*$||g' |
sed 's|^#define \([A-Z0-9a-z_]*\).*$|#num \1|g' |
grep -v '^#num __' |
while read line ; do
  if [[ "${line}" =~ 'struct' || "${line}" =~ 'union' ]] ; then
    u=""
    if [[ "${line}" =~ 'union' ]] ; then
      u="union_"
      echo "${line}" | sed 's|^union \([A-Za-z0-9_]*\).*$|#starttype union \1|g'
    else
      echo "${line}" | sed 's|^struct \([A-Za-z0-9_]*\).*$|#starttype struct \1|g'
    fi
    while read line ; do
      if [[ "${line}" =~ '}' ]] ; then
        echo '#stoptype'
        break
      else
        f=""
        if [[ "${line}" =~ '[' ]] ; then
          f="${u}array_field"
        else
          f="${u}field"
        fi
        if [[ "${line}" =~ '__s32' ]] ; then
          t="Int32"
        elif [[ "${line}" =~ '__u32' ]] ; then
          t="Word32"
        elif [[ "${line}" =~ '__le32' ]] ; then
          t="Word32"
        elif [[ "${line}" =~ '__s64' ]] ; then
          t="Int64"
        elif [[ "${line}" =~ '__u64' ]] ; then
          t="Word64"
        elif [[ "${line}" =~ '__u16' ]] ; then
          t="Word16"
        elif [[ "${line}" =~ '__u8' ]] ; then
          t="Word8"
        elif [[ "${line}" =~ 'int' ]] ; then
          t="CInt"
        elif [[ "${line}" =~ 'char' ]] ; then
          t="CChar"
        elif [[ "${line}" =~ 'unsigned long' ]] ; then
          t="CULong"
        elif [[ "${line}" =~ 'v4l2_std_id' ]] ; then
          t="<v4l2_std_id>"
        elif [[ "${line}" =~ 'struct' ]] ; then
          t="$(echo "${line}" | sed 's|^.*struct \([A-Za-z0-9_]*\) .*$|<\1>|g')"
        elif [[ "${line}" =~ 'union' ]] ; then
          t="$(echo "${line}" | sed 's|^.*union \([A-Za-z0-9_]*\) .*$|<\1>|g')"
        elif [[ "${line}" =~ 'enum' ]] ; then
          t="$(echo "${line}" | sed 's|^.*enum \([A-Za-z0-9_]*\) .*$|<\1>|g')"
        elif [[ "${line}" =~ 'void' ]] ; then
          t="Ptr ()"
        else
          t="FIXME"
        fi
        echo "${line}" | sed 's|.*[ *]\([A-Za-z0-9_]*\).*$|#'"$f"' \1 , '"${t}"'|g'
      fi
    done
  elif [[ ! "${line}" =~ '};' ]] ; then
    echo "${line}"
  fi
done ) |
tr -s "\n"
) > "${ME}/../Bindings/Linux/VideoDev2.hsc"
