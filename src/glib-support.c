#include <glib-object.h>

typedef struct FuncBlock {
  void ( *func_none)(void);
  void (  *func_one)(int *a);
  void (  *func_two)(int *a, int *b);
  void (*func_three)(int *a, int *b, int *c);
} FuncBlock;

FuncBlock *funcs;

void *
get_paramspec_types (void) {
    return g_param_spec_types;
}

void init_func_block (void) {
  funcs = (FuncBlock *)malloc(sizeof(FuncBlock));
}

FuncBlock *get_func_block (void) {
  return funcs;
}

void test_func_block (void) {
  int a = 1;
  int b = 2;
  int c = 3;

  if (funcs->func_none)
    funcs->func_none();

  if (funcs->func_one)
    funcs->func_one(&a);

  if (funcs->func_two)
    funcs->func_two(&a, &b);

  if (funcs->func_three)
    funcs->func_three(&a, &b, &c);
}
