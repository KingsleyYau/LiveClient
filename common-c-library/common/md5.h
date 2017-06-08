/*
  Independent implementation of MD5 (RFC 1321).

  This code implements the MD5 Algorithm defined in RFC 1321.
  It is derived directly from the text of the RFC and not from the
  reference implementation.

  The original and principal author of md5.h is L. Peter Deutsch
  <ghost@aladdin.com>.  Other authors are noted in the change history
  that follows (in reverse chronological order):

  1999-11-04 lpd Edited comments slightly for automatic TOC extraction.
  1999-10-18 lpd Fixed typo in header comment (ansi2knr rather than md5);
	added conditionalization for C++ compilation from Martin
	Purschke <purschke@bnl.gov>.
  1999-05-03 lpd Original version.
 */

#ifndef md5_INCLUDED
#define md5_INCLUDED

#
/*
 * This code has some adaptations for the Ghostscript environment, but it
 * will compile and run correctly in any environment with 8-bit chars and
 * 32-bit ints.  Specifically, it assumes that if the following are
 * defined, they have the same meaning as in Ghostscript: P1, P2, P3,
 * ARCH_IS_BIG_ENDIAN.
 */

//#ifndef IOS
typedef unsigned char md5_byte_t; /* 8-bit byte */
typedef unsigned int md5_word_t; /* 32-bit word */
//#else
//#include <zlib.h>
//typedef Bytef md5_byte_t;
//typedef unsigned int md5_word_t; /* 32-bit word */
//#endif

/* Define the state of the MD5 Algorithm. */
typedef struct md5_state_s {
    md5_word_t count[2];	/* message length in bits, lsw first */
    md5_word_t abcd[4];		/* digest buffer */
    md5_byte_t buf[64];		/* accumulate block */
} md5_state_t;

#ifdef __cplusplus
extern "C"
{
#endif

/* Initialize the algorithm. */
#ifdef P1
void md5_init(P1(md5_state_t *pms));
#else
void md5_init(md5_state_t *pms);
#endif

/* Append a string to the message. */
#ifdef P3
void md5_append(P3(md5_state_t *pms, const md5_byte_t *data, int nbytes));
#else
void md5_append(md5_state_t *pms, const md5_byte_t *data, int nbytes);
#endif

/* Finish the message and return the digest. */
#ifdef P2
void md5_finish(P2(md5_state_t *pms, md5_byte_t digest[16]));
#else
void md5_finish(md5_state_t *pms, md5_byte_t digest[16]);
#endif

// get md5 string with string
void GetMD5String(const char *src, char *des);
// get md5 string with data
void GetDataMD5String(const void* buffer, int bufferLen, char* des);
// get md5 string with file (1:success, 0:fail)
int GetFileMD5String(const char* filePath, char *des);


#ifdef __cplusplus
}  /* end extern "C" */
#endif

#endif /* md5_INCLUDED */
