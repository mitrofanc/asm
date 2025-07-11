#include <stdio.h>
#include <stdlib.h>
#include <png.h>
#include <time.h>
#include "invert_impl.h"

typedef unsigned char png_byte;

typedef struct Image {
    int width;
    int height;
    png_byte *r;
    png_byte *g;
    png_byte *b;
} Image;

static void read_png(const char *fname, Image *img){
    FILE *fp = fopen(fname, "rb");
    if (!fp) {
        perror(fname);
        exit(EXIT_FAILURE);
    }

    png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    png_infop   info = png_create_info_struct(png);
    if (!png || !info) {
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    if (setjmp(png_jmpbuf(png))) {
        png_destroy_read_struct(&png, &info, NULL);
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    png_init_io(png, fp);
    png_read_info(png, info);

    img->width  = png_get_image_width(png, info);
    img->height = png_get_image_height(png, info);
    png_byte ct = png_get_color_type(png, info);
    png_byte bd = png_get_bit_depth(png, info);

    if (bd == 16)
        png_set_strip_16(png);
    if (ct == PNG_COLOR_TYPE_PALETTE)
        png_set_palette_to_rgb(png);
    if (ct == PNG_COLOR_TYPE_GRAY && bd < 8)
        png_set_expand_gray_1_2_4_to_8(png);
    if (png_get_valid(png, info, PNG_INFO_tRNS))
        png_set_tRNS_to_alpha(png);
    if (ct == PNG_COLOR_TYPE_RGB_ALPHA || ct == PNG_COLOR_TYPE_GRAY_ALPHA)
        png_set_strip_alpha(png);
    if (ct == PNG_COLOR_TYPE_GRAY || ct == PNG_COLOR_TYPE_GRAY_ALPHA)
        png_set_gray_to_rgb(png);

    png_read_update_info(png, info);

    png_bytep *rows = malloc(sizeof(png_bytep) * img->height);
    if (!rows) {
        fprintf(stderr, "malloc failed for row pointers\n");
        png_destroy_read_struct(&png, &info, NULL);
        fclose(fp);
        exit(EXIT_FAILURE);
    }
    for (int y = 0; y < img->height; y++) {
        rows[y] = malloc(png_get_rowbytes(png, info));
        if (!rows[y]) {
            fprintf(stderr, "malloc failed for row %d\n", y);
            for (int k = 0; k < y; k++) free(rows[k]);
            free(rows);
            png_destroy_read_struct(&png, &info, NULL);
            fclose(fp);
            exit(EXIT_FAILURE);
        }
    }

    png_read_image(png, rows);
    png_read_end(png, NULL);

    size_t total = (size_t)img->width * img->height;
    img->r = malloc(total);
    img->g = malloc(total);
    img->b = malloc(total);
    if (!img->r || !img->g || !img->b) {
        fprintf(stderr, "malloc failed for image channels\n");
        for (int y = 0; y < img->height; y++) free(rows[y]);
        free(rows);
        free(img->r); free(img->g); free(img->b);
        png_destroy_read_struct(&png, &info, NULL);
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    for (int y = 0; y < img->height; y++) {
        png_bytep row = rows[y];
        for (int x = 0; x < img->width; x++) {
            size_t idx = (size_t)y * img->width + x;
            png_bytep px = &row[x * 3];
            img->r[idx] = px[0];
            img->g[idx] = px[1];
            img->b[idx] = px[2];
        }
        free(rows[y]);
    }
    free(rows);
    png_destroy_read_struct(&png, &info, NULL);
    fclose(fp);
}

static void write_png(const char *fname, Image *img)
{
    FILE *fp = fopen(fname, "wb");
    if (!fp) {
        perror(fname);
        exit(EXIT_FAILURE);
    }

    png_structp png = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    png_infop   info = png_create_info_struct(png);
    if (!png || !info) {
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    if (setjmp(png_jmpbuf(png))) {
        png_destroy_write_struct(&png, &info);
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    png_init_io(png, fp);
    png_set_IHDR(png, info,
                 img->width, img->height,
                 8, PNG_COLOR_TYPE_RGB,
                 PNG_INTERLACE_NONE,
                 PNG_COMPRESSION_TYPE_DEFAULT,
                 PNG_FILTER_TYPE_DEFAULT);
    png_write_info(png, info);

    png_bytep *rows = malloc(sizeof(png_bytep) * img->height);
    if (!rows) {
        fprintf(stderr, "malloc failed for write row pointers\n");
        png_destroy_write_struct(&png, &info);
        fclose(fp);
        exit(EXIT_FAILURE);
    }

    for (int y = 0; y < img->height; y++) {
        rows[y] = malloc((size_t)img->width * 3);
        if (!rows[y]) {
            fprintf(stderr, "malloc failed for write row %d\n", y);
            for (int k = 0; k < y; k++) free(rows[k]);
            free(rows);
            png_destroy_write_struct(&png, &info);
            fclose(fp);
            exit(EXIT_FAILURE);
        }

        for (int x = 0; x < img->width; x++) {
            size_t idx = (size_t)y * img->width + x;
            png_bytep px = &rows[y][x * 3];
            px[0] = img->r[idx];
            px[1] = img->g[idx];
            px[2] = img->b[idx];
        }
    }

    png_write_image(png, rows);
    png_write_end(png, NULL);

    for (int y = 0; y < img->height; y++) {
        free(rows[y]);
    }
    free(rows);
    png_destroy_write_struct(&png, &info);
    fclose(fp);
}

static void free_image(Image *img)
{
    free(img->r);
    free(img->g);
    free(img->b);
}

int main(int argc, char **argv)
{
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <input.png> <output.png>\n", argv[0]);
        return EXIT_FAILURE;
    }

    Image img = {0};
    read_png(argv[1], &img);

    unsigned long int t_start, t_end;
    t_start = clock();

    invert_colors(&img);

    t_end = clock();
    printf("invert_colors time: %.3f ms\n", (double)(t_end - t_start)/CLOCKS_PER_SEC*1000);

    write_png(argv[2], &img);
    free_image(&img);
    return EXIT_SUCCESS;
}
