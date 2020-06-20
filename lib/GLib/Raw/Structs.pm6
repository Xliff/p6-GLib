use v6.c;

use NativeCall;
use Method::Also;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Subs;
use GLib::Raw::Struct_Subs;

use GLib::Roles::Pointers;
use GLib::Roles::TypeInstance;

unit package GLib::Raw::Structs;

class GValue                is repr<CStruct> does GLib::Roles::Pointers is export { ... }

# Structs
class GArray                is repr<CStruct> does GLib::Roles::Pointers is export {
  has Str    $.data;
  has uint32 $.len;
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
}

class GList                 is repr<CStruct> does GLib::Roles::Pointers is export {
  has Pointer $!data;
  has GList   $.next;
  has GList   $.prev;

  method data is rw {
    Proxy.new:
      FETCH => sub ($)              { $!data },
      STORE => -> $, GList() $nv {
        # Thank GOD we can now replace this monstrosity:
        # nqp::bindattr(
        #   nqp::decont(self),
        #   GList,
        #   '$!data',
        #   nqp::decont( nativecast(Pointer, $nv) )
        # )
        # ...with this lesser one:
        ::?CLASS.^Attributes[0].set_value(self, $nv);
      };
  }
}

class GLogField             is repr<CStruct> does GLib::Roles::Pointers is export {
  has Str     $.key;
  has Pointer $.value;
  has gssize  $.length;
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

  method instance_init is rw {
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

  method value_set_default is rw {
    Proxy.new:
      FETCH => sub ($) { $!finalize },
      STORE => -> $, \func {
        $!value_set_default := set_func_pointer( &(func), &sprintf-PsV);
      };
  }

  method value_validate is rw {
    Proxy.new:
      FETCH => sub ($) { $!value_validate },
      STORE => -> $, \func {
        $!value_validate := set_func_pointer( &(func), &sprintf-PsV-b);
      };
  }

  method value_cmp is rw {
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
}

class GSignalQuery          is repr<CStruct> does GLib::Roles::Pointers is export {
  has guint          $.signal_id;
  has Str            $.signal_name;
  has GType          $.itype;
  has guint32        $.signal_flags;  # GSignalFlags
  has GType          $.return_type;
  has guint          $.n_params;
  has CArray[uint64] $.param_types;
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

  method ref is rw {
    Proxy.new:
      FETCH => sub ($)        { $!ref },
      STORE => -> $, \func {
        $!ref := set_func_pointer( &(func), &sprintf-P-L )
      };
  }

  method unref is rw {
    Proxy.new:
      FETCH => sub ($)        { $!unref },
      STORE => -> $, \func {
        $!unref := set_func_pointer( &(func), &sprintf-P-L )
      };
  }

  method get is rw {
    Proxy.new:
      FETCH => sub ($)        { $!get },
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

class GString               is repr<CStruct> does GLib::Roles::Pointers is export {
  has Str       $.str;
  has realUInt  $.len;
  has realUInt  $.allocated_len;
}

class GTimeVal              is repr<CStruct> does GLib::Roles::Pointers is export {
  has glong $.tv_sec;
  has glong $.tv_usec;
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
};

class GValue {
  has ulong           $!g_type;
  HAS GTypeValueList  $.data1  is rw;
  HAS GTypeValueList  $.data2  is rw;

  method g_type is also<g-type type> is rw {
    Proxy.new:
      FETCH => -> $           { GTypeEnum($!g_type) },
      STORE => -> $, Int() $i { $!g_type = $i };
  }
}

class GValueArray           is repr<CStruct> does GLib::Roles::Pointers is export {
  has guint    $.n_values;
  has gpointer $.values;          # GValue *
  has guint    $.n_preallocated;
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
}

class GParamSpecChar      is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gint8         $.minimum;
  has gint8         $.maximum;
  has gint8         $.default_value;
}

class GParamSpecUChar     is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has guint8        $.minimum;
  has guint8        $.maximum;
  has guint8        $.default_value;
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
}

class GParamSpecUInt      is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has guint         $.minimum;
  has guint         $.maximum;
  has guint         $.default_value;
}

class GParamSpecLong      is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has glong         $.minimum;
  has glong         $.maximum;
  has glong         $.default_value;
}

class GParamSpecULong     is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gulong        $.minimum;
  has gulong        $.maximum;
  has gulong        $.default_value;
}

class GParamSpecInt64     is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gint64        $.minimum;
  has gint64        $.maximum;
  has gint64        $.default_value;
}

class GParamSpecUInt64    is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has guint64       $.minimum;
  has guint64       $.maximum;
  has guint64       $.default_value;
}

class GParamSpecUnichar   is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gunichar      $.default_value;
}

class GParamSpecEnum      is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has Pointer       $.enum_class; #= GEnumClass
  has gint          $.default_value;
}

class GParamSpecFlags     is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has Pointer       $.flags_class; #= GFlagsClass;
  has guint         $.default_value;
}

class GParamSpecFloat     is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gfloat        $.minimum;
  has gfloat        $.maximum;
  has gfloat        $.default_value;
  has gfloat        $.epsilon;
}

class GParamSpecDouble    is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has gdouble       $.minimum;
  has gdouble       $.maximum;
  has gdouble       $.default_value;
  has gdouble       $.epsilon;
}

class GParamSpecValueArray  is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GParamSpec    $.parent_instance;
  has GParamSpec    $.element_spec;
  has guint         $.fixed_n_elements;
}

# Global subs requiring above structs
sub gerror is export {
  my $cge = CArray[Pointer[GError]].new;
  $cge[0] = Pointer[GError];
  $cge;
}

sub g_error_free(GError $err)
  is native(glib)
  is export
{ * }

sub clear_error($error = $ERROR) is export {
  g_error_free($error) if $error.defined;
  $ERROR = Nil;
}

sub set_error(CArray $e) is export {
  $ERROR = $e[0].deref if $e[0].defined;
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

  method long_name is rw {
    Proxy.new:
      FETCH => sub ($)        { self.^attributes(:local)[0].get_value(self) },
      STORE => -> $, Str() \s { self.^attributes(:local)[0]
                                    .set_value(self, s)                     };
  }

  method short_name is rw {
    Proxy.new:
      FETCH => sub ($)        { self.^attributes(:local)[1].get_value(self) },
      STORE => -> $, Str() \s { self.^attributes(:local)[1]
                                    .set_value(self, s)                     };
  }

  method arg_data is rw {
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

  method arg_description is rw {
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
}

class GTypeQuery          is repr<CStruct> does GLib::Roles::Pointers is export {
  has GType $!type;
  has Str   $!type_name;
  has guint $!class_size;
  has guint $!instance_size;
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
}

class GTypeFundamentalInfo is repr<CStruct> does GLib::Roles::Pointers is export {
  has GTypeFundamentalFlags $!type_flags;
}


our subset GObjectOrPointer of Mu is export
  where ::('GLib::Roles::Object') | GObject | GLib::Roles::Pointers;

class GHookList                  is repr<CStruct> does GLib::Roles::Pointers is export {
  has gulong  $.seq_id;
  has guint   $.hook_size; # :16
  has guint   $.is_setup; # :1
  has GHook   $.hooks;
  has Pointer $!dummy3;
  has Pointer $.finalize_hook; # GHookFinalizeFunc
  HAS Pointer @!dummy[2] is CArray;
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
