/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCPhotoItem.h
 *   desc: LiveChat图片消息item
 */

#include "LSLCPhotoItem.h"
#include <manrequesthandler/LSLiveChatRequestLiveChatController.h>
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

LSLCPhotoItem::LSLCPhotoItem()
{
	m_photoId = "";
	m_photoDesc = "";
	m_sendId = "";
	m_showFuzzyFilePath = "";
	m_thumbFuzzyFilePath = "";
	m_srcFilePath = "";
	m_showSrcFilePath = "";
	m_thumbSrcFilePath = "";
	m_charge = false;
}

LSLCPhotoItem::~LSLCPhotoItem()
{

}

LSLCPhotoItem::LSLCPhotoItem(LSLCPhotoItem* photoItem) {
    if (NULL != photoItem) {
        m_photoId = photoItem->m_photoId;
        m_photoDesc = photoItem->m_photoDesc;
        m_sendId = photoItem->m_sendId;
        m_showFuzzyFilePath = photoItem->m_showFuzzyFilePath;
        m_thumbFuzzyFilePath = photoItem->m_thumbFuzzyFilePath;
        m_srcFilePath = photoItem->m_srcFilePath;
        m_showSrcFilePath = photoItem->m_showSrcFilePath;
        m_thumbSrcFilePath = photoItem->m_thumbSrcFilePath;
        m_charge = photoItem->m_charge;
    }
}

// 初始化
bool LSLCPhotoItem::Init(const string& photoId				// 图片ID
						, const string& sendId				// 发送ID
						, const string& photoDesc			// 图片描述
						, const string& showFuzzyFilePath	// 用于显示的不清晰图路径
						, const string& thumbFuzzyFilePath	// 拇指不清晰图路径
						, const string& srcFilePath			// 原文件路径
						, const string& showSrcFilePath		// 用于显示的原图片路径
						, const string& thumbSrcFilePath	// 拇指原图路径
						, bool charge						// 是否已付费
						)
{
	m_photoId = photoId;
	m_sendId = sendId;
	m_photoDesc = photoDesc;
	m_charge = charge;

	if ( IsFileExist(showFuzzyFilePath) )
	{
		m_showFuzzyFilePath = showFuzzyFilePath;
	}

	if ( IsFileExist(thumbFuzzyFilePath) )
	{
		m_thumbFuzzyFilePath = thumbFuzzyFilePath;
	}

	if ( IsFileExist(srcFilePath) )
	{
		m_srcFilePath = srcFilePath;
	}

	if ( IsFileExist(showSrcFilePath) )
	{
		m_showSrcFilePath = showSrcFilePath;
	}

	if ( IsFileExist(thumbSrcFilePath) )
	{
		m_thumbSrcFilePath = thumbSrcFilePath;
	}

	return true;
}

// 更新信息
bool LSLCPhotoItem::Update(const LSLCPhotoItem* photoItem)
{
    bool result = false;
    if (NULL != photoItem) {
        result = Init(photoItem->m_photoId, photoItem->m_sendId, photoItem->m_photoDesc
                      , photoItem->m_showFuzzyFilePath, photoItem->m_thumbFuzzyFilePath
                      , photoItem->m_srcFilePath, photoItem->m_showSrcFilePath, photoItem->m_thumbSrcFilePath
                      , photoItem->m_charge);
    }
    return result;
}

// 设置图片处理状态
LSLCPhotoItem::ProcessStatus LSLCPhotoItem::GetProcessStatus(GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType)
{
	ProcessStatus status = Unknow;
	if (modeType == GMT_CLEAR) {
		if (sizeType == GPT_LARGE
			|| sizeType == GPT_MIDDLE)
		{
			status = DownloadShowSrcPhoto;
		}
		else if (sizeType == GPT_ORIGINAL)
		{
			status = DownloadSrcPhoto;
		}
		else {
			status = DownloadThumbSrcPhoto;
		}
	}
	else if (modeType == GMT_FUZZY) {
		if (sizeType == GPT_LARGE
			|| sizeType == GPT_MIDDLE)
		{
			status = DownloadShowFuzzyPhoto;
		}
		else {
			status = DownloadThumbFuzzyPhoto;
		}
	}

	return status;
}

// 添加图片处理状态
void LSLCPhotoItem::AddProcessStatus(GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType)
{
	ProcessStatus status = GetProcessStatus(modeType, sizeType);
	if (Unknow != status) {
		m_statusList.lock();
		m_statusList.push_back(status);
		m_statusList.unlock();
	}
}

// 移除图片处理状态
void LSLCPhotoItem::RemoveProcessStatus(GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType)
{
	ProcessStatus status = GetProcessStatus(modeType, sizeType);
	if (Unknow != status) {
		m_statusList.lock();
		m_statusList.erase(status);
		m_statusList.unlock();
	}
}

// 判断是否处理状态
bool LSLCPhotoItem::IsProcessStatus(GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType)
{
	bool result = false;

	ProcessStatus status = GetProcessStatus(modeType, sizeType);
	m_statusList.lock();
	result = m_statusList.has(status);
	m_statusList.unlock();

	return result;
}

// 添加购买图片处理状态
void LSLCPhotoItem::AddFeeStatus()
{
	m_statusList.lock();
	if (!m_statusList.has(PhotoFee))
	{
		m_statusList.push_back(PhotoFee);
	}
	m_statusList.unlock();
}

// 移除购买图片处理状态
void LSLCPhotoItem::RemoveFeeStatus()
{
	m_statusList.lock();
	m_statusList.erase(PhotoFee);
	m_statusList.unlock();
}

// 判断是否付费状态
bool LSLCPhotoItem::IsFee()
{
	bool result = false;

	m_statusList.lock();
	result = m_statusList.has(PhotoFee);
	m_statusList.unlock();

	return result;
}

// 判断是否正在处理中
bool LSLCPhotoItem::IsProcessing()
{
	bool result = false;
	m_statusList.lock();
	result = !m_statusList.empty();
	m_statusList.unlock();
	return result;
}

// 判断是否是检查图片收费状态
bool LSLCPhotoItem::IsProcessCheckStatus()
{
    bool result = false;
    m_statusList.lock();
    result = m_statusList.has(CheckPhoto);
    m_statusList.unlock();
    return result;
}
// 增加检查图片收费状态
void LSLCPhotoItem::AddCheckStatus()
{
    m_statusList.lock();
    if (!m_statusList.has(CheckPhoto))
    {
        m_statusList.push_back(CheckPhoto);
    }
    m_statusList.unlock();
}
// 删除检查图片收费状态
void LSLCPhotoItem::RemoveCheckStatus()
{
    m_statusList.lock();
    m_statusList.erase(CheckPhoto);
    m_statusList.unlock();
}
