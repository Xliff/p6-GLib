use v6.c;

use NativeCall;

my \G_VARIANT_TYPE_BOOLEAN     = ( CArray[uint8].allocate(1) )[0] = 'b'.ord;
my \G_VARIANT_TYPE_BYTE        = ( CArray[uint8].allocate(1) )[0] = 'y'.ord;
my \G_VARIANT_TYPE_INT16       = ( CArray[uint8].allocate(1) )[0] = 'n'.ord;
my \G_VARIANT_TYPE_UINT16      = ( CArray[uint8].allocate(1) )[0] = 'q'.ord;
my \G_VARIANT_TYPE_INT32       = ( CArray[uint8].allocate(1) )[0] = 'i'.ord;
my \G_VARIANT_TYPE_UINT32      = ( CArray[uint8].allocate(1) )[0] = 'u'.ord;
my \G_VARIANT_TYPE_INT64       = ( CArray[uint8].allocate(1) )[0] = 'x'.ord;
my \G_VARIANT_TYPE_UINT64      = ( CArray[uint8].allocate(1) )[0] = 't'.ord;
my \G_VARIANT_TYPE_HANDLE      = ( CArray[uint8].allocate(1) )[0] = 'h'.ord;
my \G_VARIANT_TYPE_DOUBLE      = ( CArray[uint8].allocate(1) )[0] = 'd'.ord;
my \G_VARIANT_TYPE_STRING      = ( CArray[uint8].allocate(1) )[0] = 's'.ord;
my \G_VARIANT_TYPE_OBJECT_PATH = ( CArray[uint8].allocate(1) )[0] = 'o'.ord;
my \G_VARIANT_TYPE_SIGNATURE   = ( CArray[uint8].allocate(1) )[0] = 'g'.ord;
my \G_VARIANT_TYPE_VARIANT     = ( CArray[uint8].allocate(1) )[0] = 'v'.ord;
my \G_VARIANT_TYPE_MAYBE       = ( CArray[uint8].allocate(1) )[0] = 'm'.ord;
my \G_VARIANT_TYPE_ARRAY       = ( CArray[uint8].allocate(1) )[0] = 'a'.ord;
my \G_VARIANT_TYPE_TUPLE       = ( CArray[uint8].allocate(1) )[0] = '('.ord;
my \G_VARIANT_TYPE_DICT_ENTRY  = ( CArray[uint8].allocate(1) )[0] = '{'.ord;

sub EXPORT (*@a --> Hash) is export {
  %(
    G_VARIANT_TYPE_BOOLEAN     => G_VARIANT_TYPE_BOOLEAN,
    G_VARIANT_TYPE_BYTE        => G_VARIANT_TYPE_BYTE,
    G_VARIANT_TYPE_INT16       => G_VARIANT_TYPE_INT16,
    G_VARIANT_TYPE_UINT16      => G_VARIANT_TYPE_UINT16,
    G_VARIANT_TYPE_INT32       => G_VARIANT_TYPE_INT32,
    G_VARIANT_TYPE_UINT32      => G_VARIANT_TYPE_UINT32,
    G_VARIANT_TYPE_INT64       => G_VARIANT_TYPE_INT64,
    G_VARIANT_TYPE_UINT64      => G_VARIANT_TYPE_UINT64,
    G_VARIANT_TYPE_HANDLE      => G_VARIANT_TYPE_HANDLE,
    G_VARIANT_TYPE_DOUBLE      => G_VARIANT_TYPE_DOUBLE,
    G_VARIANT_TYPE_STRING      => G_VARIANT_TYPE_STRING,
    G_VARIANT_TYPE_OBJECT_PATH => G_VARIANT_TYPE_OBJECT_PATH,
    G_VARIANT_TYPE_SIGNATURE   => G_VARIANT_TYPE_SIGNATURE,
    G_VARIANT_TYPE_VARIANT     => G_VARIANT_TYPE_VARIANT,
    G_VARIANT_TYPE_MAYBE       => G_VARIANT_TYPE_MAYBE,
    G_VARIANT_TYPE_ARRAY       => G_VARIANT_TYPE_ARRAY,
    G_VARIANT_TYPE_TUPLE       => G_VARIANT_TYPE_TUPLE,
    G_VARIANT_TYPE_DICT_ENTRY  => G_VARIANT_TYPE_DICT_ENTRY
  );
}
