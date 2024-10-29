/*
  List created from the output of:
    ( find . -name \*.h -exec grep -Hn 'typedef struct'} \; 1>&2 ) 2>&1 | \
       cut -d\  -f 4 | grep -v \{
*/

/* Strategy provided by p6-XML-LibXML:author<FROGGS> */
#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

#include <time.h>
#include <glib.h>
#include <glib-object.h>

#define s(name)     DLLEXPORT int sizeof_ ## name () { return sizeof(name); }

typedef struct tm tm;

typedef gint gatomicrefcount;

struct _GVariantTypeInfo
{
  gsize fixed_size;
  guchar alignment;
  guchar container_class;
};

typedef struct _GVariantTypeInfo GVariantTypeInfo;

struct _GVariant
/* see below for field member documentation */
{
  GVariantTypeInfo *type_info;
  gsize size;

  union
  {
    struct
    {
      GBytes *bytes;
      gconstpointer data;
    } serialised;

    struct
    {
      GVariant **children;
      gsize n_children;
    } tree;
  } contents;

  gint state;
  gatomicrefcount ref_count;
  gsize depth;
};

typedef struct _GVariant GVariant;

s(tm)
s(GArray)
s(GByteArray)
s(GCClosure)
s(GClosure)
s(GClosureNotifyData)
s(GCompletion)
s(GCond)
s(GDate)
s(GDebugKey)
s(GEnumValue)
s(GError)
s(GFlagsValue)
s(GHashTableIter)
s(GHook)
s(GHookList)
s(GInterfaceInfo)
s(GIOChannel)
s(GIOFuncs)
s(GList)
s(GLogField)
s(GMarkupParser)
s(GMemVTable)
s(GMutex)
s(GNode)
s(GObjectConstructParam)
//s(GObjectNotifyContext)
//s(GObjectNotifyQueue)
s(GOnce)
s(GOptionEntry)
s(GParameter)
s(GParamSpec)
s(GParamSpecBoolean)
s(GParamSpecBoxed)
s(GParamSpecChar)
s(GParamSpecClass)
s(GParamSpecDouble)
s(GParamSpecEnum)
s(GParamSpecFlags)
s(GParamSpecFloat)
s(GParamSpecGType)
s(GParamSpecInt)
s(GParamSpecInt64)
s(GParamSpecLong)
s(GParamSpecObject)
s(GParamSpecOverride)
s(GParamSpecParam)
s(GParamSpecPointer)
s(GParamSpecString)
s(GParamSpecTypeInfo)
s(GParamSpecUChar)
s(GParamSpecUInt)
s(GParamSpecUInt64)
s(GParamSpecULong)
s(GParamSpecUnichar)
s(GParamSpecValueArray)
s(GParamSpecVariant)
s(GPollFD)
s(GPrivate)
s(GPtrArray)
s(GQueue)
s(GRecMutex)
s(GRWLock)
s(GSignalInvocationHint)
s(GSignalQuery)
s(GSList)
s(GSource)
s(GSourceCallbackFuncs)
s(GSourceFuncs)
s(GStaticPrivate)
s(GStaticRecMutex)
s(GStaticRWLock)
s(GString)
s(GTestConfig)
s(GTestLogBuffer)
s(GTestLogMsg)
s(GThreadFunctions)
s(GThreadPool)
s(GTimeVal)
s(GTrashStack)
s(GTuples)
s(GTypeClass)
s(GTypeFundamentalInfo)
s(GTypeInfo)
s(GTypeInstance)
s(GTypeInterface)
s(GTypeModule)
s(GTypeModuleClass)
s(GTypePluginClass)
s(GTypeQuery)
s(GTypeValueTable)
s(GValue)
s(GValueArray)
s(GVariant)
s(GVariantBuilder)
s(GVariantDict)
s(GVariantIter)
s(GVariantTypeInfo)
s(GWeakRef)
s(GUriParamsIter)
s(GObjectClass)
