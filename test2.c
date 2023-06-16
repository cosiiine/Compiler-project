#include <stdio.h>
int a;
int z(int a, int b) {
    return a + b;
}
int main()
{
    float a = 0.;
    int b = 1;
    // do {
    //     a += 1.2;
    // } while (a < 10.);
    // printf("a = %f\n", a);
    
    int c, d;
    while (c < 10 && d < 10) {
        z(c, 1);
        z(d, 2);
    }
    printf("%d %d\n", c, d);

    return 0;
}