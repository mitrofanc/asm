#ifndef INVERT_IMPL_H
#define INVERT_IMPL_H

struct Image;

#ifdef USE_NASM
void invert_colors_nasm(struct Image *img);
#define invert_colors invert_colors_nasm
#else
void invert_colors_c(struct Image *img);
#define invert_colors invert_colors_c
#endif

#endif /* INVERT_IMPL_H */
