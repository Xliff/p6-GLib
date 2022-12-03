use v6.c;

use NativeCall;
use NativeHelpers::Blob;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;

use GLib::Object::Supplyish;

use GLib::Roles::Pointers;

package GLib::Raw::Subs {
  # Cribbed from https://github.com/CurtTilmes/perl6-dbmysql/blob/master/lib/DB/MySQL/Native.pm6
  sub malloc         (size_t --> Pointer)                    is export is native { * }
  sub realloc        (Pointer, size_t --> Pointer)           is export is native { * }
  sub calloc         (size_t, size_t --> Pointer)            is export is native { * }
  sub memcpy         (Pointer, Pointer, size_t --> Pointer)  is export is native { * }
  sub memcmp         (Pointer, Pointer, size_t --> int32)    is export is native { * }
  sub memset         (Pointer, int32, size_t)                is export is native { * }
  sub dup2           (int32, int32 --> int32)                is export is native { * }
  sub isatty         (int32 --> int32)                       is export is native { * }
  # Needed for minimal I18n
  sub setlocale      (int32, Str --> Str)                    is export is native { * }

  sub native-open    (Str, int32, int32 $m = 0)
    is export
    is symbol('open')
    is native
  { * }

  role StructSkipsTest[Str $R] is export {
    method reason { $R }
  }

  # So as not to collide with the CORE sub.
  sub native-close   (int32 --> int32)
    is export
    is symbol('close')
    is native
  { * }

  our proto sub free (|) is export { * }
  multi sub free (Pointer)                           is export is native { * }

  # Cribbed from https://stackoverflow.com/questions/1281686/determine-size-of-dynamically-allocated-memory-in-c
  sub malloc_usable_size (Pointer --> size_t)        is export is native { * }

  # Implement memcpy_pattern. Take pattern and write pattern.^elem bytes to successive areas in dest.

  sub getEndian is export {
    ( $*KERNEL.endian == BigEndian, $*KERNEL.endian == LittleEndian );
  }

  sub cast($cast-to, $obj) is export {
    nativecast($cast-to, $obj);
  }

  # This is a version of cast() that is ammenable to the .& form.
  # So:
  #      $a-poiner.&recast(AnotherType)
  sub recast ($obj, $cast-to) is export {
    cast($cast-to, $obj);
  }

  sub real-resolve-uint64($v) is export {
    $v +& 0xffffffffffffffff;
  }

  # p = Pointer
  sub p ($p) is export {
    cast(Pointer, $p);
  }

  # ba = Byte Array
  sub ba ($o) is export {
    cast(CArray[uint8], $o);
  }

  # Moved from p6-GStreamer
  sub nolf ($s) is export {
    $s.subst("\n", ' ', :g);
  }

  sub lf ($s) is export {
    $s.subst("\r\n", "\n", :g);
  }

  sub crlf ($s) is export {
    $s.subst("\n", "\r\n", :g);
  }

  proto sub intRange (|) is export
  { * }

  multi sub intRange (\T) {
    my $name = T.^name;
    (my $bits = $name) ~~ s/.+? (\d+) $/$0/;
    $bits .= Int;
    samewith( :$bits, signed => $name.starts-with('u').not )
  }
  multi sub intRange ($bits where *.defined, $signed = False) {
    intRange(:$bits, :$signed);
  }
  multi sub intRange (:$bits, :$signed = False) {
    $signed ??
      -1 * 2 ** ($bits - 1) .. 2 ** ($bits - 1) - 1
      !!
      0 .. 2 ** $bits
  }

  # cw: Coerces the value of $a to a value within $r.
  sub clamp($a, Range() $r) is export {
    max( $r.min, min($a, $r.max) )
  }

  sub unstable_get_type($name, &sub, $n is rw, $t is rw) is export {
    return $t if ($n // 0) > 0;
    repeat {
      $t = &sub();
      die "{ $name }.get_type could not get stable result"
        if $n++ > 20;
    } until $t == &sub();
    $t;
  }

  # This should be in CORE!
  sub separate (Str() $s, Int() $p) is export {
    die '$p outside of string range!' unless $p ~~ 0 .. $s.chars;
    ( $s.substr(0, $p), $s.substr($p, *) )
  }

  sub createReturnArray (\T) is export {
    my \at = T.REPR eq 'CStruct' ?? Pointer[T] !! T;
    (my $a = CArray[at].new)[0] = at;
    $a;
  }

  sub updateHash (%h, %ct, :$reverse = True) {
    state $l = Lock.new;

    $l.protect: {
      %h.append(
        $reverse ?? %ct.antipairs.Hash !! %ct
      );
    }
  }

  sub updateTypeClass(%ct, :$reverse = True) is export {
    updateHash(%typeClass, %ct, :$reverse);
  }

  sub updateTypeOrigin(%to, :$reverse = False) is export {
    updateHash(%typeOrigin, %to, :$reverse);
  }

  sub isGTypeAnInteger ($v) is export {
    return True if $v == $_ for G_TYPE_INT   ,
                                G_TYPE_UINT  ,
                                G_TYPE_LONG  ,
                                G_TYPE_ULONG ,
                                G_TYPE_INT64 ,
                                G_TYPE_UINT64;
    return False;
  }

  sub resolveNativeType (\T) is export {
    say "Resolving { T.^name } to its Raku equivalent...";
    do given T {
      when num32 | num64     { Num }

      when int8  | uint8  |
           int16 | uint16 |
           int32 | uint32 |
           int64 | uint64
                             { Int }

      when str               { Str }

      default                {
        do if T.REPR eq <CPointer CStruct>.any {
          T
        } else {
          # cw: I don't know if this is the best way to handle this.
          die "Do not know how to handle a type of { .^name }!";
        }
      }
    }
  }

  sub checkForType(\T, $v is copy) is export {
    if T !=== Nil {
      unless $v ~~ T {
        #say "Attempting to convert a { $v.^name } to { T.^name }...";
        my $resolved-name = resolveNativeType(T).^name;
        $resolved-name ~= "[{ T.of.^name }]" if $resolved-name eq 'CArray';
        #say "RN: { $resolved-name }";
        if $v.^lookup($resolved-name) -> $m {
          #say "Using coercer at { $v.^name }.$resolved-name...";
          $v = $m($v);
        }
        # Note reversal of usual comparison. This is due to the fact that
        # nativecall types must be compatible with the value, not the
        # other way around. In all other cases, T and $v should have
        # the same type value.
        die "Value does not support { $v.^name } variables. Will only accept {
          T.^name }!" unless T ~~ $v.WHAT;
      }
    }
    $v;
  }

  sub ArrayToCArray(\T, @a, :$size = @a.elems, :$null = False) is export {
    enum Handling <P NP>;
    my $handling;
    my $ca = (do given (T.REPR // '') {
      when 'P6opaque' {
        when T ~~ Str                     { $handling = P;  CArray[T]          }

        proceed
      }

      when 'CPointer' | 'P6str'  |
           'P6num'    | 'P6int'           { $handling = P;  CArray[T]          }
      when 'CStruct'  | 'CUnion'          { $handling = NP; CArray[Pointer[T]] }

      default {
        "ArrayToCArray does not know how to handle a REPR of '$_' for type {
         T.^name }"
      }
    });

    say "CA: { $ca.^name } / { $size }" if $DEBUG;

    return $ca unless @a.elems;
    $ca = $ca.new;
    for ^$size {
      my $typed = checkForType(T, @a[$_]);

      $ca[$_] = $handling == P ?? $typed !! cast(Pointer[T], $typed)
    }
    if $null {
      $ca[$size] = do given T {
        when Int             { 0          }
        when Num             { 0e0        }
        when Str             { Str        }
        when $handling == P  { T          }
        when $handling == NP { Pointer[T] }
      }
    }

    $ca;
  }

  multi sub CStringArrayToArray(CArray[Str] $sa, Int(Cool) $len) is export {
    CArrayToArray($sa, $len);
  }
  multi sub CStringArrayToArray (CArray[Str] $sa) is export {
    CArrayToArray($sa)
  }

  multi sub CArrayToArray(CArray $ca) is export {
    return Nil unless $ca;
    my ($i, @a) = (0);
    while $ca[$i] {
      @a.push: $ca[$i++];
    }
    @a;
  }
  multi sub CArrayToArray(CArray $ca, Int(Cool) $len) is export {
    return Nil unless $ca;
    my @a;
    @a[$_] = $ca[$_] for ^$len;
    @a;
  }

  sub getFlags($t, $s) is export {
    $t.pairs
      .grep({ $s +& .value })
      .map( *.key )
      .Set
  }

  sub fromFlagish ($E, $val) is export {
    $val = [+|]( |$val.map({ $E(.key).value }) )
      if $val ~~ Set;
    $val = [+|]( |$val ) if $val ~~ Positional;
    $val .= Int if $val !~~ Int && $val.^can('Int');
  }

  # GLib-level
  sub typeToGType (\t) is export {
    do given t {
      when Str             { G_TYPE_STRING  }
      when int16  | int32  { G_TYPE_INT     }
      when uint16 | uint32 { G_TYPE_UINT    }
      when int64           { G_TYPE_INT64   }
      when uint64          { G_TYPE_UINT64  }
      when num32           { G_TYPE_FLOAT   }
      when num64           { G_TYPE_DOUBLE  }
      when Pointer         { G_TYPE_POINTER }
      when Bool            { G_TYPE_BOOLEAN }
      when GObject         { G_TYPE_OBJECT  }
    };
  }

  sub resolve-gtype($gt) is export {
    die "{ $gt } is not a valid GType value"
      unless $gt ∈ GTypeEnum.enums.values;
    $gt;
  }

  multi sub resolve-gstrv(CArray[Str] $p, $length?) is export {
    my $l = $length // try $p.elems;
    die "Cannot determine the size of a CArray.{
         ''} Please use the \$length parameter in call to resolve-gstrv()!"
      if $l ~~ Failure;

    $p[ $l ] = Str unless $p[$l - 1] =:= Str;
    $p;
  }
  multi sub resolve-gstrv(@rg) is export {
    resolve-gstrv( |@rg );
  }
  multi sub resolve-gstrv( *@rg where *.all !~~ Positional ) is export {
    my $gs = CArray[Str].new;
    my $c = 0;
    for @rg {
      die "Cannot coerce element { $_.^name } to string."
        unless $_ ~~ Str || $_.^can('Str').elems;
      $gs[$c++] = $_.Str;
    }
    $gs[$gs.elems] = Str unless $gs[* - 1] =:= Str;
    $gs;
  }

  sub getBackupPath ($p is copy, $pre = 'bak') is export {
    $p .= IO if $p ~~ Str;
    my ($safe-fh, $serial);
    my $fhp = $p;
    repeat {
      $safe-fh = $fhp.extension("{ $pre }{ $serial++ }", parts => 0);
    } until $safe-fh.e.not;
    $safe-fh;
  }

  #sub create-signal-supply (%sigs, $signal, $s) is export {
  #  GLib::Object::Supplyish.new($s.Supply, %sigs, $signal);
    # my $supply = $s.Supply;
    #
    # $supply.^lookup('tap').wrap: my method (|c) {
    #   %sigs{$signal} = True;
    #   # # cw: Wrap on the Callable in |c to add the default
      # #     exception handler.
      # if c.list[0] ~~ Callable {
      #   my $wrapped = sub (|a) {
      #     CATCH { default { .message.say; .backtrace.concise.say } }
      #     c.list[0](|a);
      #   }
      #   nextwith($supply, $wrapped, |c.hash)
      # } else {
      #   nextsame;
      # }
    #   nextsame;
    # };
    # $supply
  #}

  #| ppr(*@a) - Potential Pointer Return. Handles values, potentially pointers,
  #|            that are wrapped in a CArray. If value is a Pointer type AND
  #|            a CStruct, then that value will be dereferenced.
  sub ppr (*@a) is export {
    @a .= map({
      if $_ ~~ CArray {
        if .[0].defined {
          if .[0].REPR.chars.not {
            .[0]
          } else {
            my $p = .[0];
            $p.defined ?? ( .[0] !~~ Pointer ?? .[0]
                                             !! do {
                                                 say "PPR0: { .[0].of.^name }";
                                                 say "PPR1: { .[0].of.REPR }";
                                                 .[0].of.REPR eq 'CStruct'
                                                    ?? .[0].deref
                                                    !! .[0]
                                                }
                          )
                       !! Nil;
          }
        } else {
          Nil;
        }
      }
      else { $_ }
    });
    @a.elems == 1 ?? @a[0] !! @a;
  }

  sub return-with-all ($v) is export {
    $v[0] ?? ( $v.elems == 1 ?? $v !! $v.skip(1) )
          !! Nil
  }

  sub returnFlags ($value, $returnFlags, \FT) is export {
    return $value unless $returnFlags;
    getFlags(FT, $value)
  }

  # The assumption here is "Transfer: Full"
  sub propReturnObject (
    $oo,
    $raw,
    \P,
    $C?                    is raw,
    :$ref                          =  False,
    :$attempt-real-resolve         =  False
  ) is export {
    my $o = $oo;
    return Nil unless $o;

    unless $attempt-real-resolve {
      $o = cast(P, $o);
      return $o if $raw || $C === Nil;

      return $C.new($o, :$ref)
    }

    my $o1   = GLib::Object.new( cast(GObject, $o) );
    my $type = $o1.objectType.name;

    return cast( ::($type), $o );

    $o1.createAsOriginal;
  }

  sub returnObject       (|c) is export { propReturnObject( |c ) }
  sub returnProperObject (|c) is export { propReturnObject( |c ) }

  sub subarray ($a, $o) is export {
    my $b = nativecast(Pointer[$a.of], $a);
    nativecast(CArray[$a.of], $b.add($o) );
  }

  sub nativeSized (\T, *%options) is export {
    given T {
      when int8  | uint8                   { 1 }
      when int16 | uint16                  { 2 }
      when int32 | uint32                  { 4 }
      when int64 | uint64                  { 8 }
      when num32                           { 4 }
      when num64                           { 8 }
      when Str                             { $*KERNEL.bits div 8 }
      when Int   | Num                     { %options<double> ?? 32 !! 64 }
      when .REPR eq <CStruct CPointer>.any { $*KERNEL.bits div 8 }

      default {
        # cw: Really need to start typing these!!
        die "Do not have type sizing rules for { T.^name }!";
      }
    }
  }

  sub fromPointer (
    $v,
    $typed,
    :$signed   = False,
    :$double   = False,
    :$encoding = 'utf8',
  )
    is export
  {
    return $v unless $typed !=== Nil;

    do given $typed {
      when Int {
        $_ = $double ?? ( $signed ?? int64 !! uint64 )
                     !! ( $signed ?? int32 !! uint32 );
        proceed;
      }

      when Num {
        $_ = $double ?? num64 !! num32;
        proceed;
      }

      when int32 | int64 | uint32 | uint64 | num32 | num64 {
        cast(CArray[$_], $v)[0]
      }

      when Str {
        do if $encoding ne 'utf8' {
          # cw: Proper path
          Buf.new( cast(CArray[uint8], $v) ).decode($encoding);
        } else {
          # cw: Fast path
          cast(Str, $v);
        }
      }

      when .REPR eq <CStruct CPointer>.any {
        cast($_, $v);
      }

      default {
        die "Don't know how to handle { $typed.^name } when converting from a {
            '' }pointer";
      }

    }
  }

  sub toPointer (
    $value,
    :$signed   = False,
    :$double   = False,
    :$direct   = False,
    :$encoding = 'utf8',
    :$all      = False,
    :$typed    = Str
  )
    is export
  {
    # Properly handle non-Str Cool data.
    return $value if $value ~~ Pointer;
    return ($typed !=== Nil ?? $typed !! Nil) unless $value.defined;
    my ($ov, $use-arr, \t, $v) = ( checkForType($typed, $value), False );
    if $ov ~~ Int && $direct {
      $v = Pointer.new($ov);
    } else {
      given $ov {
        # For all implementor-based classes
        when .^lookup('p').so { $ov .= p }

        when Rat { $ov .= Num; proceed }
        when Int {
          $use-arr = True;
          when $signed.so { t := $double ?? CArray[int64] !!  CArray[int32]  }
          default         { t := $double ?? CArray[uint64] !! CArray[uint32] }
        }
        when Rat | Num {
          $use-arr = True;
          t := $double ?? CArray[num64] !!  CArray[num32]
        }

        # Str
        default {
          $ov = ~$ov unless $ov ~~ Str;
          t := Str;
          # Better to use CArray[uint8] as it is less volatile than Str;
          my $ca = CArray[uint8].new( $ov.encode($encoding) );
          $ov = pointer-to($ca);
        }
      }
      if $use-arr {
        $v    = t.new;
        $v[0] = $ov;
      } else {
        $v = $ov;
      }
      $v = cast(Pointer, $v) unless $v ~~ Pointer;
    }
    $all.not ?? $v !! ($v, \t);
  }

  # Add Role to redefine name of method (guifa++)
  sub buildAccessors (\O) is export {
  	my $proxy = sub ($n, \attr) {
  		my $m = method :: is rw {
  			Proxy.new(
  				FETCH => -> $,    { my $p = attr.get_value(self);
                              ($p does GLib::Roles::Pointers)
                                if $p ~~ (Pointer, CArray).any;
                              $p },
  				STORE => -> $, \v { attr.set_value(self, v) }
  			);
  		}
      $m.set_name($n);
      $m;
  	}

  	for O.^attributes.kv -> $k, \a {
  		my $full-name = a.name;
      my ($, $attr-name) = $full-name.&separate(2);
  		next if a.has_accessor;

  		print "  Adding { $attr-name } to { O.^name }..." if $DEBUG;
  		O.^add_method(
  			$attr-name,
  			$proxy($attr-name, a)    #= $proxy() returns Method
  		);
  		say 'done' if $DEBUG;
  	}
  }

  sub nullTerminatedArraySize ($data where $data.REPR eq 'CArray') is export {
    my $idx = 0;
    repeat { } while $data[$idx++];
    $idx;
  }

  # cw: Still some concern over the this....
  sub nullTerminatedBuffer (CArray[uint8] $data) is export {
    my $s = nullTerminatedArraySize($data);
    CArray[uint8].new( |$data[^$s] );
  }

  sub newCArray (
    \T,
     $fv?,
    :$size      = 1,
    :$encoding = 'utf8'
  )
    is export
  {
    # cw: It's almost always better to make Str a CArray[uint8]
    if (T, $fv).all ~~ Str {
      return CArray[uint8].new( $fv.encode($encoding) );
    }

    my $s = T.REPR eq 'CStruct' || T ~~ Str;
    my $p = ( $s ?? CArray[T] !! CArray[ Pointer[T] ] ).allocate($size);
    $p[0] = $fv ?? $fv
                !! ($s ?? T !! Pointer[T]);
    $p;
  }

  sub mergeHash ($hash, $defaults) is export {
    $hash{ .key } //= .value for $defaults.pairs;
    $hash;
  }

  multi sub tie (@original, $index, $number, @replacement?) {
    @replacement ?? @original.splice($index, $number)
                 !! @original.splice($index, $number, @replacement);
    @original;
  }

  multi sub tie (@original, $index, $number, @replacement, $extracted is rw) {
    $extracted = @replacement
      ?? @original.splice($index, $number)
      !! @original.splice($index, $number, @replacement);

    @original;
  }

  multi sub firstObject (@original, $object, :$k = False) is export {
    $k ?? @original.first({ +$_ == +$object }, :k)
       !! @original.first({ +$_ == +$object });
  }

  # role HashDefault[\T] {
  #   method AT-KEY (\k) { callwith(k) // T };
  # }
  #
  # sub makeHashDefault ($default) is export {
  #   Hash.new but HashDefault[$default]
  # }

  our %DEFAULT-CALLBACKS is default(Callable) is export;

  # Protect potential duplicate of g_free() behind its own anonymous scope.
  {
    sub g_free (gpointer)
      is native(glib)
    { * }

    %DEFAULT-CALLBACKS = (
      GDestroyNotify => sub ($p) { g_free($p) }
    );
  }

  sub propAssignArray (\T, $i is copy) is export {
    my $typeName = T.^name;

    $i = $i.Array                       if $i.^can($typeName);
    $i = ArrayToCArray(T, $i, :null)    if $i ~~ T;
    $i = cast(gpointer, $i)             if $i ~~ CArray[T];
    X::GLib::UnkownType.new(
      message => "Value passed to css-class property is not{
                  '' } { $typeName }-compatible!";
    ).throw unless $i ~~ gpointer;
    $i;
  }

  # cw: Deprecated.
  our $DEFAULT-GDESTROY-NOTIFY is export = sub (*@a) {
    %DEFAULT-CALLBACKS<GDestroyNotify>( |@a )
      if %DEFAULT-CALLBACKS<GDestroyNotify>:exists
         &&
         %DEFAULT-CALLBACKS<GDestroyNotify> !=:= (Callable, Nil).any
  }

  sub g_destroy_none(Pointer)
    is native(glib)
    is export
  { * }

  sub g_object_new (uint64 $object_type, Str)
    returns GObject
    is native(gobject)
    is export
  { * }

  sub g_object_ref (GObject $p)
    is native(gobject)
    is export
  { * }

  sub g_object_unref (GObject $p)
    is native(gobject)
    is export
  { * }

  sub g_object_set_string_data (GObject $o, Str $key, Str $data)
    is native(gobject)
    is symbol('g_object_set_data')
    is export
  { * }

  sub _g_object_get_string_data (GObject $o, Str $key)
    returns CArray[uint8]
    is native(gobject)
    is symbol('g_object_get_data')
  { * }

  sub g_object_get_string_data (GObject $o, Str $key) is export {
    my $d = _g_object_get_string_data($o, $key);

    my $c = 0;
    my @d;
    while $d[$c++] -> $nc { @d.push: $nc }
    my $s = Buf.new(@d).decode;
    free( cast(Pointer, $d) );
    $s;
  }

  # sub g_object_set_int(GObject $o, Str $key, int32 $data is rw)
  #   is native(gobject)
  #   is symbol('g_object_set_data')
  #   is export
  #   { * }

  sub g_object_get_ptr_data (GObject $o, Str $key)
    returns Pointer
    is native(gobject)
    is symbol('g_object_get_data')
    is export
  { * }

  sub g_object_set_ptr_data (GObject $o, Str $key, Pointer $data)
    is native(gobject)
    is symbol('g_object_set_data')
    is export
  { * }

  sub g_object_setv (
    GObject     $object,
    uint32      $n_properties,
    CArray[Str] $names,
    Pointer     $v             #CArray[GValue] $values
  )
    is native(gobject)
    is export
  { * }

  sub g_object_getv (
    GObject     $object,
    uint32      $n_properties,
    CArray[Str] $names,
    Pointer     $v             #CArray[GValue] $values
  )
    is native(gobject)
    is export
  { * }

  sub g_object_get_int_data (
    GObject $object,
    Str     $name,
  )
    returns CArray[gint]
    is native(gobject)
    is symbol('g_object_get_data')
    is export
  { * }

  sub g_object_set_int_data (
    GObject      $object,
    Str          $name,
    CArray[gint] $value
  )
    is native(gobject)
    is symbol('g_object_set_data')
    is export
  { * }

  sub g_object_get_uint_data (
    GObject $object,
    Str     $name
  )
    returns CArray[guint]
    is native(gobject)
    is symbol('g_object_get_data')
    is export
  { * }

  sub g_object_set_uint_data (
    GObject       $object,
    Str           $name,
    CArray[guint] $value
  )
    is native(gobject)
    is symbol('g_object_set_data')
    is export
  { * }

  sub g_object_get_string (GObject $object, Str $key, CArray[Str] $val, Str)
    is native(gobject)
    is symbol('g_object_get')
    is export
  { * }

  sub g_object_set_string (GObject $object, Str $key, Str $val, Str)
    is native(gobject)
    is symbol('g_object_set')
    is export
  { * }

  sub g_object_get_ptr (GObject $object, Str $key, CArray[Pointer] $val, Str)
    is native(gobject)
    is symbol('g_object_get')
    is export
  { * }

  sub g_object_set_ptr (GObject $object, Str $key, Pointer $val, Str)
    is native(gobject)
    is symbol('g_object_set')
    is export
  { * }

  sub g_object_get_float (GObject $object, Str $key, CArray[gfloat] $val, Str)
    is native(gobject)
    is symbol('g_object_get')
    is export
  { * }

  sub g_object_set_float (GObject $object, Str $key, gfloat $val, Str)
    is native(gobject)
    is symbol('g_object_set')
    is export
  { * }

  sub g_object_get_double (
    GObject         $object,
    Str             $key,
    CArray[gdouble] $val,
    Str
  )
    is native(gobject)
    is symbol('g_object_get')
    is export
  { * }

  sub g_object_set_double (
    GObject  $object,
    Str      $key,
    gdouble  $val,
    Str
  )
    is native(gobject)
    is symbol('g_object_set')
    is export
  { * }

  sub g_object_get_int (GObject $object, Str $key, CArray[gint] $val, Str)
    is native(gobject)
    is symbol('g_object_get')
    is export
  { * }

  sub g_object_set_int (GObject $object, Str $key, gint $val, Str)
    is native(gobject)
    is symbol('g_object_set')
    is export
  { * }

  sub g_object_get_uint (GObject $object, Str $key, CArray[guint] $val, Str)
    is native(gobject)
    is symbol('g_object_get')
    is export
  { * }

  sub g_object_set_uint (GObject $object, Str $key, guint $val, Str)
    is native(gobject)
    is symbol('g_object_set')
    is export
  { * }

  sub g_object_get_int64 (GObject $object, Str $key, CArray[gint64] $val, Str)
    is native(gobject)
    is symbol('g_object_get')
    is export
  { * }

  sub g_object_set_int64 (GObject $object, Str $key, gint64 $val, Str)
    is native(gobject)
    is symbol('g_object_set')
    is export
  { * }

  sub g_object_get_uint64 (
    GObject         $object,
    Str             $key,
    CArray[guint64] $val,
    Str
  )
    is native(gobject)
    is symbol('g_object_get')
    is export
  { * }

  sub g_object_set_uint64 (
    GObject $object,
    Str     $key,
    guint64 $val,
    Str
  )
    is native(gobject)
    is symbol('g_object_set')
    is export
  { * }

}
