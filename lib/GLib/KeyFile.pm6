use v6.c;

use Method::Also;
use NativeCall;
use JSON::Fast;

use GLib::Raw::Types;
use GLib::Raw::KeyFile;

our @validValueTypes = (Int, Num, Bool, Str);

class GLib::KeyFile::Hash { ... }

class GLib::KeyFile  {
  has GKeyFile $!kf is implementor handles<p>;

  submethod BUILD(:$file) {
    $!kf = $file;
  }

  multi method new {
    my $file = g_key_file_new();

    $file ?? self.bless(:$file) !! Nil;
  }

  multi method new ( $file-name, $flags = 0, :$proxy, :dictionary(:%dict) ) {
    my $file = self.new;
    $file.load-from-file($file-name, $flags);
    return Nil   if     $ERROR;
    return $file unless $proxy;
    die 'Cannot use associative property without :$dictionary!';
    $file.get-associative-proxy(%dict);
  }

  method GLib::Raw::Definitions::GKeyFile
    is also<GKeyFile>
  { $!kf }

  # ↓↓↓↓ SIGNALS ↓↓↓↓
  # ↑↑↑↑ SIGNALS ↑↑↑↑

  # ↓↓↓↓ ATTRIBUTES ↓↓↓↓
  # ↑↑↑↑ ATTRIBUTES ↑↑↑↑

  # ↓↓↓↓ PROPERTIES ↓↓↓↓
  # ↑↑↑↑ PROPERTIES ↑↑↑↑

  proto method set_string_list (|)
    is also<set-string-list>
  { * }

  multi method set_string_list (
    Str() $group_name,
    Str() $key,
          @list
  ) {
    @list .= map({
      die '@list must only contain string compatible items!'
        unless .^can('Str').elems;
      .Str
    });

    my $ca  = CArray[Str].new;
    my $l   = @list.elems;
    $ca[$_] = @list[$_] for ^$l;

    samewith($group_name, $key, $ca, $l);
  }
  multi method set_string_list (
    Str()       $group_name,
    Str()       $key,
    CArray[Str] $list,
    Int()       $length
  ) {
    my gsize $l = $length;

    g_key_file_set_string_list($!kf, $group_name, $key, $list, $length);
  }

  proto method set_locale_string_list (|)
    is also<set-locale-string-list>
  { * }

  multi method set_locale_string_list (
    Str() $group_name,
    Str() $key,
    Str() $locale,
          @list
  ) {
    @list .= map({
      die '@list must only contain string compatible items!'
        unless .^can('Str').elems;
      .Str.so
    });

    my $ca  = CArray[Str].new;
    my $l   = @list.elems;
    $ca[$_] = @list[$_] for ^$l;

    samewith($group_name, $key, $locale, $ca, $l);
  }
  multi method set_locale_string_list (
    Str()       $group_name,
    Str()       $key,
    Str()       $locale,
    CArray[Str] $list,
    Int()       $length
  ) {
    my gsize $l = $length;

    g_key_file_set_locale_string_list(
      $!kf,
      $group_name,
      $key,
      $locale,
      $list,
      $length
    );
  }

  proto method set_boolean_list (|)
    is also<set-boolean-list>
  { * }

  multi method set_boolean_list (
    Str() $group_name,
    Str() $key,
          @list
  ) {
    @list .= map({
      die '@list must only contain boolean compatible items!'
        unless .^can('Int').elems;
      .Int.so
    });

    my $ca  = CArray[gboolean].new;
    my $l   = @list.elems;
    $ca[$_] = @list[$_] for ^$l;

    samewith($group_name, $key, $ca, $l);
  }
  multi method set_boolean_list (
    Str()            $group_name,
    Str()            $key,
    CArray[gboolean] $list,
    Int()            $length
  ) {
    my gsize $l = $length;

    g_key_file_set_boolean_list($!kf, $group_name, $key, $list, $length);
  }

  proto method set_double_list (|)
    is also<set-double-list>
  { * }

  multi method set_double_list (
    Str() $group_name,
    Str() $key,
          @list
  ) {
    @list .= map({
      die '@list must only contain Num compatible items!'
        unless .^can('Num').elems;
      .Num.so
    });

    my $ca  = CArray[gdouble].new;
    my $l   = @list.elems;
    $ca[$_] = @list[$_] for ^$l;

    samewith($group_name, $key, $ca, $l);
  }
  multi method set_double_list (
    Str()            $group_name,
    Str()            $key,
    CArray[gdouble]  $list,
    Int()            $length
  ) {
    my gsize $l = $length;

    g_key_file_set_double_list($!kf, $group_name, $key, $list, $length);
  }

  proto method set_integer_list (|)
    is also<set-integer-list>
  { * }

  multi method set_integer_list (
    Str() $group_name,
    Str() $key,
          @list
  ) {
    @list .= map({
      die '@list must only contain Int compatible items!'
        unless .^can('Int').elems;
      .Num.so
    });

    my $ca  = CArray[gint].new;
    my $l   = @list.elems;
    $ca[$_] = @list[$_] for ^$l;

    samewith($group_name, $key, $ca, $l);
  }
  multi method set_integer_list (
    Str()        $group_name,
    Str()        $key,
    CArray[gint] $list,
    Int()        $length
  ) {
    my gsize $l = $length;

    g_key_file_set_integer_list($!kf, $group_name, $key, $list, $length);
  }

  # ↓↓↓↓ METHODS ↓↓↓↓
  method error_quark is also<error-quark> {
    g_key_file_error_quark();
  }

  method free {
    g_key_file_free($!kf);
  }

  method get_boolean (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<get-boolean>
  {
    clear_error;
    my $b = so g_key_file_get_boolean($!kf, $group_name, $key, $error);
    set_error($error);
    $b;
  }

  proto method get_boolean_list (|)
    is also<get-boolean-list>
  { * }

  multi method get_boolean_list (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    samewith($group_name, $key, $, $error);
  }
  multi method get_boolean_list (
    Str()                   $group_name,
    Str()                   $key,
                            $length      is rw,
    CArray[Pointer[GError]] $error       =  gerror
  ) {
    my gsize $l = 0;

    clear_error;
    my $rv = g_key_file_get_boolean_list($!kf, $group_name, $key, $l, $error);
    $rv = CArrayToArray($rv, $length = $l);
    set_error($error);
    $rv;
  }

  method get_comment (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<get-comment>
  {
    clear_error;
    my $c = g_key_file_get_comment($!kf, $group_name, $key, $error);
    set_error($error);
    $c;
  }

  method get_double (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<get-double>
  {
    clear_error;
    my $d = g_key_file_get_double($!kf, $group_name, $key, $error);
    set_error($error);
    $d;
  }

  multi method get_double_list (
    Str()                   $group_name,
    Str()                   $key,
                            $length      is rw,
    CArray[Pointer[GError]] $error       =  gerror,
  )
    is also<get-double-list>
  {
    my gsize $l = 0;

    clear_error;
    my $rv = g_key_file_get_double_list($!kf, $group_name, $key, $l, $error);
    $rv = CArrayToArray($rv, $l);
    set_error($error);
    $rv;
  }

  proto method get_groups (|)
    is also<get-groups>
  { * }

  multi method get_groups (:$all = True) {
    samewith($);
  }
  multi method get_groups ($length is rw, :$all = False)  {
    my gsize $l = 0;
    my @a = CStringArrayToArray( g_key_file_get_groups($!kf, $l) );
    $length = $l;
    @a;
  }

  method get_int64 (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<get-int64>
  {
    clear_error;
    my $rv = g_key_file_get_int64($!kf, $group_name, $key, $error);
    set_error($error);
    $rv;
  }

  method get_integer (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<get-integer>
  {
    clear_error;
    my $rv = g_key_file_get_integer($!kf, $group_name, $key, $error);
    set_error($error);
    $rv;
  }

  proto method get_integer_list (|)
    is also<get-integer-list>
  { * }

  multi method get_integer_list (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror,
  ) {
    samewith($group_name, $key, $error);
  }
  multi method get_integer_list (
    Str()                   $group_name,
    Str()                   $key,
                            $length      is rw,
    CArray[Pointer[GError]] $error       =  gerror,
  ) {
    my gsize $l = 0;

    clear_error;
    my $rv = g_key_file_get_integer_list(
      $!kf,
      $group_name,
      $key,
      $l,
      $error
    );
    $rv = CArrayToArray($rv, $length = $l);
    set_error($error);
    $rv;
  }

  proto method get_keys (|)
    is also<get-keys>
  { * }

  multi method get_keys (
    Str()                   $group_name,
    CArray[Pointer[GError]] $error        = gerror,
  ) {
    samewith($group_name, $, $error);
  }
  multi method get_keys (
    Str()                   $group_name,
                            $length      is rw,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    my gsize $l = 0;

    clear_error;

    my $ka = g_key_file_get_keys($!kf, $group_name, $l, $error);
    if $DEBUG {
      say "L: { $l }";
      say "KA[{ $_ }] = { $ka[$_] }" for ^$l;
    }
    $ka = CArrayToArray($ka, $length = $l);
    say "KA ({ $length }): { $ka.join(',') }" if $DEBUG;
    set_error($error);
    $ka;
  }

  method get_locale_for_key (
    Str() $group_name,
    Str() $key,
    Str() $locale
  )
    is also<get-locale-for-key>
  {
    g_key_file_get_locale_for_key($!kf, $group_name, $key, $locale);
  }

  method get_locale_string (
    Str()                   $group_name,
    Str()                   $key,
    Str()                   $locale,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<get-locale-string>
  {
    clear_error;
    my $rv = g_key_file_get_locale_string(
      $!kf,
      $group_name,
      $key,
      $locale,
      $error
    );
    set_error($error);
    $rv;
  }


  proto method get_locale_string_list (|)
    is also<get-locale-string-list>
  { * }

  multi method get_locale_string_list (
    Str() $group_name,
    Str() $key,
    Str() $locale,
    CArray[Pointer[GError]] $error = gerror,
  ) {
    samewith($group_name, $key, $locale, $, $error);
  }
  multi method get_locale_string_list (
    Str()                   $group_name,
    Str()                   $key,
    Str()                   $locale,
                            $length      is rw,
    CArray[Pointer[GError]] $error       =  gerror,
  ) {
    my gsize $l = 0;

    clear_error;
    my $rv = g_key_file_get_locale_string_list(
      $!kf,
      $group_name,
      $key,
      $locale,
      $l,
      $error
    );
    $rv = CArrayToArray($rv, $length = $l);
    set_error($error);
    $rv;
  }

  method get_start_group
    is also<
      get-start-group
      start_group
      start-group
    >
  {
    g_key_file_get_start_group($!kf);
  }

  method get_string (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<get-string>
  {
    g_key_file_get_string($!kf, $group_name, $key, $error);
  }

  proto method get_string_list (|)
    is also<get-string-list>
  { * }

  multi method get_string_list (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror,
  ) {
    samewith($group_name, $key, $, $error);
  }
  multi method get_string_list (
    Str()                   $group_name,
    Str()                   $key,
                            $length      is rw,
    CArray[Pointer[GError]] $error       =  gerror,
  ) {
    my gsize $l = 0;

    my $sl = g_key_file_get_string_list($!kf, $group_name, $key, $l, $error);
    #if $DEBUG {
      say "L: { $l }";
      say "SL[{ $_ }] = { $sl[$_] }" for ^$l;
    #}
    $sl = CArrayToArray($sl, $length = $l);
    set_error($error);
    $sl;
  }

  method get_uint64 (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<get-uint64>
  {
    clear_error;
    my $rv = g_key_file_get_uint64($!kf, $group_name, $key, $error);
    set_error($error);
    $rv;
  }

  method get_value (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<get-value>
  {
    clear_error;
    my $rv = g_key_file_get_value($!kf, $group_name, $key, $error);
    set_error($error);
    $rv;
  }

  method has_group (Str() $group_name) is also<has-group> {
    so g_key_file_has_group($!kf, $group_name);
  }

  method has_key (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<has-key>
  {
    clear_error;
    my $rv = so g_key_file_has_key($!kf, $group_name, $key, $error);
    set_error($error);
    $rv;
  }

  method load_from_bytes (
    GBytes()                $bytes,
    Int()                   $flags,
    CArray[Pointer[GError]] $error  = gerror
  )
    is also<load-from-bytes>
  {
    my GKeyFileFlags $f = $flags;

    clear_error;
    my $rv = g_key_file_load_from_bytes($!kf, $bytes, $f, $error);
    set_error($error);
    $rv;
  }

  method load_from_data (
    Str()                   $data,
    Int()                   $length,
    Int()                   $flags,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<load-from-data>
  {
    my gsize $l = $length;
    my GKeyFileFlags $f = $flags;

    clear_error;
    my $rv = g_key_file_load_from_data($!kf, $data, $l, $f, $error);
    set_error($error);
    $rv;
  }

  method load_from_data_dirs (
    Str()                   $file,
    Str()                   $full_path,
    Int()                   $flags,
    CArray[Pointer[GError]] $error      = gerror
  )
    is also<load-from-data-dirs>
  {
    my GKeyFileFlags $f = $flags;

    clear_error;
    my $rv = so g_key_file_load_from_data_dirs(
      $!kf,
      $file,
      $full_path,
      $f,
      $error
    );
    set_error($error);
    $rv;
  }

  method load_from_dirs (
    Str()                   $file,
    Str()                   $search_dirs,
    Str()                   $full_path,
    Int()                   $flags,
    CArray[Pointer[GError]] $error        = gerror
  )
    is also<load-from-dirs>
  {
    my GKeyFileFlags $f = $flags;

    clear_error;
    my $rv = so g_key_file_load_from_dirs(
      $!kf,
      $file,
      $search_dirs,
      $full_path,
      $flags,
      $error
    );
    set_error($error);
    $rv;
  }

  method load_from_file (
    Str()                   $file,
    Int()                   $flags,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<load-from-file>
  {
    my GKeyFileFlags $f = $flags;

    clear_error;
    my $rv = so g_key_file_load_from_file($!kf, $file, $flags, $error);
    set_error($error);
    $rv;
  }

  method ref is also<upref> {
    g_key_file_ref($!kf);
    self;
  }

  method remove_comment (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<remove-comment>
  {
    clear_error;
    my $rv = so g_key_file_remove_comment($!kf, $group_name, $key, $error);
    set_error($error);
    $rv;
  }

  method remove_group (
    Str()                   $group_name,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<remove-group>
  {
    clear_error;
    my $rv = g_key_file_remove_group($!kf, $group_name, $error);
    set_error($error);
    $rv;
  }

  method remove_key (
    Str()                   $group_name,
    Str()                   $key,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<remove-key>
  {
    clear_error;
    my $rv = g_key_file_remove_key($!kf, $group_name, $key, $error);
    set_error($error);
    $rv;
  }

  method save_to_file (
    Str()                   $filename,
    CArray[Pointer[GError]] $error     = gerror
  )
    is also<save-to-file>
  {
    clear_error;
    my $rv = g_key_file_save_to_file($!kf, $filename, $error);
    set_error($error);
    $rv;
  }

  method set_boolean (Str() $group_name, Str() $key, Int() $value)
    is also<set-boolean>
  {
    my gboolean $v = so $value;

    g_key_file_set_boolean($!kf, $group_name, $key, $value);
  }

  method set_comment (
    Str()                   $group_name,
    Str()                   $key,
    Str()                   $comment,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<set-comment>
  {
    clear_error;
    my $rv = g_key_file_set_comment($!kf, $group_name, $key, $comment, $error);
    set_error($error);
    $rv;
  }

  method set_double (Str() $group_name, Str() $key, Num() $value)
    is also<set-double>
  {
    my gdouble $v = $value;

    g_key_file_set_double($!kf, $group_name, $key, $v);
  }

  method set_int64 (Str() $group_name, Str() $key, Int() $value)
    is also<set-int64>
  {
    my gint64 $v = $value;

    g_key_file_set_int64($!kf, $group_name, $key, $v);
  }

  method set_integer (Str() $group_name, Str() $key, Int() $value)
    is also<set-integer>
  {
    my gint $v = $value;

    g_key_file_set_integer($!kf, $group_name, $key, $v);
  }

  method set_list_separator (Str() $separator)
    is also<set-list-separator>
  {
    g_key_file_set_list_separator($!kf, $separator);
  }

  method set_locale_string (
    Str() $group_name,
    Str() $key,
    Str() $locale,
    Str() $string
  )
    is also<set-locale-string>
  {
    g_key_file_set_locale_string($!kf, $group_name, $key, $locale, $string);
  }

  method set_string (Str() $group_name, Str() $key, Str() $string)
    is also<set-string>
  {
    g_key_file_set_string($!kf, $group_name, $key, $string);
  }

  method set_uint64 (Str() $group_name, Str() $key, guint64 $value)
    is also<set-uint64>
  {
    my guint64 $v = $value;

    g_key_file_set_uint64($!kf, $group_name, $key, $v);
  }

  method set_value (Str() $group_name, Str() $key, Str() $value)
    is also<set-value>
  {
    g_key_file_set_value($!kf, $group_name, $key, $value);
  }

  proto method to_data (|)
    is also<to-data>
  { * }

  # Can get the length from the string, so :$all defaults to False.
  multi method to_data (
    CArray[Pointer[GError]] $error = gerror,
  ) {
    samewith($, $error);
  }
  multi method to_data (
    $length                 is       rw,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my gsize $l = 0;

    clear_error;
    my $td = g_key_file_to_data($!kf, $l, $error);
    set_error($error);
    $length = $l;
    $td;
  }

  method unref is also<downref> {
    g_key_file_unref($!kf);
  }

  method get-associative-proxy(%dict) {
    GLib::KeyFile::Hash.new(self, %dict);
  }
  # ↑↑↑↑ METHODS ↑↑↑↑

}

class GLib::KeyFile::Group { ... }

enum StoreAs <STORE_GIST STORE_JSON>;

class GLib::KeyFile::Hash does Associative {
  has               %!full-dict       is built;
  has               %!groups          is built;
  has StoreAs       $!overflow        is built  = STORE_GIST;
  has GLib::KeyFile $!key-file-object is built;

  method !init {
    %!groups = ().Hash;
    for $!key-file-object.get-groups {
      %!groups{$_} = GLib::KeyFile::Group.new(
        $_,
        $!key-file-object,
        |%!full-dict{$_}
      );
    }
  }

  submethod BUILD (:%!full-dict, :$!key-file-object) {
    self!init;
  }

  method new (
    GLib::KeyFile $key-file-object,
                  %full-dict,
                  $overflow         = STORE_GIST
  ) {
    my $o = self.bless(:%full-dict, :$key-file-object);
    $o.store-overflow-as($overflow);
    $o;
  }

  method load ($filename, :%full-dict, :$flags = 0) {
    $!key-file-object.load-from-file($filename, $flags);
    %!full-dict = %full-dict;
    self!init;
  }

  method save ($filename) {
    $!key-file-object.save-to-file($filename);
  }

  method store-overflow-as (:$json, :$gist) {
    die ':$json and :$gist cannot be used at the same time!'
      if $json && $gist;

    $!overflow = STORE_JSON if $json;
    $!overflow = STORE_GIST if $gist;
  }

  method AT-KEY (\k) {
    Proxy.new:
      FETCH => -> $ {
        do if %!groups{k} -> $g {
          $g;
        } else {
          # Special error casing
        }
      },

      STORE => -> $, $_ {

        when Hash {
          for .pairs {
            %!groups{k}{ .key } = .value;
          }
        }

        when GLib::KeyFile::Group {
          %!groups{k} = $_
        }

        default {
          die "Do not know how to handle { .^name } when assigning {
               ''}to GLib::KeyFile::Group"
        }

      }
  }

  method delete (\k) {
    if %!groups{k} {
      $!key-file-object.remove-group(k);
      %!groups{k}:delete;
    }
  }

}

class GLib::KeyFile::Group does Associative {
  has Str           $!group-name;
  has GLib::KeyFile $!key-file-object handles(*);
  has StoreAs       $!overflow;
  has               %!dict;

  method new ($group-name, $key-file-object, *%dict) {
    self.bless( :$group-name, :$key-file-object, :%dict);
  }

  method keys {
    $!key-file-object.get-keys($!group-name);
  }

  method elems {
    self.keys.elems;
  }

  method EXISTS-KEY (\k) {
    k eq self.keys.any;
  }

  method AT-KEY (\k) {
    my \kfo := $!key-file-object;

    # cw: Warning! There is nothing in the spec that says that
    #     Lists MUST be numerically indexed. As a matter of fact,
    #     the example implies otherwise.
    #
    #     THIS interface does not yet support associative indexing.

    sub set-single-value(\v) {
      given %!dict{k} {
        when Str  { kfo.set_string_list($!group-name, k, v)  }
        when Int  { kfo.set_int64_list($!group-name, k, v)   }
        when Num  { kfo.set_double_list($!group-name, k, v)  }
        when Bool { kfo.set_boolean_list($!group-name, k, v) }
      }
    }

    sub set-array-value(\v) {
      given %!dict{k} {
        when Array[Str]  { kfo.set_string_list($!group-name, k, v)  }
        when Array[Int]  { kfo.set_int64_list($!group-name, k, v)   }
        when Array[Num]  { kfo.set_double_list($!group-name, k, v)  }
        when Array[Bool] { kfo.set_boolean_list($!group-name, k, v) }

        # when Hash        {
        #   for v.pairs {
        #     given .value {
        #       when Int | Str | Num | Bool {
        #         set-single-value($!group-name, "{ k }[$_]", .value)
        #       }
        #
        #       when Hash | Array {
        #         # cw: Too much work?
        #         for .pairs {
        #           my $serialized = $!overflow == STORE_GIST
        #             ?? .value.gist
        #             !! to-json( .value );
        #
        #           set-single-value($!group-name, "{ k }[{ .key }]", $serialized);
        #         }
        #       }
        #     }
        #   }
        # }
      }
    }

    Proxy.new:
      FETCH => -> $ {
        given %!dict{k} {
          when Str         { kfo.get_string($!group-name, k)       }
          when Int         { kfo.get_int64($!group-name, k)        }
          when Num         { kfo.get_double($!group-name, k)       }
          when Bool        { kfo.get_boolean($!group-name, k)      }
          when Array[Str]  { kfo.get_string_list($!group-name, k)  }
          when Array[Int]  { kfo.get_int64_list($!group-name, k)   }
          when Array[Num]  { kfo.get_double_list($!group-name, k)  }
          when Array[Bool] { kfo.get_boolean_list($!group-name, k) }
        }
      }

      STORE => sub ( $, \v ) {
        unless kfo.has-key(k) {

          if v !~~ Array {
            die "Invalid value! Must be Str, Int, Num, or Bool not a {
                 \v.^name }."
              unless v ~~ @validValueTypes.any;

            %!dict{k} = v.WHAT;
            set-single-value(v);
            return;
          } else {
            die "Arrays must be homogeneous!" unless v.all ~~ v[0].WHAT;
            die "Array has invalid type!" unless v[0] ~~ @validValueTypes.any;
            %!dict{k} = Array[ v[0].WHAT ];
            set-array-value(v);
          }
        }

        if %!dict{k} ~~ Array {
          if v ~~ Array {
            for v[] {
              die "Storing the { v.^name } value { v ~~ Str } into key '{ k }' {
                   '' } is not allowed as that key only accepts elements of
                   type { %!dict{k}.of.^name }"
              unless $_ ~~ %!dict{k}.of
            }
          } else {
            die 'Value must be an array!';
          }
          set-array-value(v);
        } else {
          die "Storing the { v.^name } value { v ~~ Str } into key '{ k }' {
               '' } is not allowed as that key only accepts {
               %!dict{k}.^name } values"
            unless v ~~ %!dict{k};

          set-single-value(v);
        }
      }
  }

  method delete (\k) {
    $!key-file-object.remove-key(k) if $!key-file-object.has-key(k);
  }

}


BEGIN {
  @validValueTypes.push: Array[$_] for @validValueTypes;
}
