use v6.c;

use GLib::Raw::Types;

use NativeCall;
use NativeHelpers::Blob;

role GLib::Roles::PointerBasedList {

  method addToList (
    $l,
    @list,
    :$signed   = False,
    :$double   = False,
    :$direct   = False,
    :$encoding = 'utf8',
    :$typed
  ) {
    my $firstElement = True;
    for @list -> $_ is copy {
      if $typed !=:= Nil {
        if .^can($typed.^name) -> $m {
          $_ = $m($_);
        }
        die "List does not support { .^name } variables. Will only accept {
             $typed.^name }!"
        unless $_ ~~ $typed;
      }
      # Properly handle non-Str Cool data.
      my ($ov, $use-arr, \t, $v) = ($_, False);
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
            $ov = pointer-to( $ov.encode($encoding) );
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
      if $firstElement {
        $l.data       = $v;
        $firstElement = False;
      } else {
        $l.append($v);
      }
    }
  }

}
