/*
 * HttpProfileItem.h
 *
 *  Created on: 2015-3-6
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPPROFILEITEM_H_
#define HTTPPROFILEITEM_H_

#include <string>
#include <list>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"
#include "../HttpRequestConvertEnum.h"

class HttpProfileItem {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
			if( root[LIVEROOM_MYPROFILE_MANID].isString() ) {
				manid = root[LIVEROOM_MYPROFILE_MANID].asString();
			}

			if( root[LIVEROOM_MYPROFILE_AGE].isInt() ) {
				age = root[LIVEROOM_MYPROFILE_AGE].asInt();
			}

			if( root[LIVEROOM_MYPROFILE_BIRTHDAY].isString() ) {
				birthday = root[LIVEROOM_MYPROFILE_BIRTHDAY].asString();
			}

			if( root[LIVEROOM_MYPROFILE_FIRSTNAME].isString() ) {
				firstname = root[LIVEROOM_MYPROFILE_FIRSTNAME].asString();
			}

			if( root[LIVEROOM_MYPROFILE_LASTNAME].isString() ) {
				lastname = root[LIVEROOM_MYPROFILE_LASTNAME].asString();
			}

			if( root[LIVEROOM_MYPROFILE_EMAIL].isString() ) {
				email = root[LIVEROOM_MYPROFILE_EMAIL].asString();
			}

			/* 单选项目  */
			if( root[LIVEROOM_MYPROFILE_GENDER].isString() ) {
				if( root[LIVEROOM_MYPROFILE_GENDER].asString() == "M" ) {
					gender = 0;
				} else {
					gender = 1;
				}
			}

			if( root[LIVEROOM_MYPROFILE_COUNTRY].isString() ) {
				string strCountry = root[LIVEROOM_MYPROFILE_COUNTRY].asString();
				country = GetCountryCode(strCountry);
			}

			if( root[LIVEROOM_MYPROFILE_MARRY].isString() ) {
				marry = atoi(root[LIVEROOM_MYPROFILE_MARRY].asString().c_str());
			}

			if( root[LIVEROOM_MYPROFILE_HEIGHT].isString() ) {
				height = HeightToCode(atoi(root[LIVEROOM_MYPROFILE_HEIGHT].asString().c_str()));
			}

			if( root[LIVEROOM_MYPROFILE_WEIGHT].isString() ) {
				weight = WeightToCode(atoi(root[LIVEROOM_MYPROFILE_WEIGHT].asString().c_str()));
			}

			if( root[LIVEROOM_MYPROFILE_SMOKE].isString() ) {
				smoke = atoi(root[LIVEROOM_MYPROFILE_SMOKE].asString().c_str());
			}

			if( root[LIVEROOM_MYPROFILE_DRINK].isString() ) {
				drink = atoi(root[LIVEROOM_MYPROFILE_DRINK].asString().c_str());
			}

			if( root[LIVEROOM_MYPROFILE_LANGUAGE].isString() ) {
				language = atoi(root[LIVEROOM_MYPROFILE_LANGUAGE].asString().c_str());
			}

			if( root[LIVEROOM_MYPROFILE_RELIGION].isString() ) {
				religion = atoi(root[LIVEROOM_MYPROFILE_RELIGION].asString().c_str());
			}

			if( root[LIVEROOM_MYPROFILE_EDUCATION].isString() ) {
				education = atoi(root[LIVEROOM_MYPROFILE_EDUCATION].asString().c_str());
			}

			if( root[LIVEROOM_MYPROFILE_PROFESSION].isString() ) {
				profession = atoi(root[LIVEROOM_MYPROFILE_PROFESSION].asString().c_str());
			}

			if( root[LIVEROOM_MYPROFILE_ETHNICITY].isString() ) {
				ethnicity = EthnicityToCode(atoi(root[LIVEROOM_MYPROFILE_ETHNICITY].asString().c_str()));
			}

			if( root[LIVEROOM_MYPROFILE_INCOME].isString() ) {
				income = atoi(root[LIVEROOM_MYPROFILE_INCOME].asString().c_str());
			}

			if( root[LIVEROOM_MYPROFILE_CHILDREN].isString() ) {
				children = atoi(root[LIVEROOM_MYPROFILE_CHILDREN].asString().c_str());
			}

			/* 简介 */
			if( root[LIVEROOM_MYPROFILE_JJ].isString() ) {
				resume = root[LIVEROOM_MYPROFILE_JJ].asString();
			}

			if( root[LIVEROOM_MYPROFILE_RS_CONTENT].isString() ) {
				resume_content = root[LIVEROOM_MYPROFILE_RS_CONTENT].asString();
			}

			if( root[LIVEROOM_MYPROFILE_RS_STATUS].isString() ) {
				resume_status = atoi(root[LIVEROOM_MYPROFILE_RS_STATUS].asString().c_str());
			}


			if( root[LIVEROOM_MYPROFILE_ADDRESS1].isString() ) {
				address1 = root[LIVEROOM_MYPROFILE_ADDRESS1].asString();
			}

			if( root[LIVEROOM_MYPROFILE_ADDRESS2].isString() ) {
				address2 = root[LIVEROOM_MYPROFILE_ADDRESS2].asString();
			}

			if( root[LIVEROOM_MYPROFILE_CITY].isString() ) {
				city = root[LIVEROOM_MYPROFILE_CITY].asString();
			}

			if( root[LIVEROOM_MYPROFILE_PROVINCE].isString() ) {
				province = root[LIVEROOM_MYPROFILE_PROVINCE].asString();
			}

			if( root[LIVEROOM_MYPROFILE_ZIPCODE].isString() ) {
				zipcode = root[LIVEROOM_MYPROFILE_ZIPCODE].asString();
			}

			if( root[LIVEROOM_MYPROFILE_TELEPHONE].isString() ) {
				telephone = root[LIVEROOM_MYPROFILE_TELEPHONE].asString();
			}

			if( root[LIVEROOM_MYPROFILE_FAX].isString() ) {
				fax = root[LIVEROOM_MYPROFILE_FAX].asString();
			}

			if( root[LIVEROOM_MYPROFILE_ALTERNATE_EMAIL].isString() ) {
				alternate_email = root[LIVEROOM_MYPROFILE_ALTERNATE_EMAIL].asString();
			}

			if( root[LIVEROOM_MYPROFILE_MONEY].isString() ) {
				money = root[LIVEROOM_MYPROFILE_MONEY].asString();
			}

			/* 头像 */
			if( root[LIVEROOM_MYPROFILE_V_ID].isInt() ) {
				v_id = root[LIVEROOM_MYPROFILE_V_ID].asInt();
			}

			if( root[LIVEROOM_MYPROFILE_PHOTO].isString() ) {
				photo = atoi(root[LIVEROOM_MYPROFILE_PHOTO].asString().c_str());
			}

			if( root[LIVEROOM_MYPROFILE_PHOTOURL].isString() ) {
				photoURL = root[LIVEROOM_MYPROFILE_PHOTOURL].asString();
			}

			if( root[LIVEROOM_MYPROFILE_INTEGRAL].isString() ) {
				integral = atoi(root[LIVEROOM_MYPROFILE_INTEGRAL].asString().c_str());
			}

			/* 手机 */
			if( root[LIVEROOM_MYPROFILE_MOBILE].isString() ) {
				mobile = root[LIVEROOM_MYPROFILE_MOBILE].asString();
			}

			if( root[LIVEROOM_MYPROFILE_MOBILE_CC].isString() ) {
				mobile_cc = GetCountryCode(root[LIVEROOM_MYPROFILE_MOBILE_CC].asString());
			}

			if( root[LIVEROOM_MYPROFILE_MOBILE_STATUS].isString() ) {
				mobile_status = atoi(root[LIVEROOM_MYPROFILE_MOBILE_STATUS].asString().c_str());
			}

			/* 固话 */
			if( root[LIVEROOM_MYPROFILE_LANDLINE].isString() ) {
				landline = root[LIVEROOM_MYPROFILE_LANDLINE].asString();
			}

			if( root[LIVEROOM_MYPROFILE_LANDLINE_CC].isString() ) {
				landline_cc = GetCountryCode(root[LIVEROOM_MYPROFILE_LANDLINE_CC].asString());
			}

			if( root[LIVEROOM_MYPROFILE_LANDLINE_AC].isString() ) {
				landline_ac = root[LIVEROOM_MYPROFILE_LANDLINE_AC].asString();
			}

			if( root[LIVEROOM_MYPROFILE_LANDLINE_STATUS].isString() ) {
				landline_status = atoi(root[LIVEROOM_MYPROFILE_LANDLINE_STATUS].asString().c_str());
			}

			if( root[LIVEROOM_MYPROFILE_INTERESTS].isString() ) {
				string interestString = root[LIVEROOM_MYPROFILE_INTERESTS].asString();
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
            
            if( root[LIVEROOM_MYPROFILE_ZODIAC].isString() ) {
                zodiac = atoi(root[LIVEROOM_MYPROFILE_ZODIAC].asString().c_str());
            }
        }
	}

	HttpProfileItem() {
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
	virtual ~HttpProfileItem() {

	}

	/**
	 * 获取个人信息回调
	 * manid				男士ID
	 * age				年龄
	 * birthday			出生日期
	 * firstname			男士first name
	 * lastname			男士last name
	 * gender			性别
	 * email				电子邮箱
	 * country			国家，参考枚举 <RequestEnum.Country>
	 * marry				婚姻状况
	 * height			身高
	 * weight			体重
	 * smoke				吸烟情况
	 * drink				喝酒情况
	 * language			语言
	 * religion			宗教
	 * education			教育程度
	 * profession		职业
	 * ethnicity			人种
	 * income			收入情况
	 * children			子女状况
	 * rs				个人描述
	 * rs_content		个人描述审核状态
	 * rs_status			审核中的个人描述
	 * address1			地址1
	 * address2			地址2
	 * city				城市
	 * province			省份
	 * zipcode			邮政编码
	 * telephone			电话
	 * fax				传真
	 * alternate_email	备用邮箱
	 * money				余额
	 * v_id				身份认证状态(0=未上传,1=待审核,2=未通过,3=通过)
	 * photo				男士相片状态标识
	 * photoURL			男士相片URL
	 * integral			剩余积分
	 * mobile			手机号码
	 * mobile_cc			手机国家区号，参考枚举 <RequestEnum.Country>
	 * mobile_status		手机审核状态
	 * landline			固话号码
	 * landline_cc		固话国家区号，参考枚举 <RequestEnum.Country>
	 * landline_ac		固话区号
	 * landline_status	固话审核状态
	 * interests			兴趣爱好
     * zodiac            星座
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

#endif /* HTTPPROFILEITEM_H_ */
