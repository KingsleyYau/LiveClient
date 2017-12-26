/*
 * PngHandler.cpp
 *
 *  Created on: 2015-05-12
 *      Author: Samson
 */

#include "PngHandler.h"
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>
#include <common/CommonFunc.h>

#include "PngReader.h"
#include "PngWriter.h"

// 把一张很长的图片裁剪成一张张小图片
bool PngHandler::ConvertImage(const string& path)
{
	bool result = false;
	const char* SUBFILENAME = "_%d";
	FileLog("ImageHandler", "PngHandler::ConvertImage() begin, path:%s", path.c_str());

	do {
		// 加载图片
		PngReader readPng;
		if (!readPng.SetFilePath(path)
			|| !readPng.Init()) 
		{
			break;
		}
		FileLog("ImageHandler", "PngHandler::ConvertImage() init readPng success, path:%s", path.c_str());

		// 生成目录图片路径
		string desFilePath("");
		string desFileExt("");
		// 找文件名
		size_t beginPos = 0;
		size_t filePos = path.rfind("/");
		if (filePos != string::npos) {
			beginPos = filePos;
		}
		else {
			filePos = path.rfind("\\");
			beginPos = (filePos != string::npos ? filePos : beginPos);
		}
		// 找后缀
		size_t pos = path.find(".", beginPos);
		if (pos != string::npos) {
			desFileExt = path.substr(pos);
			desFilePath = path.substr(0, pos);
		}
		else {
			desFilePath = path;
		}
		// 是否纵向（否则表示横向）
		bool isVertical = readPng.GetHeight() > readPng.GetWidth();

		// 判断是否可以裁剪成完整的图片文件
		if ((isVertical ? readPng.GetHeight()%readPng.GetWidth() : readPng.GetWidth()%readPng.GetHeight()) == 0)
		{
			// 裁剪生成的文件数量及图片大小
			int fileCount = isVertical ? readPng.GetHeight()/readPng.GetWidth() : readPng.GetWidth()/readPng.GetHeight();
			png_uint_32 imageSize = isVertical ? readPng.GetWidth() : readPng.GetHeight();
			// 生成row buffer
			size_t rowBytes = readPng.GetRowBytes();
			png_bytep rowBuffer = NULL;
			if (rowBytes > 0) {
				rowBuffer = new png_byte[rowBytes];
				memset(rowBuffer, 0, rowBytes);
			}

			if (fileCount > 1 && NULL != rowBuffer)
			{
				result = true;

				string subFilePath("");
				char subFileName[64] = {0};
				for (int i = 0; i < fileCount; i++)
				{
					// 生成子文件路径
					snprintf(subFileName, sizeof(subFileName), SUBFILENAME, i);
					subFilePath = desFilePath;
					subFilePath += subFileName;
					subFilePath += desFileExt;

					FileLog("ImageHandler", "PngHandler::ConvertImage() build sub file begin, isVertical:%d, width:%d, height:%d, imageSize:%d, subFilePath:%s, desFilePath:%s"
							, isVertical, readPng.GetWidth(), readPng.GetHeight(), imageSize, subFilePath.c_str(), desFilePath.c_str());

					if (!isVertical) {
						// 处理横向文件
						PngReader srcPng;
						PngWriter desPng;
						if (srcPng.SetFilePath(path)
							&& srcPng.Init()
							&& desPng.SetFilePath(subFilePath)
							&& desPng.Init()
							&& desPng.SetWriteInfoByReadInfo(srcPng, imageSize, imageSize))
						{
							for (int pass = 0; pass < srcPng.GetNumPass(); pass++)
							{
								for (png_uint_32 k = 0; k < imageSize; k++)
								{
									int offset = imageSize * i;
									srcPng.ReadRowData(rowBuffer);
									desPng.WriteRowData(rowBuffer + offset);
								}
							}

							srcPng.SetEnd();
							desPng.SetWriteEndInfoByReadEndInfo(srcPng);

							FileLog("ImageHandler", "PngHandler::ConvertImage() build sub file success, subFilePath:%s", subFilePath.c_str());
						}
					}
					else {
						// 处理纵向文件
					}

					FileLog("ImageHandler", "PngHandler::ConvertImage() build sub file end, subFilePath:%s", subFilePath.c_str());
				}
			}

			delete[] rowBuffer;
			rowBuffer = NULL;
		}
	} while (false);

	FileLog("ImageHandler", "PngHandler::ConvertImage() end, path:%s", path.c_str());

	return result;
}

bool PngHandler::CombineImage(const list<string>& srcFilePaths, const string& desFilePath, CombineImageCallbackFuncDef callback, void* obj)
{
	bool result = false;

	const char* tempFileName = ".tmp.png";

	// 是否转换图片格式标志
	bool isTransFile = false;
	// 合并图片list
	list<string> srcFilePathList;
	// 合并的目标图片临时路径
	string desTempFilePath = desFilePath + tempFileName;
	// 第一张源图
	PngReader srcReadPng;

	do {
		// 检查参数是否正确
		if (srcFilePaths.empty() || desFilePath.empty() || NULL == callback)
		{
			break;
		}

		// 判断是否需要转换图片（转为RGBA）
		{
			if (srcReadPng.SetFilePath(*srcFilePaths.begin()) && srcReadPng.Init())
			{
				isTransFile = (PNG_COLOR_TYPE_RGB_ALPHA != srcReadPng.GetColorType()
								|| 16 != srcReadPng.GetBitDepth());
			}

			if (isTransFile) {
				// 生成转换格式的临时文件
				for (list<string>::const_iterator iter = srcFilePaths.begin();
					iter != srcFilePaths.end();
					iter++)
				{
					string desFile = (*iter) + tempFileName;
					if (TransPngFormat(*iter, desFile, PF_RGBALPHA_16BIT)) {
						srcFilePathList.push_back(desFile);
					}
				}
			}
			else {
				// copy文件路径list
				srcFilePathList.assign(srcFilePaths.begin(), srcFilePaths.end());
			}
		}


		// 加载第一张图片
		PngReader readPng;
		if (!readPng.SetFilePath(*srcFilePathList.begin())
			|| !readPng.Init()) 
		{
			break;
		}

		// 获取图片尺寸
		const png_uint_32 srcWidth = readPng.GetWidth();
		const png_uint_32 srcHeight = readPng.GetHeight();
		// 计算目标图片尺寸
		const png_uint_32 desWidth = srcWidth * srcFilePathList.size();
		const png_uint_32 desHeight = srcHeight;

		// 创建目标图片所需内存
		const png_uint_32 srcRowSize = readPng.GetRowBytes();
		const png_uint_32 desRowSize = srcRowSize * srcFilePathList.size();
		const png_uint_32 desBufferSize = desRowSize * desHeight;
		png_bytep desBuffer = new png_byte[desBufferSize];
		if (NULL == desBuffer) {
			break;
		}

		// 合并图片
		PngWriter desPng;
		if (desPng.SetFilePath(desTempFilePath)
			&& desPng.Init()
			&& desPng.SetWriteInfoByReadInfo(readPng, desWidth, desHeight))
		{
			// 是否继续处理标志
			bool start = true;

			// 读取图片数据到内存
			int i = 0;
			for (list<string>::const_iterator iter = srcFilePathList.begin();
				iter != srcFilePathList.end() && start;
				iter++, i++)
			{
				// 回调并获取是否允许标志
				start = callback(*iter, obj);

				PngReader srcPng;
				if (start							// 回调允许继续处理
					&& srcPng.SetFilePath(*iter)	// 加载图片
					&& srcPng.Init()
					&& srcRowSize == srcPng.GetRowBytes())
				{
					// copy图片数据
					for (int pass = 0; pass < srcPng.GetNumPass(); pass++)
					{
						for (png_uint_32 k = 0; k < srcHeight; k++)
						{
							int offset = i*srcRowSize + pass*desRowSize + k*desRowSize;
							srcPng.ReadRowData(desBuffer + offset);
						}
					}
				}
			}

			// 把内存的图片数据生成png
			if (start)
			{
				for (png_uint_32 i = 0; i < desHeight; i++)
				{
					int offset = i * desRowSize;
					desPng.WriteRowData(desBuffer + offset);
				}
			}

			desPng.SetWriteEndInfoByReadEndInfo(readPng);

			result = start;
		}

		// 释放内存
		delete []desBuffer;
		desBuffer = NULL;
	} while (false);

	// 转换文件格式的后续处理
	if (isTransFile)
	{
		// 转换回源图格式
		if (result) {
			PNG_FORMAT pngFormat = PF_RGBALPHA_16BIT;
			switch (srcReadPng.GetColorType())
			{
			case PNG_COLOR_TYPE_GRAY:
				pngFormat = PF_GRAY_8BIT;
				break;
			case PNG_COLOR_TYPE_GRAY_ALPHA:
				pngFormat = PF_GRAYALPHA_8BIT;
				break;
			case PNG_COLOR_TYPE_RGB:
				pngFormat = PF_RGB_16BIT;
				break;
			case PNG_COLOR_TYPE_PALETTE:
			case PNG_COLOR_TYPE_RGB_ALPHA:
				pngFormat = PF_RGBALPHA_16BIT;
				break;
			}
			TransPngFormat(desTempFilePath, desFilePath, pngFormat);

			// 删除临时文件
			RemoveFile(desTempFilePath);
		}

		// 删除临时文件
		for (list<string>::const_iterator iter = srcFilePathList.begin();
			iter != srcFilePathList.end();
			iter++)
		{
			RemoveFile(*iter);
		}
	}

	return result;
}

bool PngHandler::TransPngFormat(const string& srcFilePath, const string& desFilePath, PNG_FORMAT pngFormat)
{
	bool result = false;

	// 初始化变量
	png_image image;
	memset(&image, 0, (sizeof image));
	image.version = PNG_IMAGE_VERSION;

	// 加载源文件
	if (png_image_begin_read_from_file(&image, srcFilePath.c_str()) != 0)
	{
		// 设置图片格式
		switch (pngFormat)
		{
		case PF_GRAY_8BIT:
			image.format = PNG_FORMAT_GRAY;
			break;
		case PF_GRAYALPHA_8BIT:
			image.format = PNG_FORMAT_GA;
			break;
		case PF_RGB_16BIT:
			image.format = PNG_FORMAT_RGB;
			break;
		case PF_RGBALPHA_16BIT:
			image.format = PNG_FORMAT_RGBA;
			break;
		}

		// 创建buffer
		png_bytep buffer = NULL;
		size_t bufferSize = PNG_IMAGE_SIZE(image);
		buffer = new png_byte[bufferSize];

		if (buffer != NULL 
			&& png_image_finish_read(&image, NULL, buffer, 0, NULL) != 0)
		{
			result = (png_image_write_to_file(&image, desFilePath.c_str(), 0, buffer, 0, NULL) != 0);
        }

		delete[] buffer;
	}

	return result;
}

