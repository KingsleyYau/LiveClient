/*
 * KZip.cpp
 *
 *  Created on: 2015-6-29
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "KZip.h"

#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>

#ifdef IOS
#include <zlib.h>
#endif

#include <common/KLog.h>

#define WRITEBUFFERSIZE (16384)
#define MAXFILENAME (256)

KZip::KZip() {
	// TODO Auto-generated constructor stub
	mZipFile = NULL;
	mPassword = "";
	mComment = "";
	FileLog("common", "KZip( zlib version : %s )", zlibVersion());
}

KZip::~KZip() {
	// TODO Auto-generated destructor stub
}

/**
 * 根据目录生成zip文件
 * @param src 		需要增加的源文件路径
 * @param zipFile 	生成的zip路径
 * @param password 	生成的zip文件密钥
 */
bool KZip::CreateZipFromDir(string src, string zipFile, string password, string comment) {
	FileLog("common", "AddFile( "
					"src : %s, "
					"zipFile : %s, "
					"password : %s, "
					"comment : %s"
					" )",
					src.c_str(),
					zipFile.c_str(),
					password.c_str(),
					comment.c_str()
					);

	bool bFlag = false;

	mPassword = password;
	mComment = comment;

	if( mZipFile != NULL ) {
		zipClose(mZipFile, NULL);
		mZipFile = NULL;
	}

	mZipFile = zipOpen(zipFile.c_str(), APPEND_STATUS_CREATE);

	if( mZipFile != NULL ) {
		bFlag = AddFile(src, "");
		zipClose(mZipFile, NULL);
		mZipFile = NULL;
	}

	return bFlag;
}

/**
 * 递归增加文件或者目录
 * @param src 		需要增加的源文件路径
 * @param parent 	父目录, 用于递归时候生成zip中路径
 */
bool KZip::AddFile(string src, string parent) {
	FileLog("common", "AddFile( "
					"src : %s, "
					"parent : %s"
					" )",
					src.c_str(),
					parent.c_str()
					);

	bool bFlag = false;

	string relativePath = "";
	string fileName = "";

	DIR *dp;
	struct dirent *entry;
	struct stat statbuf;
	if( (dp = opendir(src.c_str())) != NULL ) {
		 while( (entry = readdir(dp) ) != NULL ) {
			 if ( parent.length() == 0 ) {
				 relativePath = entry->d_name;
			 } else {
				 relativePath = parent + "/" + entry->d_name;
			 }

			 fileName = src + "/" + entry->d_name;

			 lstat(fileName.c_str(), &statbuf);//使用绝对路径

		     if( S_ISDIR(statbuf.st_mode) ) {
		    	 if( strcmp(".", entry->d_name) == 0 || strcmp("..", entry->d_name) == 0 ) {
		    		 continue;
		    	 }
		    	 AddFile(fileName, relativePath);
		     }else{
		    	 AddFileToZip(fileName, relativePath);
		     }
		 }
		 closedir(dp);
		 bFlag = true;
	}

	return bFlag;
}

/**
 * 增加文件
 * @param src		需要增加的源文件路径
 * @param fileName	zip中文件名称
 */
bool KZip::AddFileToZip(string src, string fileName) {
	FileLog("common", "AddFileToZip( "
					"src : %s, "
					"fileName : %s"
					" )",
					src.c_str(),
					fileName.c_str()
					);

	bool bFlag = true;

	zip_fileinfo zi;
	zi.tmz_date.tm_sec = zi.tmz_date.tm_min = zi.tmz_date.tm_hour =
	zi.tmz_date.tm_mday = zi.tmz_date.tm_mon = zi.tmz_date.tm_year = 0;
	zi.dosDate = 0;
	zi.internal_fa = 0;
	zi.external_fa = 0;
	GetFileTime(src.c_str(), &zi.tmz_date, &zi.dosDate);

	unsigned long crcFile = 0;

	char buf[WRITEBUFFERSIZE] = {'\0'};
	int ret = ZIP_OK;
	if( mPassword.length() > 0 ) {
		ret = GetFileCrc(src.c_str(), buf, WRITEBUFFERSIZE, &crcFile);
	}

	if( (ret != ZIP_OK) )
		return false;

	FileLog("common", "AddFileToZip( crcFile : %d )", crcFile);
	ret = zipOpenNewFileInZip3(
			mZipFile,
			fileName.c_str(),
			&zi,
			NULL,
			0,
			NULL,
			0,
			(mComment.length() > 0 ? mComment.c_str():NULL),
			Z_DEFLATED,
			Z_BEST_COMPRESSION,
			0,
			-MAX_WBITS,
			DEF_MEM_LEVEL,
			Z_DEFAULT_STRATEGY,
			(mPassword.length() > 0 ? mPassword.c_str():NULL),
			crcFile
			);

	if( ret != ZIP_OK || src.length() == 0 ) {
		bFlag = false;
	}

	if( bFlag ) {
		FILE* file = NULL;
		file = fopen(src.c_str(), "rb");
		if ( file == NULL ) {
			bFlag = false;
		}

		if( bFlag ) {
			int numBytes = 0;
			while( !feof(file) ) {
				numBytes = fread(buf, 1, sizeof(buf), file);
				ret = zipWriteInFileInZip(mZipFile, buf, numBytes);
				if( ferror(file) || ret != ZIP_OK ) {
					bFlag = false;
					break;
				}
			}
			fclose(file);
		}

		zipCloseFileInZip(mZipFile);
	}

	FileLog("common", "AddFileToZip( finish )");
	return bFlag;
}

/* calculate the CRC32 of a file,
   because to encrypt a file, we need known the CRC32 of the file before */
int KZip::GetFileCrc(
		const char* filenameinzip,
		void* buf,
		unsigned long size_buf,
		unsigned long* result_crc
		) {
   unsigned long calculate_crc = 0;
   int err = ZIP_OK;
#ifndef IOS
    unsigned long size_read = 0;
#else
    unsigned int size_read = 0;
#endif
   unsigned long total_read = 0;

   FILE * fin = fopen(filenameinzip, "rb");
   if( fin == NULL ) {
       err = ZIP_ERRNO;
   } else {
	   do {
		   err = ZIP_OK;
		   size_read = (int)fread(buf, 1, size_buf, fin);
		   if (size_read < size_buf) {
			   if ( feof(fin) == 0 ) {
				   err = ZIP_ERRNO;
			   }
		   }
		   if ( size_read > 0 ) {
#ifndef IOS
			   calculate_crc = crc32(calculate_crc, (unsigned char FAR*)buf, size_read);
#else
               calculate_crc = crc32(calculate_crc, (Bytef *)buf, size_read);
#endif
		   }
		   total_read += size_read;
	   } while ( ( err == ZIP_OK ) && ( size_read > 0 ) );
	   fclose(fin);
   }

   *result_crc=calculate_crc;
   return err;
}

/**
 * 获取文件修改时间
 * @param file 		name of file to get info on
 * @param tmzip		return value: access, modific. and creation times
 * @param dt		dostime
 */
uLong KZip::GetFileTime(const char* file, tm_zip* tmzip, uLong* dt) {
  int ret = 0;
  struct stat s;        /* results of stat() */
  struct tm* filedate;
  time_t tm_t = 0;

  if ( strcmp(file, "-") != 0 )
  {
    char name[MAXFILENAME + 1];
    int len = strlen(file);
    if ( len > MAXFILENAME )
      len = MAXFILENAME;

    strncpy(name, file, MAXFILENAME - 1);
    /* strncpy doesnt append the trailing NULL, of the string is too long. */
    name[ MAXFILENAME ] = '\0';

    if (name[len - 1] == '/')
      name[len - 1] = '\0';
    /* not all systems allow stat'ing a file with / appended */
    if (stat(name,&s)==0)
    {
      tm_t = s.st_mtime;
      ret = 1;
    }
  }
  filedate = localtime(&tm_t);

  tmzip->tm_sec  = filedate->tm_sec;
  tmzip->tm_min  = filedate->tm_min;
  tmzip->tm_hour = filedate->tm_hour;
  tmzip->tm_mday = filedate->tm_mday;
  tmzip->tm_mon  = filedate->tm_mon ;
  tmzip->tm_year = filedate->tm_year;

  return ret;
}
