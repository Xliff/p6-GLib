use v6.c;

use Method::Also;

use GLib::Raw::Types;

use GLib::Object::Raw::Binding;

role GLib::Roles::Bindable {

  method bind (
    ::?CLASS:U:
    GObject() $source,
    Str()     $source_property,
    GObject() $target,
    Str()     $target_property,
    Int()     $flags            = 3    # G_BINDING_BIDIRECTIONAL +| G_BINDING_SYNC_CREATE
  ) {
    my $f = $flags;
    my $binding = g_object_bind_property(
      $source,
      $source_property,
      $target,
      $target_property,
      $f
    );

    $binding ?? self.bless( :$binding ) !! Nil;
  }

  method bind_full (
    ::?CLASS:U:
    GObject()      $source,
    Str()          $source_property,
    GObject()      $target,
    Str()          $target_property,
    Int()          $flags,
                   &transform_to,
                   &transform_from,
    gpointer       $user_data        = gpointer,
                   &notify           = gpointer
  )
    is also<bind-full>
  {
    my $f = $flags;
    my $binding = g_object_bind_property_full(
      $source,
      $source_property,
      $target,
      $target_property,
      $f,
      &transform_to,
      &transform_from,
      $user_data,
      &notify
    );

    $binding ?? self.bless( :$binding ) !! Nil;
  }

  method bind_with_closures (
    ::?CLASS:U:
    GObject()  $source,
    Str()      $source_property,
    GObject()  $target,
    Str()      $target_property,
    Int()      $flags,
    GClosure() $transform_to     = GClosure,
    GClosure() $transform_from   = GClosure
  )
    is also<bind-with-closures>
  {
    my $f = $flags;
    my $binding =  g_object_bind_property_with_closures(
      $source,
      $source_property,
      $target,
      $target_property,
      $f,
      $transform_to,
      $transform_from
    );

    $binding ?? self.bless( :$binding ) !! Nil;
  }

}
