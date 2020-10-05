use v6.c;

use nqp;
use NativeCall;

use GLib::Compat::Definitions;
use GLib::Roles::Pointers;

unit package GLib::Raw::Definitions;

our $ERROR        is export;
our @ERRORS       is export;
our $ERROR-THROWS is export;
our $DEBUG        is export = 0;

class X::GLib::GError is Exception {
  has $!gerror handles <domain code>;

  submethod BUILD (:$!gerror) { }

  method new ($gerror) {
    self.bless( :$gerror, message => $gerror.message );
  }
}

# Forced compile count
my constant forced = 95;

# Libs
constant glib         is export  = 'glib-2.0',v0;
constant gobject      is export  = 'gobject-2.0',v0;

sub glib-support is export {
  state $libname = '';

  unless $libname {
    my $ext = 'dll';
    my $os = $*DISTRO.is-win ?? 'windows' !! 'unix';
    if $os eq 'unix' {
      # Which one?
      $os = $*KERNEL.name;
      $ext = 'so';
    }
    $libname = %?RESOURCES{
      "lib/{ $*KERNEL.arch }/{ $os }/glib-support.{ $ext }"
    }.absolute;
  }

  $libname;
}

constant realUInt is export = $*KERNEL.bits == 32 ?? uint32 !! uint64;

constant gboolean                       is export := uint32;
constant gchar                          is export := Str;
constant gconstpointer                  is export := Pointer;
constant gdouble                        is export := num64;
constant gfloat                         is export := num32;
constant gint                           is export := int32;
constant gint8                          is export := int8;
constant gint16                         is export := int16;
constant gint32                         is export := int32;
constant gint64                         is export := int64;
constant glong                          is export := int64;
constant goffset                        is export := uint64;
constant gpointer                       is export := Pointer;
constant gsize                          is export := uint64;
constant gssize                         is export := int64;
constant guchar                         is export := Str;
constant gshort                         is export := int8;
constant gushort                        is export := uint8;
constant guint                          is export := uint32;
constant guint8                         is export := uint8;
constant guint16                        is export := uint16;
constant guint32                        is export := uint32;
constant guint64                        is export := uint64;
constant gulong                         is export := uint64;
constant gunichar                       is export := uint32;
constant gunichar2                      is export := uint16;
constant va_list                        is export := Pointer;
constant time_t                         is export := uint64;
constant uid_t                          is export := uint32;
constant gid_t                          is export := uint32;
constant pid_t                          is export := int32;

# Conditionals!
constant GPid                           is export := realUInt;

# Function Pointers
constant GAsyncReadyCallback            is export := Pointer;
constant GBindingTransformFunc          is export := Pointer;
constant GCallback                      is export := Pointer;
constant GCompareDataFunc               is export := Pointer;
constant GCompareFunc                   is export := Pointer;
constant GCopyFunc                      is export := Pointer;
constant GClosureMarshal                is export := Pointer;
constant GClosureNotify                 is export := Pointer;
constant GDate                          is export := uint64;
constant GDestroyNotify                 is export := Pointer;
constant GQuark                         is export := uint32;
constant GEqualFunc                     is export := Pointer;
constant GFunc                          is export := Pointer;
constant GHFunc                         is export := Pointer;
constant GLogFunc                       is export := Pointer;
constant GLogWriterFunc                 is export := Pointer;
constant GPrintFunc                     is export := Pointer;
constant GReallocFunc                   is export := Pointer;
constant GSignalAccumulator             is export := Pointer;
constant GSignalEmissionHook            is export := Pointer;
constant GSignalCMarshaller             is export := Pointer;
constant GSignalCVaMarshaller           is export := Pointer;
constant GStatBuf                       is export := stat;
constant GStrv                          is export := CArray[Str];
constant GThreadFunc                    is export := Pointer;
constant GTimeSpan                      is export := int64;
constant GType                          is export := uint64;
constant GBoxedCopyFunc                 is export := Pointer;
constant GBoxedFreeFunc                 is export := Pointer;

# Because an enum wasn't good enough due to:
# "Incompatible MROs in P6opaque rebless for types GLIB_SYSDEF_LINUX and GSocketFamily"
constant GLIB_SYSDEF_POLLIN        is export = 1;
constant GLIB_SYSDEF_POLLOUT       is export = 4;
constant GLIB_SYSDEF_POLLPRI       is export = 2;
constant GLIB_SYSDEF_POLLHUP       is export = 16;
constant GLIB_SYSDEF_POLLERR       is export = 8;
constant GLIB_SYSDEF_POLLNVAL      is export = 32;
constant GLIB_SYSDEF_AF_UNIX       is export = 1;
constant GLIB_SYSDEF_AF_INET       is export = 2;
constant GLIB_SYSDEF_AF_INET6      is export = 10;
constant GLIB_SYSDEF_MSG_OOB       is export = 1;
constant GLIB_SYSDEF_MSG_PEEK      is export = 2;
constant GLIB_SYSDEF_MSG_DONTROUTE is export = 4;

constant G_PARAM_USER_SHIFT        is export = 8;
constant G_LOG_DOMAIN              is export = "\0";

class GAsyncQueue              is repr<CPointer> is export does GLib::Roles::Pointers { }
class GBinding                 is repr<CPointer> is export does GLib::Roles::Pointers { }
class GBookmarkFile            is repr<CPointer> is export does GLib::Roles::Pointers { }
class GBytes                   is repr<CPointer> is export does GLib::Roles::Pointers { }
class GDateTime                is repr<CPointer> is export does GLib::Roles::Pointers { }
class GData                    is repr<CPointer> is export does GLib::Roles::Pointers { }
class GTree                    is repr<CPointer> is export does GLib::Roles::Pointers { }
class GChecksum                is repr<CPointer> is export does GLib::Roles::Pointers { }
class GHashTable               is repr<CPointer> is export does GLib::Roles::Pointers { }
class GHashTableIter           is repr<CPointer> is export does GLib::Roles::Pointers { }
class GHmac                    is repr<CPointer> is export does GLib::Roles::Pointers { }
class GHook                    is repr<CPointer> is export does GLib::Roles::Pointers { }  #= size = 64
class GIConv                   is repr<CPointer> is export does GLib::Roles::Pointers { }
class GIOChannel               is repr<CPointer> is export does GLib::Roles::Pointers { }
class GKeyFile                 is repr<CPointer> is export does GLib::Roles::Pointers { }
class GMainLoop                is repr<CPointer> is export does GLib::Roles::Pointers { }
class GMainContext             is repr<CPointer> is export does GLib::Roles::Pointers { }
class GMappedFile              is repr<CPointer> is export does GLib::Roles::Pointers { }
class GMarkupParser            is repr<CPointer> is export does GLib::Roles::Pointers { }
class GMarkupParseContext      is repr<CPointer> is export does GLib::Roles::Pointers { }
class GMatchInfo               is repr<CPointer> is export does GLib::Roles::Pointers { }
#class GMutex                   is repr<CPointer> is export does GLib::Roles::Pointers { }
class GModule                  is repr<CPointer> is export does GLib::Roles::Pointers { }
#class GObject                  is repr<CPointer> is export does GLib::Roles::Pointers { }
class GOptionGroup             is repr<CPointer> is export does GLib::Roles::Pointers { }
class GPatternSpec             is repr<CPointer> is export does GLib::Roles::Pointers { }
#class GParamSpec               is repr<CPointer> is export does GLib::Roles::Pointers { }
class GParamSpecPool           is repr<CPointer> is export does GLib::Roles::Pointers { }
class GPrivate                 is repr<CPointer> is export does GLib::Roles::Pointers { }
class GRand                    is repr<CPointer> is export does GLib::Roles::Pointers { }
class GRegex                   is repr<CPointer> is export does GLib::Roles::Pointers { }
class GRWLock                  is repr<CPointer> is export does GLib::Roles::Pointers { }
# To be converted into CStruct when I'm not so scurred of it.
# It has bits.... BITS! -- See https://stackoverflow.com/questions/1490092/c-c-force-bit-field-order-and-alignment
class GScannerConfig           is repr<CPointer> is export does GLib::Roles::Pointers { }
# Also has a CStruct representation, and should be converted.
class GScanner                 is repr<CPointer> is export does GLib::Roles::Pointers { }
class GSequence                is repr<CPointer> is export does GLib::Roles::Pointers { }
class GSequenceIter            is repr<CPointer> is export does GLib::Roles::Pointers { }
class GSource                  is repr<CPointer> is export does GLib::Roles::Pointers { }
class GTestCase                is repr<CPointer> is export does GLib::Roles::Pointers { }
class GTestSuite               is repr<CPointer> is export does GLib::Roles::Pointers { }
class GThread                  is repr<CPointer> is export does GLib::Roles::Pointers { }
class GThreadPool              is repr<CPointer> is export does GLib::Roles::Pointers { }
class GTimer                   is repr<CPointer> is export does GLib::Roles::Pointers { }
class GTimeZone                is repr<CPointer> is export does GLib::Roles::Pointers { }
class GTypePlugin              is repr<CPointer> is export does GLib::Roles::Pointers { }
class GTokenValue              is repr<CPointer> is export does GLib::Roles::Pointers { }
class GVariant                 is repr<CPointer> is export does GLib::Roles::Pointers { }
class GVariantBuilder          is repr<CPointer> is export does GLib::Roles::Pointers { }
class GVariantDict             is repr<CPointer> is export does GLib::Roles::Pointers { }
class GVariantIter             is repr<CPointer> is export does GLib::Roles::Pointers { }
class GVariantType             is repr<CPointer> is export does GLib::Roles::Pointers { }

our role Implementor is export {};

# Mark
multi sub trait_mod:<is>(Attribute:D \attr, :$implementor!) is export {
  # YYY - Warning if a second attribute is marked?
  attr does Implementor;
}

# Find.
sub findProperImplementor ($attrs) is export {
  # Will need to search the entire attributes list for the
  # proper main variable. Then sort for the one with the largest
  # MRO.
  $attrs.grep( * ~~ Implementor ).sort( -*.package.^mro.elems )[0]
}

# "Exhaustive" maximal...
multi max (:&by = {$_}, :$all!, *@list) is export {
  # Find the maximal value...
  my $max = max my @values = @list.map: &by;

  # Extract and return all values matching the maximal...
  @list[ @values.kv.map: {$^index unless $^value cmp $max} ];
}

INIT {

  if %*ENV<P6_GLIB_DEBUG> {
    say '»————————————> setting debug';
    $DEBUG = True;
  }

}