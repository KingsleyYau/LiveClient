/*
 * LSLCMagicIconConfig.h
 *
 *  Created on: 2016年4月7日
 *      Author: HOUNOR DE ELITES
 */

#ifndef LSLCMAGICICONCONFIG_H_
#define LSLCMAGICICONCONFIG_H_

#include <string>
#include <list>
using namespace std;

#include "../LSLiveChatRequestLiveChatDefine.h"
#include <xml/tinyxml.h>

class LSLCMagicIconConfig {
public:
	class LSLCMagicIconType{
	public:
		LSLCMagicIconType(){
			typeId = "";
			typeTitle = "";
		}
		LSLCMagicIconType(const LSLCMagicIconType& type){
			typeId = type.typeId;
			typeTitle = type.typeTitle;
		}
		virtual ~LSLCMagicIconType(){}
	public:
		bool parsing(Json::Value root){
			bool result = false;
			if( root.isObject()){
                /* typeId */
                if (root[LC_GET_MAGICICON_CONFIG_ID].isString()) {
                    typeId = root[LC_GET_MAGICICON_CONFIG_ID].asString();
                }
                
                /* typeTitle */
                if (root[LC_GET_MAGICICON_CONFIG_TITLE].isString()) {
                    typeTitle = root[LC_GET_MAGICICON_CONFIG_TITLE].asString();
                }

				if(!typeId.empty()){
					result = true;
				}
			}
			return result;
		}
	public:
		string typeId;
		string typeTitle;
	};
	typedef list<LSLCMagicIconType> MagicTypeList;

	class LSLCMagicIconItem{
	public:
		LSLCMagicIconItem(){
			iconId = "";
			iconTitle = "";
			price = 0.0;
			hotflag = 0;
			typeId = "";
			updatetime = 0;
		}
		LSLCMagicIconItem(const LSLCMagicIconItem& item){
			iconId = item.iconId;
			iconTitle = item.iconTitle;
			price = item.price;
			hotflag = item.hotflag;
			typeId = item.typeId;
			updatetime = item.updatetime;
		}
		virtual ~LSLCMagicIconItem(){}
	public:
		bool parsing(Json::Value root){
			bool result = false;
			if(root.isObject()){
                /* iconId */
                if (root[LC_GET_MAGICICON_CONFIG_ID].isString()) {
                    iconId = root[LC_GET_MAGICICON_CONFIG_ID].asString();
                }
                
                /* iconTitle */
                if (root[LC_GET_MAGICICON_CONFIG_TITLE].isString()) {
                    iconTitle = root[LC_GET_MAGICICON_CONFIG_TITLE].asString();
                }
                
                /* price */
                if (root[LC_GET_MAGICICON_CONFIG_PRICE].isNumeric()) {
                    price = root[LC_GET_MAGICICON_CONFIG_PRICE].asDouble();
                }
                
                /* hotflag */
                if (root[LC_GET_MAGICICON_CONFIG_HOTFLAG].isNumeric()) {
                    hotflag = root[LC_GET_MAGICICON_CONFIG_HOTFLAG].asInt();
                }
                
                /* typeId */
                if (root[LC_GET_MAGICICON_CONFIG_TYPEID].isString()) {
                    typeId = root[LC_GET_MAGICICON_CONFIG_TYPEID].asString();
                }
	
                /* updatetime */
                if (root[LC_GET_MAGICICON_CONFIG_UPDATETIME].isNumeric()) {
                    updatetime = root[LC_GET_MAGICICON_CONFIG_UPDATETIME].asInt();
                }

				if(!iconId.empty()){
					result = true;
				}
			}
			return result;
		}
	public:
		string iconId;
		string iconTitle;
		double price;
		int hotflag;
		string typeId;
		int updatetime;
	};
	typedef list<LSLCMagicIconItem> MagicIconList;
public:
	LSLCMagicIconConfig(){
		path = "";
		maxupdatetime = 0;
	}
	LSLCMagicIconConfig(const LSLCMagicIconConfig& config){
		path = config.path;
		maxupdatetime = config.maxupdatetime;
		typeList = config.typeList;
		magicIconList = config.magicIconList;
	}
	virtual ~LSLCMagicIconConfig(){

	}
public:
	bool parsing(const Json::Value& root){
		bool result = false;
		if(root.isObject()){
                /* path */
                if (root[LC_GET_MAGICICON_CONFIG_BASE_PATH].isString()) {
                    path = root[LC_GET_MAGICICON_CONFIG_BASE_PATH].asString();
                }
                /* maxupdatetime */
                if (root[LC_GET_MAGICICON_CONFIG_MAXUPDATETIME].isNumeric()) {
                    maxupdatetime = root[LC_GET_MAGICICON_CONFIG_MAXUPDATETIME].asInt();
                }

                if (root[LC_GET_MAGICICON_CONFIG_DATA].isObject()) {
                    Json::Value data = root[LC_GET_MAGICICON_CONFIG_DATA];
                    if (data[LIVECHAT_INFO].isArray()) {
                        for (int i = 0; i < data[LIVECHAT_INFO].size(); i++) {
                            LSLCMagicIconItem magicItem;
                            if (magicItem.parsing(data[LIVECHAT_INFO].get(i, Json::Value::null))) {
                                magicIconList.push_back(magicItem);
                            }
                        }
                    }
                    
                    if (data[LC_GET_MAGICICON_CONFIG_TYPELIST].isArray()) {
                        for (int i = 0; i < data[LC_GET_MAGICICON_CONFIG_TYPELIST].size(); i++) {
                            LSLCMagicIconType magicType;
                            if (magicType.parsing(data[LC_GET_MAGICICON_CONFIG_TYPELIST].get(i, Json::Value::null))) {
                                typeList.push_back(magicType);
                            }
                        }
                    }
                }
            
			}

			if(!path.empty()){
				result = true;
			}
		return result;
	}
public:      
	string path;
	long maxupdatetime;
	MagicTypeList typeList;
	MagicIconList magicIconList;
};

#endif /* MAGICICONCONFIG_H_ */
