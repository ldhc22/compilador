
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

void writeFile(char *file, char *text);

char * genMult(char * dest, char * arg1, char * arg2);

char * genDiv(char * dest, char * arg1, char * arg2);

char * genSum(char * dest, char * arg1, char * arg2);

char * genMinus(char * dest, char * arg1, char * arg2);

char * genAssign(char * dest, char * arg);