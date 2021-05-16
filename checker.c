#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>

#define WIDTH	128		/* default width */
#define HEIGHT	128		/* default height */
#define OFFSET	0		/* height above sea level */
#define MAXCOL	65535		/* maximum colour value */
#define BUMP	8

int main(int argc, char *argv[])
{

    int i = 0;
    int j = 0;
    uint16_t z = 0;

    /* basic PPM file, allowing easy preview */

    fprintf(stdout, "P2\n");
    fprintf(stdout, "%u %u\n", WIDTH, HEIGHT);
    fprintf(stdout, "%u\n", MAXCOL);

    for (i = 0; i < HEIGHT ; i++) {
        for (j = 0; j < WIDTH ; j++) {

            if ((j % 16) < 8) {
                if ((i % 16) < 8) {
                    z = (MAXCOL/2) + (OFFSET - BUMP);
                } else {
                    z = (MAXCOL/2) + (OFFSET + BUMP);
                }
            } else {
                if ((i % 16) < 8) {
                    z = (MAXCOL/2) + (OFFSET + BUMP);
                } else {
                    z = (MAXCOL/2) + (OFFSET - BUMP);
                }
            }

            fprintf(stdout, "%u\n", z);
        }
    }

    exit(0);
}
