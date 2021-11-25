use v6.c;

use NativeCall;

use GLib::Raw::Definitions;

unit package GLib::Raw::Enums;

our %strToGType is export;

# In the future, this mechanism may need to be used via BEGIN block for all
# enums that vary by OS -- Kaiepi++!
#
# my constant TheseChangeByOS = Metamodel::EnumHOW.new_type: :name<TheseChangeByOS>, :base_type(Int);
# TheseChangeByOS.^add_role: NumericEnumeration;
# TheseChangeByOS.^set_package: OUR
# TheseChangeByOS.^compose;
# if $*DISTRO.is-win {
#     TheseChangeByOS.^add_enum_value: 'a' => ...;
#     TheseChangeByOS.^add_enum_value: 'b' => ...;
#     TheseChangeByOS.^add_enum_value: 'c' => ...;
#     TheseChangeByOS.^add_enum_value: 'd' => ...;
# } else {
#     TheseChangeByOS.^add_enum_value: 'a' => ...;
#     TheseChangeByOS.^add_enum_value: 'b' => ...;
#     TheseChangeByOS.^add_enum_value: 'c' => ...;
#     TheseChangeByOS.^add_enum_value: 'd' => ...;
# }
# TheseChangeByOS.^compose_values;

constant GFormatSizeFlags is export := guint32;
our enum GFormatSizeFlagsEnum is export (
  G_FORMAT_SIZE_DEFAULT     => 0,
  G_FORMAT_SIZE_LONG_FORMAT => 1,
  G_FORMAT_SIZE_IEC_UNITS   => 1 +< 1,
  G_FORMAT_SIZE_BITS        => 1 +< 2
);

constant GUserDirectory is export := guint32;
our enum GUserDirectoryEnum is export <
  G_USER_DIRECTORY_DESKTOP
  G_USER_DIRECTORY_DOCUMENTS
  G_USER_DIRECTORY_DOWNLOAD
  G_USER_DIRECTORY_MUSIC
  G_USER_DIRECTORY_PICTURES
  G_USER_DIRECTORY_PUBLIC_SHARE
  G_USER_DIRECTORY_TEMPLATES
  G_USER_DIRECTORY_VIDEOS
>;

constant GBindingFlags      is export := guint32;
our enum GBindingFlagsEnum  is export (
  G_BINDING_DEFAULT        => 0,
  G_BINDING_BIDIRECTIONAL  => 1,
  G_BINDING_SYNC_CREATE    => 1 +< 1,
  G_BINDING_INVERT_BOOLEAN => 1 +< 2
);

constant GChecksumType      is export := guint32;
our enum GChecksumTypeEnum  is export <
  G_CHECKSUM_MD5,
  G_CHECKSUM_SHA1,
  G_CHECKSUM_SHA256,
  G_CHECKSUM_SHA512,
  G_CHECKSUM_SHA384
>;

constant GConnectFlags      is export := guint32;
our enum GConnectFlagsEnum  is export (
  G_CONNECT_AFTER       => 1,
  G_CONNECT_SWAPPED     => 2
);

constant GErrorType         is export := guint32;
our enum GErrorTypeEnum     is export <
  G_ERR_UNKNOWN
  G_ERR_UNEXP_EOF
  G_ERR_UNEXP_EOF_IN_STRING
  G_ERR_UNEXP_EOF_IN_COMMENT
  G_ERR_NON_DIGIT_IN_CONST
  G_ERR_DIGIT_RADIX
  G_ERR_FLOAT_RADIX
  G_ERR_FLOAT_MALFORMED
>;

constant GFileError is export := guint32;
our enum GFileErrorEnum is export <
 G_FILE_ERROR_EXIST
 G_FILE_ERROR_ISDIR
 G_FILE_ERROR_ACCES
 G_FILE_ERROR_NAMETOOLONG
 G_FILE_ERROR_NOENT
 G_FILE_ERROR_NOTDIR
 G_FILE_ERROR_NXIO
 G_FILE_ERROR_NODEV
 G_FILE_ERROR_ROFS
 G_FILE_ERROR_TXTBSY
 G_FILE_ERROR_FAULT
 G_FILE_ERROR_LOOP
 G_FILE_ERROR_NOSPC
 G_FILE_ERROR_NOMEM
 G_FILE_ERROR_MFILE
 G_FILE_ERROR_NFILE
 G_FILE_ERROR_BADF
 G_FILE_ERROR_INVAL
 G_FILE_ERROR_PIPE
 G_FILE_ERROR_AGAIN
 G_FILE_ERROR_INTR
 G_FILE_ERROR_IO
 G_FILE_ERROR_PERM
 G_FILE_ERROR_NOSYS
 G_FILE_ERROR_FAILED
>;

constant GIOChannelError is export := guint;
our enum GIOChannelErrorEnum is export <
  G_IO_CHANNEL_ERROR_FBIG
  G_IO_CHANNEL_ERROR_INVAL
  G_IO_CHANNEL_ERROR_IO
  G_IO_CHANNEL_ERROR_ISDIR
  G_IO_CHANNEL_ERROR_NOSPC
  G_IO_CHANNEL_ERROR_NXIO
  G_IO_CHANNEL_ERROR_OVERFLOW
  G_IO_CHANNEL_ERROR_PIPE
  G_IO_CHANNEL_ERROR_FAILED
>;

# cw: These values are for LINUX!
constant GIOCondition is export := guint;
our enum GIOConditionEnum is export (
  G_IO_IN     => 1,
  G_IO_OUT    => 4,
  G_IO_PRI    => 2,
  G_IO_ERR    => 8,
  G_IO_HUP    => 16,
  G_IO_NVAL   => 32,
);

constant GIOFlags is export := guint;
our enum GIOFlagsEnum is export (
  G_IO_FLAG_APPEND       => 1,
  G_IO_FLAG_NONBLOCK     => 2,
  G_IO_FLAG_IS_READABLE  => 1 +< 2,      # Read only flag
  G_IO_FLAG_IS_WRITABLE  => 1 +< 3,      # Read only flag
  G_IO_FLAG_IS_WRITEABLE => 1 +< 3,      # Misspelling in 2.29.10 and earlier
  G_IO_FLAG_IS_SEEKABLE  => 1 +< 4,      # Read only flag
  G_IO_FLAG_MASK         => (1 +< 5) - 1,
  G_IO_FLAG_GET_MASK     => (1 +< 5) - 1,
  G_IO_FLAG_SET_MASK     => 1 +| 2
);

constant GIOStatus is export := guint;
our enum GIOStatusEnum is export <
  G_IO_STATUS_ERROR
  G_IO_STATUS_NORMAL
  G_IO_STATUS_EOF
  G_IO_STATUS_AGAIN
>;

constant GKeyFileError      is export := guint;
our enum GKeyFileErrorEnum  is export <
  G_KEY_FILE_ERROR_UNKNOWN_ENCODING
  G_KEY_FILE_ERROR_PARSE
  G_KEY_FILE_ERROR_NOT_FOUND
  G_KEY_FILE_ERROR_KEY_NOT_FOUND
  G_KEY_FILE_ERROR_GROUP_NOT_FOUND
  G_KEY_FILE_ERROR_INVALID_VALUE
>;


constant GKeyFileFlags      is export := guint;
our enum GKeyFileFlagsEnum  is export (
  G_KEY_FILE_NONE              => 0,
  G_KEY_FILE_KEEP_COMMENTS     => 1,
  G_KEY_FILE_KEEP_TRANSLATIONS => 2
);

constant GLogWriterOutput      is export := guint32;
our enum GLogWriterOutputEnum  is export (
  G_LOG_WRITER_UNHANDLED => 0,
  G_LOG_WRITER_HANDLED   => 1,
);

constant GMarkupParseFlags     is export := guint32;
our enum GMarkupParseFlagsEnum is export (
    G_MARKUP_DO_NOT_USE_THIS_UNSUPPORTED_FLAG =>  1,
    G_MARKUP_TREAT_CDATA_AS_TEXT              =>  1 +< 1,
    G_MARKUP_PREFIX_ERROR_POSITION            =>  1 +< 2,
    G_MARKUP_IGNORE_QUALIFIED                 =>  1 +< 3,
);

constant GNormalizeMode        is export := guint32;
our enum GNormalizeModeEnum    is export (
  G_NORMALIZE_DEFAULT           => 0,
  G_NORMALIZE_NFD               => 0,     # G_NORMALIZE_DEFAULT,
  G_NORMALIZE_DEFAULT_COMPOSE   => 1,
  G_NORMALIZE_NFC               => 1,     # G_NORMALIZE_DEFAULT_COMPOSE,
  G_NORMALIZE_ALL               => 2,
  G_NORMALIZE_NFKD              => 2,     # G_NORMALIZE_ALL,
  G_NORMALIZE_ALL_COMPOSE       => 3,
  G_NORMALIZE_NFKC              => 3      # G_NORMALIZE_ALL_COMPOSE
);

constant GModuleFlags     is export := guint32;
our enum GModuleFlagsEnum is export (
  G_MODULE_BIND_LAZY    => 1,
  G_MODULE_BIND_LOCAL   => 1 +< 1,
  G_MODULE_BIND_MASK    => 0x03
);

constant GOnceStatus     is export := guint32;
our enum GOnceStatusEnum is export <
  G_ONCE_STATUS_NOTCALLED
  G_ONCE_STATUS_PROGRESS
  G_ONCE_STATUS_READY
>;

constant GOptionFlags is export := guint;
our enum GOptionFlagsEnum is export (
  G_OPTION_FLAG_NONE            => 0,
  G_OPTION_FLAG_HIDDEN          => 1,
  G_OPTION_FLAG_IN_MAIN         => 1 +< 1,
  G_OPTION_FLAG_REVERSE         => 1 +< 2,
  G_OPTION_FLAG_NO_ARG          => 1 +< 3,
  G_OPTION_FLAG_FILENAME        => 1 +< 4,
  G_OPTION_FLAG_OPTIONAL_ARG    => 1 +< 5,
  G_OPTION_FLAG_NOALIAS         => 1 +< 6
);

constant GOptionArg is export := guint32;
our enum GOptionArgEnum is export <
  G_OPTION_ARG_NONE
  G_OPTION_ARG_STRING
  G_OPTION_ARG_INT
  G_OPTION_ARG_CALLBACK
  G_OPTION_ARG_FILENAME
  G_OPTION_ARG_STRING_ARRAY
  G_OPTION_ARG_FILENAME_ARRAY
  G_OPTION_ARG_DOUBLE
  G_OPTION_ARG_INT64
>;

constant GOptionError is export := guint32;
our enum GOptionErrorEnum is export <
  G_OPTION_ERROR_UNKNOWN_OPTION
  G_OPTION_ERROR_BAD_VALUE
  G_OPTION_ERROR_FAILED
>;

constant GParamFlags     is export := gint32;
our enum GParamFlagsEnum is export (
  G_PARAM_READABLE         => 1 +< 0,
  G_PARAM_WRITABLE         => 1 +< 1,
  G_PARAM_READWRITE        => 1 +| 1 +< 1, # (G_PARAM_READABLE | G_PARAM_WRITABLE),
  G_PARAM_CONSTRUCT        => 1 +< 2,
  G_PARAM_CONSTRUCT_ONLY   => 1 +< 3,
  G_PARAM_LAX_VALIDATION   => 1 +< 4,
  G_PARAM_STATIC_NAME      => 1 +< 5,
  G_PARAM_PRIVATE          => 1 +< 5,      # GLIB_DEPRECATED_ENUMERATOR_IN_2_26
  G_PARAM_STATIC_NICK      => 1 +< 6,
  G_PARAM_STATIC_BLURB     => 1 +< 7,
  G_PARAM_EXPLICIT_NOTIFY  => 1 +< 30,
  G_PARAM_DEPRECATED       => -2147483648
);

constant GPollableReturn     is export := gint;
our enum GPollableReturnEnum is export (
  G_POLLABLE_RETURN_FAILED       => 0,
  G_POLLABLE_RETURN_OK           => 1,
  G_POLLABLE_RETURN_WOULD_BLOCK  => -27 # -G_IO_ERROR_WOULD_BLOCK
);

constant GSeekType           is export := guint;
our enum GSeekTypeEnum       is export <
  G_SEEK_CUR
  G_SEEK_SET
  G_SEEK_END
>;

constant GSignalFlags     is export := guint32;
our enum GSignalFlagsEnum is export (
  G_SIGNAL_RUN_FIRST    => 1,
  G_SIGNAL_RUN_LAST     => 1 +< 1,
  G_SIGNAL_RUN_CLEANUP  => 1 +< 2,
  G_SIGNAL_NO_RECURSE   => 1 +< 3,
  G_SIGNAL_DETAILED     => 1 +< 4,
  G_SIGNAL_ACTION       => 1 +< 5,
  G_SIGNAL_NO_HOOKS     => 1 +< 6,
  G_SIGNAL_MUST_COLLECT => 1 +< 7,
  G_SIGNAL_DEPRECATED   => 1 +< 8
);

constant GSignalMatchType     is export := guint32;
our enum GSignalMatchTypeEnum is export (
  G_SIGNAL_MATCH_ID        => 1,
  G_SIGNAL_MATCH_DETAIL    => 1 +< 1,
  G_SIGNAL_MATCH_CLOSURE   => 1 +< 2,
  G_SIGNAL_MATCH_FUNC      => 1 +< 3,
  G_SIGNAL_MATCH_DATA      => 1 +< 4,
  G_SIGNAL_MATCH_UNBLOCKED => 1 +< 5
);

our constant G_SIGNAL_MATCH_MASK is export = 0x3f;

constant GSourceReturn     is export := guint32;
our enum GSourceReturnEnum is export <
  G_SOURCE_REMOVE
  G_SOURCE_CONTINUE
>;

constant GSliceConfig     is export := guint32;
our enum GSliceConfigEnum is export (
  G_SLICE_CONFIG_ALWAYS_MALLOC        => 1,
  'G_SLICE_CONFIG_BYPASS_MAGAZINES',
  'G_SLICE_CONFIG_WORKING_SET_MSECS',
  'G_SLICE_CONFIG_COLOR_INCREMENT',
  'G_SLICE_CONFIG_CHUNK_SIZES',
  'G_SLICE_CONFIG_CONTENTION_COUNTER'
);

constant GTimeType     is export  := guint32;
our enum GTimeTypeEnum is export <
  G_TIME_TYPE_STANDARD
  G_TIME_TYPE_DAYLIGHT
  G_TIME_TYPE_UNIVERSAL
>;

# Token types
constant GTokenType     is export := guint32;
our enum GTokenTypeEnum is export (
  G_TOKEN_EOF                   =>  0,
  G_TOKEN_LEFT_PAREN            => '('.ord,
  G_TOKEN_RIGHT_PAREN           => ')'.ord,
  G_TOKEN_LEFT_CURLY            => '{'.ord,
  G_TOKEN_RIGHT_CURLY           => '}'.ord,
  G_TOKEN_LEFT_BRACE            => '['.ord,
  G_TOKEN_RIGHT_BRACE           => ']'.ord,
  G_TOKEN_EQUAL_SIGN            => '='.ord,
  G_TOKEN_COMMA                 => ','.ord,

  G_TOKEN_NONE                  => 256,

  'G_TOKEN_ERROR',
  'G_TOKEN_CHAR',
  'G_TOKEN_BINARY',
  'G_TOKEN_OCTAL',
  'G_TOKEN_INT',
  'G_TOKEN_HEX',
  'G_TOKEN_FLOAT',
  'G_TOKEN_STRING',
  'G_TOKEN_SYMBOL',
  'G_TOKEN_IDENTIFIER',
  'G_TOKEN_IDENTIFIER_NULL',
  'G_TOKEN_COMMENT_SINGLE',
  'G_TOKEN_COMMENT_MULTI',

  # Private
  'G_TOKEN_LAST'
);

constant GTraverseFlags     is export := guint32;
our enum GTraverseFlagsEnum is export (
  G_TRAVERSE_LEAVES     => 1,      # 1 << 0,
  G_TRAVERSE_NON_LEAVES => 2,      # 1 << 1,
  G_TRAVERSE_ALL        => 1 +| 2, # G_TRAVERSE_LEAVES | G_TRAVERSE_NON_LEAVES,
  G_TRAVERSE_MASK       => 0x03,   # 0x03,
  G_TRAVERSE_LEAFS      => 1,      # G_TRAVERSE_LEAVES,
  G_TRAVERSE_NON_LEAFS  => 2       # G_TRAVERSE_NON_LEAVES
);

constant GTraverseType     is export := guint32;
our enum GTraverseTypeEnum is export <
  G_IN_ORDER
  G_PRE_ORDER
  G_POST_ORDER
  G_LEVEL_ORDER
>;

# No constant because ... GType
our enum GTypeEnum is export (
  G_TYPE_INVALID   => 0,
  G_TYPE_NONE      => (1  +< 2),
  G_TYPE_INTERFACE => (2  +< 2),
  G_TYPE_CHAR      => (3  +< 2),
  G_TYPE_UCHAR     => (4  +< 2),
  G_TYPE_BOOLEAN   => (5  +< 2),
  G_TYPE_INT       => (6  +< 2),
  G_TYPE_UINT      => (7  +< 2),
  G_TYPE_LONG      => (8  +< 2),
  G_TYPE_ULONG     => (9  +< 2),
  G_TYPE_INT64     => (10 +< 2),
  G_TYPE_UINT64    => (11 +< 2),
  G_TYPE_ENUM      => (12 +< 2),
  G_TYPE_FLAGS     => (13 +< 2),
  G_TYPE_FLOAT     => (14 +< 2),
  G_TYPE_DOUBLE    => (15 +< 2),
  G_TYPE_STRING    => (16 +< 2),
  G_TYPE_POINTER   => (17 +< 2),
  G_TYPE_BOXED     => (18 +< 2),
  G_TYPE_PARAM     => (19 +< 2),
  G_TYPE_OBJECT    => (20 +< 2),
  G_TYPE_VARIANT   => (21 +< 2),

  G_TYPE_RESERVED_GLIB_FIRST => 22,
  G_TYPE_RESERVED_GLIB_LAST  => 31,
  G_TYPE_RESERVED_BSE_FIRST  => 32,
  G_TYPE_RESERVED_BSE_LAST   => 48,
  G_TYPE_RESERVED_USER_FIRST => 49
);

constant GUnicodeType     is export := guint32;
our enum GUnicodeTypeEnum is export <
  G_UNICODE_CONTROL
  G_UNICODE_FORMAT
  G_UNICODE_UNASSIGNED
  G_UNICODE_PRIVATE_USE
  G_UNICODE_SURROGATE
  G_UNICODE_LOWERCASE_LETTER
  G_UNICODE_MODIFIER_LETTER
  G_UNICODE_OTHER_LETTER
  G_UNICODE_TITLECASE_LETTER
  G_UNICODE_UPPERCASE_LETTER
  G_UNICODE_SPACING_MARK
  G_UNICODE_ENCLOSING_MARK
  G_UNICODE_NON_SPACING_MARK
  G_UNICODE_DECIMAL_NUMBER
  G_UNICODE_LETTER_NUMBER
  G_UNICODE_OTHER_NUMBER
  G_UNICODE_CONNECT_PUNCTUATION
  G_UNICODE_DASH_PUNCTUATION
  G_UNICODE_CLOSE_PUNCTUATION
  G_UNICODE_FINAL_PUNCTUATION
  G_UNICODE_INITIAL_PUNCTUATION
  G_UNICODE_OTHER_PUNCTUATION
  G_UNICODE_OPEN_PUNCTUATION
  G_UNICODE_CURRENCY_SYMBOL
  G_UNICODE_MODIFIER_SYMBOL
  G_UNICODE_MATH_SYMBOL
  G_UNICODE_OTHER_SYMBOL
  G_UNICODE_LINE_SEPARATOR
  G_UNICODE_PARAGRAPH_SEPARATOR
  G_UNICODE_SPACE_SEPARATOR
>;

constant GUnicodeBreakType     is export := guint32;
our enum GUnicodeBreakTypeEnum is export <
  G_UNICODE_BREAK_MANDATORY
  G_UNICODE_BREAK_CARRIAGE_RETURN
  G_UNICODE_BREAK_LINE_FEED
  G_UNICODE_BREAK_COMBINING_MARK
  G_UNICODE_BREAK_SURROGATE
  G_UNICODE_BREAK_ZERO_WIDTH_SPACE
  G_UNICODE_BREAK_INSEPARABLE
  G_UNICODE_BREAK_NON_BREAKING_GLUE
  G_UNICODE_BREAK_CONTINGENT
  G_UNICODE_BREAK_SPACE
  G_UNICODE_BREAK_AFTER
  G_UNICODE_BREAK_BEFORE
  G_UNICODE_BREAK_BEFORE_AND_AFTER
  G_UNICODE_BREAK_HYPHEN
  G_UNICODE_BREAK_NON_STARTER
  G_UNICODE_BREAK_OPEN_PUNCTUATION
  G_UNICODE_BREAK_CLOSE_PUNCTUATION
  G_UNICODE_BREAK_QUOTATION
  G_UNICODE_BREAK_EXCLAMATION
  G_UNICODE_BREAK_IDEOGRAPHIC
  G_UNICODE_BREAK_NUMERIC
  G_UNICODE_BREAK_INFIX_SEPARATOR
  G_UNICODE_BREAK_SYMBOL
  G_UNICODE_BREAK_ALPHABETIC
  G_UNICODE_BREAK_PREFIX
  G_UNICODE_BREAK_POSTFIX
  G_UNICODE_BREAK_COMPLEX_CONTEXT
  G_UNICODE_BREAK_AMBIGUOUS
  G_UNICODE_BREAK_UNKNOWN
  G_UNICODE_BREAK_NEXT_LINE
  G_UNICODE_BREAK_WORD_JOINER
  G_UNICODE_BREAK_HANGUL_L_JAMO
  G_UNICODE_BREAK_HANGUL_V_JAMO
  G_UNICODE_BREAK_HANGUL_T_JAMO
  G_UNICODE_BREAK_HANGUL_LV_SYLLABLE
  G_UNICODE_BREAK_HANGUL_LVT_SYLLABLE
  G_UNICODE_BREAK_CLOSE_PARANTHESIS
  G_UNICODE_BREAK_CONDITIONAL_JAPANESE_STARTER
  G_UNICODE_BREAK_HEBREW_LETTER
  G_UNICODE_BREAK_REGIONAL_INDICATOR
  G_UNICODE_BREAK_EMOJI_BASE
  G_UNICODE_BREAK_EMOJI_MODIFIER
  G_UNICODE_BREAK_ZERO_WIDTH_JOINER
>;

constant GUnicodeScript     is export := guint32;
our enum GUnicodeScriptEnum is export (
  # ISO 15924 code
  G_UNICODE_SCRIPT_INVALID_CODE => -1,
  G_UNICODE_SCRIPT_COMMON       => 0,  # Zyyy
  'G_UNICODE_SCRIPT_INHERITED',          # Zinh (Qaai)
  'G_UNICODE_SCRIPT_ARABIC',             # Arab
  'G_UNICODE_SCRIPT_ARMENIAN',           # Armn
  'G_UNICODE_SCRIPT_BENGALI',            # Beng
  'G_UNICODE_SCRIPT_BOPOMOFO',           # Bopo
  'G_UNICODE_SCRIPT_CHEROKEE',           # Cher
  'G_UNICODE_SCRIPT_COPTIC',             # Copt (Qaac)
  'G_UNICODE_SCRIPT_CYRILLIC',           # Cyrl (Cyrs)
  'G_UNICODE_SCRIPT_DESERET',            # Dsrt
  'G_UNICODE_SCRIPT_DEVANAGARI',         # Deva
  'G_UNICODE_SCRIPT_ETHIOPIC',           # Ethi
  'G_UNICODE_SCRIPT_GEORGIAN',           # Geor (Geon, Geoa)
  'G_UNICODE_SCRIPT_GOTHIC',             # Goth
  'G_UNICODE_SCRIPT_GREEK',              # Grek
  'G_UNICODE_SCRIPT_GUJARATI',           # Gujr
  'G_UNICODE_SCRIPT_GURMUKHI',           # Guru
  'G_UNICODE_SCRIPT_HAN',                # Hani
  'G_UNICODE_SCRIPT_HANGUL',             # Hang
  'G_UNICODE_SCRIPT_HEBREW',             # Hebr
  'G_UNICODE_SCRIPT_HIRAGANA',           # Hira
  'G_UNICODE_SCRIPT_KANNADA',            # Knda
  'G_UNICODE_SCRIPT_KATAKANA',           # Kana
  'G_UNICODE_SCRIPT_KHMER',              # Khmr
  'G_UNICODE_SCRIPT_LAO',                # Laoo
  'G_UNICODE_SCRIPT_LATIN',              # Latn (Latf, Latg)
  'G_UNICODE_SCRIPT_MALAYALAM',          # Mlym
  'G_UNICODE_SCRIPT_MONGOLIAN',          # Mong
  'G_UNICODE_SCRIPT_MYANMAR',            # Mymr
  'G_UNICODE_SCRIPT_OGHAM',              # Ogam
  'G_UNICODE_SCRIPT_OLD_ITALIC',         # Ital
  'G_UNICODE_SCRIPT_ORIYA',              # Orya
  'G_UNICODE_SCRIPT_RUNIC',              # Runr
  'G_UNICODE_SCRIPT_SINHALA',            # Sinh
  'G_UNICODE_SCRIPT_SYRIAC',             # Syrc (Syrj, Syrn, Syre)
  'G_UNICODE_SCRIPT_TAMIL',              # Taml
  'G_UNICODE_SCRIPT_TELUGU',             # Telu
  'G_UNICODE_SCRIPT_THAANA',             # Thaa
  'G_UNICODE_SCRIPT_THAI',               # Thai
  'G_UNICODE_SCRIPT_TIBETAN',            # Tibt
  'G_UNICODE_SCRIPT_CANADIAN_ABORIGINAL',# Cans
  'G_UNICODE_SCRIPT_YI',                 # Yiii
  'G_UNICODE_SCRIPT_TAGALOG',            # Tglg
  'G_UNICODE_SCRIPT_HANUNOO',            # Hano
  'G_UNICODE_SCRIPT_BUHID',              # Buhd
  'G_UNICODE_SCRIPT_TAGBANWA',           # Tagb

  # Unicode-4.0 additions
  'G_UNICODE_SCRIPT_BRAILLE',            # Brai
  'G_UNICODE_SCRIPT_CYPRIOT',            # Cprt
  'G_UNICODE_SCRIPT_LIMBU',              # Limb
  'G_UNICODE_SCRIPT_OSMANYA',            # Osma
  'G_UNICODE_SCRIPT_SHAVIAN',            # Shaw
  'G_UNICODE_SCRIPT_LINEAR_B',           # Linb
  'G_UNICODE_SCRIPT_TAI_LE',             # Tale
  'G_UNICODE_SCRIPT_UGARITIC',           # Ugar

  # Unicode-4.1 additions
  'G_UNICODE_SCRIPT_NEW_TAI_LUE',        # Talu
  'G_UNICODE_SCRIPT_BUGINESE',           # Bugi
  'G_UNICODE_SCRIPT_GLAGOLITIC',         # Glag
  'G_UNICODE_SCRIPT_TIFINAGH',           # Tfng
  'G_UNICODE_SCRIPT_SYLOTI_NAGRI',       # Sylo
  'G_UNICODE_SCRIPT_OLD_PERSIAN',        # Xpeo
  'G_UNICODE_SCRIPT_KHAROSHTHI',         # Khar

  # Unicode-5.0 additions
  'G_UNICODE_SCRIPT_UNKNOWN',            # Zzzz
  'G_UNICODE_SCRIPT_BALINESE',           # Bali
  'G_UNICODE_SCRIPT_CUNEIFORM',          # Xsux
  'G_UNICODE_SCRIPT_PHOENICIAN',         # Phnx
  'G_UNICODE_SCRIPT_PHAGS_PA',           # Phag
  'G_UNICODE_SCRIPT_NKO',                # Nkoo

  # Unicode-5.1 additions
  'G_UNICODE_SCRIPT_KAYAH_LI',           # Kali
  'G_UNICODE_SCRIPT_LEPCHA',             # Lepc
  'G_UNICODE_SCRIPT_REJANG',             # Rjng
  'G_UNICODE_SCRIPT_SUNDANESE',          # Sund
  'G_UNICODE_SCRIPT_SAURASHTRA',         # Saur
  'G_UNICODE_SCRIPT_CHAM',               # Cham
  'G_UNICODE_SCRIPT_OL_CHIKI',           # Olck
  'G_UNICODE_SCRIPT_VAI',                # Vaii
  'G_UNICODE_SCRIPT_CARIAN',             # Cari
  'G_UNICODE_SCRIPT_LYCIAN',             # Lyci
  'G_UNICODE_SCRIPT_LYDIAN',             # Lydi

  # Unicode-5.2 additions
  'G_UNICODE_SCRIPT_AVESTAN',                # Avst
  'G_UNICODE_SCRIPT_BAMUM',                  # Bamu
  'G_UNICODE_SCRIPT_EGYPTIAN_HIEROGLYPHS',   # Egyp
  'G_UNICODE_SCRIPT_IMPERIAL_ARAMAIC',       # Armi
  'G_UNICODE_SCRIPT_INSCRIPTIONAL_PAHLAVI',  # Phli
  'G_UNICODE_SCRIPT_INSCRIPTIONAL_PARTHIAN', # Prti
  'G_UNICODE_SCRIPT_JAVANESE',               # Java
  'G_UNICODE_SCRIPT_KAITHI',                 # Kthi
  'G_UNICODE_SCRIPT_LISU',                   # Lisu
  'G_UNICODE_SCRIPT_MEETEI_MAYEK',           # Mtei
  'G_UNICODE_SCRIPT_OLD_SOUTH_ARABIAN',      # Sarb
  'G_UNICODE_SCRIPT_OLD_TURKIC',             # Orkh
  'G_UNICODE_SCRIPT_SAMARITAN',              # Samr
  'G_UNICODE_SCRIPT_TAI_THAM',               # Lana
  'G_UNICODE_SCRIPT_TAI_VIET',               # Tavt

  # Unicode-6.0 additions
  'G_UNICODE_SCRIPT_BATAK',                  # Batk
  'G_UNICODE_SCRIPT_BRAHMI',                 # Brah
  'G_UNICODE_SCRIPT_MANDAIC',                # Mand

  # Unicode-6.1 additions
  'G_UNICODE_SCRIPT_CHAKMA',                 # Cakm
  'G_UNICODE_SCRIPT_MEROITIC_CURSIVE',       # Merc
  'G_UNICODE_SCRIPT_MEROITIC_HIEROGLYPHS',   # Mero
  'G_UNICODE_SCRIPT_MIAO',                   # Plrd
  'G_UNICODE_SCRIPT_SHARADA',                # Shrd
  'G_UNICODE_SCRIPT_SORA_SOMPENG',           # Sora
  'G_UNICODE_SCRIPT_TAKRI',                  # Takr

  # Unicode 7.0 additions
  'G_UNICODE_SCRIPT_BASSA_VAH',              # Bass
  'G_UNICODE_SCRIPT_CAUCASIAN_ALBANIAN',     # Aghb
  'G_UNICODE_SCRIPT_DUPLOYAN',               # Dupl
  'G_UNICODE_SCRIPT_ELBASAN',                # Elba
  'G_UNICODE_SCRIPT_GRANTHA',                # Gran
  'G_UNICODE_SCRIPT_KHOJKI',                 # Khoj
  'G_UNICODE_SCRIPT_KHUDAWADI',              # Sind
  'G_UNICODE_SCRIPT_LINEAR_A',               # Lina
  'G_UNICODE_SCRIPT_MAHAJANI',               # Mahj
  'G_UNICODE_SCRIPT_MANICHAEAN',             # Manu
  'G_UNICODE_SCRIPT_MENDE_KIKAKUI',          # Mend
  'G_UNICODE_SCRIPT_MODI',                   # Modi
  'G_UNICODE_SCRIPT_MRO',                    # Mroo
  'G_UNICODE_SCRIPT_NABATAEAN',              # Nbat
  'G_UNICODE_SCRIPT_OLD_NORTH_ARABIAN',      # Narb
  'G_UNICODE_SCRIPT_OLD_PERMIC',             # Perm
  'G_UNICODE_SCRIPT_PAHAWH_HMONG',           # Hmng
  'G_UNICODE_SCRIPT_PALMYRENE',              # Palm
  'G_UNICODE_SCRIPT_PAU_CIN_HAU',            # Pauc
  'G_UNICODE_SCRIPT_PSALTER_PAHLAVI',        # Phlp
  'G_UNICODE_SCRIPT_SIDDHAM',                # Sidd
  'G_UNICODE_SCRIPT_TIRHUTA',                # Tirh
  'G_UNICODE_SCRIPT_WARANG_CITI',            # Wara

  # Unicode 8.0 additions
  'G_UNICODE_SCRIPT_AHOM',                   # Ahom
  'G_UNICODE_SCRIPT_ANATOLIAN_HIEROGLYPHS',  # Hluw
  'G_UNICODE_SCRIPT_HATRAN',                 # Hatr
  'G_UNICODE_SCRIPT_MULTANI',                # Mult
  'G_UNICODE_SCRIPT_OLD_HUNGARIAN',          # Hung
  'G_UNICODE_SCRIPT_SIGNWRITING',            # Sgnw

  # Unicode 9.0 additions
  'G_UNICODE_SCRIPT_ADLAM',                  # Adlm
  'G_UNICODE_SCRIPT_BHAIKSUKI',              # Bhks
  'G_UNICODE_SCRIPT_MARCHEN',                # Marc
  'G_UNICODE_SCRIPT_NEWA',                   # Newa
  'G_UNICODE_SCRIPT_OSAGE',                  # Osge
  'G_UNICODE_SCRIPT_TANGUT',                 # Tang

  # Unicode 10.0 additions
  'G_UNICODE_SCRIPT_MASARAM_GONDI',          # Gonm
  'G_UNICODE_SCRIPT_NUSHU',                  # Nshu
  'G_UNICODE_SCRIPT_SOYOMBO',                # Soyo
  'G_UNICODE_SCRIPT_ZANABAZAR_SQUARE',       # Zanb

  # Unicode 11.0 additions
  'G_UNICODE_SCRIPT_DOGRA',                  # Dogr
  'G_UNICODE_SCRIPT_GUNJALA_GONDI',          # Gong
  'G_UNICODE_SCRIPT_HANIFI_ROHINGYA',        # Rohg
  'G_UNICODE_SCRIPT_MAKASAR',                # Maka
  'G_UNICODE_SCRIPT_MEDEFAIDRIN',            # Medf
  'G_UNICODE_SCRIPT_OLD_SOGDIAN',            # Sogo
  'G_UNICODE_SCRIPT_SOGDIAN'                 # Sogd
);

# This name could be bad...
constant GVariantClass     is export := guint32;
our enum GVariantClassEnum is export <
  G_VARIANT_CLASS_BOOLEAN
  G_VARIANT_CLASS_BYTE
  G_VARIANT_CLASS_INT16
  G_VARIANT_CLASS_UINT16
  G_VARIANT_CLASS_INT32
  G_VARIANT_CLASS_UINT32
  G_VARIANT_CLASS_INT64
  G_VARIANT_CLASS_UINT64
  G_VARIANT_CLASS_HANDLE
  G_VARIANT_CLASS_DOUBLE
  G_VARIANT_CLASS_STRING
  G_VARIANT_CLASS_OBJECT_PATH
  G_VARIANT_CLASS_SIGNATURE
  G_VARIANT_CLASS_VARIANT
  G_VARIANT_CLASS_MAYBE
  G_VARIANT_CLASS_ARRAY
  G_VARIANT_CLASS_TUPLE
  G_VARIANT_CLASS_DICT_ENTRY
>;

constant GPriority is export := guint32;
our enum GPriorityEnum is export (
  G_PRIORITY_HIGH         => -100,
  G_PRIORITY_DEFAULT      => 0,
  G_PRIORITY_HIGH_IDLE    => 100,
  G_PRIORITY_DEFAULT_IDLE => 200,
  G_PRIORITY_LOW          => 300
);

constant GTypeDebugFlags is export := guint32;
our enum GTypeDebugFlagsEnum is export (
  G_TYPE_DEBUG_NONE           => 0,
  G_TYPE_DEBUG_OBJECTS        => 1 +< 0,
  G_TYPE_DEBUG_SIGNALS        => 1 +< 1,
  G_TYPE_DEBUG_INSTANCE_COUNT => 1 +< 2,
  G_TYPE_DEBUG_MASK           => 0x07
);

constant GTypeFundamentalFlags is export := guint32;
our enum GTypeFundamentalFlagsEnum is export (
  G_TYPE_FLAG_CLASSED           => 1 +< 0,
  G_TYPE_FLAG_INSTANTIATABLE    => 1 +< 1,
  G_TYPE_FLAG_DERIVABLE         => 1 +< 2,
  G_TYPE_FLAG_DEEP_DERIVABLE    => 1 +< 3
);

constant GTypeFlags is export := guint32;
our enum GTypeFlagsEnum is export (
  G_TYPE_FLAG_ABSTRACT          => 1 +< 4,
  G_TYPE_FLAG_VALUE_ABSTRACT    => 1 +< 5
);

constant GParamType is export := GType;
our enum GParamTypeEnums is export (
  G_TYPE_PARAM_CHAR_IDX         => 0,
  G_TYPE_PARAM_UCHAR_IDX        => 1,
  G_TYPE_PARAM_BOOLEAN_IDX      => 2,
  G_TYPE_PARAM_INT_IDX          => 3,
  G_TYPE_PARAM_UINT_IDX         => 4,
  G_TYPE_PARAM_LONG_IDX         => 5,
  G_TYPE_PARAM_ULONG_IDX        => 6,
  G_TYPE_PARAM_INT64_IDX        => 7,
  G_TYPE_PARAM_UINT64_IDX       => 8,
  G_TYPE_PARAM_UNICHAR_IDX      => 9,
  G_TYPE_PARAM_ENUM_IDX         => 10,
  G_TYPE_PARAM_FLAGS_IDX        => 11,
  G_TYPE_PARAM_FLOAT_IDX        => 12,
  G_TYPE_PARAM_DOUBLE_IDX       => 13,
  G_TYPE_PARAM_STRING_IDX       => 14,
  G_TYPE_PARAM_PARAM_IDX        => 15,
  G_TYPE_PARAM_BOXED_IDX        => 16,
  G_TYPE_PARAM_POINTER_IDX      => 17,
  G_TYPE_PARAM_VALUE_ARRAY_IDX  => 18,
  G_TYPE_PARAM_OBJECT_IDX       => 19,
  G_TYPE_PARAM_OVERRIDE_IDX     => 20,
  G_TYPE_PARAM_GTYPE_IDX        => 21,
  G_TYPE_PARAM_VARIANT_IDX      => 22
);

constant GSpawnError is export := guint32;
our enum GSpawnErrorEnum is export <
  G_SPAWN_ERROR_FORK
  G_SPAWN_ERROR_READ
  G_SPAWN_ERROR_CHDIR
  G_SPAWN_ERROR_ACCES
  G_SPAWN_ERROR_PERM
  G_SPAWN_ERROR_TOO_BIG
  G_SPAWN_ERROR_NOEXEC
  G_SPAWN_ERROR_NAMETOOLONG
  G_SPAWN_ERROR_NOENT
  G_SPAWN_ERROR_NOMEM
  G_SPAWN_ERROR_NOTDIR
  G_SPAWN_ERROR_LOOP
  G_SPAWN_ERROR_TXTBUSY
  G_SPAWN_ERROR_IO
  G_SPAWN_ERROR_NFILE
  G_SPAWN_ERROR_MFILE
  G_SPAWN_ERROR_INVAL
  G_SPAWN_ERROR_ISDIR
  G_SPAWN_ERROR_LIBBAD
  G_SPAWN_ERROR_FAILED
>;
constant G_SPAWN_ERROR_2BIG = G_SPAWN_ERROR_TOO_BIG;

constant GSpawnFlags is export := guint32;
our enum GSpawnFlagsEnum is export (
  G_SPAWN_DEFAULT                => 0,
  G_SPAWN_LEAVE_DESCRIPTORS_OPEN => 1 +< 0,
  G_SPAWN_DO_NOT_REAP_CHILD      => 1 +< 1,
  G_SPAWN_SEARCH_PATH            => 1 +< 2,
  G_SPAWN_STDOUT_TO_DEV_NULL     => 1 +< 3,
  G_SPAWN_STDERR_TO_DEV_NULL     => 1 +< 4,
  G_SPAWN_CHILD_INHERITS_STDIN   => 1 +< 5,
  G_SPAWN_FILE_AND_ARGV_ZERO     => 1 +< 6,
  G_SPAWN_SEARCH_PATH_FROM_ENVP  => 1 +< 7,
  G_SPAWN_CLOEXEC_PIPES          => 1 +< 8
);

constant GRegexError is export := guint32;
our enum GRegexErrorEnum is export (
  'G_REGEX_ERROR_COMPILE',
  'G_REGEX_ERROR_OPTIMIZE',
  'G_REGEX_ERROR_REPLACE',
  'G_REGEX_ERROR_MATCH',
  'G_REGEX_ERROR_INTERNAL',
  G_REGEX_ERROR_STRAY_BACKSLASH                              => 101,
  G_REGEX_ERROR_MISSING_CONTROL_CHAR                         => 102,
  G_REGEX_ERROR_UNRECOGNIZED_ESCAPE                          => 103,
  G_REGEX_ERROR_QUANTIFIERS_OUT_OF_ORDER                     => 104,
  G_REGEX_ERROR_QUANTIFIER_TOO_BIG                           => 105,
  G_REGEX_ERROR_UNTERMINATED_CHARACTER_CLASS                 => 106,
  G_REGEX_ERROR_INVALID_ESCAPE_IN_CHARACTER_CLASS            => 107,
  G_REGEX_ERROR_RANGE_OUT_OF_ORDER                           => 108,
  G_REGEX_ERROR_NOTHING_TO_REPEAT                            => 109,
  G_REGEX_ERROR_UNRECOGNIZED_CHARACTER                       => 112,
  G_REGEX_ERROR_POSIX_NAMED_CLASS_OUTSIDE_CLASS              => 113,
  G_REGEX_ERROR_UNMATCHED_PARENTHESIS                        => 114,
  G_REGEX_ERROR_INEXISTENT_SUBPATTERN_REFERENCE              => 115,
  G_REGEX_ERROR_UNTERMINATED_COMMENT                         => 118,
  G_REGEX_ERROR_EXPRESSION_TOO_LARGE                         => 120,
  G_REGEX_ERROR_MEMORY_ERROR                                 => 121,
  G_REGEX_ERROR_VARIABLE_LENGTH_LOOKBEHIND                   => 125,
  G_REGEX_ERROR_MALFORMED_CONDITION                          => 126,
  G_REGEX_ERROR_TOO_MANY_CONDITIONAL_BRANCHES                => 127,
  G_REGEX_ERROR_ASSERTION_EXPECTED                           => 128,
  G_REGEX_ERROR_UNKNOWN_POSIX_CLASS_NAME                     => 130,
  G_REGEX_ERROR_POSIX_COLLATING_ELEMENTS_NOT_SUPPORTED       => 131,
  G_REGEX_ERROR_HEX_CODE_TOO_LARGE                           => 134,
  G_REGEX_ERROR_INVALID_CONDITION                            => 135,
  G_REGEX_ERROR_SINGLE_BYTE_MATCH_IN_LOOKBEHIND              => 136,
  G_REGEX_ERROR_INFINITE_LOOP                                => 140,
  G_REGEX_ERROR_MISSING_SUBPATTERN_NAME_TERMINATOR           => 142,
  G_REGEX_ERROR_DUPLICATE_SUBPATTERN_NAME                    => 143,
  G_REGEX_ERROR_MALFORMED_PROPERTY                           => 146,
  G_REGEX_ERROR_UNKNOWN_PROPERTY                             => 147,
  G_REGEX_ERROR_SUBPATTERN_NAME_TOO_LONG                     => 148,
  G_REGEX_ERROR_TOO_MANY_SUBPATTERNS                         => 149,
  G_REGEX_ERROR_INVALID_OCTAL_VALUE                          => 151,
  G_REGEX_ERROR_TOO_MANY_BRANCHES_IN_DEFINE                  => 154,
  G_REGEX_ERROR_DEFINE_REPETION                              => 155,
  G_REGEX_ERROR_INCONSISTENT_NEWLINE_OPTIONS                 => 156,
  G_REGEX_ERROR_MISSING_BACK_REFERENCE                       => 157,
  G_REGEX_ERROR_INVALID_RELATIVE_REFERENCE                   => 158,
  G_REGEX_ERROR_BACKTRACKING_CONTROL_VERB_ARGUMENT_FORBIDDEN => 159,
  G_REGEX_ERROR_UNKNOWN_BACKTRACKING_CONTROL_VERB            => 160,
  G_REGEX_ERROR_NUMBER_TOO_BIG                               => 161,
  G_REGEX_ERROR_MISSING_SUBPATTERN_NAME                      => 162,
  G_REGEX_ERROR_MISSING_DIGIT                                => 163,
  G_REGEX_ERROR_INVALID_DATA_CHARACTER                       => 164,
  G_REGEX_ERROR_EXTRA_SUBPATTERN_NAME                        => 165,
  G_REGEX_ERROR_BACKTRACKING_CONTROL_VERB_ARGUMENT_REQUIRED  => 166,
  G_REGEX_ERROR_INVALID_CONTROL_CHAR                         => 168,
  G_REGEX_ERROR_MISSING_NAME                                 => 169,
  G_REGEX_ERROR_NOT_SUPPORTED_IN_CLASS                       => 171,
  G_REGEX_ERROR_TOO_MANY_FORWARD_REFERENCES                  => 172,
  G_REGEX_ERROR_NAME_TOO_LONG                                => 175,
  G_REGEX_ERROR_CHARACTER_VALUE_TOO_LARGE                    => 176,
);

constant GRegexMatchFlags is export := guint32;
our enum GRegexMatchFlagsEnum is export (
  G_REGEX_MATCH_ANCHORED         => 1 +< 4,
  G_REGEX_MATCH_NOTBOL           => 1 +< 7,
  G_REGEX_MATCH_NOTEOL           => 1 +< 8,
  G_REGEX_MATCH_NOTEMPTY         => 1 +< 10,
  G_REGEX_MATCH_PARTIAL          => 1 +< 15,
  G_REGEX_MATCH_NEWLINE_CR       => 1 +< 20,
  G_REGEX_MATCH_NEWLINE_LF       => 1 +< 21,
  G_REGEX_MATCH_NEWLINE_CRLF     => 1 +< 20 +| 1 +< 21,    #= G_REGEX_MATCH_NEWLINE_CR | G_REGEX_MATCH_NEWLINE_LF,
  G_REGEX_MATCH_NEWLINE_ANY      => 1 +< 22,
  G_REGEX_MATCH_NEWLINE_ANYCRLF  => 1 +< 20 +| 1 +< 22,    #= G_REGEX_MATCH_NEWLINE_CR | G_REGEX_MATCH_NEWLINE_ANY,
  G_REGEX_MATCH_BSR_ANYCRLF      => 1 +< 23,
  G_REGEX_MATCH_BSR_ANY          => 1 +< 24,
  G_REGEX_MATCH_PARTIAL_SOFT     => 1 +< 15,               #= G_REGEX_MATCH_PARTIAL,
  G_REGEX_MATCH_PARTIAL_HARD     => 1 +< 27,
  G_REGEX_MATCH_NOTEMPTY_ATSTART => 1 +< 28
);

constant GRegexCompileFlags is export := guint32;
our enum GRegexCompileFlagsEnum is export (
  G_REGEX_CASELESS          => 1 +< 0,
  G_REGEX_MULTILINE         => 1 +< 1,
  G_REGEX_DOTALL            => 1 +< 2,
  G_REGEX_EXTENDED          => 1 +< 3,
  G_REGEX_ANCHORED          => 1 +< 4,
  G_REGEX_DOLLAR_ENDONLY    => 1 +< 5,
  G_REGEX_UNGREEDY          => 1 +< 9,
  G_REGEX_RAW               => 1 +< 11,
  G_REGEX_NO_AUTO_CAPTURE   => 1 +< 12,
  G_REGEX_OPTIMIZE          => 1 +< 13,
  G_REGEX_FIRSTLINE         => 1 +< 18,
  G_REGEX_DUPNAMES          => 1 +< 19,
  G_REGEX_NEWLINE_CR        => 1 +< 20,
  G_REGEX_NEWLINE_LF        => 1 +< 21,
  G_REGEX_NEWLINE_CRLF      => 1 +< 20 +| 1 +< 21, #= G_REGEX_NEWLINE_CR | G_REGEX_NEWLINE_LF,
  G_REGEX_NEWLINE_ANYCRLF   => 1 +< 20 +| 1 +< 22, #= G_REGEX_NEWLINE_CR | 1 << 22,
  G_REGEX_BSR_ANYCRLF       => 1 +< 23,
  G_REGEX_JAVASCRIPT_COMPAT => 1 +< 25
);

constant GFileTest is export := guint32;
our enum GFileTestEnum is export (
  G_FILE_TEST_IS_REGULAR    => 1,
  G_FILE_TEST_IS_SYMLINK    => 1 +< 1,
  G_FILE_TEST_IS_DIR        => 1 +< 2,
  G_FILE_TEST_IS_EXECUTABLE => 1 +< 3,
  G_FILE_TEST_EXISTS        => 1 +< 4
);

constant GLogLevelFlags is export := guint32;
enum GLogLevelFlagsEnums is export (
  # log flags
  G_LOG_FLAG_RECURSION          => 1,
  G_LOG_FLAG_FATAL              => 1 +< 1,

  # GLib log level+>
  G_LOG_LEVEL_ERROR             => 1 +< 2,       #= always fatal
  G_LOG_LEVEL_CRITICAL          => 1 +< 3,
  G_LOG_LEVEL_WARNING           => 1 +< 4,
  G_LOG_LEVEL_MESSAGE           => 1 +< 5,
  G_LOG_LEVEL_INFO              => 1 +< 6,
  G_LOG_LEVEL_DEBUG             => 1 +< 7,

  G_LOG_LEVEL_MASK              => 0b11111100    #= ~(G_LOG_FLAG_RECURSION | G_LOG_FLAG_FATAL)
);

constant GTestLogType is export := guint32;
enum GTestLogTypeEnum is export (
  'G_TEST_LOG_NONE',
  'G_TEST_LOG_ERROR',             #= s:msg
  'G_TEST_LOG_START_BINARY',      #= s:binaryname s:seed
  'G_TEST_LOG_LIST_CASE',         #= s:testpath
  'G_TEST_LOG_SKIP_CASE',         #= s:testpath
  'G_TEST_LOG_START_CASE',        #= s:testpath
  'G_TEST_LOG_STOP_CASE',         #= d:status d:nforks d:elapsed
  'G_TEST_LOG_MIN_RESULT',        #= s:blurb d:result
  'G_TEST_LOG_MAX_RESULT',        #= s:blurb d:result
  'G_TEST_LOG_MESSAGE',           #= s:blurb
  'G_TEST_LOG_START_SUITE',
  'G_TEST_LOG_STOP_SUITE'
);

constant GTestResult is export := guint32;
enum GTestResultEnum is export <
  G_TEST_RUN_SUCCESS
  G_TEST_RUN_SKIPPED
  G_TEST_RUN_FAILURE
  G_TEST_RUN_INCOMPLETE
>;

constant GTestFileType is export := guint32;
our enum GTestFileTypeEnum is export <
  G_TEST_DIST
  G_TEST_BUILT
>;

constant GTestTrapFlags is export := guint32;
our enum GTestTrapFlagsEnum is export (
  G_TEST_TRAP_SILENCE_STDOUT    => 1 +< 7,
  G_TEST_TRAP_SILENCE_STDERR    => 1 +< 8,
  G_TEST_TRAP_INHERIT_STDIN     => 1 +< 9
);

constant GTestSubprocessFlags is export := guint32;
our enum GTestSubprocessFlagsEnum is export (
  G_TEST_SUBPROCESS_INHERIT_STDIN  => 1,
  G_TEST_SUBPROCESS_INHERIT_STDOUT => 1 +< 1,
  G_TEST_SUBPROCESS_INHERIT_STDERR => 1 +< 2
);

constant GDateDMY is export := guint32;
our enum GDateDMYEnum is export (
  G_DATE_DAY   => 0,
  G_DATE_MONTH => 1,
  G_DATE_YEAR  => 2,
);

constant GDateMonth is export := guint32;
our enum GDateMonthEnum is export (
  G_DATE_BAD_MONTH =>  0,
  G_DATE_JANUARY   =>  1,
  G_DATE_FEBRUARY  =>  2,
  G_DATE_MARCH     =>  3,
  G_DATE_APRIL     =>  4,
  G_DATE_MAY       =>  5,
  G_DATE_JUNE      =>  6,
  G_DATE_JULY      =>  7,
  G_DATE_AUGUST    =>  8,
  G_DATE_SEPTEMBER =>  9,
  G_DATE_OCTOBER   => 10,
  G_DATE_NOVEMBER  => 11,
  G_DATE_DECEMBER  => 12,
);

constant GDateWeekday is export := guint32;
our enum GDateWeekdayEnum is export (
  G_DATE_BAD_WEEKDAY => 0,
  G_DATE_MONDAY      => 1,
  G_DATE_TUESDAY     => 2,
  G_DATE_WEDNESDAY   => 3,
  G_DATE_THURSDAY    => 4,
  G_DATE_FRIDAY      => 5,
  G_DATE_SATURDAY    => 6,
  G_DATE_SUNDAY      => 7,
);

our $g-param-spec-types is export;

sub get_paramspec_types ()
  returns CArray[GType]
  is native(&glib-support)
  is export
{ * }

sub getEnumValueByNick(\T, Str() $nick) is export {
  state %cache;

  my \n := T.^wname;
  unless %cache{n}:exists {
    my $remove = max :all, :by{.chars},
      keys [∩] T.enums.keys».match(/.+/, :ex)».Str;
    #@tokens.map({ $_ .=  subst($remove[0], ''); s/_/-/; .lc });
    %cache{n} = (gather for T.enums.pairs {
      my @a = .key.subst($remove[0], '').subst('_', '-');
      take Pair.new(@a[* - 1], .value);
      take Pair.new(@a[* - 1].lc, .value);
    }).Hash
  }
  ::(T)( %cache{n}{$nick} )
}

our %DOMAINS is export = (
  51 => GKeyFileErrorEnum
);

BEGIN {
  %strToGType = GTypeEnum.enums.pairs.map({
    Pair.new( .key.subst("G_TYPE_").lc, GTypeEnum( .value ) )
  });
}

INIT {
  CATCH { .message.say; .backtrace.concise.say }

  $g-param-spec-types = get_paramspec_types;
}
