/*
 * SimulatorProtocolTool.h
 *
 *  Created on: 2015-09-10
 *      Author: Samson
 *        Desc: 模拟器协议处理工具
 */

#ifndef SIMULATORPROTOCOLTOOL_H_
#define SIMULATORPROTOCOLTOOL_H_

#include <string>
using namespace std;

// 虚拟设备识别处理类
class SimulatorProtocolTool
{
public:
	SimulatorProtocolTool();
	~SimulatorProtocolTool();

public:
	// 根据value获取加密随机数
	unsigned int EncodeValue(bool value);
	// 解密随机数获取布尔类型
	bool DecodeValue(unsigned int code, bool& value);

	// 加密描述字符串
	string EncodeDesc(const string& value, unsigned int key);
	// 解密描述字符串
	bool DecodeDesc(const string& code, unsigned int key, string& value);

private:
	// 生成真正的加密key
	string BuildKey(unsigned int key);
};

#endif /* SIMULATORPROTOCOLTOOL_H_ */
