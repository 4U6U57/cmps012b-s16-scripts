#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define progfile FileReverse.java
#define perffile .d.performance.f
#define desfile .d.design.f
#define perfmax 5
#define desmax 5

int main (int argc, char **argv) {
  printf("This script is not yet ready\n\r");
  if (1) return 0;

  int gradep = 5; // p: performance, d: design
  int graded = 5;
  char notesp[1024] = {};
  char notesd[1024] = {};

  FILE *fp = fopen("progfile", "r");
  if (!fp) {
    printf("Warning: %s not found\n\r Now setting grade to ", progfile);
    printf("zero and adding appropriate notes\n\r");
    gradep = 0;
    graded = 0;
    strcpy(notesp, "Output test failed due to lack of code\n\r");
    strcpy(notesd, "Design grade receives a zero for lack of code\n\r");
  }
  fclose(fp);
  char temp[1024] = {};
  for (;fgets(temp, 1023, stdin);) {
    printf("%s]", argv[0]);
    if (0) {




    } else if (strncmp(temp, "-q")) {
      break;
    }
      system(temp);
    }
  }
  fp = fopen("perffile", "w");
  fprintf(fp, "%d / %d\n\r%s\n\r", gradep, perfmax, notesp);
  fclose(fp);
  fp = fopen("desfile", "w");
  fprintf(fp, "%d / %d\n\r%s\n\r", graded, desmax, notesd);
  fclose(fp);
}
