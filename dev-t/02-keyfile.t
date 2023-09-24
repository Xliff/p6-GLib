#!/usr/bin/env raku
use v6.c;

use GLib::Raw::Types;
use GLib::KeyFile;

use Test;

my $key-file = GLib::KeyFile.new;

my $io = '.'.IO;
$io .= add('t') unless $io.add('test.ini').e;
$io .= add('test.ini');

plan 6;

unless $key-file.load-from-file(
  $io.absolute,
  G_KEY_FILE_KEEP_COMMENTS +| G_KEY_FILE_KEEP_TRANSLATIONS
) {
  fail "Could not load key file { $io.absolute }!";
  exit;
}

my $int-value    = $key-file.get-integer('test', 'int_value');
my $str-value    = $key-file.get-string('test', 'str_value');
my $double-value = $key-file.get-double('test', 'double_value');

is $str-value,    'hello world',            "Value from the key 'test/str_value' is correct";
is $int-value,    5,                        "Value from the key 'test/int_value' is correct";
is $double-value, 8.888765,                 "Value from the key 'test/double_value' is correct";

$key-file.set-string('test', 'str_value', $str-value x 2);
$key-file.set-integer('test', 'int_value', ++$int-value);
$key-file.set-integer('test', 'double_value', $double-value * 2);

$int-value    = $key-file.get-integer('test', 'int_value');
$str-value    = $key-file.get-string('test', 'str_value');
$double-value = $key-file.get-integer('test', 'double_value');

is $int-value,    6,                        "Value from the key 'test/int_value' is correct after set";
is $double-value, 17,                       "Value from the key 'test/double_value' is correct after set";
is $str-value,    'hello worldhello world', "Value from the key 'test/str_value' is correct after set";

my @sv = ($str-value, $int-value, $double-value);
$key-file.set-string-list('test', 'str_list', @sv);

my @groups = $key-file.get-groups;
for @groups.kv ->  $k, $v {
  my @keys = $key-file.get-keys($v)[];
  for @keys.kv -> $kk, $kv {
    my $value = $key-file.get-value($v, $kv);
  }
}
