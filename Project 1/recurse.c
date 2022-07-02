#include <stdio.h>
#include <math.h>
#include <stdlib.h>

int f(int n) {
    if (n==0) {
        return -2;
    }
    return 3*n + 2*f(n-1) - 2;
}

int main(int argc, char *argv[]) {
    int n = atoi(argv[1]);
    int ret = f(n);
    printf("%d\n", ret);
    return 0;
}