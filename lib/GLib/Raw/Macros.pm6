use v6.c;

use experimental :macros;

unit package GLib::Raw::Macros;

# cw: For future functionality...
#
# macro TYPE-RESOLVER (\T, $f) is export {
#   quasi {
#     BEGIN {
#       use JSON::Fast;
#
#       my %widgets;
#       my \O = {{{ T }}};
#       my \P = O.getTypePair;
#       given {{{ $f }}}.IO.open( :rw ) {
#         .lock;
#         my $existing = .slurp;
#         %widgets = try from-json($existing) if $existing.chars;
#         %widgets{ P.head.^shortname } = P.tail.^name;
#         .seek(0, SeekFromBeginning);
#         .spurt: to-json(%widgets);
#         .close;
#       }
#     }
#
#     INIT {
#       my \O = {{{ T }}};
#       %widget-types{O.get_type} = {
#         name        => O.^name,
#         object      => O,
#         pair        => O.getTypePair
#       }
#     }
#   }
# }
