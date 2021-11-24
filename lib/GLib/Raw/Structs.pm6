use v6.c;

use NativeCall;
use Method::Also;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Exceptions;
use GLib::Raw::Object;
use GLib::Raw::Subs;
use GLib::Raw::Struct_Subs;

use GLib::Roles::Pointers;
use GLib::Roles::TypeInstance;

unit package GLib::Raw::Structs;

# cw: Testing this thought out...
our $ERROR-REPLACEMENT is export = sub { %ERROR{$*PID} };

class GValue                is repr<CStruct> does GLib::Roles::Pointers is export { ... }

# CArray replacement for sized classes
class SizedCArray is CArray is export does Positional {
  has               $!size;

  # Delegate everything but 'elems'
  has CArray[uint8] $!native handles *.grep({ ( .name // '' ) ne 'elems' });

  method size is rw {
    Proxy.new:
      FETCH => -> $     { $!size },
      STORE => -> $, \s { $!size = s }
  }

  method AT-POS (\k) {
    $!native[k];
  }

  method elems { $!size.defined ?? $!size !! nextsame }

  submethod BUILD ( :$!native, :$!size ) { }

  method new ($native, $size) {
    self.bless( :$native, :$size );
  }

}

# Structs

# Opaque to code?
class GTypeInterface        is repr<CStruct> does GLib::Roles::Pointers is export {
  has GType $.g_type;
  has GType $.g_instance_type;

  method g-type          { $!g_type          }
  method g-instance-type { $!g_instance_type }
}

class GArray                is repr<CStruct> does GLib::Roles::Pointers is export {
  has Pointer $.data;
  has uint32  $.len;

  method p { +$!data }
}

class GByteArray            is repr<CStruct> does GLib::Roles::Pointers is export {
  has CArray[uint8] $.data;
  has guint         $.len;

  method Blob {
    Blob.new( $.data[ ^$.len ] );
  }
}

class GCond                 is repr<CStruct> does GLib::Roles::Pointers is export {
  # Private
  has gpointer $!p;
  has guint    @!i[2] is CArray;
}

class GDate                 is repr<CStruct> does GLib::Roles::Pointers is export {
  has guint32 $.julian_days is rw;
  has guint32 $!packed-data;

  method julian-days is rw { $!julian_days }

  # cw: Accessor methods for packed fields?
  # guint julian : 1;
  # guint dmy    : 1;
  # guint day    : 6;
  # guint month  : 4;
  # guint year   : 16;
}

class GError                is repr<CStruct> does GLib::Roles::Pointers is export {
  has uint32        $.domain;
  has int32         $.code;
  has Str           $!message;

  submethod BUILD (:$!domain, :$!code, :$message) {
    self.message = $message;
  }

  method new ($domain, $code, $message) {
    self.bless(:$domain, :$code, :$message);
  }

  method message is rw {
    Proxy.new:
      FETCH => sub ($) { $!message },
      STORE => -> $, Str() $val {
        ::?CLASS.^attributes[* - 1].set_value(self, $val)
      };
  }

  method gist {
    my $domain-extra = %DOMAINS{ self.domain }:exists
      ?? " [{ %DOMAINS{ self.domain }( self.code ) }] " !! '';

    self.^name ~ ".new(domain => { self.domain }, " ~
    "code => { self.code }{ $domain-extra })";
  }

}

class GList                 is repr<CStruct> does GLib::Roles::Pointers is export {
  has Pointer $!data;
  has GList   $.next;
  has GList   $.prev;

  method data is rw {
    Proxy.new:
      FETCH => sub ($)           { $!data },
      STORE => -> $, Pointer $nv {
        # Thank GOD we can now replace this monstrosity:
        # nqp::bindattr(
        #   nqp::decont(self),
        #   GList,
        #   '$!data',
        #   nqp::decont( nativecast(Pointer, $nv) )
        # )
        # ...with this lesser one:
        #::?CLASS.^Attributes[0].set_value(self, $nv);
        # ... and now maybe this sensible one...
        $!data := $nv;
      };
  }
}

#| Skip Struct
class GLogField-Str         is repr<CStruct> does GLib::Roles::Pointers is export {
  has Str     $.key;
  has Str     $.value;
  has gssize  $.length is rw;

  method setValue (Str $v) {
    $!value := $v;
    $!length = $v.chars;
  }
}

class GLogField             is repr<CStruct> does GLib::Roles::Pointers is export {
  has Str     $.key;
  has Pointer $.value;
  has gssize  $.length is rw;

  method GLib::Raw::Structs::GLogField-Str
    is also<GLogField-Str>
  { cast(GLogField-Str, self) }


  method getValueStr {
    self.GLogField-Str.value;
  }

  method setValueStr (Str $v) {
    self.GLogField-Str.setValue($v);
  }
}

class GParamSpecTypeInfo    is repr<CStruct> does GLib::Roles::Pointers is export {
  # type system portion
  has guint16       $.n_preallocs   is rw;                            # optional
  has guint16       $.instance_size is rw;                            # obligatory
  has Pointer       $!instance_init;         # (GParamSpec   *pspec);   optional

  # class portion
  has GType         $.value_type    is rw;                            # obligatory
  has Pointer       $!finalize;              # (GParamSpec   *pspec); # optional
  has Pointer       $!value_set_default;     # (GParamSpec   *pspec,  # recommended
                                             #  GValue       *value);
  has Pointer       $!value_validate;        # (GParamSpec   *pspec,  # optional
                                             #  GValue       *value); # --> gboolean
  has Pointer       $!values_cmp;            # (GParamSpec   *pspec,  # recommended
                                             #  const GValue *value1,
                                             #  const GValue *value2) # --> gint

  # See comments on GSourceCallbackFuncs on how to properly implement
  # C-function-pointer handling.
  method instance_init is rw is also<instance-init> {
    Proxy.new:
      FETCH => sub ($) { $!instance_init },
      STORE => -> $, \func {
        $!finalize := set_func_pointer( &(func), &sprintf-Ps);
      };
  }

  method finalize is rw {
    Proxy.new:
      FETCH => sub ($) { $!finalize },
      STORE => -> $, \func {
        $!finalize := set_func_pointer( &(func), &sprintf-Ps);
      };
  }

  method value_set_default is rw is also<value-set-default> {
    Proxy.new:
      FETCH => sub ($) { $!finalize },
      STORE => -> $, \func {
        $!value_set_default := set_func_pointer( &(func), &sprintf-PsV);
      };
  }

  method value_validate is rw is also<value-validate> {
    Proxy.new:
      FETCH => sub ($) { $!value_validate },
      STORE => -> $, \func {
        $!value_validate := set_func_pointer( &(func), &sprintf-PsV-b);
      };
  }

  method value_cmp is rw is also<value-cmp> {
    Proxy.new:
      FETCH => sub ($) { $!values_cmp },
      STORE => -> $, \func {
        $!values_cmp := set_func_pointer( &(func), &sprintf-PsVV-i);
      };
  }

}

class GOnce                 is repr<CStruct> does GLib::Roles::Pointers is export {
  has guint    $.status;    # GOnceStatus
  has gpointer $.retval;
}

class GPtrArray             is repr<CStruct> does GLib::Roles::Pointers is export {
  has CArray[Pointer] $.pdata;
  has guint           $.len;
}

#| Skip Struct
class GPollFDNonWin         is repr<CStruct> does GLib::Roles::Pointers is export {
  has gint	    $.fd;
  has gushort 	$.events;
  has gushort 	$.revents;
}

#| Skip Struct
class GPollFDWin            is repr<CStruct> does GLib::Roles::Pointers is export {
  has gushort 	$.events;
  has gushort 	$.revents;
}

class GRecMutex             is repr<CStruct> does GLib::Roles::Pointers is export {
  # Private
  has gpointer $!p;
  has uint64   $!i    # guint i[2];
}

class GSignalInvocationHint is repr<CStruct> does GLib::Roles::Pointers is export {
  has guint   $.signal_id;
  has GQuark  $.detail;
  has guint32 $.run_type;             # GSignalFlags

  method signal-id { $!signal_id }
  method run-type  { $!run_type  }
}

class GSignalQuery          is repr<CStruct> does GLib::Roles::Pointers is export {
  has guint          $.signal_id;
  has Str            $.signal_name;
  has GType          $.itype;
  has guint32        $.signal_flags;  # GSignalFlags
  has GType          $.return_type;
  has guint          $.n_params;
  has CArray[uint64] $.param_types;

  method signal-id    { $!signal_id    }
  method signal-name  { $!signal_name  }
  method signal-flags { $!signal_flags }
  method return-type  { $!return_type  }
  method n-params     { $!n_params     }
  method param-types  { $!param_types  }
}

class GSList                is repr<CStruct> does GLib::Roles::Pointers is export {
  has Pointer $!data;
  has GSList  $.next;
}

class GSourceCallbackFuncs  is repr<CStruct> does GLib::Roles::Pointers is export {
  has Pointer $!ref,   # (gpointer     cb_data);
  has Pointer $!unref, # (gpointer     cb_data);
  has Pointer $!get,   # (gpointer     cb_data,
                       #  GSource     *source,
                       #  GSourceFunc *func,
                       #  gpointer    *data);

   submethod BUILD (:$ref, :$unref, :$get) {
     self.ref   = $ref   if $ref.defined;
     self.unref = $unref if $unref.defined;
     self.get   = $get   if $get.defined;
   }

   # Since this is a class of callbacks, it might behoove this class to
   # be a bit chimeric in it's handling of each member.
   #
   # Fortunately, we're already doing much of this with objects, so let's
   # emulate that behavior with function pointers.
   #
   # Below, each method will return a function pointer with :raw set,
   # OR a ready-to-use Callable if not.
   #
   # Callable return is implemented here, currently NYI over much of the larger
   # work
  method ref (:$raw = False) is rw {
    Proxy.new:
      FETCH => sub ($) {
        $raw ?? $!ref
             !! cast( :(gpointer --> int64), $!get );
      },
      STORE => -> $, \func {
        $!ref := set_func_pointer( &(func), &sprintf-P-L )
      };
  }

  method unref (:$raw = False) is rw {
    Proxy.new:
      FETCH => sub ($)        {
        $raw ?? $!unref
             !! cast( :(gpointer --> int64), $!unref)
      },
      STORE => -> $, \func {
        $!unref := set_func_pointer( &(func), &sprintf-P-L )
      };
  }

  method get (:$raw = False) is rw {
    Proxy.new:
      FETCH => sub ($) {
        $raw ?? $!get
             !! cast( :(gpointer, GSource, & (gpointer --> guint32), gpointer) )
      }
      STORE => -> $, \func {
        $!get := set_func_pointer( &(func), &sprintf-PSƒP )
      };
  }
};

class GSourceFuncs          is repr<CStruct> does GLib::Roles::Pointers is export {
  has Pointer $!prepare;          # (GSource    *source,
                                  #  gint       *timeout);
  has Pointer $!check;            # (GSource    *source);
  has Pointer $!dispatch;         # (GSource    *source,
                                  #  GSourceFunc callback,
                                  #  gpointer    user_data);
  has Pointer $!finalize;         # (GSource    *source); /* Can be NULL */
  has Pointer $!closure_callback;
  has Pointer $!closure_marshall;

  sub p-default  (GSource, CArray[gint] $t is rw --> gboolean) {
    $t[0] = 0;
    1;
  }
  sub cd-default (GSource --> gboolean) { 1 };

  submethod BUILD (
    :$prepare   = &p-default,
    :$check     = &cd-default,
    :$dispatch,
    :$finalize  = &cd-default
  ) {
    self.prepare  = $prepare;
    self.check    = $check;
    self.dispatch = $dispatch;
    self.finalize = $finalize;
  }

  method prepare is rw {
    Proxy.new:
      FETCH => sub ($) { $!prepare },
      STORE => -> $, \func {
        $!prepare := set_func_pointer( &(func), &sprintf-SCi-b);
      };
  }

  method check is rw {
    Proxy.new:
      FETCH => sub ($) { $!check },
      STORE => -> $, \func {
        $!check := set_func_pointer( &(func), &sprintf-S-b);
      }
  }

  method dispatch is rw {
    Proxy.new:
      FETCH => sub ($) { $!dispatch },
      STORE => -> $, \func {
        $!dispatch := set_func_pointer( &(func), &sprintf-SƒP-b);
      }
  }

  method finalize is rw {
    Proxy.new:
      FETCH => sub ($) { $!finalize },
      STORE => -> $, \func {
        $!finalize := set_func_pointer( &(func), &sprintf-S-b);
      }
  }

  method size-of (GSourceFuncs:U:) { return nativesizeof(GSourceFuncs) }

}

class GQueue                is repr<CStruct> does GLib::Roles::Pointers is export {
  has GList $!head;
  has GList $!tail;
  has guint $.length is rw; # Change WITH CARE!

  method head is rw {
    Proxy.new:
      FETCH => -> $             { $!head },
      STORE => -> $, GList() $h { $!head := $h };
  }

  method tail is rw {
    Proxy.new:
      FETCH => -> $             { $!tail },
      STORE => -> $, GList() $t { $!tail := $t };
  }

}

class GString               is repr<CStruct> does GLib::Roles::Pointers is export {
  has Str       $!str;
  has realUInt  $.len;
  has realUInt  $.allocated_len;

  method str is rw {
    Proxy.new:
      FETCH => -> $           { $!str       },
      STORE => -> $, Str() $v { $!str := $v };
  }

  method allocated-len { $!allocated_len }
}

class GTimeVal              is repr<CStruct> does GLib::Roles::Pointers is export {
  has glong $.tv_sec;
  has glong $.tv_usec;

  method tv_sec  { $!tv_sec  }
  method tv_usec { $!tv_usec }
};

class GTypeValueList        is repr('CUnion')  does GLib::Roles::Pointers is export {
  has int32	          $.v_int     is rw;
  has uint32          $.v_uint    is rw;
  has long            $.v_long    is rw;
  has ulong           $.v_ulong   is rw;
  has int64           $.v_int64   is rw;
  has uint64          $.v_uint64  is rw;
  has num32           $.v_float   is rw;
  has num64           $.v_double  is rw;
  has OpaquePointer   $.v_pointer is rw;

  method v-int     is rw { $!v_int     }
  method v-uint    is rw { $!v_uint    }
  method v-long    is rw { $!v_long    }
  method v-ulong   is rw { $!v_ulong   }
  method v-int64   is rw { $!v_int64   }
  method v-uint64  is rw { $!v_uint64  }
  method v-float   is rw { $!v_float   }
  method v-double  is rw { $!v_double  }
  method v-pointer is rw { $!v_pointer }
};

class GValue {
  has ulong           $!g_type;
  HAS GTypeValueList  $.data1  is rw;
  HAS GTypeValueList  $.data2  is rw;

  proto method g_type (|)
    is also<
      g-type
      type
    >
  { * }

  multi method g_type(:$fundamental is required) {
    # Subs from GLib::Raw::Types included here to prevent circularity.
    sub g_type_parent (GType)
      returns GType
      is native(gobject)
    { * }

    sub g_type_fundamental (GType)
      returns GType
      is native(gobject)
    { * }

    sub g_type_name (GType)
      returns Str
      is native(gobject)
    { * }

    my $f = g_type_fundamental($!g_type);
    say "Fundamental type of { g_type_name($!g_type) } is { g_type_name($f) }"
      if $DEBUG;

    GTypeEnum($f);
  }
  multi method g_type (:$enum = True) is rw {
    Proxy.new:
      FETCH => sub ($) {
         if $enum {
           return GTypeEnum($!g_type) if GTypeEnum.enums.values.any == $!g_type
         }
         $!g_type
      },

      STORE => -> $, Int() $i { $!g_type = $i };
  }

}

class GValueArray           is repr<CStruct> does GLib::Roles::Pointers is export {
  has guint    $.n_values;
  has gpointer $.values;          # GValue *
  has guint    $.n_preallocated;

  method n-values       { $!n_values       }
  method n-preallocated { $!n_preallocated }
}

class GParamSpec is repr<CStruct> does GLib::Roles::Pointers is export {
  also does GLib::Roles::TypeInstance;

  HAS GTypeInstance $.g_type_instance;
  has Str           $.name;          #= interned string
  has GParamFlags   $.flags;
  has GType         $.value_type;
  has GType         $.owner_type;    #= class or interface using this property

  # Private
  has Str           $!nick;
  has Str           $!blurb;
  has GData         $!qdata;
  has guint         $!ref_count;
  has guint         $!param_id;

  method getTypeName {
    self.g_type_instance.getTypeName;
  }

  method g_type_instance { $!g_type_instance }
  method value_type      { $!value_type      }
  method owner_type      { $!owner_type      }
  method ref_count       { $!ref_count       }
  method param_id        { $!param_id        }
}

class GParamSpecChar      is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gint8         $.minimum;
  has gint8         $.maximum;
  has gint8         $.default_value;

  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecUChar     is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has guint8        $.minimum;
  has guint8        $.maximum;
  has guint8        $.default_value;

  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecBoolean   is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gboolean      $.default_value;
}

class GParamSpecInt       is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gint          $.minimum;
  has gint          $.maximum;
  has gint          $.default_value;

  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecUInt      is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has guint         $.minimum;
  has guint         $.maximum;
  has guint         $.default_value;

  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecLong      is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has glong         $.minimum;
  has glong         $.maximum;
  has glong         $.default_value;

  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecULong     is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gulong        $.minimum;
  has gulong        $.maximum;
  has gulong        $.default_value;

  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecInt64     is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gint64        $.minimum;
  has gint64        $.maximum;
  has gint64        $.default_value;

  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecUInt64    is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has guint64       $.minimum;
  has guint64       $.maximum;
  has guint64       $.default_value;

  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecUnichar   is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gunichar      $.default_value;

  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecEnum      is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has Pointer       $!enum_class;        #= GEnumClass
  has gint          $.default_value;

  method enum_class {
    # Not defined here, so late binding!
    cast( ::('GEnumClass'), $!enum_class );
  }

  method enum-class      { self.enum_class }
  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecFlags     is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has Pointer       $!flags_class;       #= GFlagsClass;
  has guint         $.default_value;

  method flags_class {
    # Not defined here, so late binding!
    cast( ::('GFlagsClass'), $!flags_class );
  }

  method flags-class     { self.flags_class }
  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecFloat     is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gfloat        $.minimum;
  has gfloat        $.maximum;
  has gfloat        $.default_value;
  has gfloat        $.epsilon;

  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecDouble    is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gdouble       $.minimum;
  has gdouble       $.maximum;
  has gdouble       $.default_value;
  has gdouble       $.epsilon;

  method parent-instance { $!parent_instance }
  method default-value   { $!default_value   }
}

class GParamSpecValueArray  is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has GParamSpec    $.element_spec;
  has guint         $.fixed_n_elements;

  method parent-instance                 { $!parent_instance  }
  method element-spec                    { $!element_spec     }
  method fixed-n-elements is also<elems> { $!fixed_n_elements }
}

# Global subs requiring above structs
sub gerror-blank is export {
  CArray[Pointer[GError]];
}

sub gerror is export {
  my $cge = CArray[Pointer[GError]].new;
  $cge[0] = Pointer[GError];
  $cge;
}

sub g_error_free(GError $err)
  is native(glib)
  is export
{ * }

sub clear_error ($error = $ERROR) is export {
  g_error_free($error) if $error.defined;
  $ERROR = Nil;
}

sub get-error ($e) is export {
  $e.defined ??
    ( $e[0].defined ?? $e[0].deref !! GError )
    !!
    Nil
}

sub set_error(CArray $e) is export {
  if $e[0].defined {
    $ERROR = %ERROR{$*PID} = get-error($e);
    X::GLib::Error.new($ERROR).throw if $ERROR-THROWS;
    #%ERRROS{$*PID}.push: [ $ERROR-REPLACEMENT(), Backtrace.new ];
    @ERRORS.push: [ $ERROR, Backtrace.new ];
  }
}

sub no-error ($e?) is export {
  return True if $e.defined.not && $ERROR.defined.not;

  my $error := $e ?? get-error($e) !! $ERROR;
  return True unless $error.domain > 0;
  return True unless $error.code   > 0;
  return False;
}

sub sprintf-Ps (
  Blob,
  Str,
  & (GParamSpec),
  gpointer
)
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub sprintf-PsV (
  Blob,
  Str,
  & (GParamSpec, GValue),
  gpointer
 --> int64
)
    is native is symbol('sprintf') { * }

sub sprintf-PsV-b (
  Blob,
  Str,
  & (GParamSpec, GValue --> gboolean),
  gpointer
)
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

sub sprintf-PsVV-i (
  Blob,
  Str,
  & (GParamSpec, GValue, GValue --> gint),
  gpointer
)
  returns int64
  is export
  is native
  is symbol('sprintf')
{ * }

# Must be declared LAST.
constant GPollFD            is export = $*DISTRO.is-win ?? GPollFDWin !! GPollFDNonWin;

class GClosure            is repr<CStruct> does GLib::Roles::Pointers is export {
  has uint64 $!dummy1;
  has uint64 $!dummy2;
  has uint64 $!dummy3;
  has uint64 $!dummy4;
}

class GCClosure           is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GClosure $!dummy1;
  has gpointer $!callback;
}

class GDebugKey           is repr<CStruct> does GLib::Roles::Pointers is export {
  has Str   $.key;
  has guint $.value;
}

class GOptionEntry        is repr<CStruct> does GLib::Roles::Pointers is export {
  has Str         $!long_name;
  has Str         $!short_name;
  has gint        $.flags            is rw;
  has GOptionArg  $.arg              is rw;
  has gpointer    $!arg_data;
  has Str         $!description;
  has Str         $!arg_description;

  method long_name is rw is also<long-name> {
    Proxy.new:
      FETCH => sub ($)        { self.^attributes(:local)[0].get_value(self) },
      STORE => -> $, Str() \s { self.^attributes(:local)[0]
                                    .set_value(self, s)                     };
  }

  method short_name is rw is also<short-name> {
    Proxy.new:
      FETCH => sub ($)        { self.^attributes(:local)[1].get_value(self) },
      STORE => -> $, Str() \s { self.^attributes(:local)[1]
                                    .set_value(self, s)                     };
  }

  method arg_data is rw is also<arg-data> {
    Proxy.new:
      FETCH => sub ($)           { self.^attributes(:local)[4].get_value(self) },
      STORE => -> $, gpointer \p { self.^attributes(:local)[4]
                                       .set_value(self, p)                     };
  }

  method description is rw {
    Proxy.new:
      FETCH => sub ($)        { self.^attributes(:local)[5].get_value(self) },
      STORE => -> $, Str() \s { self.^attributes(:local)[5]
                                    .set_value(self, s)                     };
  }

  method arg_description is rw is also<arg-description> {
    Proxy.new:
      FETCH => sub ($)           { self.^attributes(:local)[6].get_value(self) },
      STORE => -> $, gpointer \p { self.^attributes(:local)[6]
                                       .set_value(self, p)                     };
  }

};

# TO BE EXPANDED UPON, LATER!

class GInterfaceInfo      is repr<CStruct> does GLib::Roles::Pointers is export {
  has Pointer $!interface_init;     #= GInterfaceInitFunc
  has Pointer $!interface_finalize; #= GInterfaceFinalizeFunc
  has Pointer $!interface_data;

  method interface_init     { $!interface_init     }
  method interface_finalize { $!interface_finalize }
  method interface_data     { $!interface_data     }
}

class GTypeValueTable     is repr<CStruct> does GLib::Roles::Pointers is export {
  has Pointer $!value_init;         #= (GValue       *value);
  has Pointer $!value_free;         #= (GValue       *value);
  has Pointer $!value_copy;         #= (const GValue *src_value, GValue *dest_value);
  # varargs functionality (optional)
  has Pointer $!value_peek_pointer; #= (const GValue *value --> Pointer);
  has Str     $!collect_format;
  has Pointer $!collect_value;      #= (GValue *value, guint n_collect_values, GTypeCValue *collect_values, guint collect_flags --> Str);
  has Str     $!lcopy_format;
  has Pointer $!lcopy_value;        #= (const GValue *value, guint n_collect_values, GTypeCValue *collect_values, guint collect_flags --> Str);

  method value_init         { $!value_init         }
  method value_free         { $!value_free         }
  method value_copy         { $!value_copy         }
  method value_peek_pointer { $!value_peek_pointer }
  method collect_format     { $!collect_format     }
  method collect_value      { $!collect_value      }
  method lcopy_format       { $!lcopy_format       }
  method lcopy_value        { $!lcopy_value        }
}

class GTypeQuery          is repr<CStruct> does GLib::Roles::Pointers is export {
  has GType $!type;
  has Str   $!type_name;
  has guint $!class_size;
  has guint $!instance_size;

  method type-name     { $!type_name     }
  method class-size    { $!class_size    }
  method instance-size { $!instance_size }
}

class GTypeInfo           is repr<CStruct> does GLib::Roles::Pointers is export {
  # interface types, classed types, instantiated types
  has guint16         $!class_size;
  has Pointer         $!base_init;      #= GBaseInitFunc
  has Pointer         $!base_finalize;  #= GBaseFinalizeFunc
  # interface types, classed types, instantiated types
  has Pointer         $!class_init;     #= GClassInitFunc
  has Pointer         $!class_finalize; #= GClassFinalizeFunc
  has Pointer         $!class_data;     #= gconstpointer
  # instantiated types
  has guint16         $!instance_size;
  has guint16         $!n_preallocs;
  has Pointer         $!instance_init;  #= GInstanceInitFunc
  # value handling
  has GTypeValueTable $!value_table;

  method class-size     { $!class_size     }
  method base-init      { $!base_init      }
  method base-finalize  { $!base_finalize  }
  method class-init     { $!class_init     }
  method class-finalize { $!class_finalize }
  method class-data     { $!class_data     }
  method instance-size  { $!instance_size  }
  method n-preallocs    { $!n_preallocs    }
  method instance-init  { $!instance_init  }
  method value-table    { $!value_table    }

}

class GTypeFundamentalInfo is repr<CStruct> does GLib::Roles::Pointers is export {
  has GTypeFundamentalFlags $!type_flags;
}


our subset GObjectOrPointer of Mu is export
  where ::('GLib::Roles::Object') | GObject | GLib::Roles::Pointers;

class GHookList                  is repr<CStruct> does GLib::Roles::Pointers is export {
  has gulong  $.seq_id;
  has guint   $.hook_size;                # :16
  has guint   $.is_setup;                 # :1
  has GHook   $.hooks;
  has Pointer $!dummy3;
  has Pointer $.finalize_hook;            # GHookFinalizeFunc
  HAS Pointer @!dummy[2]       is CArray;

  method seq-id        { $!seq_id }
  method hook-size     { $!hook_size }
  method is-setup      { $!is_setup }
  method finalize-hook { $!finalize_hook }
}

class GParameter            is repr<CStruct> does GLib::Roles::Pointers is export {
  has Str    $!name;
  HAS GValue $!value;

  method name is rw {
    Proxy.new:
      FETCH => sub ($)                { $!name },
      STORE => -> $, Str() $val    { self.^attributes(:local)[0]
                                         .set_value(self, $val)    };
  }

  method value is rw {
    Proxy.new:
      FETCH => sub ($)                { $!value },
      STORE => -> $, GValue() $val { self.^attributes(:local)[0]
                                         .set_value(self, $val)    };
  }
}

# class GDataElt              is repr<CStruct> does GLib::Roles::Pointers is export {
#   has GQuark         $!key;
#   has Pointer        $!data;
#   has GDestroyNotify $!destroy;
# }
#
# class GData                 is repr<CStruct> does GLib::Roles::Pointers is export {
#   has guint32  $!len;
#   has guint32  $!alloc;
#   HAS GDataElt @.data[1] is CArray;
# }
#
# class GDataset              is repr<CStruct> does GLib::Roles::Pointers is export {
#   has Pointer $!location;
#   has Pointer $!datalist;
# }

class GTestConfig            is repr<CStruct> does GLib::Roles::Pointers is export {
  has gboolean      $.test_initialized is rw;
  has gboolean      $.test_quick       is rw; #= disable thorough tests
  has gboolean      $.test_perf        is rw; #= run performance tests
  has gboolean      $.test_verbose     is rw; #= extra info
  has gboolean      $.test_quiet       is rw; #= reduce output
  has gboolean      $.test_undefined   is rw; #= run tests that are meant to assert

  method test-initialized is rw { $!test_initialized }
  method test-quick       is rw { $!test_quick }
  method test-perf        is rw { $!test_perf }
  method test-verbose     is rw { $!test_verbose }
  method test-quiet       is rw { $!test_quiet }
  method test-undefined   is rw { $!test_undefined }
}

class GTestLogMsg            is repr<CStruct> does GLib::Roles::Pointers is export {
  has GTestLogType  $.log_type         is rw;
  has guint         $.n_strings        is rw;
  has CArray[Str]   $.strings               ; #= NULL terminated
  has guint         $.n_nums           is rw;
  has CArray[num64] $.nums                  ;

  method log-type  is rw { $!log_type  }
  method n-strings is rw { $!n_strings }
  method n-nums    is rw { $!n_nums    }
}

class GTestLogBuffer         is repr<CStruct> does GLib::Roles::Pointers is export {
  has GString       $!data;
  has GSList        $!msgs;
}

class GMutex                 is repr<CUnion>  does GLib::Roles::Pointers is export {
  has gpointer      $!p;
  HAS guint         @!i[2] is CArray;
}

class GNode                  is repr<CStruct>  does GLib::Roles::Pointers is export {
  has gpointer $!data;
  has GNode    $!next;
  has GNode    $!prev;
  has GNode    $!parent;
  has GNode    $!children;

  method data is rw {
    Proxy.new:
      FETCH => -> $              { $!data },
      STORE => -> $, gpointer $d { $!data := $d };
  }

  method next is rw {
    Proxy.new:
      FETCH => -> $             { $!next },
      STORE => -> $, GNode() $n { $!next := $n };
  }

  method prev is rw {
    Proxy.new:
      FETCH => -> $             { $!prev },
      STORE => -> $, GNode() $n { $!prev := $n };
  }

  method parent is rw {
    Proxy.new:
      FETCH => -> $             { $!parent },
      STORE => -> $, GNode() $n { $!parent := $n };
  }

  method children is rw {
    Proxy.new:
      FETCH => -> $             { $!children },
      STORE => -> $, GNode() $n { $!children := $n };
  }

  # Use in place of GNODE_IS_ROOT
  method is_root is also<is-root> {
    $!parent.defined.not && $!prev.defined.not && $!next.defined.not
  }

  # Use in place of GNODE_IS_LEAF
  method is_leaf is also<is-leaf> { $!children.defined.not }

}

class GWeakRef               is repr<CStruct>  does GLib::Roles::Pointers is export {
  has Pointer $!priv;
}
