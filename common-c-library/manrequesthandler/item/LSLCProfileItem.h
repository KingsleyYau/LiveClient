/*
 * LSLCProfileItem.h
 *
 *  Created on: 2015-3-6
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCPROFILEITEM_H_
#define LSLCPROFILEITEM_H_

#include <string>
#include <list>
using namespace std;

#include <json/json/json.h>

#include "../LSLiveChatRequestProfileDefine.h"

#include "../LSLiveChatRequestEnumDefine.h"

class LSLCProfileItem {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
			if( root[PROFILE_MANID].isString() ) {
				manid = root[PROFILE_MANID].asString();
			}

			if( root[PROFILE_AGE].isInt() ) {
				age = root[PROFILE_AGE].asInt();
			}

			if( root[PROFILE_BIRTHDAY].isString() ) {
				birthday = root[PROFILE_BIRTHDAY].asString();
			}

			if( root[PROFILE_FIRSTNAME].isString() ) {
				firstname = root[PROFILE_FIRSTNAME].asString();
			}

			if( root[PROFILE_LASTNAME].isString() ) {
				lastname = root[PROFILE_LASTNAME].asString();
			}

			if( root[PROFILE_EMAIL].isString() ) {
				email = root[PROFILE_EMAIL].asString();
			}

			/* 单选项目  */
			if( root[PROFILE_GENDER].isString() ) {
				if( root[PROFILE_GENDER].asString() == "M" ) {
					gender = 0;
				} else {
					gender = 1;
				}
			}

			if( root[PROFILE_COUNTRY].isString() ) {
				string strCountry = root[PROFILE_COUNTRY].asString();
				country = GetCountryCode(strCountry);
			}

			if( root[PROFILE_MARRY].isString() ) {
				marry = atoi(root[PROFILE_MARRY].asString().c_str());
			}

			if( root[PROFILE_HEIGHT].isString() ) {
				height = HeightToCode(atoi(root[PROFILE_HEIGHT].asString().c_str()));
			}

			if( root[PROFILE_WEIGHT].isString() ) {
				weight = WeightToCode(atoi(root[PROFILE_WEIGHT].asString().c_str()));
			}

			if( root[PROFILE_SMOKE].isString() ) {
				smoke = atoi(root[PROFILE_SMOKE].asString().c_str());
			}

			if( root[PROFILE_DRINK].isString() ) {
				drink = atoi(root[PROFILE_DRINK].asString().c_str());
			}

			if( root[PROFILE_LANGUAGE].isString() ) {
				language = atoi(root[PROFILE_LANGUAGE].asString().c_str());
			}

			if( root[PROFILE_RELIGION].isString() ) {
				religion = atoi(root[PROFILE_RELIGION].asString().c_str());
			}

			if( root[PROFILE_EDUCATION].isString() ) {
				education = atoi(root[PROFILE_EDUCATION].asString().c_str());
			}

			if( root[PROFILE_PROFESSION].isString() ) {
				profession = atoi(root[PROFILE_PROFESSION].asString().c_str());
			}

			if( root[PROFILE_ETHNICITY].isString() ) {
				ethnicity = EthnicityToCode(atoi(root[PROFILE_ETHNICITY].asString().c_str()));
			}

			if( root[PROFILE_INCOME].isString() ) {
				income = atoi(root[PROFILE_INCOME].asString().c_str());
			}

			if( root[PROFILE_CHILDREN].isString() ) {
				children = atoi(root[PROFILE_CHILDREN].asString().c_str());
			}

			/* 简介 */
			if( root[PROFILE_JJ].isString() ) {
				resume = root[PROFILE_JJ].asString();
			}

			if( root[PROFILE_RS_CONTENT].isString() ) {
				resume_content = root[PROFILE_RS_CONTENT].asString();
			}

			if( root[PROFILE_RS_STATUS].isString() ) {
				resume_status = atoi(root[PROFILE_RS_STATUS].asString().c_str());
			}


			if( root[PROFILE_ADDRESS1].isString() ) {
				address1 = root[PROFILE_ADDRESS1].asString();
			}

			if( root[PROFILE_ADDRESS2].isString() ) {
				address2 = root[PROFILE_ADDRESS2].asString();
			}

			if( root[PROFILE_CITY].isString() ) {
				city = root[PROFILE_CITY].asString();
			}

			if( root[PROFILE_PROVINCE].isString() ) {
				province = root[PROFILE_PROVINCE].asString();
			}

			if( root[PROFILE_ZIPCODE].isString() ) {
				zipcode = root[PROFILE_ZIPCODE].asString();
			}

			if( root[PROFILE_TELEPHONE].isString() ) {
				telephone = root[PROFILE_TELEPHONE].asString();
			}

			if( root[PROFILE_FAX].isString() ) {
				fax = root[PROFILE_FAX].asString();
			}

			if( root[PROFILE_ALTERNATE_EMAIL].isString() ) {
				alternate_email = root[PROFILE_ALTERNATE_EMAIL].asString();
			}

			if( root[PROFILE_MONEY].isString() ) {
				money = root[PROFILE_MONEY].asString();
			}

			/* 头像 */
			if( root[PROFILE_V_ID].isInt() ) {
				v_id = root[PROFILE_V_ID].asInt();
			}

			if( root[PROFILE_PHOTO].isString() ) {
				photo = atoi(root[PROFILE_PHOTO].asString().c_str());
			}

			if( root[PROFILE_PHOTOURL].isString() ) {
				photoURL = root[PROFILE_PHOTOURL].asString();
			}

			if( root[PROFILE_INTEGRAL].isString() ) {
				integral = atoi(root[PROFILE_INTEGRAL].asString().c_str());
			}

			/* 手机 */
			if( root[PROFILE_MOBILE].isString() ) {
				mobile = root[PROFILE_MOBILE].asString();
			}

			if( root[PROFILE_MOBILE_CC].isString() ) {
				mobile_cc = GetCountryCode(root[PROFILE_MOBILE_CC].asString());
			}

			if( root[PROFILE_MOBILE_STATUS].isString() ) {
				mobile_status = atoi(root[PROFILE_MOBILE_STATUS].asString().c_str());
			}

			/* 固话 */
			if( root[PROFILE_LANDLINE].isString() ) {
				landline = root[PROFILE_LANDLINE].asString();
			}

			if( root[PROFILE_LANDLINE_CC].isString() ) {
				landline_cc = GetCountryCode(root[PROFILE_LANDLINE_CC].asString());
			}

			if( root[PROFILE_LANDLINE_AC].isString() ) {
				landline_ac = root[PROFILE_LANDLINE_AC].asString();
			}

			if( root[PROFILE_LANDLINE_STATUS].isString() ) {
				landline_status = atoi(root[PROFILE_LANDLINE_STATUS].asString().c_str());
			}

			if( root[PROFILE_INTERESTS].isString() ) {
				string interestString = root[PROFILE_INTERESTS].asString();
				string interest = "";
				std::size_t index = 0, next;

				// 最后增加一个分割符号，方便统一处理
				interestString.append(",");
				next = interestString.find(",");

				while( next != string::npos ) {
					// 找到分割符号
					interest = interestString.substr(index, next - index);
					interests.push_back(interest);
					index = next + 1;

					if( index < interestString.length() - 1 ) {
						// 寻找下一个
						next = interestString.find(",", index);
					} else {
						break;
					}
				}
			}
            
            if( root[PROFILE_ZODIAC].isString() ) {
                zodiac = atoi(root[PROFILE_ZODIAC].asString().c_str());
            }
        }
	}

	LSLCProfileItem() {
		manid = "";
		age = 0;
		birthday = "";
		firstname = "";
		lastname = "";
		email = "";

		gender = 0;
		country = GetOtherCountryCode();
		marry = 0;
		height = 0;
		weight = 0;
		smoke = 0;
		drink = 0;
		language = 0;
		religion = 0;
		education = 0;
		profession = 0;
		ethnicity = 0;
		income= 0 ;
		children = 0;

		resume = "";
		resume_content = "";
		resume_status = 0;

		address1 = "";
		address2 = "";
		city = "";
		province = "";
		zipcode = "";
		telephone = "";
		fax = "";
		alternate_email = "";
		money = "";

		v_id = 0;
		photo = 0;
		photoURL = "";
		integral = 0;

		mobile = "";
		mobile_cc = 0;
		mobile_status = 0;

		landline = "";
		landline_cc = 0;
		landline_ac = "";
		landline_status = 0;
        
        zodiac = 0;
	}
	virtual ~LSLCProfileItem() {

	}

	/**
	 * 获取个人信息回调
	 * @param manid				男士ID
	 * @param age				年龄
	 * @param birthday			出生日期
	 * @param firstname			男士first name
	 * @param lastname			男士last name
	 * @param gender			性别
	 * @param email				电子邮箱
	 * @param country			国家，参考枚举 <RequestEnum.Country>
	 * @param marry				婚姻状况
	 * @param height			身高
	 * @param weight			体重
	 * @param smoke				吸烟情况
	 * @param drink				喝酒情况
	 * @param language			语言
	 * @param religion			宗教
	 * @param education			教育程度
	 * @param profession		职业
	 * @param ethnicity			人种
	 * @param income			收入情况
	 * @param children			子女状况
	 * @param rs				个人描述
	 * @param rs_content		个人描述审核状态
	 * @param rs_status			审核中的个人描述
	 * @param address1			地址1
	 * @param address2			地址2
	 * @param city				城市
	 * @param province			省份
	 * @param zipcode			邮政编码
	 * @param telephone			电话
	 * @param fax				传真
	 * @param alternate_email	备用邮箱
	 * @param money				余额
	 * @param v_id				身份认证状态(0=未上传,1=待审核,2=未通过,3=通过)
	 * @param photo				男士相片状态标识
	 * @param photoURL			男士相片URL
	 * @param integral			剩余积分
	 * @param mobile			手机号码
	 * @param mobile_cc			手机国家区号，参考枚举 <RequestEnum.Country>
	 * @param mobile_status		手机审核状态
	 * @param landline			固话号码
	 * @param landline_cc		固话国家区号，参考枚举 <RequestEnum.Country>
	 * @param landline_ac		固话区号
	 * @param landline_status	固话审核状态
	 * @param interests			兴趣爱好
     * @param zodiac            星座
	 */

	string manid;
	int age;
	string birthday;
	string firstname;
	string lastname;
	string email;

	int gender;
	int country;
	int marry;
	int height;
	int weight;
	int smoke;
	int drink;
	int language;
	int religion;
	int education;
	int profession;
	int ethnicity;
	int income;
	int children;

	string resume;
	string resume_content;
	int resume_status;

	string address1;
	string address2;
	string city;
	string province;
	string zipcode;
	string telephone;
	string fax;
	string alternate_email;
	string money;

	int v_id;
	int photo;
	string photoURL;
	int integral;

	string mobile;
	int mobile_cc;
	int mobile_status;

	string landline;
	int landline_cc;
	string landline_ac;
	int landline_status;

	list<string> interests;
                
    int zodiac;
};

#endif /* LSLCPROFILEITEM_H_ */
