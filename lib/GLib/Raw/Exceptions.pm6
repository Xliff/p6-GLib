use v6.c;

class X::GLib::GError is Exception {
  has $!gerror handles <domain code>;

  submethod BUILD (:$!gerror) { }

  method new ($gerror) {
    self.bless( :$gerror, message => $gerror.message );
  }
}

class X::GLib::Object::AttributeNotFound is Exception {
  has $.attribute;

  method message {
    "Attribute '{ $!attribute }' not found!"
  }

  multi method new ($attribute) {
    self.bless(:$attribute);
  }
}

class X::GLib::Object::AttributeValueOutOfBounds is Exception {
  has $.attribute;
  has $.value;
  has $.range;

  method message {
    "{ $!value     } is outside the valid range of {
       $!range     } for the '{
       $!attribute }' attribute";
  }
}

class X::GLib::Variant::NotAContainer is Exception {
  method message {
    'Variant is not a container, so cannot serve as a Positional!';
  }
}

package GLib::Raw::Exceptions { }
