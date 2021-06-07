#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <WinSock2.h>
#pragma comment(lib, "Ws2_32.lib")


int main(int argc, char *argv[])
{

  FILE *input = NULL;
  FILE *output = NULL;
  uint16_t w = 0;   /* width */
  uint16_t h = 0;   /* height */
  uint16_t r = 0;   /* range */
  uint16_t x = 0; 
  uint16_t y = 0;   
  uint16_t d = 0;   
  uint16_t t = 0;
  
  char buffer[70];
  uint16_t **data;

  if (argc < 3) {
      fprintf(stderr, "eroder <input> <output>\n");
    exit(1);   
  }

  fprintf(stderr, "Reading %s ...\n", argv[1]);

  input = fopen(argv[1], "rb");

  if (!input) {
      fprintf(stderr, "can't open file for reading\n");
      exit(1);
  }
  memset((char *) &buffer, 0, 70);
  fgets((char *) &buffer, 69, input);
  
  if (strncmp((const char* ) &buffer, "P5\n", 3) ==0 && strlen(buffer) == 3)  {
      fprintf(stderr, "PGM signature found\n");
  } else {
      fprintf(stderr, "Invalid input (%s)\n", buffer);
      fclose(input);
      exit(1);
  }

  memset((char *) &buffer, 0, 70);
  fgets((char *) &buffer, 69, input);
  sscanf((const char*) &buffer, "%hu %hu\n", &w, &h);

  memset((char *) &buffer, 0, 70);
  fgets((char *) &buffer, 69, input);
  sscanf((const char*) &buffer, "%hu\n", &r);

  fprintf(stderr, "width = %u\n", w);
  fprintf(stderr, "height = %u\n", h);
  fprintf(stderr, "range = %u\n", r);

  data = (uint16_t **) malloc(h *  sizeof(uint16_t *));
  
  for (y = 0 ; y < h; y++) {
    data[y] = (uint16_t *) malloc(w *sizeof(uint16_t));
  }

  /* read PGM binary format */

  for (y = 0 ; y < h; y++) {
    for (x = 0 ; x < w; x++) {
        //memset((char *) &buffer, 0, 70);
        //fgets((char *) &buffer, 69, input);
        //sscanf((const char*) &buffer, "%hu\n", &d);
        fread(&t, 2, 1, input);
        data[x][y]=ntohs(t);
    }
  }
 
  fclose (input); 

  /* write the data back out */

  fprintf(stderr, "Writing  %s ...\n", argv[2]);

  output = fopen(argv[2], "wb");
  if (!output) {
      fprintf(stderr, "can't open file for reading\n");
      exit(1);
  }
  fprintf(output, "P5\n%hu %hu\n%hu\n", w, h, r);

  /* write PGM ASCII format */

  for (y = 0 ; y < h; y++) {
    for (x = 0 ; x < w; x++) {
        fprintf(output, "%hu\n", data[x][y]);  
    }
  }
  fclose(output);

  exit (0);

}
