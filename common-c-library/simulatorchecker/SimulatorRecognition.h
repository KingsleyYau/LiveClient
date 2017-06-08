/*
 * SimulatorRecognition.h
 *
 *  Created on: 2015-09-09
 *      Author: Samson
 *        Desc: 模拟器识别类
 */

#ifndef SIMULATORRECOGNITION_H_
#define SIMULATORRECOGNITION_H_

#include <string>
#include <list>
#include <map>
using namespace std;

// 虚拟设备识别结果描述元素
typedef struct _tagSimulatorRecognitionDescItem
{
	string key;			// 检测项的key
	string value;		// 检测项获取到的内容
	string matchValue;	// 匹配的内容

	_tagSimulatorRecognitionDescItem()
	{
		key = "";
		value = "";
		matchValue = "";
	}
} SimulatorRecognitionDescItem;
// 虚拟设备识别结果描述列表
typedef list<SimulatorRecognitionDescItem> SimulatorRecognitionDescList;

// 属性map(key, value)
typedef map<string, string> SMPropMap;

// 虚拟设备识别处理类
class SimulatorRecognition
{
public:
	// 识别是否虚拟设备
	static bool IsSimulator(SimulatorRecognitionDescList& descList);

private:
	// 获取闪存分区状态
	static inline bool GetDiskStats(string& desc);
	// 获取闪存分区状态匹配信息
	static inline void GetMatchDiskStats(bool getSuccess, const string& desc, string& match);
	// 获取MAC地址
	static inline bool GetMac(string& desc);
	// 获取MAC地址匹配信息
	static inline void GetMatchMac(bool getSuccess, const string& desc, string& match);
	// 获取prop信息
	static inline bool GetProp(SMPropMap& propMap, string& desc);
	// 获取prop信息匹配信息（返回匹配分数）
	static inline void GetMatchProp(bool getSuccess, const string& desc, string& match);
	// 获取CPU信息
	static inline bool GetCpuInfo(string& desc);
	// 获取CPU信息匹配信息
	static inline void GetMatchCpuInfo(bool getSuccess, const string& desc, string& match);
	// 获取驱动信息
	static inline bool GetDrivers(string& desc);
	// 获取驱动信息匹配信息
	static inline void GetMatchDrivers(bool getSuccess, const string& desc, string& match);
	// 判断虚拟设备专有文件 qemud 是否存在
	static inline bool IsQemudFileExist();
	// 判断虚拟设备专有文件 qemu_pipe 是否存在
	static inline bool IsQemuPipeFileExist();

private:
	// 读取数据处理方法
	static bool GetData(const string& path, string& desc);
};

#endif /* SIMULATORRECOGNITION_H_ */
