/*
 * ZBHttpBaseTask.cpp
 *
 *  Created on: 2018-3-1
 *      Author: Max
 */

#include "ZBHttpBaseTask.h"

ZBHttpBaseTask::ZBHttpBaseTask() {
	// TODO Auto-generated constructor stub
	mpHttpTaskCallback = NULL;
	mbCanStart = true;
}

ZBHttpBaseTask::~ZBHttpBaseTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpBaseTask::SetHttpTaskCallback(IZBHttpTaskCallback* callback) {
	mpHttpTaskCallback = callback;
}

IZBHttpTaskCallback* ZBHttpBaseTask::GetHttpTaskCallback() {
	return mpHttpTaskCallback;
}

bool ZBHttpBaseTask::Start() {
	FileLog(LIVESHOW_HTTP_LOG, "ZBHttpBaseTask::Start( task : %p, mbStop : %s )", this, mbCanStart?"true":"false");
	bool bFlag = mbCanStart;
	if( !bFlag ) {
		OnTaskFinish();
	}
	return bFlag;
}

void ZBHttpBaseTask::Stop() {
	FileLog(LIVESHOW_HTTP_LOG, "ZBHttpBaseTask::Stop( task : %p )", this);
	mbCanStart = false;
}

void ZBHttpBaseTask::Reset() {
	mbCanStart = true;
}

void ZBHttpBaseTask::OnTaskFinish() {
	FileLog(LIVESHOW_HTTP_LOG, "ZBHttpBaseTask::OnTaskFinish( task : %p )", this);
	if( mpHttpTaskCallback != NULL ) {
		mpHttpTaskCallback->OnTaskFinish(this);
	}
}
