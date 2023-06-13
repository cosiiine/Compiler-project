# include <stdio.h>

int c;	// global variable

int f(int a, float b) {
	if (a == b) {	// a, b are different type
		return 1.0;	// return wrong type
	} else if (c) {
		a %= b;		// b is not int
		return;		// return wrong type
	}
	return a == c ? 1 : 0;
}
float g() {
	char c;		// local variable
	c = 'c';	// local test	: correct type
	c = 0;		// global test 	: wrong type
}