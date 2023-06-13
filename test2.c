#include <stdio.h>

void main() {
    float a = -1.0e-3;  // exp float
    int x = 0, y = 1;

    switch (x)
    {
        case 0:
            a += x;     // a, x: different type
            break;

        case 1.2:       // wrong type
            a++;
            break;
        
        default:
            break;
    }

    return;
}