/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCEmotionItem.h
 *   desc: LiveChat高级表情消息item
 */

#pragma once

#include <string>
#include <vector>
using namespace std;

typedef vector<string>	LCEmotionPathVector;
class IAutoLock;
class LSLCEmotionItem
{
public:
	LSLCEmotionItem();
    LSLCEmotionItem(LSLCEmotionItem* emotionItem);
	virtual ~LSLCEmotionItem();

public:
	// 初始化
	bool Init(const string& emotionId			// 高级表情ID
			, const string& imagePath			// 缩略图
			, const string& playBigPath			// 播放大图路径
			, const string& playBigSubPath		// 播放大图子路径
			);
	// 根据播放大图子路径枚举所有播放图片
	bool SetPlayBigSubPath(const string& playBigSubPath);
    
    // 高级表情item加锁
    void LockEmotion();
    // 高级表情item解锁
    void UnlockEmotion();

public:
	string	m_emotionId;	// 高级表情ID
	string	m_imagePath;	// 缩略图路径
	string 	m_playBigPath;	// 播放大图路径
	LCEmotionPathVector	m_playBigPaths;	// 播放大图路径数组
    
   IAutoLock*      m_emotionLock;  // 高级表情item锁
};
