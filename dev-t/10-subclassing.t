use v6.c;

use NativeCall;

use GLib::Raw::Traits;
use GLib::Raw::Types;
use GLib::Object::Raw::ParamSpec;

use GLib::Object::ParamSpec;
use GLib::Object::TypeModule;
use GLib::Class::Object;

use GLib::Roles::Object;
use GLib::Roles::Implementor;

class String::Holder { ... }

class StringHolderClass is repr<CStruct> {
  HAS GObjectClass $.parent;
}

class StringHolder is repr<CStruct> {
  HAS GObject $.parent;

  has Str $!title       is gattribute;
  has Str $!icon        is gattribute;
  has Str $!description is gattribute;

  # Need a way to link attributes to GObject numeric so it can be called
  # statically.

  method title is rw {
    Proxy.new:
      FETCH => -> $     { $!title },
      STORE => sub ($, \v) {
        return unless v ~~ Str && v;
        say "Setting title to { v }...";

        $!title := resolveToStr(v)
      }
  }

  method icon is rw {
    Proxy.new:
      FETCH => -> $     { $!icon },
      STORE => sub ($, \v) {
        return unless v ~~ Str && v;

        say "Setting icon to { v }...";
        $!icon := resolveToStr(v)
      }
  }

  method description is rw {
    Proxy.new:
      FETCH => -> $     { $!description },
      STORE => sub ($, \v) {
        return unless v ~~ Str && v;

        say "Setting description to { v }...";
        $!description := resolveToStr(v)
      }
  }

  method finalize is g-vfunc {
    my $Parent = GLib::Object.new($.parent);
    $Parent.finalize;
  }

  method get_type {
    state $n = GLib::Object::TypeModule.register-static(
      ::?CLASS.getTypePair.head,
      class-struct => StringHolderClass
    );
    $n;
  }

  method getTypePair {
    [StringHolder, String::Holder]
  }

}

our subset StringHolderAncestry is export of Mu
  where StringHolder | GObject;

class String::Holder {
  also does GLib::Roles::Object;

  has StringHolder $!sh is implementor handles<
    title
    icon
    description
    get_type
  >;

  submethod BUILD ( :$string-holder ) {
    self.setStringHolder($string-holder) if $string-holder;
  }

  method setStringHolder (StringHolderAncestry $_) {
    my $to-parent;

    $!sh = do {
      when StringHolder {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(StringHolder, $_);
      }
    }
    self!setObject($to-parent);
  }

  method StringHolder { $!sh }

  proto method new (|)
  { * }

  multi method new (
    StringHolderAncestry  $string-holder,
                         :$ref             = True
  ) {
    return Nil unless $string-holder;

    my $o = self.bless( :$string-holder );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    Str() $title       = '',
    Str() $icon        = '',
    Str() $description = ''
  ) {
    my $string-holder = self.new-object-ptr( self.get_type );

    my $o = $string-holder ?? self.bless( :$string-holder ) !! Nil;
    return Nil unless $o;

    $o.title       = $title;
    $o.icon        = $icon,
    $o.description = $description;
    $o;
  }
}

INIT my $ = StringHolder.get_type;

sub MAIN {
  my GType $n  = StringHolder.get_type;

  my $sc = cast( gpointer, g_type_class_ref($n) );
  my $t  = GLib::Object::Type.new($n);

  say "Type name:   { $t.name }";
  say "Type number: { $n }";

  my guint $np = 0;

  say "SC: { $sc }";

  my $ps = g_object_class_list_properties($sc, $np);
  say "PS: { $ps[^$np] }";

  my @a = $ps[^$np].map({ GLib::Object::ParamSpec.new( .deref ) });

  @a.map( *.name ).gist.say;
}
