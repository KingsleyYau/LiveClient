/*
 * command.cpp
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "command.h"
#ifdef ANDROID
#include <sys/system_properties.h>
#endif
#include "KLog.h"
#include <stdlib.h>

#define PRODUCT_MODEL		"ro.product.model"	 			// Model
#define PRODUCT_BRAND		"ro.product.brand"	 			// Brand
#define PRODUCT_MANUFACT	"ro.product.manufacturer"		// Manufacturer
#define BUILD_VERSION		"ro.build.version.release"		// android release
#define BUILD_SDK			"ro.build.version.sdk"			// android sdk version
#define BUILD_CPUABI		"ro.product.cpu.abi"			// CPU info
#define BUILD_CPUABILIST	"ro.product.cpu.abilist"		// CPU abi list
#define SF_DENSITY			"ro.sf.lcd_density"				// density(DPI)
#define LOCAL_LANGUAGE		"ro.product.locale.language"	// language
#define LOCAL_REGION		"ro.product.locale.region"		// country
#define BOOT_SERIALNO		"ro.boot.serialno"				// boot serialno
#define RO_SERIALNO			"ro.serialno"					// serialno
#define RO_HARDWARE			"ro.hardware"					// hardware
#define DISPLAY_ID			"ro.build.display.id"			// displayid
#define VER_INCREMENTAL		"ro.build.version.incremental"	// version incremental
#define BUILD_HOST			"ro.build.host"					// host
#define BUILD_FLAVOR		"ro.build.flavor"				// flavor
#define PRODUCT_NAME		"ro.product.name"				// product name
#define PRODUCT_DEVICE		"ro.product.device"				// product device
#define BOARD_PLATFORM		"ro.board.platform"				// platform
#define RO_CHIPNAME			"ro.chipname"					// chipname
#define BUILD_DESCRIPTION	"ro.build.description"			// description

typedef struct PhoneInfo {
	string model;
	string manufacturer;
	string brand;
	string buildVersion;
	string buildSDKVersion;
	string densityDpi;
	string cpuAbi;
	string cpuAbiList;
	string language;
	string region;
	string bootSerialno;
	string serialno;
	string hardware;
	string displayId;
	string verIncremental;
	string host;
	string flavor;
	string productName;
	string productDevice;
	string platform;
	string chipname;
	string description;
} PHONEINFO, *LPPHONEINFO;
static PHONEINFO g_phoneInfo;

// 一次性获取多个手机属性
bool GetPhoneInfo()
{
	bool result = false;
	string sCommand = "cat /system/build.prop 2>&1";

	FILE *ptr = popen(sCommand.c_str(), "r");
	if(ptr != NULL) {
		result = true;
		const unsigned int bufferLen = 2048;
		char buffer[bufferLen] = {0};

		while(fgets(buffer, bufferLen, ptr) != NULL) {
			string result = buffer;

			// skip if start with #
			if( result.length() > 0 && result.c_str()[0] == '#' ) {
				continue;
			}

			// skip if not found '='
			std::string::size_type sep = result.find("=");
			if( string::npos == sep ) {
				continue;
			}

			string key = result.substr(0, sep);

			if( key == PRODUCT_MODEL )
			{
				g_phoneInfo.model = result.substr(key.length() + 1, result.length() - (key.length() + 1 + 1));
			}
			else if( key == PRODUCT_MANUFACT )
			{
				g_phoneInfo.manufacturer = result.substr(key.length() + 1, result.length() - (key.length() + 1 + 1));
			}
			else if( key == PRODUCT_BRAND )
			{
				g_phoneInfo.brand = result.substr(key.length() + 1, result.length() - (key.length() + 1 + 1));
			}
			else if( key == BUILD_VERSION )
			{
				g_phoneInfo.buildVersion = result.substr(key.length() + 1, result.length() - (key.length() + 1 + 1));
			}
			else if( key == BUILD_SDK )
			{
				g_phoneInfo.buildSDKVersion = result.substr(key.length() + 1, result.length() - (key.length() + 1 + 1));
			}
			else if( key == SF_DENSITY )
			{
				g_phoneInfo.densityDpi = result.substr(key.length() + 1, result.length() - (key.length() + 1 + 1));
			}
			else if( key == BUILD_CPUABI )
			{
				g_phoneInfo.cpuAbi = result.substr(key.length() + 1, result.length() - (key.length() + 1 + 1));
			}
			else if( key == BUILD_CPUABILIST )
			{
				g_phoneInfo.cpuAbiList = result.substr(key.length() + 1, result. length() - (key.length() + 1 + 1));
			}
			else if( key == LOCAL_LANGUAGE )
			{
				g_phoneInfo.language = result.substr(key.length() + 1, result.length() - (key.length() + 1 + 1));
			}
			else if( key == LOCAL_REGION )
			{
				g_phoneInfo.region = result.substr(key.length() + 1, result.length() - (key.length() + 1 + 1));
			}
			else if ( key == BOOT_SERIALNO )
			{
				g_phoneInfo.bootSerialno = result.substr(key.length() + 1, result.length() - (key.length() + 1 + 1));
			}
			else if ( key == RO_SERIALNO )
			{
				g_phoneInfo.serialno = result.substr(key.length() + 1, result.length() - (key.length() + 1 + 1));
			}
			else if ( key == RO_HARDWARE )
			{
				g_phoneInfo.hardware = result.substr(key.length() + 1, result.length() - (key.length() +1 + 1));
			}
			else if ( key == DISPLAY_ID )
			{
				g_phoneInfo.displayId = result.substr(key.length() + 1, result.length() - (key.length() +1 + 1));
			}
			else if ( key == VER_INCREMENTAL )
			{
				g_phoneInfo.verIncremental = result.substr(key.length() + 1, result.length() - (key.length() +1 + 1));
			}
			else if ( key == BUILD_HOST )
			{
				g_phoneInfo.host = result.substr(key.length() + 1, result.length() - (key.length() +1 + 1));
			}
			else if ( key == BUILD_FLAVOR )
			{
				g_phoneInfo.flavor = result.substr(key.length() + 1, result.length() - (key.length() +1 + 1));
			}
			else if ( key == PRODUCT_NAME )
			{
				g_phoneInfo.productName = result.substr(key.length() + 1, result.length() - (key.length() +1 + 1));
			}
			else if ( key == PRODUCT_DEVICE )
			{
				g_phoneInfo.productDevice = result.substr(key.length() + 1, result.length() - (key.length() +1 + 1));
			}
			else if ( key == BOARD_PLATFORM )
			{
				g_phoneInfo.platform = result.substr(key.length() + 1, result.length() - (key.length() +1 + 1));
			}
			else if ( key == RO_CHIPNAME )
			{
				g_phoneInfo.chipname = result.substr(key.length() + 1, result.length() - (key.length() +1 + 1));
			}
			else if ( key == BUILD_DESCRIPTION )
			{
				g_phoneInfo.description = result.substr(key.length() + 1, result.length() - (key.length() +1 + 1));
			}
		}
		pclose(ptr);
		ptr = NULL;
	}

//	char temp[1024];
//	memset(temp, '\0', sizeof(temp));
//	__system_property_get(param.c_str(), temp);
//	model = temp;
	return result;
}

// use this function __system_property_get
/*
 * 获取手机属性
 */
string GetPhoneInfo(string param) {

	string findName = " ";
	string sCommand = "cat /system/build.prop 2>&1";
	string model = "";

	if(param.length() == 0) {
		return model;
	}

	FILE *ptr = popen(sCommand.c_str(), "r");
	if(ptr != NULL) {
		char buffer[2048] = {'\0'};

		while(fgets(buffer, 2048, ptr) != NULL) {
			string result = buffer;
			if(string::npos != result.find(param)) {
				// +1 for =
				model = result.substr(param.length() + 1, result.length() - (param.length() + 1 + 1));
				break;
			}
		}
		pclose(ptr);
		ptr = NULL;
	}

//	char temp[1024];
//	memset(temp, '\0', sizeof(temp));
//	__system_property_get(param.c_str(), temp);
//	model = temp;

	return model;
}

/*
 * Model
 */
string GetPhoneModel() {
//	string model = GetPhoneInfo(PRODUCT_MODEL);
//	if(model.length() > 0) {
//		FileLog("JNI::GetPhoneModel()", "Model : %s", model.c_str());
//	}
//	return model;
	return g_phoneInfo.model;
}

/*
 * Manufacturer
 */
string GetPhoneManufacturer() {
//	string strManufacturer = GetPhoneInfo(PRODUCT_MANUFACT);
//	if (!strManufacturer.empty()) {
//		FileLog("JNI::GetPhoneManufacturer()", "Manufacturer : %s", strManufacturer.c_str());
//	}
//	return strManufacturer;
	return g_phoneInfo.manufacturer;
}

/*
 * Brand
 */
string GetPhoneBrand() {
//	string model = GetPhoneInfo(PRODUCT_BRAND);
//	if(model.length() > 0) {
//		FileLog("JNI::GetPhoneBrand()", "Brand : %s", model.c_str());
//	}
//	return model;
	return g_phoneInfo.brand;
}

/*
 * android version
 */
string GetPhoneBuildVersion() {
//	string model = GetPhoneInfo(BUILD_VERSION);
//	if(model.length() > 0) {
//		FileLog("JNI::GetPhoneBuildVersion()", "鎵惧埌鎵嬫満Android鐗堟湰:%s", model.c_str());
//	}
//	return model;
	return g_phoneInfo.buildVersion;
}

string GetPhoneBuildSDKVersion() {
//	string strSdkVersion = GetPhoneInfo(BUILD_SDK);
//	if (!strSdkVersion.empty()) {
//		FileLog("JNI::GetPhoneBuildSDKVersion()", "SDK Version:%s", strSdkVersion.c_str());
//	}
//	return strSdkVersion;
	return g_phoneInfo.buildSDKVersion;
}

string GetPhoneDensityDPI() {
//	string strDensityDPI = GetPhoneInfo(SF_DENSITY);
//	if (!strDensityDPI.empty()) {
//		FileLog("JNI::GetPhoneDensityDPI()", "Density DPI:%s", strDensityDPI.c_str());
//	}
//	return strDensityDPI;
	return g_phoneInfo.densityDpi;
}

/*
 * BUILD_CPUABI
 */
string GetPhoneCpuAbi() {
//	string model = GetPhoneInfo(BUILD_CPUABI);
//	if(model.length() > 0) {
//		FileLog("JNI::GetPhoneCpuAbi()", "Android CPU ABI : %s", model.c_str());
//	}
//	return model;
	return g_phoneInfo.cpuAbi;
}

string GetPhoneCpuAbiList()
{
	return g_phoneInfo.cpuAbiList;
}

string GetPhoneLocalLanguage() {
//	string strLanguage = GetPhoneInfo(LOCAL_LANGUAGE);
//	if (!strLanguage.empty()) {
//		FileLog("JNI::GetPhoneLocalLanguage()", "Language:%s", strLanguage.c_str());
//	}
//	return strLanguage;
	return g_phoneInfo.language;
}

string GetPhoneLocalRegion() {
//	string strRegion = GetPhoneInfo(LOCAL_REGION);
//	if (!strRegion.empty()) {
//		FileLog("JNI::GetPhoneLocalRegion()", "Region:%s", strRegion.c_str());
//	}
//	return strRegion;
	return g_phoneInfo.region;
}

string GetPhoneHardware()
{
	return g_phoneInfo.hardware;
}

string GetPhoneDisplayId()
{
	return g_phoneInfo.displayId;
}

string GetPhoneVersionIncremental()
{
	return g_phoneInfo.verIncremental;
}

string GetPhoneHost()
{
	return g_phoneInfo.host;
}

string GetPhoneFlavor()
{
	return g_phoneInfo.flavor;
}

string GetPhoneProductName()
{
	return g_phoneInfo.productName;
}

string GetPhoneProductDevice()
{
	return g_phoneInfo.productDevice;
}

string GetPhoneBoardPlatform()
{
	return g_phoneInfo.platform;
}

string GetPhoneChipName()
{
	return g_phoneInfo.chipname;
}

string GetPhoneBuildDescription()
{
	return g_phoneInfo.description;
}

/*
 * 获取进程名的Pid
 */
int GetProcessPid(string name) {
	FileLog("JNI::GetProcessPid", "正在获取进程(%s)Pid...", name.c_str());
	int iPid = -1;

	string findName = " ";
	findName += name;
	string sCommand = "ps 2>&1";
	string reslut = "";

	FILE *ptr = popen(sCommand.c_str(), "r");
	if(ptr != NULL) {
		char buffer[2048] = {'\0'};

		// 获取第一行字段
		int iColumn = -1, index = 0;
		if(fgets(buffer, 2048, ptr) != NULL) {
			char *p = strtok(buffer, " ");
			while(p != NULL) {
				reslut = p;
				if(reslut == "PID") {
					iColumn = index;
					break;
				}
				index++;
				p = strtok(NULL, " ");
			}
		}

		// 获取进程pid
		if(iColumn != -1) {
			while(fgets(buffer, 2048, ptr) != NULL) {
				string reslut = buffer;
				if(string::npos != reslut.find(findName.c_str())) {
					char *p = strtok(buffer, " ");
					for(int i = 0; p != NULL; i++) {
						if(i == iColumn) {
							// 找到进程pid
							iPid = atoi(p);
							FileLog("JNI::GetProcessPid", "找到进程Pid:%s", p);
							break;
						}
						p = strtok(NULL, " ");
					}
				}
			}
		}

		pclose(ptr);
		ptr = NULL;
	}

	return iPid;
}

/*
 * 运行命令
 */
void SystemComandExecute(string command) {
	string sCommand = command;
	sCommand += " &>/dev/null";
	//system(sCommand.c_str());
    popen(sCommand.c_str(), "w");
	FileLog("JNI::SystemComandExecute", "command : %s", sCommand.c_str());
}

/*
 * 运行带返回命令
 */
string SystemComandExecuteWithResult(string command) {
	string result = "";
	string sCommand = command;
	sCommand += " 2>&1";

	FILE *ptr = popen(sCommand.c_str(), "r");
	if(ptr != NULL) {
		char buffer[2048] = {'\0'};
		while(fgets(buffer, 2048, ptr) != NULL) {
			result += buffer;
		}
		pclose(ptr);
		ptr = NULL;
	}
	FileLog("JNI::SystemComandExecuteWithResult", "command : %s \ncommand result : %s", sCommand.c_str(), result.c_str());
	return result;
}

/*
 * 以Root权限运行命令
 */
void SystemComandExecuteWithRoot(string command) {
	string sCommand;
	sCommand = "echo \"";//"su -c \"";
	sCommand += command;
	sCommand += "\"|su";
	SystemComandExecute(sCommand);
}

/*
 * 以Root权限运行带返回命令
 */
string SystemComandExecuteWithRootWithResult(string command) {
	string sCommand = command;
	sCommand = "echo \"";//"su -c \"";
	sCommand += command;
	sCommand += "\"|su";
	return SystemComandExecuteWithResult(sCommand);
}

/*
 * 重新挂载/system为可读写模式
 */
bool MountSystem() {
	bool bFlag = false;

	char pBuffer[2048] = {'\0'};
	string result = "";

	// 获取原/system挂载
	FILE *ptr = popen("mount", "r");
	if(ptr != NULL) {

		while(fgets(pBuffer, 2048, ptr) != NULL) {
			result = pBuffer;

			if(string::npos != result.find("/system")) {
				// 找到/system挂载路径
				char* dev = strtok(pBuffer, " ");
				result = dev;
				FileLog("JNI::MountSystem", "找到/system挂载路径:%s", result.c_str());
				break;
			}
		}
		pclose(ptr);
		ptr = NULL;
	}

	// 更改挂载为rw
	sprintf(pBuffer, "mount -o remount rw,%s /system", result.c_str());
	result = SystemComandExecuteWithRootWithResult(pBuffer);
	if(result.length() == 0) {
		FileLog("JNI::MountSystem", "挂载/system为可读写成功!");
		bFlag = true;
	}
	else {
		FileLog("JNI::MountSystem", "挂载/system为可读写失败!");
	}

	return bFlag;
}

/*
 * 拷贝文件到指定目录下
 * @param	destDirPath:	目标目录
 */
bool RootNonExecutableFile(string sourceFilePath, string destDirPath, string destFileName) {
	bool bFlag = false;

	char pBuffer[2048] = {'\0'};
	string result = "";

	if(MountSystem()) {
		// 开始拷贝
		string fileName = sourceFilePath;

		if(destFileName.length() == 0) {
			// 没有指定文件名,用原来的名字
			string::size_type pos = string::npos;
			pos = sourceFilePath.find_last_of('/');
			if(string::npos != pos) {
				pos ++;
				fileName = sourceFilePath.substr(pos, sourceFilePath.length() - pos);
			}
			fileName = destDirPath + fileName;
		}
		else {
			// 指定文件名
			fileName = destDirPath + destFileName;
		}

		sprintf(pBuffer, "cat %s > %s", sourceFilePath.c_str(), fileName.c_str());
		result = SystemComandExecuteWithRootWithResult(pBuffer);
		if(result.length() == 0) {
			// 拷贝成功
			FileLog("JNI::RootNonExecutableFile", "拷贝%s到%s成功!", sourceFilePath.c_str(), fileName.c_str());
			bFlag = true;
		}
		else {
			FileLog("JNI::RootNonExecutableFile", "拷贝%s到%s失败!", sourceFilePath.c_str(), fileName.c_str());
		}
	}

	return bFlag;
}

/*
 * 安装可执行文件到 目标目录
 * @param destDirPath:	目标目录
 */
bool RootExecutableFile(string sourceFilePath, string destDirPath, string destFileName) {
	bool bFlag = false;

	char pBuffer[2048] = {'\0'};
	string result = "";

	// 开始拷贝
	string fileName = "";

	if(destFileName.length() == 0) {
		// 没有指定文件名,用原来的名字
		string::size_type pos = string::npos;
		pos = sourceFilePath.find_last_of('/');
		if(string::npos != pos) {
			pos ++;
			fileName = sourceFilePath.substr(pos, sourceFilePath.length() - pos);
		}
	}
	else {
		// 指定文件名
		fileName = destFileName;
	}

	// 如果在运行先关闭
	int iPid = GetProcessPid(fileName);
	if(iPid != -1) {
		FileLog("JNI::RootExecutableFile", "发现%s(PID:%d)正在运行, 先杀掉!", fileName.c_str(), iPid);
		sprintf(pBuffer, "kill -9 %d", iPid);
		SystemComandExecuteWithRoot(pBuffer);
	}

	if(RootNonExecutableFile(sourceFilePath, destDirPath, fileName)) {
		fileName = destDirPath + fileName;
		sprintf(pBuffer, "chmod 4755 %s", fileName.c_str());
		result = SystemComandExecuteWithRootWithResult(pBuffer);
		if(result.length() == 0) {
			// 更改权限成功
			FileLog("JNI::RootExecutableFile", "提升%s权限为4755成功!", fileName.c_str());
			bFlag = true;
		}
		else {
			FileLog("JNI::RootExecutableFile", "提升%s权限为4755失败!", fileName.c_str());
		}
	}

	return bFlag;
}
