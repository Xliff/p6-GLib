use v6.c;

use NativeCall;

use GLib::Roles::Pointers;

unit package GLib::Compat::Definitions;

my constant realUint is export = $*KERNEL.bits == 32 ?? uint32 !! uint64;
my constant realInt  is export = $*KERNEL.bits == 32 ?? int32  !! int64;

our constant PF_INET     is export = 2;
our constant PF_INET6    is export = 10;
our constant AF_INET     is export = PF_INET;
our constant AF_INET6    is export = PF_INET6;
our constant FILE        is export := Pointer;
our constant sa_family_t is export := int16;
our constant in_port_t   is export := int16;
# cw: Need definition for sa_family_t

# cw; <kneejerk>It's kinda inexcusable for a parser advanced as Raku's to NOT
#     be able to handle leading 0's as a decimal number. Nor would it be
#     confusing to do so!</kneejerk>
constant FileAccessFlags is export := uint32;
our enum FileAccessFlagsEnum is export (
  O_RDONLY     =>         0,
  O_WRONLY     =>         1,
  O_RDWR       =>         2,
  O_ACCMODE    =>         3,
  O_CREAT      =>       100,       # not fcntl
  O_EXCL       =>       200,       # not fcntl
  O_NOCTTY     =>       400,       # not fcntl
  O_TRUNC      =>      1000,       # not fcntl
  O_APPEND     =>      2000,
  O_NONBLOCK   =>      4000,
  O_DSYNC      =>     10000,       # used to be O_SYNC, see below
  FASYNC       =>     20000,       # fcntl, for BSD compatibility
  O_DIRECT     =>     40000,       # direct disk access hint
  O_LARGEFILE  =>    100000,
  O_DIRECTORY  =>    200000,       # must be a directory
  O_NOFOLLOW   =>    400000,       # don't follow links
  O_NOATIME    =>   1000000,
  O_CLOEXEC    =>   2000000       # set close_on_exec
);

constant FileModes is export := uint32;
our enum FileModesEnum is export (
  S_IFMT   =>   170000,
  S_IFSOCK =>   140000,
  S_IFLNK  =>   120000,
  S_IFREG  =>   100000,
  S_IFBLK  =>    60000,
  S_IFDIR  =>    40000,
  S_IFCHR  =>    20000,
  S_IFIFO  =>    10000,
  S_ISUID  =>     4000,
  S_ISGID  =>     2000,
  S_ISVTX  =>     1000,
  S_IRWXU  =>      700,
  S_IRUSR  =>      400,
  S_IWUSR  =>      200,
  S_IXUSR  =>      100,
  S_IRWXG  =>       70,
  S_IRGRP  =>       40,
  S_IWGRP  =>       20,
  S_IXGRP  =>       10,
  S_IRWXO  =>        7,
  S_IROTH  =>        4,
  S_IWOTH  =>        2,
  S_IXOTH  =>        1
);

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

class tm          is repr<CStruct> is export does GLib::Roles::Pointers {
  has int32 $.tm_sec     is rw; #= seconds [0,61]
  has int32 $.tm_min     is rw; #= minutes [0,59]
  has int32 $.tm_hour    is rw; #= hour [0,23]
  has int32 $.tm_mday    is rw; #= day of month [1,31]
  has int32 $.tm_mon     is rw; #= month of year [0,11]
  has int32 $.tm_year    is rw; #= years since 1900
  has int32 $.tm_wday    is rw; #= day of week [0,6] (Sunday = 0)
  has int32 $.tm_yday    is rw; #= day of year [0,365]
  has int32 $.tm_isdst   is rw; #= daylight savings flag
  has int64 $.tm_gmtoff  is rw; #= seconds east of UTC
  has Str   $.tm_zone;          #= Timezone abbreviation

  method DateTime {
    DateTime.new(
      year   => self.tm_year,
      month  => self.tm_mon,
      day    => self.tm_day,
      hour   => self.tm_hour,
      minute => self.tm_min,
      second => self.tm_sec,
      offset => self.tm_gmtoff
    )
  }

  method new (DateTime $d) {
    self.bless(
      tm_year   => $d.year,
      tm_mon    => $d.month,
      tm_day    => $d.day,
      tm_hour   => $d.hour,
      tm_min    => $d.minute,
      tm_sec    => $d.second.Int,
      tm_gmtoff => $d.offset
    );
  }
}

sub htonl (uint32)
  returns uint32
  is native
  is export
{ * }

# cw: Yeah, and now we have to worry about this...
constant LC_ADDRESS  is export = 9;
constant LC_MESSAGES is export = 5;

class timeval is repr<CStruct> does GLib::Roles::Pointers is export {
  # cw: Signed my ass!
  has uint64 $.tv_sec  is rw;
  has uint64 $.tv_nsec is rw;
}
