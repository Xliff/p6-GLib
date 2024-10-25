use v6.c;

role X::GLib::Roles::Message {
  has $!message is built;

  method message {
    "[{ self.^name }] " ~ $!message
  }
}

class X::GLib::Exception is Exception does X::GLib::Roles::Message { }

class X::GLib::NYI is X::NYI does X::GLib::Roles::Message {

  multi method new (
    :$item  is required,
    :$class
  ) {
    my $message = $item;
    $message ~= " in { $class.^name }" unless $class === Any;

    self.bless( message => "{ $message } NYI!" )
  }

}

class X::GLib::InvalidState is X::GLib::Exception {

  multi method new ( :$message = 'Invalid State' ) {
    self.bless(:$message);
  }
}

class X::GLib::Object::AttributeNotFound is X::GLib::Exception {
  has $.attribute;

  multi method new (
    :$attribute is required,
    :$message                = "Attribute '{ $attribute }' not found!"
  ) {
    self.bless( :$attribute, :$message );
  }
}

class X::GLib::Object::AttributeValueOutOfBounds is X::GLib::Exception {
  has $.attribute;
  has $.value;
  has $.range;

  method new (
    :$message = "[{ self.^name }] "
                ~
                "{ $!value     } is outside the valid range of {
                   $!range     } for the '{
                   $!attribute }' attribute"
  ) {
    self.bless( :$message );
  }
}

class X::GLib::Variant::NotAContainer is X::GLib::Exception {

  method new (
    :$message = 'Variant is not a container, so cannot serve as a Positional!'
  ) {
    self.bless( :$message );
  }

}

class X::GLib::InvalidSize is X::GLib::Exception {
  multi method new ( :$message = 'Invalid size!' ) {
    self.bless( :$message );
  }
}

class X::GLib::UnknownType is X::GLib::Exception {
  multi method new ( :$message = 'Unknown type!' ) {
    self.bless( :$message );
  }
}

class X::GLib::InvalidType is X::GLib::Exception {
  multi method new ( :$message = 'Invalid type!' ) {
    self.bless( :$message );
  }
}

class X::GLib::InvalidArgument is X::GLib::Exception {
  multi method new ( :$message = 'Invalid argument' ) {
    self.bless( :$message );
  }
}

class X::GLib::InvalidArguments is X::GLib::InvalidArgument {
}

class X::GLib::InvalidNumberOfArguments is X::GLib::Exception {
  method new ( :$message = 'Invalid number of arguments' ) {
    self.bless( :$message );
  }
}

class X::GLib::InvalidIndex is X::GLib::Exception {
}

class X::GLib::OnlyOneOf is X::GLib::Exception {
  has @.values  is built;

  submethod BUILD ( :$values ) {
    @!values = $values;
  }

  method new ( :
    :$values  is required,
    :$message              = "Can use only one of the following variables: {
                               @.values.join(', ') }"
  ) {
    self.bless( :$values, :$message );
  }

}

class X::GLib::ProtectedMethod is X::GLib::Exception {
  method new ( :$message = 'Cannot execute a protected method from here.' ) {
    self.bless( :$message );
  }
}

class X::GLib::DynamicObjectFailure is X::GLib::Exception {

  method new ($type, :$any = False) {
    self.bless(
      message => "Dynamic module loading of { $type.^name } " ~ (
        $any ?? "resulted in an object with no type!"
             !! "failed!"
      )
    );
  }

}

package GLib::Raw::Exceptions { }
