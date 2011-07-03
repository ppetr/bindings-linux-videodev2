#!/bin/bash
ME="$(dirname "$(readlink -f "$0")")"
mkdir -p "${ME}/../Bindings/Linux"
patch -s -p0 -o "${ME}/../Bindings/Linux/videodev2.h" "/usr/include/linux/videodev2.h" "${ME}/videodev2.h.diff"
(
cat <<EOF
#include <bindings.cmacros.h>
#define __OLD_VIDIOC_
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
{-# LANGUAGE DeriveDataTypeable, ForeignFunctionInterface, MultiParamTypeClasses, StandaloneDeriving, TypeSynonymInstances #-}
-- ...edit the generating script instead of this machine-generated file...
#include <bindings.dsl.h>
#include <sys/time.h>
#define __OLD_VIDIOC_
#include "videodev2.h"
-- | Bindings for Video For Linux Two (v4l2), wrapping:
--   <file:///usr/include/linux/videodev2.h>
--   Upstream documentation at:
--   <http://linuxtv.org/downloads/v4l-dvb-apis/>
module Bindings.Linux.VideoDev2 where
import System.Posix.IOCtl
#strict_import
import Foreign(unsafePerformIO)
import Data.Typeable (Typeable)
deriving instance Typeable C'timeval
deriving instance Typeable C'v4l2_rect
deriving instance Typeable C'v4l2_fract
deriving instance Typeable C'v4l2_capability
deriving instance Typeable C'v4l2_pix_format
deriving instance Typeable C'v4l2_fmtdesc
deriving instance Typeable C'v4l2_frmsize_discrete
deriving instance Typeable C'v4l2_frmsize_stepwise
deriving instance Typeable C'v4l2_frmsizeenum
deriving instance Typeable C'v4l2_frmsizeenum_u
deriving instance Typeable C'v4l2_frmival_stepwise
deriving instance Typeable C'v4l2_frmivalenum
deriving instance Typeable C'v4l2_frmivalenum_u
deriving instance Typeable C'v4l2_timecode
deriving instance Typeable C'v4l2_jpegcompression
deriving instance Typeable C'v4l2_requestbuffers
deriving instance Typeable C'v4l2_buffer_u
deriving instance Typeable C'v4l2_buffer
deriving instance Typeable C'v4l2_framebuffer
deriving instance Typeable C'v4l2_clip
deriving instance Typeable C'v4l2_window
deriving instance Typeable C'v4l2_captureparm
deriving instance Typeable C'v4l2_outputparm
deriving instance Typeable C'v4l2_cropcap
deriving instance Typeable C'v4l2_crop
deriving instance Typeable C'v4l2_standard
deriving instance Typeable C'v4l2_input
deriving instance Typeable C'v4l2_output
deriving instance Typeable C'v4l2_control
deriving instance Typeable C'v4l2_ext_control
deriving instance Typeable C'v4l2_ext_controls
deriving instance Typeable C'v4l2_ext_control_u
deriving instance Typeable C'v4l2_queryctrl
deriving instance Typeable C'v4l2_querymenu
deriving instance Typeable C'v4l2_tuner
deriving instance Typeable C'v4l2_modulator
deriving instance Typeable C'v4l2_frequency
deriving instance Typeable C'v4l2_hw_freq_seek
deriving instance Typeable C'v4l2_rds_data
deriving instance Typeable C'v4l2_audio
deriving instance Typeable C'v4l2_audioout
deriving instance Typeable C'v4l2_enc_idx_entry
deriving instance Typeable C'v4l2_enc_idx
deriving instance Typeable C'v4l2_vbi_format
deriving instance Typeable C'v4l2_sliced_vbi_format
deriving instance Typeable C'v4l2_sliced_vbi_cap
deriving instance Typeable C'v4l2_sliced_vbi_data
deriving instance Typeable C'v4l2_mpeg_vbi_itv0_line
deriving instance Typeable C'v4l2_mpeg_vbi_fmt_ivtv
deriving instance Typeable C'v4l2_format
deriving instance Typeable C'v4l2_mpeg_vbi_fmt_ivtv_u
deriving instance Typeable C'v4l2_streamparm
deriving instance Typeable C'v4l2_dbg_match
deriving instance Typeable C'v4l2_dbg_register
deriving instance Typeable C'v4l2_dbg_chip_ident
deriving instance Typeable C'v4l2_format_u
deriving instance Typeable C'v4l2_encoder_cmd_u
deriving instance Typeable C'v4l2_encoder_cmd
deriving instance Typeable C'v4l2_dbg_match_u
deriving instance Typeable C'v4l2_streamparm_u
#starttype struct timeval
#field tv_sec , CLong
#field tv_usec , CLong
#stoptype
#synonym_t v4l2_std_id , Word64
#cinline v4l2_fourcc , Word8 -> Word8 -> Word8 -> Word8 -> IO Word32
#cinline V4L2_FIELD_HAS_TOP , <v4l2_field> -> IO CInt
#cinline V4L2_FIELD_HAS_BOTTOM , <v4l2_field> -> IO CInt
#cinline V4L2_FIELD_HAS_BOTH , <v4l2_field> -> IO CInt
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
sed 's|^#define \([A-Z0-9_]*\) \(_IO[RW]*([^,]*, [0-9]*, struct \([A-Z0-9a-z_]*\))\)$|#num \1\n#opaque_t \1\ninstance IOControl C'"'"'\1 C'"'"'\3 where ioctlReq _ = c'"'"'\1|g' |
sed 's|^#define \([A-Z0-9_]*\) \(_IO[RW]*([^,]*, [0-9]*, enum \([A-Z0-9a-z_]*\))\)$|#num \1\n#opaque_t \1\ninstance IOControl C'"'"'\1 C'"'"'\3 where ioctlReq _ = c'"'"'\1|g' |
sed 's|^#define \([A-Z0-9_]*\) \(_IO[RW]*([^,]*, [0-9]*, \(v4l2_std_id\))\)$|#num \1\n#opaque_t \1\ninstance IOControl C'"'"'\1 C'"'"'\3 where ioctlReq _ = c'"'"'\1|g' |
sed 's|^#define \([A-Z0-9_]*\) \(_IO[RW]*([^,]*, [0-9]*, int)\)$|#num \1\n#opaque_t \1\ninstance IOControl C'"'"'\1 CInt where ioctlReq _ = c'"'"'\1|g' |
sed 's|^#define \([A-Z0-9_]*\) \(_IO[RW]*([^,]*, [0-9]*)\)$|#num \1\n#opaque_t \1\ninstance IOControl C'"'"'\1 CInt where ioctlReq _ = c'"'"'\1|g' |
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
          t="()"
        else
          t="FIXME"
        fi
        if [[ "${line}" =~ '*' ]] ; then
          t="Ptr ${t}"
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
