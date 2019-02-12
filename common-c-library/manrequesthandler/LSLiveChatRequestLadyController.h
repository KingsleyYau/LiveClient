/*
 * LSLiveChatRequestLadyController.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTLADYCONTROLLER_H_
#define LSLIVECHATREQUESTLADYCONTROLLER_H_

#include "LSLiveChatRequestBaseController.h"

#include <list>
using namespace std;

#include "LSLiveChatRequestLadyDefine.h"

#include "item/LSLCLadyMatch.h"
#include "item/LSLCLady.h"
#include "item/LSLCLadyDetail.h"
#include "item/LSLCLadyCall.h"
#include "item/LSLCLadyRecentContact.h"
#include "item/LSLCLadySignListItem.h"
#include "item/LSLCFavoriteItem.h"

#include <json/json/json.h>

typedef void (*OnQueryLadyMatch)(long requestId, bool success, LSLCLadyMatch item, string errnum, string errmsg);
typedef void (*OnSaveLadyMatch)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnQueryLadyList)(long requestId, bool success, list<LSLCLady> ladyList, int totalCount, string errnum, string errmsg);
typedef void (*OnQueryLadyDetail)(long requestId, bool success, LSLCLadyDetail item, string errnum, string errmsg);
typedef void (*OnAddFavouritesLady)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnRemoveFavouritesLady)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnQueryLadyCall)(long requestId, bool success, LSLCLadyCall item, string errnum, string errmsg);
typedef void (*OnRecentContact)(long requestId, bool success, const string& errnum, const string& errmsg, const list<LSLCLadyRecentContact>& list);
typedef void (*OnRemoveContactList)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnSignList)(long requestId, bool success, const string& errnum, const string& errmsg, const list<LSLCLadySignListItem>& list);
typedef void (*OnUploadSign)(long requestId, bool success, const string& errnum, const string& errmsg);
typedef void (*OnReportLady)(long requestId, bool success, const string& errnum, const string& errmsg);
typedef void (*OnGetFavoriteList)(long requestId, bool success, const string& errnum, const string& errmsg, list<LSLCFavoriteItem>& favList, int totalCount);
typedef struct LSLiveChatRequestLadyControllerCallback {
	OnQueryLadyMatch onQueryLadyMatch;
	OnSaveLadyMatch onSaveLadyMatch;
	OnQueryLadyList onQueryLadyList;
	OnQueryLadyDetail onQueryLadyDetail;
	OnAddFavouritesLady onAddFavouritesLady;
	OnRemoveFavouritesLady onRemoveFavouritesLady;
	OnQueryLadyCall onQueryLadyCall;
	OnRecentContact onRecentContact;
	OnRemoveContactList onRemoveContactList;
	OnSignList onSignList;
	OnUploadSign onUploadSign;
    OnReportLady onReportLady;
    OnGetFavoriteList onGetFavoriteList;
} LSLiveChatRequestLadyControllerCallback;


class LSLiveChatRequestLadyController : public LSLiveChatRequestBaseController, public ILSLiveChatHttpRequestManagerCallback {
public:
	LSLiveChatRequestLadyController(LSLiveChatHttpRequestManager* pHttpRequestManager, LSLiveChatRequestLadyControllerCallback callback/*, CallbackManager* pCallbackManager*/);
	virtual ~LSLiveChatRequestLadyController();

	/**
	 * 4.1.获取匹配女士条件
	 * @return			请求唯一标识
	 */
	long QueryLadyMatch();

	/**
	 * 4.2.保存匹配女士条件
	 * @param ageRangeFrom		起始年龄
	 * @param ageRangeTo		结束年龄
	 * @param marry				婚姻状况
	 * @param children			子女状况
	 * @param education			教育程度
	 * @return					请求唯一标识
	 */
	long SaveLadyMatch(int ageRangeFrom, int ageRangeTo, int children, int marry, int education);

    /**
     * 4.3.条件查询女士列表
     * @param pageIndex			当前页数
     * @param pageSize			每页行数
     * @param searchType		查询类型
     * @param womanId			女士ID(长度等于0：默认)
     * @param isOnline			是否在线(-1：默认，0：否，1：是)
     * @param ageRangeFrom		起始年龄(小于0：默认)
     * @param ageRangeTo		结束年龄(小于0：默认)
     * @param country			国家(长度等于0：默认)
     * @param orderBy			排序规则(-1：默认，0：最新加入，1：年龄升序，2：年龄降序)
     * @param deviceId			设备唯一标识
     * @param gender            性别(用于iOS假服务器)
     * @return					请求唯一标识
     */
	long QueryLadyList(int pageIndex, int pageSize, int searchType, const string& womanId,
			int isOnline, int ageRangeFrom, int ageRangeTo, const string& country, int orderBy,
            const string& deviceId, LadyGenderType genderType = LADY_GENDER_DEFAULT);

    /**
     * 4.4.查询女士详细信息
     * @param womanId			女士ID
     * @return					请求唯一标识
     */
    long QueryLadyDetail(string womanId);

    /**
     * 4.5.收藏女士
     * @param womanId			女士ID
     * @return					请求唯一标识
     */
    long AddFavouritesLady(string womanId);

    /**
     * 4.6.删除收藏女士
     * @param womanId			女士ID
     * @return					请求唯一标识
     */
    long RemoveFavouritesLady(string womanId);

    /**
     * 4.7.获取女士Direct Call TokenID
     * @param womanId			女士ID
     * @return					请求唯一标识
     */
    long QueryLadyCall(string womanId);

    /**
	 * 获取最近联系人列表（ver3.0起）
	 * @return					请求唯一标识
	 */
    long RecentContactList();

    /**
	 * 删除联系人列表（ver3.0.3起）
	 * @return					请求唯一标识
	 */
    long RemoveContactList(list<string> womanIds);

    /**
	 * 查询女士标签列表（ver3.0起）
	 * @param womanId			女士ID
	 * @return					请求唯一标识
	 */
    long QuerySignList(const string& womanId);

    /**
	 * 提交女士标签（ver3.0起）
	 * @param womanId			女士ID
	 * @param signIds			选中的标签列表
	 * @return					请求唯一标识
	 */
    long UploadSigned(const string& womanId, const list<string> signIds);
    
    /**
     *  举报女士
     *  @param womanId          女士ID
     *  @return                 请求唯一标识
     */
    long ReportLady(const string& womanId);
    
    /**
     * 5.13.获取收藏女士列表
     * @param pageIndex            当前页数
     * @param pageSize             每页行数
     * @param womanId              女士ID
     * @param onLine               在线状态
     * @return                    请求唯一标识
     */
    long GetFavoriteList(int pageIndex, int pageSize, const string& womanId, FindLadyOnLineType onLine);

protected:
	void onSuccess(long requestId, string path, const char* buf, int size);
	void onFail(long requestId, string path);

private:
	LSLiveChatRequestLadyControllerCallback mLSLiveChatRequestLadyControllerCallback;
};

#endif /* LSLIVECHATREQUESTLADYCONTROLLER_H_ */
