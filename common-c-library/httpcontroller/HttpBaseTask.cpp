/*
 * HttpBaseTask.cpp
 *
 *  Created on: 2015-9-15
 *      Author: Max
 */

#include "HttpBaseTask.h"

HttpBaseTask::HttpBaseTask() {
	// TODO Auto-generated constructor stub
	mpHttpTaskCallback = NULL;
	mbCanStart = true;
}

HttpBaseTask::~HttpBaseTask() {
	// TODO Auto-generated destructor stub
}

void HttpBaseTask::SetHttpTaskCallback(IHttpTaskCallback* callback) {
	mpHttpTaskCallback = callback;
}

IHttpTaskCallback* HttpBaseTask::GetHttpTaskCallback() {
	return mpHttpTaskCallback;
}

bool HttpBaseTask::Start() {
	FileLog(LIVESHOW_HTTP_LOG, "HttpBaseTask::Start( task : %p, mbStop : %s )", this, mbCanStart?"true":"false");
	bool bFlag = mbCanStart;
	if( !bFlag ) {
		OnTaskFinish();
	}
	return bFlag;
}

void HttpBaseTask::Stop() {
	FileLog(LIVESHOW_HTTP_LOG, "HttpBaseTask::Stop( task : %p )", this);
	mbCanStart = false;
}

void HttpBaseTask::Reset() {
	mbCanStart = true;
}

void HttpBaseTask::OnTaskFinish() {
	FileLog(LIVESHOW_HTTP_LOG, "HttpBaseTask::OnTaskFinish( task : %p )", this);
	if( mpHttpTaskCallback != NULL ) {
		mpHttpTaskCallback->OnTaskFinish(this);
	}
}
