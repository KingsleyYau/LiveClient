/*
 * PngReader.h
 *
 *  Created on: 2015-05-14
 *      Author: Samson
 *        desc: png读操作类
 */

#ifndef _INC_PNGREADER_
#define _INC_PNGREADER_

#include <libpng/png.h>
#include <string>
using namespace std;

// png读文件类
class PngReader
{
public:
	PngReader();
	virtual ~PngReader();

public:
	// 设置png文件路径
	bool SetFilePath(const string& path);
	// 初始化
	bool Init();
	// 释放资源
	void Release();

	// 获取图片宽度
	png_uint_32 GetWidth() const;
	// 获取图片高度
	png_uint_32 GetHeight() const;
	// 获取图片数据保存类型
	int GetNumPass() const;
	// 获取图片颜色类型
	int GetColorType() const;
	// 获取多少bit一个像素
	int GetBitDepth() const;

	// 设置至结尾
	void SetEnd();
	// 获取每行png数据所需要的字节数
	size_t GetRowBytes();
	// 读取一行png数据
	bool ReadRowData(png_bytep buffer);

	// 获取png_structp
	png_structp GetRead();
	// 获取png_infop
	png_infop GetReadInfo();
	// 获取结尾的png_infop
	png_infop GetReadEndInfo();

private:
	// 获取png信息
	bool GetPngInfo(png_uint_32& width, png_uint_32& height, int& numPass, int& colorType, int& bitDepth);

private:
	string		m_path;
	FILE*		m_file;

	png_uint_32	m_width;
	png_uint_32	m_height;
	int			m_numPass;
	int			m_colorType;
	int			m_bitDepth;

	png_structp	m_readPtr;
	png_infop	m_readInfoPtr;
	png_infop	m_readEndInfoPtr;
};

#endif
