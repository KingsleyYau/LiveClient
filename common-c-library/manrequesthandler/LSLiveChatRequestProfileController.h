/*
 * LSLiveChatRequestProfileController.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTPROFILECONTROLLER_H_
#define LSLIVECHATREQUESTPROFILECONTROLLER_H_

#include "LSLiveChatRequestBaseController.h"

#include <list>
using namespace std;

#include <json/json/json.h>

#include "LSLiveChatRequestProfileDefine.h"

#include "item/LSLCProfileItem.h"

typedef void (*OnGetMyProfile)(long requestId, bool success, LSLCProfileItem item, string errnum, string errmsg);
typedef void (*OnUpdateMyProfile)(long requestId, bool success, bool rsModified, string errnum, string errmsg);
typedef void (*OnStartEditResume)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnSaveContact)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnUploadHeaderPhoto)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnActivateEmail)(long requestId, bool success, string errnum, string errmsg);

typedef struct LSLiveChatRequestProfileControllerCallback {
	OnGetMyProfile onGetMyProfile;
	OnUpdateMyProfile onUpdateMyProfile;
	OnStartEditResume onStartEditResume;
	OnSaveContact onSaveContact;
	OnUploadHeaderPhoto	onUploadHeaderPhoto;
    OnActivateEmail     onActivateEmail;
} LSLiveChatRequestProfileControllerCallback;

class LSLiveChatRequestProfileController : public LSLiveChatRequestBaseController, public ILSLiveChatHttpRequestManagerCallback {
public:
	LSLiveChatRequestProfileController(LSLiveChatHttpRequestManager* pHttpRequestManager, LSLiveChatRequestProfileControllerCallback callback/*, CallbackManager* pCallbackManager*/);
	virtual ~LSLiveChatRequestProfileController();

	/**
	 * 2.1.查询个人信息
	 * @return				请求唯一标识
	 */
	long GetMyProfile();

	/**
	 * 2.2.修改个人信息
	 * @param weight		体重
	 * @param height		身高
	 * @param language		语言
	 * @param ethnicity		人种
	 * @param religion		宗教
	 * @param education		教育程度
	 * @param profession	职业
	 * @param income		收入情况
	 * @param children		子女状况
	 * @param smoke			吸烟情况
	 * @param drink			喝酒情况
	 * @param resume		个人简介
	 * @param interests		兴趣爱好
	 * @return				请求唯一标识
	 */
	long UpdateProfile(int weight, int height, int language, int ethnicity, int religion,
			int education, int profession, int income, int children, int smoke, int drink,
			string resume, list<string> interests, int zodiac);

	/**
	 * 2.3.开始编辑简介触发计时
	 * @return				请求唯一标识
	 */
	long StartEditResume();

	/**
	 * 2.4.保存联系电话
	 * @param telephone			电话号码
	 * @param telephone_cc		国家区号,参考枚举 <RequestEnum.Country>
	 * @param landline			固定电话号码
	 * @param landline_cc		固定电话号码国家区号,参考枚举 <RequestEnum.Country>
	 * @param landline_ac		固话区号
	 * @return					请求唯一标识
	 */
	long SaveContact(string telephone, int telephone_cc, string landline, int landline_cc,
			string landline_ac);

	/**
	 * 2.5.上传头像
	 * @param fileName			文件名
	 * @return					请求唯一标识
	 */
	long UploadHeaderPhoto(string fileName);
    
    /**
     * 3.6.邮箱验证
     * @param handleType         处理方式（SendChangeEmail：更改邮箱并发送验证邮件， ReSend：重新发送验证邮件）
     * @param newEmail           可无（do ＝ SendChandeEmail时需填写）
     * @return                   请求唯一标识
     */
    long ActivateEmail(int handleType, string newEmail);

protected:
	void onSuccess(long requestId, string path, const char* buf, int size);
	void onFail(long requestId, string path);

private:
	LSLiveChatRequestProfileControllerCallback mLSLiveChatRequestProfileControllerCallback;
};

#endif /* LSLIVECHATREQUESTPROFILECONTROLLER_H_ */
