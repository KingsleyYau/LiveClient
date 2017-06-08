/*
 * KZip.h
 *
 *  Created on: 2015-6-29
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef KZIP_H_
#define KZIP_H_

#include <zip/zip.h>

#include <string>
using namespace std;

class KZip {
public:
	KZip();
	virtual ~KZip();

	/**
	 * 根据文件或者目录生成zip文件
	 * @param src 		需要增加的源文件路径
	 * @param zipFile 	生成的zip文件路径
	 * @param password 	生成的zip文件密钥
	 */
	bool CreateZipFromDir(string src, string zipFile, string password = "", string comment = "");

private:
	/**
	 * 递归增加文件或者目录
	 * @param src 		需要增加的源文件路径
	 * @param parent 	父目录, 用于递归时候生成zip文件中路径
	 */
	bool AddFile(string src, string parent);

	/**
	 * 增加文件
	 * @param src		需要增加的源文件路径
	 * @param fileName	zip文件中文件名称
	 */
	bool AddFileToZip(string src, string fileName);

	/**
	 * 获取文件crc校验
	 * @param filenameinzip
	 * @param buf
	 * @param size_buf
	 * @param result_crc
	 */
	int GetFileCrc(
			const char* filenameinzip,
			void* buf,
			unsigned long size_buf,
			unsigned long* result_crc
			);

	/**
	 * 获取文件修改时间
	 * @param file 		name of file to get info on
	 * @param tmzip		return value: access, modific. and creation times
	 * @param dt		dostime
	 */
	uLong GetFileTime(const char* file, tm_zip* tmzip, uLong* dt);

private:
	zipFile mZipFile;
	string mPassword;
	string mComment;
};

#endif /* KZIP_H_ */
