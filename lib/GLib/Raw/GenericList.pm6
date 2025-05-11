use v6.c;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;

use GLib::Roles::ListData;

unit package GLib::Raw::GenericList;

sub returnGenericList (
  \LT,
  $gl     is copy,
  $glist,
  $raw,
  $T      =  Str,
  $O      =  Any,
  :$seq   =  True,
  :$ref   =  False,
  :$free
)
  is export
{
  return Nil unless $gl;
  return $gl if     $glist && $raw;

  my $ol = $gl;

  #say '-- pre return gL';

  $gl = LT.new($gl) but GLib::Roles::ListData[$T];
  return $gl if $glist;

  #say '-- post return GL';

  return $gl.Array if $raw || $O === Any;
  #die 'Cannot convert GList to Object array when no Object-type specified!'
  #  if $O =:= Nil;

  #say '-- pre Map';

  my $list = $gl.Array.map({
     #say "GL-Map: { .gist } ({ +.p })";
    $O.new($_, :$ref);
  });
  return $list if $seq;

  #say '-- pre Array';
  $free($ol) if $free;

  $list.Array;
}
