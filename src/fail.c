#include <stdio.h>
#include <stdlib.h>

int main() {
    char * x  = malloc(sizeof(char) * 5);
    free(x);
    printf("%s\n",x);
    printf("Hello from Fil-C Hermetic Harness!\n");
    return 0;
}
