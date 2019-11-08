/* spatial subdivision */

#include <stdio.h>
#include <stdint.h>

#define MIDPOINT	127

uint8_t landscape[128][128];

int main(int argc, char *argv[])
{
	int rows = 1, cols = 1;
	int i = 0, j = 0;

	/* initialize entire array to midpoint */

	for (i = 0; i < 128; i++) {
		for (j = 0; j < 128 ; j++) {
			landscape[i][j] = MIDPOINT;
			}
		}

}
