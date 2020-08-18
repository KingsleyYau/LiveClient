/*
 * HttpOrderExpiredReportTask.cpp
 *
 *  Created on: 2020-06-29
 *      Author: Alex
 *        desc: 16.5.Google失效订单列表上传（仅Android）
 */

#include "HttpOrderExpiredReportTask.h"
#include <common/md5.h>

typedef map<string, string, less<string>> mapTmp;

HttpOrderExpiredReportTask::HttpOrderExpiredReportTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_ORDEREXPIREDREPORT;
}

HttpOrderExpiredReportTask::~HttpOrderExpiredReportTask() {
	// TODO Auto-generated destructor stub
}

void HttpOrderExpiredReportTask::SetCallback(IRequestOrderExpiredReportCallback* callback) {
	mpCallback = callback;
}

void HttpOrderExpiredReportTask::SetParam(
                                         string manId,
                                         string deviceId,
                                         string deviceModel,
                                         string system,
                                         string appSdk,
                                         OrderExpiredList list
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    mapTmp tmp;
    
    if( manId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDEREXPIREDREPORT_MANID, manId.c_str());
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ORDEREXPIREDREPORT_MANID, manId));
    
    if( deviceId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDEREXPIREDREPORT_DEVICEID, deviceId.c_str());
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ORDEREXPIREDREPORT_DEVICEID, deviceId.c_str()));
    
    if( deviceModel.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDEREXPIREDREPORT_DEVICEMODEL, deviceModel.c_str());
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ORDEREXPIREDREPORT_DEVICEMODEL, deviceModel.c_str()));
    
    if( system.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDEREXPIREDREPORT_SYSTEM, system.c_str());
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ORDEREXPIREDREPORT_SYSTEM, system.c_str()));

    
    if( appSdk.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDEREXPIREDREPORT_APPSDK, appSdk.c_str());
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ORDEREXPIREDREPORT_APPSDK, appSdk.c_str()));
    
    Json::Value listJson;
    for (OrderExpiredList::iterator iter = list.begin(); iter != list.end(); iter++) {
        HttpOrderExpiredItem item = (*iter);
        //Json::Value itemJson;
        //itemJson[LIVEROOM_ORDEREXPIREDREPORT_ORDERINFOS] = item.PackInfo();
        listJson.append(Json::Value(item.PackInfo()));
    }
    
    string orderListInfo("");
    //Json::Value orderInfoJson;
    Json::FastWriter jsonWriter;
    orderListInfo = jsonWriter.write(listJson);
    
    string newOrderListInfo = orderListInfo;
    if (orderListInfo.length() > 0) {
        newOrderListInfo = orderListInfo.substr(0, orderListInfo.length() - 1);
    }
    
    mHttpEntiy.AddContent(LIVEROOM_ORDEREXPIREDREPORT_ORDERINFOS, orderListInfo.c_str());
    
    tmp.insert(mapTmp::value_type(LIVEROOM_ORDEREXPIREDREPORT_ORDERINFOS, newOrderListInfo));
    
    string strTemp = "4#5j@!94*s^a(e2";
    for(mapTmp::iterator itr = tmp.begin(); itr != tmp.end(); itr++) {
        char cTemp[1024];
        snprintf(cTemp, sizeof(cTemp), "%s=%s&", (itr->first).c_str(), (itr->second).c_str());
        strTemp += cTemp;
    }

    // 生成MD5字符串
    char strMD5[2048] = {0};
    GetMD5String(strTemp.c_str(), strMD5);

    mHttpEntiy.AddContent(LIVEROOM_ORDEREXPIREDREPORT_SIGN, strMD5);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpOrderExpiredReportTask::SetParam( "
            "task : %p, "
            "manid : %s, "
            "deviceId : %s, "
            "deviceModel : %s, "
            "system : %s, "
            "appSdk : %s, "
            "orderListInfo : %s, "
            "strTemp : %s, "
            "strMD5 : %s"
            ")",
            this,
            manId.c_str(),
            deviceId.c_str(),
            deviceModel.c_str(),
            system.c_str(),
            appSdk.c_str(),
            newOrderListInfo.c_str(),
            strTemp.c_str(),
            strMD5
            );
}



bool HttpOrderExpiredReportTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpOrderExpiredReportTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    string errmsg = "";
    string code = "";
    string orderNo = "";
    string productId = "";
    bool bParse = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseAndroidPaid(buf, size, code, errmsg, &dataJson);
        if (bParse) {
            if (dataJson[LIVEROOM_IOSPAY_ORDERNO].isString()) {
                orderNo = dataJson[LIVEROOM_IOSPAY_ORDERNO].asString();
            }
            if (dataJson[LIVEROOM_IOSPAY_PRODUCTID].isString()) {
                productId = dataJson[LIVEROOM_IOSPAY_PRODUCTID].asString();
            }
        }
        // bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        code = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnOrderExpiredReport(this, bParse, code, errmsg);
    }
    
    return bParse;
}

