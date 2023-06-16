#include <stdio.h>
int global;
void z() {
    int a = 1;
    printf("call function\n");
    printf("a = %d\n\n", a);
    return;
}
int main()
{
    int a = 0, i;
    float b;

    z();

    for (i = 0; i < 10; i=i+1) {
        if (a > 5) printf("%d\n", a);
        else printf("fail\n");
        a = a + i;
    }

    printf("=== finish ===\n");

    return 0;
}