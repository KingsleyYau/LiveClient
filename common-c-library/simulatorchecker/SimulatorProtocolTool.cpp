/*
 * SimulatorProtocolTool.cpp
 *
 *  Created on: 2015-09-10
 *      Author: Samson
 *        Desc: 模拟器协议处理工具
 */

#include "SimulatorProtocolTool.h"
#include <stdint.h>
#include <cstdlib>
#include <string.h>
#include <common/Arithmetic.h>

SimulatorProtocolTool::SimulatorProtocolTool()
{
	srand(time(NULL)*121);
}

SimulatorProtocolTool::~SimulatorProtocolTool()
{

}

// 根据value生成加密的随机数
unsigned int SimulatorProtocolTool::EncodeValue(bool value)
{
	// 生成随机数
	unsigned int code = 1;
	int i = 0;
	for (i = 0; i < 4; i++)
	{
		code *= rand() + 1;
	}

	// ---- 生成加密 ----
	// 取第12-15位，及第16-19位进行加密（防止高位在右边的系统出现兼容问题）
	unsigned char param1 = (code & 0x0000F000) >> 12;
	unsigned char param2 = (code & 0x000F0000) >> 16;
	// 得出4位的异或结果（高4位为0），若第3、4位任一位非0则表示true，否则false
	unsigned char paramResult = param1 ^ param2;
	// 生成加密数
	if (value && (paramResult & 0x0C) == 0)
	{
		// 与value不相符，第18位加1
		code += 0x00040000;
	}
	else if (!value && (paramResult & 0x0C) > 0)
	{
		// 与value不相符，把第18、19位改为与 第14、15位一致
		code = (code & 0xFFF3FFFF) | ((code & 0x0000C000) << 4);
	}

	// ---- 生成校验 ----
	// 生成第4-7位，与第24-27位进行同或结果为0的校验位（防止高位在右边的系统出现兼容问题）
	code = (code & 0xF0FFFFFF) | ((~code & 0x000000F0) << 20);
	// 生成第0位，与第31位进行异或结果为1的校验位（防止高位在右边的系统出现兼容问题）
	if (((code & 0x00000001) << 31) ^ (code & 0x80000000) == 0) {
		code = (code & 0x7FFFFFFF) | (((~code) & 0x00000001) << 31);
	}
	// 生成第2位，与第29位进行异或结果为1的校验位（防止高位在右边的系统出现兼容问题）
	if (((code & 0x00000004) << 27) ^ (code & 0x20000000) == 0) {
		code = (code & 0xDFFFFFFF) | (((~code) & 0x00000004) << 27);
	}
	// 生成第8位，与第23位进行异或结果为1的校验位（防止高位在右边的系统出现兼容问题）
	if (((code & 0x00000100) << 15) ^ (code & 0x00800000) == 0) {
		code = (code & 0xFF7FFFFF) | (((~code) & 0x00000100) << 15);
	}
	// 生成第11位，与第20位进行异或结果为1的校验位（防止高位在右边的系统出现兼容问题）
	if (((code & 0x00000800) << 9) ^ (code & 0x00100000) == 0) {
		code = (code & 0xFFEFFFFF) | (((~code) & 0x00000800) << 9);
	}

	return code;
}

// 解密加密的随机数value
bool SimulatorProtocolTool::DecodeValue(unsigned int code, bool& value)
{
	bool result = false;

	// 获取第4-7位，与第24-27位进行检验，若同或结果为0则成功，否则失败（防止高位在右边的系统出现兼容问题）
	unsigned char check1 = ((~code) & 0x0F000000) >> 24;
	unsigned char check2 = (code & 0x000000F0) >> 4;
	bool checkResult1 = (check1 ^ check2) == 0;
	// 获取第0位，与第31位进行校验，若异或结果为1则成功，否则失败（防止高位在右边的系统出现兼容问题）
	bool checkResult2 = (((code & 0x00000001) << 31) ^ (code & 0x80000000)) != 0;
	// 获取第2位，与第29位进行校验，若异或结果为1则成功，否则失败（防止高位在右边的系统出现兼容问题）
	bool checkResult3 = (((code & 0x00000004) << 27) ^ (code & 0x20000000)) != 0;
	// 获取第8位，与第23位进行校验，若异或结果为1则成功，否则失败（防止高位在右边的系统出现兼容问题）
	bool checkResult4 = (((code & 0x00000100) << 15) ^ (code & 0x00800000)) != 0;
	// 获取第11位，与第20位进行校验，若异或结果为1则成功，否则失败（防止高位在右边的系统出现兼容问题）
	bool checkResult5 = (((code & 0x00000800) << 9) ^ (code & 0x00100000)) != 0;

	result = checkResult1 && checkResult2 && checkResult3 && checkResult4 && checkResult5;

	if (result)
	{
		// 取第12-15位与第16-19位进行异或（防止高位在左边或右边的不同系统出现兼容问题）
		unsigned char param1 = (unsigned char)((code & 0x0000F000) >> 12);
		unsigned char param2 = (unsigned char)((code & 0x000F0000) >> 16);
		unsigned char paramResult = param1 ^ param2;

		// 判断value的真实值
		value = (paramResult & 0x0C) != 0;
	}

	return result;
}

// 生成真正的加密key
string SimulatorProtocolTool::BuildKey(unsigned int key)
{
	string strKey("");

	// 生成key
	char cKey[256] = {0};
	sprintf(cKey, "%08X%s", key, "QpidDate");

	strKey = cKey;

	return strKey;
}

// 加密描述字符串
string SimulatorProtocolTool::EncodeDesc(const string& value, unsigned int key)
{
	string result("");

	// 生成key
	string strKey = BuildKey(key);

	// 生成加密数据
	if ( !value.empty() )
	{
		result = Arithmetic::AesEncrypt(strKey, value);
	}

	return result;
}

// 解密描述字符串
bool SimulatorProtocolTool::DecodeDesc(const string& code, unsigned int key, string& value)
{
	bool result = false;

	// 生成key
	string strKey = BuildKey(key);

	// 解密数据
	if ( !code.empty() )
	{
		value = Arithmetic::AesDecrypt(strKey, code);
		result = !value.empty();
	}

	return result;
}
