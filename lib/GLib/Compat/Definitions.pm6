use v6.c;

use NativeCall;

use GLib::Roles::Pointers;

unit package GLib::Compat::Definitions;

our constant PF_INET     is export = 2;
our constant PF_INET6    is export = 10;
our constant AF_INET     is export = PF_INET;
our constant AF_INET6    is export = PF_INET6;
our constant FILE        is export := Pointer;
our constant sa_family_t is export := int16;
our constant in_port_t   is export := int16;
# cw: Need definition for sa_family_t

constant INADDR_LOOPBACK is export := 0x7f000001; # Inet 127.0.0.1

class sockaddr   is repr<CStruct> is export does GLib::Roles::Pointers {
    has sa_family_t  $.sa_family is rw;   #= address family
    has Str          $!sa_data;           #= socket address (variable-length data)

    method sa_data is rw {
      Proxy.new:
        FETCH => -> $           { $!sa_data },
        STORE => -> $, Str() \s { $!sa_data := s };
    }
}

class in_addr     is repr<CStruct> is export does GLib::Roles::Pointers {
  has uint32 $.s_addr is rw;
}

class sockaddr_in is repr<CStruct> is export does GLib::Roles::Pointers {
    has sa_family_t $.sin_family is rw;   #= address family
    has in_port_t   $.sin_port   is rw;   #= Port number.
    HAS in_addr     $.sin_addr;           #= Internet address.

    # Pad 4 bytes
    has CArray[uint8] @.sin_zero[4] is CArray;
}

class stat        is repr<CStruct> is export does GLib::Roles::Pointers {
  has uint64 $.st_dev;
  has uint64 $.st_ino;
  has uint16 $.st_mode;
  has uint16 $.st_nlink;
  has uint16 $.st_uid;
  has uint16 $.st_gid;
  has uint64 $.st_rdev;
  has uint64 $.st_size;
  has uint64 $.st_blksize;
  has uint64 $.st_blocks;
  has uint64 $.st_atime;
  has uint64 $.st_atime_nsec;
  has uint64 $.st_mtime;
  has uint64 $.st_mtime_nsec;
  has uint64 $.st_ctime;
  has uint64 $.st_ctime_nsec;
  has uint64 $.__unused4;
  has uint64 $.__unused5;
}

sub htonl (uint32)
  returns uint32
  is native
  is export
{ * }
