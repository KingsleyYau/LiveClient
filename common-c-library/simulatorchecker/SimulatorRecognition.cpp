/*
 * SimulatorRecognition.cpp
 *
 *  Created on: 2015-09-09
 *      Author: Samson
 *        Desc: 模拟器识别类
 */

#include "SimulatorRecognition.h"
#include <common/IPAddress.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <ctype.h>
#include <algorithm>
#include <common/command.h>
#include <common/KLog.h>

#include <stdint.h>

// 设备信息文件
#define DISKSTATS		"/proc/diskstats" 		// 闪存分区信息
#define CPUINFO			"/proc/cpuinfo"	 		// cpu信息
#define DRIVERS			"/proc/tty/drivers"		// 驱动信息

// 虚拟设备专有文件
#define QEMUD			"/dev/socket/qemud"		//
#define QEMUPIPE		"/dev/qemu_pipe"		//

// 结果描述关键字
#define RKEY_DISKSTATS	"diskstats"				// 闪存分区结果关键字
#define RKEY_MAC		"mac"					// MAC地址结果关键字
#define RKEY_PROP		"prop"					// prop信息结果关键字
#define RKEY_CPU		"cpu"					// cpu信息结果关键字
#define RKEY_DRIVERS	"drivers"				// 驱动信息结果关键字
#define RKEY_QEMUD		"qemud"					// qemud文件结果关键字
#define RKEY_QEMUPIPE	"qemu_pipe"				// qemu_pipe文件结果关键字

// 识别是否虚拟设备
bool SimulatorRecognition::IsSimulator(SimulatorRecognitionDescList& descList)
{
	bool result = false;

	// 清空结果列表
	descList.clear();

	// 初始化获取设备信息
	GetPhoneInfo();

	// 闪存识别
	string diskStats("");
	string matchDiskStats("");
	bool getDiskStatsResult = GetDiskStats(diskStats);
	GetMatchDiskStats(getDiskStatsResult, diskStats, matchDiskStats);
	SimulatorRecognitionDescItem diskStatsItem;
	diskStatsItem.key = RKEY_DISKSTATS;
	diskStatsItem.value = diskStats;
	diskStatsItem.matchValue = matchDiskStats;
	descList.push_back(diskStatsItem);

	// MAC地址识别
	string mac("");
	string matchMac("");
	bool getMacResult = GetMac(mac);
	GetMatchMac(getMacResult, mac, matchMac);
	SimulatorRecognitionDescItem macItem;
	macItem.key = RKEY_MAC;
	macItem.value = mac;
	macItem.matchValue = matchMac;
	descList.push_back(macItem);

	// prop信息识别
	string prop("");
	string matchProp("");
	SMPropMap propMap;
	bool getPropResult = GetProp(propMap, prop);
	GetMatchProp(getPropResult, prop, matchProp);
	SimulatorRecognitionDescItem propItem;
	propItem.key = RKEY_PROP;
	propItem.value = prop;
	propItem.matchValue = matchProp;
	descList.push_back(propItem);

	// cpu信息识别
	string cpuInfo("");
	string matchCpuInfo("");
	bool getCpuResult = GetCpuInfo(cpuInfo);
	GetMatchCpuInfo(getCpuResult, cpuInfo, matchCpuInfo);
	SimulatorRecognitionDescItem cpuInfoItem;
	cpuInfoItem.key = RKEY_CPU;
	cpuInfoItem.value = cpuInfo;
	cpuInfoItem.matchValue = matchCpuInfo;
	descList.push_back(cpuInfoItem);

	// 驱动信息识别
	string drivers("");
	string matchDrivers("");
	bool getDriversResult = GetDrivers(drivers);
	GetMatchDrivers(getDriversResult, drivers, matchDrivers);
	SimulatorRecognitionDescItem driversItem;
	driversItem.key = RKEY_DRIVERS;
	driversItem.value = drivers;
	driversItem.matchValue = matchDrivers;
	descList.push_back(driversItem);

	// qemud 文件是否存在
//	bool checkQemudResult = IsQemudFileExist();
//	SimulatorRecognitionDescItem qemudItem;
//	qemudItem.key = RKEY_QEMUD;
//	qemudItem.value = (checkQemudResult ? "1" : "0");
//	descList.push_back(qemudItem);

	//qemu_pipe 文件是否存在
//	bool checkQemuPipeResult = IsQemuPipeFileExist();
//	SimulatorRecognitionDescItem qemuPipeItem;
//	qemuPipeItem.key = RKEY_QEMUPIPE;
//	qemuPipeItem.value = (checkQemuPipeResult ? "1" : "0");
//	descList.push_back(qemuPipeItem);

	// --- 检测是否模拟器 ----
	// 检测是否存在设备号
	if ( propMap.end() != propMap.find("ro.serialno") )
	{
		SMPropMap::const_iterator iterSerialno = propMap.find("ro.serialno");
		if ( (*iterSerialno).second.empty() )
		{
			FileLog("SimulatorRecognition", "IsSimulator() checkProp: true, ro.serialno is empty");
			result = true;
		}
	}
	else {
		FileLog("SimulatorRecognition", "IsSimulator() checkProp: true, not found ro.serialno");
		result = true;
	}

	// 检测cpu是否PC类型
	if ( result == false )
	{
		// 转成小写
		string checkCpuInfo = cpuInfo;
		transform(checkCpuInfo.begin(), checkCpuInfo.end(), checkCpuInfo.begin(), tolower);

		if (string::npos != checkCpuInfo.find("intel"))
		{
			if (string::npos != checkCpuInfo.find(" core ")
					|| string::npos != checkCpuInfo.find(" core(")
					|| string::npos != checkCpuInfo.find(" pentium ")
					|| string::npos != checkCpuInfo.find(" pentium("))
			{
				// cpu是PC的，一定是模拟器
				FileLog("SimulatorRecognition", "IsSimulator() checkCpuInfo: true, core or pentium");
				result = true;
			}
			else if (string::npos == checkCpuInfo.find(" lm ")
						&& string::npos == checkCpuInfo.find(" vmx ")
						&& string::npos == checkCpuInfo.find(" aes "))
			{
				// 没有找到x86_64的cpu指令集，可能是模拟器
				FileLog("SimulatorRecognition", "IsSimulator() checkCpuInfo: true, not found 'lm', 'vmx', 'aes'");
				result = true;
			}
		}
		else if (string::npos != checkCpuInfo.find("amd"))
		{
			if (string::npos == checkCpuInfo.find(" lm ")
					&& string::npos == checkCpuInfo.find(" svm ")
					&& string::npos == checkCpuInfo.find(" aes "))
			{
				// 没有找到x86_64的cpu指令集，可能是模拟器
				FileLog("SimulatorRecognition", "IsSimulator() checkCpuInfo: true, not found 'lm', 'svm', 'aes'");
				result = true;
			}
		}
	}

	FileLog("SimulatorRecognition", "IsSimulator() check end, result: %d", result);

	return result;
}

// 获取闪存分区状态
bool SimulatorRecognition::GetDiskStats(string& desc)
{
	bool result = false;

	result = GetData(DISKSTATS, desc);

	FileLog("SimulatorRecognition", "SimulatorRecognition::GetDiskStats() result:%d, desc:%s"
			, result, desc.c_str());

	return result;
}

// 判断是否虚拟设备的闪存分区状态（暂时只收集信息，不作判断）
void SimulatorRecognition::GetMatchDiskStats(bool getSuccess, const string& desc, string& match)
{

}

// 获取MAC地址
bool SimulatorRecognition::GetMac(string& desc)
{
	bool result = false;

	list<string> macList = IPAddress::GetMacAddressList();
	if ( !macList.empty() )
	{
		list<string>::const_iterator iter = macList.begin();
		for (iter = macList.begin(); iter != macList.end(); iter++ )
		{
			if ( iter != macList.begin() )
			{
				desc += ", ";
			}
			desc += *iter;
		}

		result = true;
	}

	FileLog("SimulatorRecognition", "SimulatorRecognition::GetMac() result:%d, desc:%s"
				, result, desc.c_str());

	return result;
}

// 获取MAC地址匹配信息
void SimulatorRecognition::GetMatchMac(bool getSuccess, const string& desc, string& match)
{

}

// 获取prop信息
bool SimulatorRecognition::GetProp(SMPropMap& propMap, string& desc)
{
	bool result = false;

	FileLog("SimulatorRecognition", "SimulatorRecognition::GetProp() begin");

	// 读取prop
	const char* cmd = "getprop";
	FILE *ptr = popen(cmd, "r");
	if(ptr != NULL) {
		result = true;
		const unsigned int bufferLen = 2048;
		char buffer[bufferLen] = {0};

		string key("");
		string value("");
		while(fgets(buffer, bufferLen, ptr) != NULL)
		{
			// get key
			char* keyBegin = strchr(buffer, '[');
			if( NULL == keyBegin ) {
				continue;
			}
			char* keyEnd = strchr(keyBegin, ']');
			if( NULL == keyEnd ) {
				continue;
			}
			if ( keyBegin + 1 == keyEnd ) {
				continue;
			}
			key.assign(keyBegin + 1, keyEnd);

			// find ':'
			char* sign = strchr(keyEnd, ':');
			if ( NULL == sign ) {
				continue;
			}

			// get value
			char* valueBegin = strchr(sign, '[');
			if ( NULL == valueBegin ) {
				continue;
			}
			char* valueEnd = strchr(valueBegin, ']');
			if ( NULL == valueEnd ) {
				continue;
			}
			if ( valueEnd > valueBegin + 1 ) {
				value.assign(valueBegin + 1, valueEnd);
			}

			propMap.insert(SMPropMap::value_type(key, value));

			FileLog("SimulatorRecognition", "SimulatorRecognition::GetProp() key:%s, value:%s", key.c_str(), value.c_str());

			desc += buffer;
			desc += "\n";
		}
		pclose(ptr);
		ptr = NULL;
	}

	FileLog("SimulatorRecognition", "SimulatorRecognition::GetProp() end");

//	desc += "ro.boot.serialno";
//	desc += ":";
//	desc += GetPhoneBootSerialno();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.serialno";
//	desc += ":";
//	desc += GetPhoneSerialno();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.hardware";
//	desc += ":";
//	desc += GetPhoneHardware();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.product.model";
//	desc += ":";
//	desc += GetPhoneModel();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.product.brand";
//	desc += ":";
//	desc += GetPhoneBrand();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.product.manufacturer";
//	desc += ":";
//	desc += GetPhoneManufacturer();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.product.cpu.abilist";
//	desc += ":";
//	desc += GetPhoneCpuAbiList();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.build.display.id";
//	desc += ":";
//	desc += GetPhoneDisplayId();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.build.version.incremental";
//	desc += ":";
//	desc += GetPhoneVersionIncremental();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.build.host";
//	desc += ":";
//	desc += GetPhoneHost();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.build.flavor";
//	desc += ":";
//	desc += GetPhoneFlavor();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.product.name";
//	desc += ":";
//	desc += GetPhoneProductName();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.board.platform";
//	desc += ":";
//	desc += GetPhoneBoardPlatform();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.chipname";
//	desc += ":";
//	desc += GetPhoneChipName();
//
//	if ( !desc.empty() )
//	{
//		desc += ", ";
//	}
//
//	desc += "ro.build.description";
//	desc += ":";
//	desc += GetPhoneBuildDescription();

	result = !desc.empty();

//	FileLog("SimulatorRecognition", "SimulatorRecognition::GetProp() result:%d, desc:%s"
//					, result, desc.c_str());

	return result;
}

// 获取prop信息匹配信息
void SimulatorRecognition::GetMatchProp(bool getSuccess, const string& desc, string& match)
{
}

// 获取CPU信息
bool SimulatorRecognition::GetCpuInfo(string& desc)
{
	bool result = false;

	result = GetData(CPUINFO, desc);

	FileLog("SimulatorRecognition", "SimulatorRecognition::GetCpuInfo() result:%d, desc:%s"
					, result, desc.c_str());

	return result;
}

// 获取CPU信息匹配信息
void SimulatorRecognition::GetMatchCpuInfo(bool getSuccess, const string& desc, string& match)
{

}

// 获取驱动信息
bool SimulatorRecognition::GetDrivers(string& desc)
{
	bool result = false;

	result = GetData(DRIVERS, desc);

	FileLog("SimulatorRecognition", "SimulatorRecognition::GetDrivers() result:%d, desc:%s"
					, result, desc.c_str());

	return result;
}

// 获取驱动信息匹配信息
void SimulatorRecognition::GetMatchDrivers(bool getSuccess, const string& desc, string& match)
{

}

// 判断虚拟设备专有文件 qemud 是否存在
bool SimulatorRecognition::IsQemudFileExist()
{
	bool result = false;

	string desc;
	result = GetData(QEMUD, desc);

	FileLog("SimulatorRecognition", "SimulatorRecognition::IsQemudFileExist() result:%d, desc:%s"
					, result, desc.c_str());

	return result;
}

// 判断虚拟设备专有文件 qemu_pipe 是否存在
bool SimulatorRecognition::IsQemuPipeFileExist()
{
	bool result = false;

	string desc;
	result = GetData(QEMUPIPE, desc);

	FileLog("SimulatorRecognition", "SimulatorRecognition::IsQemuPipeFileExist() result:%d, desc:%s"
					, result, desc.c_str());

	return result;
}

// 读取数据处理方法
bool SimulatorRecognition::GetData(const string& path, string& desc)
{
	bool result = false;

	if ( !path.empty() )
	{
		const unsigned int bufferSize = 2048;
		char buffer[bufferSize] = {0};

		int fd = open(path.c_str(), O_RDONLY);
		int readBytes = read(fd, buffer, bufferSize - 1);
		close(fd);

		if (readBytes > 0)
		{
			desc = buffer;
			result = true;
		}
	}

	return result;
}
