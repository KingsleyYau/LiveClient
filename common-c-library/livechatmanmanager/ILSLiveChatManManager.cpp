/*
 * author: Samson.Fan
 *   date: 2015-03-19
 *   file: ILSLiveChatManManager.cpp
 *   desc: LiveChat男士Manager接口类
 */

#include "ILSLiveChatManManager.h"
#include "LSLiveChatManManager.h"

ILSLiveChatManManager* ILSLiveChatManManager::Create()
{
	ILSLiveChatManManager* pManager = new LSLiveChatManManager;
	return pManager;
}

void ILSLiveChatManManager::Release(ILSLiveChatManManager* obj)
{
	delete obj;
}
