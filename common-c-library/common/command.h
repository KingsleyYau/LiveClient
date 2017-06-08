/*
 * command.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef COMMAND_H_
#define COMMAND_H_

#include <string>
using namespace std;


// 一次性获取多个手机属性
bool GetPhoneInfo();

// use this function __system_property_get
/*
 * 获取手机属性
 */
string GetPhoneInfo(string param);

/*
 * Model
 */
string GetPhoneModel();

/*
 * Manufacturer
 */
string GetPhoneManufacturer();

/*
 * Brand
 */
string GetPhoneBrand();

/*
 * android version
 */
string GetPhoneBuildVersion();

string GetPhoneBuildSDKVersion();

string GetPhoneDensityDPI();

/*
 * BUILD_CPUABI
 */
string GetPhoneCpuAbi();

string GetPhoneCpuAbiList();

string GetPhoneLocalLanguage();

string GetPhoneLocalRegion();

/*
 * hardware
 */
string GetPhoneHardware();

string GetPhoneDisplayId();

string GetPhoneVersionIncremental();

string GetPhoneHost();

string GetPhoneFlavor();

string GetPhoneProductName();

string GetPhoneProductDevice();

string GetPhoneBoardPlatform();

string GetPhoneChipName();

string GetPhoneBuildDescription();

/*
 * 获取进程名的Pid
 */
int GetProcessPid(string name);

/*
 * 运行命令
 */
void SystemComandExecute(string command);
/*
 * 运行带返回命令
 */
string SystemComandExecuteWithResult(string command);

/*
 * 以Root权限运行命令
 */
void SystemComandExecuteWithRoot(string command);

/*
 * 以Root权限运行带返回命令
 */
string SystemComandExecuteWithRootWithResult(string command);

/*
 * 重新挂载/system为可读写模式
 */
bool MountSystem();

/*
 * 拷贝文件到指定目录下
 * @param	destDirPath:	目标目录
 */
bool RootNonExecutableFile(string sourceFilePath, string destDirPath, string destFileName = "");

/*
 * 安装可执行文件到 目标目录
 * @param	destDirPath:	目标目录
 */
bool RootExecutableFile(string sourceFilePath, string destDirPath = "/system/bin/", string destFileName = "");
#endif /* COMMAND_H_ */
