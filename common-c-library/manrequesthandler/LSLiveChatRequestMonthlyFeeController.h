/*
 * LSLiveChatRequestMonthlyFeeController.h
 *
 *  Created on: 2016-5-10
 *      Author: Hunter
 */

#ifndef LSLIVECHATREQUESTMONTHLYFEECONTROLLER_H_
#define LSLIVECHATREQUESTMONTHLYFEECONTROLLER_H_

#include "LSLiveChatRequestBaseController.h"

#include <list>
using namespace std;

#include "LSLiveChatRequestMonthlyFeeDefine.h"

#include "item/LSLCMonthlyFeeTip.h"

#include "item/LSLCMonthlyFeeInstructionItem.h"

#include <json/json/json.h>

typedef void (*OnQueryMemberType)(long requestId, bool success, string errnum, string errmsg, int memberType, string mfeeEndDate);
typedef void (*OnGetMonthlyFeeTips)(long requestId, bool success, string errnum, string errmsg, list<LSLCMonthlyFeeTip> tipsList);
typedef void (*OnGetPremiumMemberShip)(long requestId, bool success, string errnum, string errmsg, LSLCMonthlyFeeInstructionItem memberShip);
typedef struct LSLiveChatRequestMonthlyFeeControllerCallback {
	OnQueryMemberType onQueryMemberType;
	OnGetMonthlyFeeTips onGetMonthlyFeeTips;
    OnGetPremiumMemberShip onGetPremiumMemberShip;
} LSLiveChatRequestMonthlyFeeControllerCallback;


class LSLiveChatRequestMonthlyFeeController : public LSLiveChatRequestBaseController, public ILSLiveChatHttpRequestManagerCallback {
public:
	LSLiveChatRequestMonthlyFeeController(LSLiveChatHttpRequestManager* pHttpRequestManager, LSLiveChatRequestMonthlyFeeControllerCallback callback/*, CallbackManager* pCallbackManager*/);
	virtual ~LSLiveChatRequestMonthlyFeeController();

    /**
     * 13.1.获取月费会员类型
     * @return					请求唯一标识
     */
	long QueryMemberType();

    /**
     * 13.2.获取月费提示层数据
     * @return					请求唯一标识
     */
	long GetMonthlyFeeTips();
    
    /**
     * 6.2.获取买点送月费的文字说明
     * @return					请求唯一标识
     */
    long GetPremiumMemberShip();
    

protected:
	void onSuccess(long requestId, string path, const char* buf, int size);
	void onFail(long requestId, string path);

private:
	LSLiveChatRequestMonthlyFeeControllerCallback mLSLiveChatRequestMonthlyFeeControllerCallback;
};

#endif /* LSLIVECHATREQUESTMONTHLYFEECONTROLLER_H_ */
