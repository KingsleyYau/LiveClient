package com.qpidnetwork.livemodule.httprequest.item;

import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Children;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Country;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Drink;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Education;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Ethnicity;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.HandleEmailType;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Height;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Income;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Language;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Profession;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Religion;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Smoke;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Weight;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Zodiac;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Marry;

import java.io.Serializable;
import java.util.ArrayList;

public class LSProfileItem implements Serializable {
	/**
	 *
	 */
	private static final long serialVersionUID = 4522153366553519360L;
	public LSProfileItem() {

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
	 * @param country			国家,参考枚举 <RequestEnum.Country>
	 * @param marry				婚姻状况,参考枚举 <RequestEnum.Marry>
	 * @param height			身高
	 * @param weight			体重
	 * @param smoke				吸烟情况
	 * @param drink				喝酒情况
	 * @param language			语言
	 * @param religion			宗教
	 * @param education			教育程度,参考枚举 <RequestEnum.Education>
	 * @param profession		职业
	 * @param ethnicity			人种
	 * @param income			收入情况
	 * @param children			子女状况,参考枚举 <RequestEnum.Children>
	 * @param resume			个人描述
	 * @param resume_content	个人描述审核状态
	 * @param resume_status		审核中的个人描述
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
	 */
	public LSProfileItem(
			String manid,
			int age,
			String birthday,
			String firstname,
			String lastname,
			String email,
			
			int gender,
			int country,
			int marry,
			int height,
			int weight,
			int smoke,
			int drink,
			int language,
			int religion,
			int education,
			int profession,
			int ethnicity,
			int income,
			int children,
			
			String resume,
			String resume_content,
			int resume_status,

			String address1,
			String address2,
			String city,
			String province,
			String zipcode,
			String telephone,
			String fax,
			String alternate_email,
			String money,
			
			int v_id,
			int photo,
			String photoURL,
			int integral,
			
			String mobile,
			int mobile_cc,
			int mobile_status,
			
			String landline,
			int landline_cc,
			String landline_ac,
			int landline_status,
			
			ArrayList<String> interests,
			int zodiac
				) {
		this.manid = manid;
		this.age = age;
		this.birthday = birthday;
		this.firstname = firstname;
		this.lastname = lastname;
		this.email = email;
		
		if( gender < 0 || gender >= Gender.values().length ) {
			this.gender = Gender.values()[0];
		} else {
			this.gender = Gender.values()[gender];
		}
		
		if( country < 0 || country >= Country.values().length ) {
			this.country = Country.values()[0];
		} else {
			this.country = Country.values()[country];
		}
		
		if( marry < 0 || marry >= Marry.values().length ) {
			this.marry = Marry.values()[0];
		} else {
			this.marry = Marry.values()[marry];
		}
		
		if( height < 0 || height >= Height.values().length ) {
			this.height = Height.values()[0];
		} else {
			this.height = Height.values()[height];
		}
		
		if( weight < 0 || weight >= Weight.values().length ) {
			this.weight = Weight.values()[0];
		} else {
			this.weight = Weight.values()[weight];
		}
		
		if( smoke < 0 || smoke >= Smoke.values().length ) {
			this.smoke = Smoke.values()[0];
		} else {
			this.smoke = Smoke.values()[smoke];
		}
		
		if( drink < 0 || drink >= Drink.values().length ) {
			this.drink = Drink.values()[0];
		} else {
			this.drink = Drink.values()[drink];
		}
		
		if( language < 0 || language >= Language.values().length ) {
			this.language = Language.values()[0];
		} else {
			this.language = Language.values()[language];
		}
		
		if( religion < 0 || religion >= Religion.values().length ) {
			this.religion = Religion.values()[0];
		} else {
			this.religion = Religion.values()[religion];
		}
		
		if( education < 0 || education >= Education.values().length ) {
			this.education = Education.values()[0];
		} else {
			this.education = Education.values()[education];
		}
		
		if( profession < 0 || profession >= Profession.values().length ) {
			this.profession = Profession.values()[0];
		} else {
			this.profession = Profession.values()[profession];
		}
		
		if( ethnicity < 0 || ethnicity >= Ethnicity.values().length ) {
			this.ethnicity = Ethnicity.values()[0];
		} else {
			this.ethnicity = Ethnicity.values()[ethnicity];
		}
		
		if( income < 0 || income >= Income.values().length ) {
			this.income = Income.values()[0];
		} else {
			this.income = Income.values()[income];
		}
		
		if( children < 0 || children >= Children.values().length ) {
			this.children = Children.values()[0];
		} else {
			this.children = Children.values()[children];
		}
		
		this.resume = resume;
		this.resume_content = resume_content;
		
		if( resume_status < 0 || resume_status >= ResumeStatus.values().length ) {
			this.resume_status = ResumeStatus.values()[0];
		} else {
			this.resume_status = ResumeStatus.values()[resume_status];
		}

		this.address1 = address1;
		this.address2 = address2;
		this.city = city;
		this.province = province;
		this.zipcode = zipcode;
		this.telephone = telephone;
		this.fax = fax;
		this.alternate_email = alternate_email;
		this.money = money;
		
		this.v_id = VType.values()[v_id];
		this.photo = Photo.values()[photo];
		this.photoURL = photoURL;
		this.integral = integral;
		
		this.mobile = mobile;
		
		if( mobile_cc < 0 || mobile_cc >= Country.values().length ) {
			this.mobile_cc = Country.values()[0];
		} else {
			this.mobile_cc = Country.values()[mobile_cc];
		}
		
		if( mobile_status < 0 || mobile_status >= MobileStatus.values().length ) {
			this.mobile_status = MobileStatus.values()[0];
		} else {
			this.mobile_status = MobileStatus.values()[mobile_status];
		}
		
		this.landline = landline;
		
		if( landline_cc < 0 || landline_cc >= Country.values().length ) {
			this.landline_cc = Country.values()[0];
		} else {
			this.landline_cc = Country.values()[landline_cc];
		}
		
		this.landline_ac = landline_ac;
		
		if( landline_status < 0 || landline_status >= LandLineStatus.values().length ) {
			this.landline_status = LandLineStatus.values()[0];
		} else {
			this.landline_status = LandLineStatus.values()[landline_status];
		}
		
		this.interests = interests;

		if( zodiac < 0 || zodiac >= Zodiac.values().length ) {
			this.zodiac = Zodiac.values()[0];
		} else {
			this.zodiac = Zodiac.values()[zodiac];
		}
	}

	public LSProfileItem(LSProfileItem item){
		this.copy(item);
	}
	
	public String manid;
	public int age;
	public String birthday;
	public String firstname;
	public String lastname;
	public String email;
	
	public enum Gender {
		Male,
		Female
	}
	public Gender gender;
	public Country country;
	public Marry marry;
	public Height height;
	public Weight weight;
	public Smoke smoke;
	public Drink drink;
	public Language language;
	public Religion religion;
	public Education education;
	public Profession profession;
	public Ethnicity ethnicity;
	public Income income;
	public Children children;
	public Zodiac zodiac = Zodiac.Unknow;	//add by Jagger 2017-5-24 给个默认值,以免空指针
	
	public String resume;
	public String resume_content;
	public enum ResumeStatus {
		Unknow,
		UnVerify,
		Verified,
		NotVerified,
	}
	public ResumeStatus resume_status;

	public String address1;
	public String address2;
	public String city;
	public String province;
	public String zipcode;
	public String telephone;
	public String fax;
	public String alternate_email;
	public String money;
	
	public enum VType {
		None,
		Verifing,
		Fail,
		Pass,
	}
	public VType v_id;
	
	public enum Photo {
		None,
		Yes,
		Verifing,
		InstitutionsFail,
		Fail,
	}
	public Photo photo;
	public String photoURL;
	public int integral;
	
	public String mobile;
	public Country mobile_cc;
	public enum MobileStatus {
		Unknow,
		UnVerify,
		Verified,
		NotVerified,
	}
	public MobileStatus mobile_status;
	
	public String landline;
	public Country landline_cc;
	public String landline_ac;
	public enum LandLineStatus {
		Unknow,
		UnVerify,
		Verified,
		NotVerified,
	}
	public LandLineStatus landline_status;
	
	/**
	 * 是否显示头像
	 * @return
	 */
	public boolean showPhoto() {
		if ( photo == Photo.None || photo == Photo.Fail ){
			return false;
		}
		return true;
	}
	
	/**
	 * 是否显示上传
	 * @return
	 */
	public boolean showUpload() {
		if( v_id == VType.Verifing && photo == Photo.Yes ) {
		} else if( v_id == VType.Pass && photo == Photo.Yes ) {
		} else if( photo == Photo.Verifing ) {
		} else {
			// 允许改变
			return true;
		}
		return false;
	}
	
	public ArrayList<String> interests;

	/**
	 * 对象拷贝
	 * @param profileItem
	 */
	public void copy(LSProfileItem profileItem){
		this.manid = profileItem.manid;
		this.age = profileItem.age;
		this.birthday = profileItem.birthday;
		this.firstname = profileItem.firstname;
		this.lastname = profileItem.lastname;
		this.email = profileItem.email;

		this.gender = profileItem.gender;
		this.country = profileItem.country;
		this.marry = profileItem.marry;
		this.height = profileItem.height;
		this.weight = profileItem.weight;
		this.smoke = profileItem.smoke;
		this.drink = profileItem.drink;
		this.language = profileItem.language;
		this.religion = profileItem.religion;
		this.education = profileItem.education;
		this.profession = profileItem.profession;
		this.ethnicity = profileItem.ethnicity;
		this.income = profileItem.income;
		this.children = profileItem.children;

		this.resume = profileItem.resume;
		this.resume_content = profileItem.resume_content;
		this.resume_status = profileItem.resume_status;

		this.address1 = profileItem.address1;
		this.address2 = profileItem.address2;
		this.city = profileItem.city;
		this.province = profileItem.province;
		this.zipcode = profileItem.zipcode;
		this.telephone = profileItem.telephone;
		this.fax = profileItem.fax;
		this.alternate_email = profileItem.alternate_email;
		this.money = profileItem.money;

		this.v_id = profileItem.v_id;
		this.photo = profileItem.photo;
		this.photoURL = profileItem.photoURL;
		this.integral = profileItem.integral;

		this.mobile = profileItem.mobile;
		this.mobile_cc = profileItem.mobile_cc;
		this.mobile_status = profileItem.mobile_status;

		this.landline = profileItem.landline;
		this.landline_cc = profileItem.landline_cc;
		this.landline_ac = profileItem.landline_ac;
		this.landline_status = profileItem.landline_status;

		this.interests = profileItem.interests;
		this.zodiac = profileItem.zodiac;
	}
}
