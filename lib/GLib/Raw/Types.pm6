use v6;

#use GLib::Raw::Exports;

my %exports;
my @default-symbols = MY::.keys;

#sub defSyms is export { @default-symbols }
#sub myExports is export { %exports }

module GLib::Raw::Types {
  use GLib::Raw::Definitions;
  use GLib::Raw::Enums;
  use GLib::Raw::Exceptions;
  use GLib::Raw::Object;
  use GLib::Raw::Structs;
  use GLib::Raw::Subs;
  use GLib::Raw::Struct_Subs;
  use GLib::Roles::Pointers;

  %exports = MY::.pairs.grep({ .key ne @default-symbols.any }).Map;
}

sub EXPORT () { %exports }

# Old system
#
# need GLib::Raw::Definitions;
# need GLib::Raw::Enums;
# need GLib::Raw::Exceptions;
# need GLib::Raw::Object;
# need GLib::Raw::Structs;
# need GLib::Raw::Subs;
# need GLib::Raw::Struct_Subs;
# need GLib::Roles::Pointers;
#
# BEGIN {
#   glib-re-export($_) for @GLib::Raw::Exports::glib-exports;
# }
