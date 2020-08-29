#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct _CStructTest {
  int a, b;
  float c;
  double d;
  char *e;
} CStructTest;

CStructTest *getStructArray() {
  CStructTest *list;
  int idx;
  char *num;

  list = (CStructTest *)calloc(5, sizeof(CStructTest));

  for (idx = 0; idx < 5; idx++) {
    list[idx].a = idx;
    list[idx].b = idx + 1;
    list[idx].c = 22.0 / 7.0 * idx;
    list[idx].d = idx ? (22.0 / 7.0 / idx) : 0;
    list[idx].e = malloc(10);
    num = (char *)malloc(5);
    sprintf(num, "%1d", idx);
    strcpy(list[idx].e, "Hello ");
    strcat(list[idx].e, num );
  }

  return list;
}
