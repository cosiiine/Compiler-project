#include <stdio.h>
int a;
int z(int a, int b) {
    return a + b;
}
int main()
{
    int a = 0;
    int b = 1;
    do {
        a += 1;
        printf("%d", a);
    } while (a < 10)
    
    while (a > 0) {
        a = a - 1;
        printf("%d", a);
    }

    return 0;
}