#include <stdio.h>
#include <math.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    int n = atoi(argv[1]);
    double ret = pow(2.0, (double)n) - 1.0;
    printf("%d\n", (int)ret);
    return 0;
}
