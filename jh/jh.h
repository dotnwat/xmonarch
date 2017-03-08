#ifndef JH_H
#define JH_H

#ifdef __cplusplus
extern "C" {
#endif

extern int jh(int hashbitlen, const unsigned char *input,
    unsigned long long input_len, unsigned char *output);

#ifdef __cplusplus
}
#endif

#endif
