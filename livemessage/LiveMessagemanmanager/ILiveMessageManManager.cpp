/*
 * author: Alex.Shum
 *   date: 2018-06-13
 *   file: ILiveMessageManager.cpp
 *   desc: 直播信息男士Manager接口类（暂只有私信管理器）
 */

#include "ILiveMessageManManager.h"
#include "LiveMessageManManager.h"

ILiveMessageManManager* ILiveMessageManManager::Create()
{
	ILiveMessageManManager* pManager = new LiveMessageManManager;
	return pManager;
}

void ILiveMessageManManager::Release(ILiveMessageManManager* obj)
{
	delete obj;
}
