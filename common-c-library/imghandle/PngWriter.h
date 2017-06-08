/*
 * PngWrite.h
 *
 *  Created on: 2015-05-14
 *      Author: Samson
 *        desc: png写操作类
 */

#ifndef _INC_PNGWRITER_
#define _INC_PNGWRITER_

#include <libpng/png.h>
#include "PngReader.h"
#include <string>
using namespace std;

// png写文件类
class PngWriter
{
public:
	PngWriter();
	virtual ~PngWriter();

public:
	// 设置png文件路径
	bool SetFilePath(const string& path);
	// 初始化
	bool Init();
	// 释放资源
	void Release();
	// 写入一行png数据
	bool WriteRowData(png_bytep data);
	// 获取png_strctp
	png_structp GetWrite();
	// 获取png_infop
	png_infop GetWriteInfo();
	// 获取结尾的png_infop
	png_infop GetWriteEndInfo();
	// 把读取的png信息写入到文件
	bool SetWriteInfoByReadInfo(PngReader& readPng, png_uint_32 desWidth, png_uint_32 desHeight);
	// 把读取结尾的png信息写入到文件
	bool SetWriteEndInfoByReadEndInfo(PngReader& readPng);

private:
	string		m_path;
	FILE*		m_file;
	png_structp	m_writePtr;
	png_infop	m_writeInfoPtr;
	png_infop	m_writeEndInfoPtr;
};

#endif
