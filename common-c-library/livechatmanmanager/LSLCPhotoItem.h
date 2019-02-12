/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCPhotoItem.h
 *   desc: LiveChat图片消息item
 */

#pragma once

#include <string>
#include <vector>
#include <manrequesthandler/LSLiveChatRequestLiveChatDefine.h>
#include <common/list_lock.h>
using namespace std;

typedef vector<string>	LCEmotionPathVector;
class LSLCPhotoItem
{
public:
	// 图片处理状态
	typedef enum {
		Unknow,						// 未知状态
		PhotoFee,					// 正在付费
		DownloadThumbFuzzyPhoto,	// 正在下载拇指不清晰图
		DownloadShowFuzzyPhoto,		// 正在下载用于显示的不清晰图
		DownloadThumbSrcPhoto,		// 正在下载拇指原图
		DownloadShowSrcPhoto,		// 正在下载用于显示的原图
		DownloadSrcPhoto,			// 正在下载原图
        CheckPhoto,                // 正在查询中
	} ProcessStatus;

	// 图片处理状态列表定义
	typedef list_lock<ProcessStatus> ProcessStatusList;
    
public:
	LSLCPhotoItem();
    LSLCPhotoItem(LSLCPhotoItem* photoItem);
	virtual ~LSLCPhotoItem();

public:
	// 初始化
	bool Init(const string& photoId				// 图片ID
			, const string& sendId				// 发送ID
			, const string& photoDesc			// 图片描述
			, const string& showFuzzyFilePath	// 用于显示的不清晰图路径
			, const string& thumbFuzzyFilePath	// 拇指不清晰图路径
			, const string& srcFilePath			// 原文件路径
			, const string& showSrcFilePath		// 用于显示的原图片路径
			, const string& thumbSrcFilePath	// 拇指原图路径
			, bool charge						// 是否已付费
			);
    
    // 更新信息
    bool Update(const LSLCPhotoItem* photoItem);

	// 添加图片处理状态
	void AddProcessStatus(GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType);
	// 移除图片处理状态
	void RemoveProcessStatus(GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType);
	// 判断是否处理状态
	bool IsProcessStatus(GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType);
	// 添加购买图片处理状态
	void AddFeeStatus();
	// 移除购买图片处理状态
	void RemoveFeeStatus();
	// 判断是否正在付费状态
	bool IsFee();
	// 判断是否正在处理中
	bool IsProcessing();
    
    // 判断是否是检查图片收费状态
    bool IsProcessCheckStatus();
    // 增加检查图片收费状态
    void AddCheckStatus();
    // 删除检查图片收费状态
    void RemoveCheckStatus();

public:
	static ProcessStatus GetProcessStatus(GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType);

public:
	string	m_photoId;				// 图片ID
	string 	m_photoDesc;			// 图片描述
	string	m_sendId;				// 发送ID
	string	m_showFuzzyFilePath;	// 用于显示的不清晰图路径
	string 	m_thumbFuzzyFilePath;	// 拇指不清晰图路径
	string	m_srcFilePath;			// 原图路径
	string 	m_showSrcFilePath;		// 用于显示的原图路径
	string	m_thumbSrcFilePath;		// 拇指原图路径
	bool	m_charge;				// 是否已付费
private:
	ProcessStatusList	m_statusList;	// 图片处理状态列表
    
};
