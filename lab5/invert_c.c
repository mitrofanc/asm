#include "invert_impl.h"
#include <stddef.h>
#include <stdint.h>

typedef unsigned char png_byte;

struct Image {
    int width;
    int height;
    png_byte *r;
    png_byte *g;
    png_byte *b;
};

void invert_colors_c(struct Image *img){
    size_t total = (size_t) img->width * img->height;
    for (size_t i = 0; i < total; ++i) {
        img->r[i] = ~img->r[i];
        img->g[i] = ~img->g[i];
        img->b[i] = ~img->b[i];
    }
}
