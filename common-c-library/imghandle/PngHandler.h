/*
 * PngHandler.h
 *
 *  Created on: 2015-05-12
 *      Author: Samson
 * Description: PNG图片处理类（直接处理PNG图片数据，不把PNG解为BMP）
 */

#ifndef _INC_PNGHANDLER_
#define _INC_PNGHANDLER_

#include <string>
#include <list>
using namespace std;

class PngHandler
{
public:
	typedef enum _tagCombineType {
		CombineType_Draw,	// 绘画(不改变形状)
		CombineType_Tile,	// 平铺(repeat至宽度结束为止)
	} CombineType;

public:
	PngHandler() {}
	virtual ~PngHandler() {}
public:
	// 把一张很长的图片裁剪成一张张小图片
	static bool ConvertImage(const string& path);

	// 把很多图片合并成一张很长的图片
	typedef bool (*CombineImageCallbackFuncDef) (const string& srcFile, void* obj);	// 开始合成图片回调(srcFile：准备合成的图片，obj：输入参数，return true/false：继续处理/中止)
	static bool CombineImage(const list<string>& srcFilePaths, const string& desFilePath, CombineImageCallbackFuncDef callback, void* obj);

	// 转换png图片格式
	typedef enum _tagPNG_FORMAT {
		PF_GRAY_8BIT,		// 8位灰度图（不透明）
		PF_GRAYALPHA_8BIT,	// 8位透明灰度图
		PF_RGB_16BIT,		// 16位图（不透明）
		PF_RGBALPHA_16BIT,	// 16位透明图
	}PNG_FORMAT;
	static bool TransPngFormat(const string& srcFilePath, const string& desFilePath, PNG_FORMAT pngFormat);
};

#endif
