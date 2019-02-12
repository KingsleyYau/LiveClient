/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCVoiceItem.h
 *   desc: LiveChat语音消息item
 */

#pragma once

#include <string>
using namespace std;

class LSLCVoiceItem
{
public:
	LSLCVoiceItem();
    LSLCVoiceItem(LSLCVoiceItem* voiceItem);
	virtual ~LSLCVoiceItem();

public:
	// 初始化
	bool Init(
		const string& voiceId
		, const string& filePath
		, int timeLength
		, const string& fileType
		, const string& checkCode
		, bool charge);

public:
	string	m_voiceId;
	string	m_filePath;
	int		m_timeLength;
	string	m_fileType;
	string	m_checkCode;
	bool	m_charge;
	bool	m_processing;
};
