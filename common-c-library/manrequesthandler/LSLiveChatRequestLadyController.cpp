/*
 * LSLiveChatRequestLadyController.cpp
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "LSLiveChatRequestLadyController.h"

LSLiveChatRequestLadyController::LSLiveChatRequestLadyController(LSLiveChatHttpRequestManager *phttprequestManager, LSLiveChatRequestLadyControllerCallback callback/* CallbackManager* pCallbackManager*/) {
	// TODO Auto-generated constructor stub
	SetHttpRequestManager(phttprequestManager);
	mLSLiveChatRequestLadyControllerCallback = callback;
}

LSLiveChatRequestLadyController::~LSLiveChatRequestLadyController() {
	// TODO Auto-generated destructor stub
}

/* IhttprequestManagerCallback */
void LSLiveChatRequestLadyController::onSuccess(long requestId, string url, const char* buf, int size) {
	FileLog("httprequest", "LSLiveChatRequestLadyController::onSuccess( url : %s, buf( size : %d ) )", url.c_str(), size);
	if (size < MAX_LOG_BUFFER) {
		FileLog("httprequest", "LSLiveChatRequestLadyController::onSuccess(), buf: %s", buf);
	}

	/* parse base result */
	string errnum = "";
	string errmsg = "";
	Json::Value data;

	bool bFlag = HandleResult(buf, size, errnum, errmsg, &data);

	/* resopned parse ok, callback success */
	if( url.compare(QUERY_LADY_MATCH_PATH) == 0 ) {
		/* 4.1.获取匹配女士条件 */
		LSLCLadyMatch item;
		item.Parse(data);
		if( mLSLiveChatRequestLadyControllerCallback.onQueryLadyMatch != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onQueryLadyMatch(requestId, bFlag, item, errnum, errmsg);
		}
	} else if( url.compare(SAVE_LADY_MATCH_PATH) == 0 ) {
		/* 4.2.保存匹配女士条件 */
		if( mLSLiveChatRequestLadyControllerCallback.onSaveLadyMatch != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onSaveLadyMatch(requestId, bFlag, errnum, errmsg);
		}
	} else if( url.compare(QUERY_LADY_LIST_PATH) == 0 ) {
		/* 4.3.条件查询女士列表 */
		list<LSLCLady> ladyList;
		int totalCount = 0;
		if( data[COMMON_DATA_COUNT].isInt() ) {
			totalCount = data[COMMON_DATA_COUNT].asInt();
		}
		if( data[COMMON_DATA_LIST].isArray() ) {
			for(int i = 0; i < data[COMMON_DATA_LIST].size(); i++ ) {
				LSLCLady lady;
				lady.Parse(data[COMMON_DATA_LIST].get(i, Json::Value::null));
				ladyList.push_back(lady);
			}
		} else {
			// parsing fail
			bFlag = false;
			errnum = LOCAL_ERROR_CODE_PARSEFAIL;
			errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
		}

		if( mLSLiveChatRequestLadyControllerCallback.onQueryLadyList != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onQueryLadyList(requestId, bFlag, ladyList,
					totalCount, errnum, errmsg);
		}
	} else if( url.compare(QUERY_LADY_DETAIL_PATH) == 0 ) {
		/* 4.4.查询女士详细信息 */
		LSLCLadyDetail item;
		item.Parse(data);
		if( mLSLiveChatRequestLadyControllerCallback.onQueryLadyDetail != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onQueryLadyDetail(requestId, bFlag, item, errnum, errmsg);
		}
	} else if( url.compare(ADD_FAVORITES_LADY_PATH) == 0 ) {
		/* 4.5.收藏女士 */
		if( mLSLiveChatRequestLadyControllerCallback.onAddFavouritesLady != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onAddFavouritesLady(requestId, bFlag, errnum, errmsg);
		}
	} else if( url.compare(REMOVE_FAVORITES_LADY_PATH) == 0 ) {
		/* 4.6.删除收藏女士 */
		if( mLSLiveChatRequestLadyControllerCallback.onRemoveFavouritesLady != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onRemoveFavouritesLady(requestId, bFlag, errnum, errmsg);
		}
	} else if( url.compare(QUERY_DIRECT_CALL_LADY_PATH) == 0 ) {
		/* 4.7.获取女士Direct Call TokenID */
		LSLCLadyCall item;
		item.Parse(data);
		if( mLSLiveChatRequestLadyControllerCallback.onQueryLadyCall != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onQueryLadyCall(requestId, bFlag, item, errnum, errmsg);
		}
	} else if ( url.compare(QUERY_RECENTCONTACT_PATH) == 0 ) {
		/* 4.8.获取最近联系人列表（ver3.0起） */
		list<LSLCLadyRecentContact> list;
		if( data[COMMON_DATA_LIST].isArray() ) {
			for(int i = 0; i < data[COMMON_DATA_LIST].size(); i++ ) {
				LSLCLadyRecentContact item;
				if (item.Parse(data[COMMON_DATA_LIST].get(i, Json::Value::null))) {
					list.push_back(item);
				}
			}
		} else {
			// parsing fail
			bFlag = false;
			errnum = LOCAL_ERROR_CODE_PARSEFAIL;
			errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
		}

		if (mLSLiveChatRequestLadyControllerCallback.onRecentContact != NULL) {
			mLSLiveChatRequestLadyControllerCallback.onRecentContact(requestId, bFlag, errnum, errmsg, list);
		}
	}else if( url.compare(QUERY_REMOVECONTACT_PATH) == 0 ){
		/* 4.9 删除联系人返回 3.0.3开始使用 */
		if( mLSLiveChatRequestLadyControllerCallback.onRemoveContactList != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onRemoveContactList(requestId, bFlag, errnum, errmsg);
		}
	} else if ( url.compare(QUERY_SIGNLIST_PATH) == 0 ) {
		/* 4.9.查询女士标签列表（ver3.0起） */
		list<LSLCLadySignListItem> list;
		if( data[COMMON_DATA_LIST].isArray() ) {
			for(int i = 0; i < data[COMMON_DATA_LIST].size(); i++ ) {
				LSLCLadySignListItem item;
				if (item.Parse(data[COMMON_DATA_LIST].get(i, Json::Value::null))) {
					list.push_back(item);
				}
			}
		} else {
			// parsing fail
			bFlag = false;
			errnum = LOCAL_ERROR_CODE_PARSEFAIL;
			errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
		}

		if (mLSLiveChatRequestLadyControllerCallback.onSignList != NULL) {
			mLSLiveChatRequestLadyControllerCallback.onSignList(requestId, bFlag, errnum, errmsg, list);
		}
	} else if ( url.compare(QUERY_UPLOADSIGN_PATH) == 0 ) {
		/* 4.10.提交女士标签（ver3.0起） */
		if( mLSLiveChatRequestLadyControllerCallback.onUploadSign != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onUploadSign(requestId, bFlag, errnum, errmsg);
		}
    } else if ( url.compare(REPORT_LADY_PATH) == 0 ) {
        /* 举报女士 */
        if ( mLSLiveChatRequestLadyControllerCallback.onReportLady != NULL ) {
            mLSLiveChatRequestLadyControllerCallback.onReportLady(requestId, bFlag, errnum, errmsg);
        }
    } else if ( url.compare(GET_FAVORITE_LIST_PATH) == 0 ) {
        /* 5.13.获取收藏女士列表 */
        list<LSLCFavoriteItem> favList;
        int totalCount = 0;
        int pageIndex = 0;
        int pageSize = 0;
        if( data[COMMON_PAGE_INDEX].isNumeric() ) {
            pageIndex = data[COMMON_PAGE_INDEX].asInt();
        }
        
        if( data[COMMON_PAGE_SIZE].isNumeric() ) {
            pageSize = data[COMMON_PAGE_SIZE].asInt();
        }
        
        if( data[COMMON_DATA_COUNT].isNumeric() ) {
            totalCount = data[COMMON_DATA_COUNT].asInt();
        }
        if( data[COMMON_DATA_LIST].isArray() ) {
            for(int i = 0; i < data[COMMON_DATA_LIST].size(); i++ ) {
                LSLCFavoriteItem item;
                item.Parse(data[COMMON_DATA_LIST].get(i, Json::Value::null));
                favList.push_back(item);
            }
        } else {
            // parsing fail
            bFlag = false;
            errnum = LOCAL_ERROR_CODE_PARSEFAIL;
            errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
        }
        
        if( mLSLiveChatRequestLadyControllerCallback.onGetFavoriteList != NULL ) {
            mLSLiveChatRequestLadyControllerCallback.onGetFavoriteList(requestId, bFlag, errnum, errmsg, favList, totalCount);
        }
    }

	FileLog("httprequest", "LSLiveChatRequestLadyController::onSuccess() url: %s, end", url.c_str());
}
void LSLiveChatRequestLadyController::onFail(long requestId, string url) {
	FileLog("httprequest", "LSLiveChatRequestLadyController::onFail( url : %s )", url.c_str());
	/* request fail, callback fail */
	if( url.compare(QUERY_LADY_MATCH_PATH) == 0 ) {
		/* 4.1.获取匹配女士条件 */
		LSLCLadyMatch item;
		if( mLSLiveChatRequestLadyControllerCallback.onQueryLadyMatch != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onQueryLadyMatch(requestId, false, item, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(SAVE_LADY_MATCH_PATH) == 0 ) {
		/* 4.2.保存匹配女士条件 */
		if( mLSLiveChatRequestLadyControllerCallback.onSaveLadyMatch != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onSaveLadyMatch(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(QUERY_LADY_LIST_PATH) == 0 ) {
		/* 4.3.条件查询女士列表 */
		list<LSLCLady> ladyList;
		if( mLSLiveChatRequestLadyControllerCallback.onQueryLadyList != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onQueryLadyList(requestId, false, ladyList, 0, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(QUERY_LADY_DETAIL_PATH) == 0 ) {
		/* 4.4.查询女士详细信息 */
		LSLCLadyDetail item;
		if( mLSLiveChatRequestLadyControllerCallback.onQueryLadyDetail != NULL ) {;
			mLSLiveChatRequestLadyControllerCallback.onQueryLadyDetail(requestId, false, item, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(ADD_FAVORITES_LADY_PATH) == 0 ) {
		/* 4.5.收藏女士 */
		if( mLSLiveChatRequestLadyControllerCallback.onAddFavouritesLady != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onAddFavouritesLady(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(REMOVE_FAVORITES_LADY_PATH) == 0 ) {
		/* 4.6.删除收藏女士 */
		if( mLSLiveChatRequestLadyControllerCallback.onRemoveFavouritesLady != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onRemoveFavouritesLady(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(QUERY_DIRECT_CALL_LADY_PATH) == 0 ) {
		/* 4.7.获取女士Direct Call TokenID */
		LSLCLadyCall item;
		if( mLSLiveChatRequestLadyControllerCallback.onQueryLadyCall != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onQueryLadyCall(requestId, false, item, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if ( url.compare(QUERY_RECENTCONTACT_PATH) == 0 ) {
		/* 4.8.获取最近联系人列表（ver3.0起） */
		if( mLSLiveChatRequestLadyControllerCallback.onRecentContact != NULL ) {
			list<LSLCLadyRecentContact> list;
			mLSLiveChatRequestLadyControllerCallback.onRecentContact(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC, list);
		}
	}else if ( url.compare(QUERY_REMOVECONTACT_PATH) == 0 ) {
        /* 4.9 删除联系人返回 3.0.3开始使用 */
        if( mLSLiveChatRequestLadyControllerCallback.onRemoveContactList != NULL ) {
            mLSLiveChatRequestLadyControllerCallback.onRemoveContactList(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
        }
    }else if ( url.compare(QUERY_SIGNLIST_PATH) == 0 ) {
		/* 4.10.查询女士标签列表（ver3.0起） */
		if( mLSLiveChatRequestLadyControllerCallback.onSignList != NULL ) {
			list<LSLCLadySignListItem> list;
			mLSLiveChatRequestLadyControllerCallback.onSignList(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC, list);
		}
	} else if ( url.compare(QUERY_UPLOADSIGN_PATH) == 0 ) {
		/* 4.10.提交女士标签（ver3.0起） */
		if( mLSLiveChatRequestLadyControllerCallback.onUploadSign != NULL ) {
			mLSLiveChatRequestLadyControllerCallback.onUploadSign(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
    } else if ( url.compare(REPORT_LADY_PATH) == 0 ) {
        /* 举报女士 */
        if ( mLSLiveChatRequestLadyControllerCallback.onReportLady != NULL ) {
            mLSLiveChatRequestLadyControllerCallback.onReportLady(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
        }
    } else if ( url.compare(GET_FAVORITE_LIST_PATH) == 0 ) {
        /* 获取收藏女士列表 */
        if ( mLSLiveChatRequestLadyControllerCallback.onGetFavoriteList != NULL ) {
            list<LSLCFavoriteItem> list;
            mLSLiveChatRequestLadyControllerCallback.onGetFavoriteList(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC, list, 0);
        }
    }

	FileLog("httprequest", "LSLiveChatRequestLadyController::onFail() url: %s, end", url.c_str());
}

/**
 * 4.1.获取匹配女士条件
 * @param callback
 * @return			请求唯一标识
 */
long LSLiveChatRequestLadyController::QueryLadyMatch() {
	HttpEntiy entiy;

	string url = QUERY_LADY_MATCH_PATH;
	FileLog("httprequest", "LSLiveChatRequestLadyController::QueryLadyMatch( url : %s )",
			url.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 4.2.保存匹配女士条件
 * @param ageRangeFrom		起始年龄
 * @param ageRangeTo		结束年龄
 * @param marry				婚姻状况
 * @param children			子女状况
 * @param education			教育程度
 * @param callback
 * @return					请求唯一标识
 */
long LSLiveChatRequestLadyController::SaveLadyMatch(int ageRangeFrom, int ageRangeTo, int marry,
		int children, int education) {
	char temp[16];

	HttpEntiy entiy;

	sprintf(temp, "%d", ageRangeFrom);
	entiy.AddContent(LADY_AGE_RANGE_FROM, temp);

	sprintf(temp, "%d", ageRangeTo);
	entiy.AddContent(LADY_AGE_RANGE_TO, temp);

	sprintf(temp, "%d", marry);
	entiy.AddContent(LADY_M_MARRY, temp);

	sprintf(temp, "%d", children);
	entiy.AddContent(LADY_M_CHILDREN, temp);

	sprintf(temp, "%d", education);
	entiy.AddContent(LADY_M_EDUCATION, temp);

	string url = SAVE_LADY_MATCH_PATH;
	FileLog("httprequest", "LSLiveChatRequestLadyController::SaveLadyMatch( "
			"url : %s, "
			"ageRangeFrom : %d, "
			"ageRangeTo : %d, "
			"marry : %d, "
			"children : %d, "
			"education : %d "
			")",
			url.c_str(),
			ageRangeFrom,
			ageRangeTo,
			marry,
			children,
			education);

	return StartRequest(url, entiy, this);
}

/**
 * 4.3.条件查询女士列表
 * @param pageIndex			当前页数
 * @param pageSize			每页行数
 * @param searchType		查询类型,参考枚举
 * @param womanId			女士ID
 * @param isOnline			是否在线
 * @param ageRangeFrom		起始年龄
 * @param ageRangeTo		结束年龄
 * @param country			国家
 * @return					请求唯一标识
 */
long LSLiveChatRequestLadyController::QueryLadyList(int pageIndex, int pageSize, int searchType, const string& womanId,
		int isOnline, int ageRangeFrom, int ageRangeTo, const string& country, int orderBy, const string& deviceId,
        LadyGenderType genderType) {
	char temp[16];

	HttpEntiy entiy;

	sprintf(temp, "%d", pageIndex);
	entiy.AddContent(COMMON_PAGE_INDEX, temp);

	sprintf(temp, "%d", pageSize);
	entiy.AddContent(COMMON_PAGE_SIZE, temp);

	sprintf(temp, "%d", searchType);
	entiy.AddContent(LADY_QUERY_TYPE, temp);

	if( womanId.length() > 0 ) {
		entiy.AddContent(LADY_WOMAN_ID, womanId.c_str());
	}

	if ( isOnline >= 0 ) {
		sprintf(temp, "%d", isOnline);
		entiy.AddContent(LADY_ISONLINE, temp);
	}

	if( ageRangeFrom >= 0 ) {
		sprintf(temp, "%d", ageRangeFrom);
		entiy.AddContent(LADY_AGE_RANGE_FROM, temp);
	}

	if( ageRangeTo >= 0 ) {
		sprintf(temp, "%d", ageRangeTo);
		entiy.AddContent(LADY_AGE_RANGE_TO, temp);
	}

	if( country.length() > 0 ) {
		entiy.AddContent(LADY_COUNTRY, country.c_str());
	}

	if( orderBy >= 0 ) {
		sprintf(temp, "%d", orderBy);
		entiy.AddContent(LADY_ORDERBY, temp);
	}

	if ( deviceId.length() > 0 ) {
		entiy.AddContent(LADY_DEVICEID, deviceId.c_str());
	}
    
    // 用于iOS假服务器
    if (genderType != LADY_GENDER_DEFAULT) {
        entiy.AddContent(LADY_GENDER, LadyGenderProtocol[genderType]);
    }

	string url = QUERY_LADY_LIST_PATH;
	FileLog("httprequest", "LSLiveChatRequestLadyController::QueryLadyList( "
			"url : %s, "
			"pageIndex : %d, "
			"pageSize : %d, "
			"searchType : %d, "
			"womanId : %s, "
			"isOnline : %d, "
			"ageRangeFrom : %d, "
			"ageRangeTo : %d, "
			"country : %s "
			"orderBy : %d "
			"deviceId : %s "
            "genderType : %d"
			")",
			url.c_str(),
			pageIndex,
			pageSize,
			searchType,
			womanId.c_str(),
			isOnline,
			ageRangeFrom,
			ageRangeTo,
			country.c_str(),
			orderBy,
			deviceId.c_str(),
            genderType);

	return StartRequest(url, entiy, this);
}

/**
 * 4.4.查询女士详细信息
 * @param womanId			女士ID
 * @return					请求唯一标识
 */
long LSLiveChatRequestLadyController::QueryLadyDetail(string womanId) {
	HttpEntiy entiy;

	if( womanId.length() > 0 ) {
		entiy.AddContent(LADY_WOMAN_ID, womanId);
	}

	string url = QUERY_LADY_DETAIL_PATH;
	FileLog("httprequest", "LSLiveChatRequestLadyController::QueryLadyDetail( "
			"url : %s, "
			"womanId : %s "
			")",
			url.c_str(),
			womanId.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 4.5.收藏女士
 * @param womanId			女士ID
 * @return					请求唯一标识
 */
long LSLiveChatRequestLadyController::AddFavouritesLady(string womanId) {
	HttpEntiy entiy;

	if( womanId.length() > 0 ) {
		entiy.AddContent(LADY_WOMAN_ID, womanId);
	}

	string url = ADD_FAVORITES_LADY_PATH;
	FileLog("httprequest", "LSLiveChatRequestLadyController::AddFavouritesLady( "
			"url : %s, "
			"womanId : %s, "
			")",
			url.c_str(),
			womanId.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 4.6.删除收藏女士
 * @param womanId			女士ID
 * @return					请求唯一标识
 */
long LSLiveChatRequestLadyController::RemoveFavouritesLady(string womanId) {
	HttpEntiy entiy;

	if( womanId.length() > 0 ) {
		entiy.AddContent(LADY_WOMAN_ID, womanId);
	}

	string url = REMOVE_FAVORITES_LADY_PATH;
	FileLog("httprequest", "LSLiveChatRequestLadyController::RemoveFavouritesLady( "
			"url : %s, "
			"womanId : %s, "
			")",
			url.c_str(),
			womanId.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 4.7.获取女士Direct Call TokenID
 * @param womanId			女士ID
 * @return					请求唯一标识
 */
long LSLiveChatRequestLadyController::QueryLadyCall(string womanId) {
	HttpEntiy entiy;

	if( womanId.length() > 0 ) {
		entiy.AddContent(LADY_WOMAN_ID, womanId);
	}

	string url = QUERY_DIRECT_CALL_LADY_PATH;
	FileLog("httprequest", "LSLiveChatRequestLadyController::QueryLadyCall( "
			"url : %s, "
			"womanId : %s, "
			")",
			url.c_str(),
			womanId.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 获取最近联系人列表（ver3.0起）
 * @return					请求唯一标识
 */
long LSLiveChatRequestLadyController::RecentContactList()
{
	HttpEntiy entiy;

	string url = QUERY_RECENTCONTACT_PATH;
	FileLog("httprequest", "LSLiveChatRequestLadyController::RecentContactList( "
			"url : %s, "
			")",
			url.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 删除最近联系人（ver3.0.3起）
 * @param womanListId	被删除的女士Id列表
 * @return				请求唯一标识
 */
long LSLiveChatRequestLadyController::RemoveContactList(list<string> womanListId) {

	HttpEntiy entiy;

	string womanId = "";
	for(list<string>::iterator itr = womanListId.begin(); itr != womanListId.end(); itr++) {
		womanId += *itr;
		womanId += ",";
	}
	if( womanId.length() > 0 ) {
		womanId = womanId.substr(0, womanId.length() - 1);
		entiy.AddContent(REMOVE_CONTACT_WOMANID, womanId);
	}

	string url = QUERY_REMOVECONTACT_PATH;
	FileLog("httprequest", "LSLiveChatRequestLadyController::RemoveContactList( "
			"url : %s, "
			"womanId : %s "
			")",
			url.c_str(),
			womanId.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 查询女士标签列表（ver3.0起）
 * @param womanId			女士ID
 * @return					请求唯一标识
 */
long LSLiveChatRequestLadyController::QuerySignList(const string& womanId)
{
	HttpEntiy entiy;

	if( !womanId.empty() ) {
		entiy.AddContent(LADY_WOMAN_ID, womanId);
	}

	string url = QUERY_SIGNLIST_PATH;
	FileLog("httprequest", "LSLiveChatRequestLadyController::QuerySignList( "
			"url : %s, "
			"womanId : %s, "
			")",
			url.c_str(),
			womanId.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 提交女士标签（ver3.0起）
 * @param womanId			女士ID
 * @param signIds			选中的标签列表
 * @return					请求唯一标识
 */
long LSLiveChatRequestLadyController::UploadSigned(const string& womanId, const list<string> signIds)
{
	HttpEntiy entiy;

	if( !womanId.empty() ) {
		entiy.AddContent(LADY_WOMAN_ID, womanId);
	}

	string strSignIds("");
	list<string>::const_iterator iter;
	for (iter = signIds.begin(); iter != signIds.end(); iter++) {
		if (!strSignIds.empty()) {
			strSignIds += ",";
		}
		strSignIds += (*iter);
	}
	entiy.AddContent(LADY_SIGNID, strSignIds);

	string url = QUERY_UPLOADSIGN_PATH;
	FileLog("httprequest", "LSLiveChatRequestLadyController::UploadSigned( "
			"url : %s, "
			"womanId : %s, "
			"signId : %s, "
			")",
			url.c_str(),
			womanId.c_str(),
			strSignIds.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 *  举报女士
 *  @param womanId          女士ID
 *  @return                 请求唯一标识
 */
long LSLiveChatRequestLadyController::ReportLady(const string& womanId)
{
    HttpEntiy entiy;
    
    if( !womanId.empty() ) {
        entiy.AddContent(LADY_WOMAN_ID, womanId);
    }
    
    string url = REPORT_LADY_PATH;
    FileLog("httprequest", "LSLiveChatRequestLadyController::ReportLady( "
            "url : %s, "
            "womanId : %s"
            ")",
            url.c_str(),
            womanId.c_str()
            );
    
    return StartRequest(url, entiy, this);
}

long LSLiveChatRequestLadyController::GetFavoriteList(int pageIndex, int pageSize, const string& womanId, FindLadyOnLineType onLine) {
    char temp[16];
    
    HttpEntiy entiy;
    
    sprintf(temp, "%d", pageIndex);
    entiy.AddContent(COMMON_PAGE_INDEX, temp);
    
    sprintf(temp, "%d", pageSize);
    entiy.AddContent(COMMON_PAGE_SIZE, temp);

    if( womanId.length() > 0 ) {
        entiy.AddContent(FAVORITE_WOMANID, womanId);
    }
    
    if (onLine >= FINDLADYONLINETYPE_NOLIMIT && onLine <= FINDLADYONLINETYPE_Online) {
        sprintf(temp, "%d", onLine);
        entiy.AddContent(FAVORITE_ONLINE, temp);
    }
    
    string url = GET_FAVORITE_LIST_PATH;
    FileLog("httprequest", "LSLiveChatRequestLadyController::GetFavoriteList( "
            "url : %s, "
            "pageIndex : %d, "
            "pageSize : %d, "
            ")",
            url.c_str(),
            pageIndex,
            pageSize);
    
    return StartRequest(url, entiy, this);
}
