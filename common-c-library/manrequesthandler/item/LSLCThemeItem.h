/*
 * LSLCThemeItem.h
 *
 *  Created on: 2016年4月19日
 *      Author: Hunter
 */

#ifndef LSLCTHEMEITEM_H_
#define LSLCTHEMEITEM_H_

#include <string>
#include <list>
using namespace std;

#include "../LSLiveChatRequestOtherDefine.h"
#include <xml/tinyxml.h>

class LSLCThemeItem{
public:
	LSLCThemeItem(){
		themeId = "";
		price = 0.0;
		isNew = false;
		isSale = false;
		typeId = "";
		tagId = "";
		title = "";
		validsecond = 0;
		isBase = 0;
		descript = "";
	}

	LSLCThemeItem(const LSLCThemeItem& item){
		themeId = item.themeId;
		price = item.price;
		isNew = item.isNew;
		isSale = item.isSale;
		typeId = item.typeId;
		tagId = item.tagId;
		title = item.title;
		validsecond = item.validsecond;
		isBase = item.isBase;
		descript = item.descript;
	}
	virtual ~LSLCThemeItem(){}
public:
	bool parsing(const TiXmlNode* themeItemNode){
		bool result = false;
		if(NULL != themeItemNode){
			//themeId
			const TiXmlElement* themeIdNode = themeItemNode->FirstChildElement(LC_GET_THEME_CONFIG_THEME_ID);
			if(NULL != themeIdNode){
				themeId = themeIdNode->GetText();
			}
			//price
			const TiXmlElement* priceNode = themeItemNode->FirstChildElement(LC_GET_THEME_CONFIG_THEME_PRICE);
			if(NULL != priceNode){
				const char* pPrice = priceNode->GetText();
				price = atof(pPrice);
			}
			//isNew
			const TiXmlElement* isNewNode = themeItemNode->FirstChildElement(LC_GET_THEME_CONFIG_THEME_ISNEW);
			if(NULL != isNewNode){
				isNew = (atoi(isNewNode->GetText())==1)?true:false;
			}
			//isSale
			const TiXmlElement* isSaleNode = themeItemNode->FirstChildElement(LC_GET_THEME_CONFIG_THEME_ISSALE);
			if(NULL != isSaleNode){
				isSale = (atoi(isSaleNode->GetText())==1)?true:false;
			}
			//typeId
			const TiXmlElement* typeIdNode = themeItemNode->FirstChildElement(LC_GET_THEME_CONFIG_THEME_TYPEID);
			if(NULL != typeIdNode){
				typeId = typeIdNode->GetText();
			}
			//tagId
			const TiXmlElement* tagIdNode = themeItemNode->FirstChildElement(LC_GET_THEME_CONFIG_THEME_TAGSID);
			if(NULL != tagIdNode){
				tagId = tagIdNode->GetText();
			}
			//title
			const TiXmlElement* titleNode = themeItemNode->FirstChildElement(LC_GET_THEME_CONFIG_THEME_TITLE);
			if(NULL != titleNode){
				title = titleNode->GetText();
			}
			//validsecond
			const TiXmlElement* validsecondNode = themeItemNode->FirstChildElement(LC_GET_THEME_CONFIG_THEME_VALIDSECOND);
			if(NULL != validsecondNode){
				validsecond = atoi(validsecondNode->GetText());
			}
			//isBase
			const TiXmlElement* isBaseNode = themeItemNode->FirstChildElement(LC_GET_THEME_CONFIG_THEME_ISBASE);
			if(NULL != isBaseNode){
				isBase = atoi(isBaseNode->GetText());
			}
			//descript
			const TiXmlElement* descriptNode = themeItemNode->FirstChildElement(LC_GET_THEME_CONFIG_THEME_DESCRIPT);
			if(NULL != descriptNode){
				descript = descriptNode->GetText();
			}

			if(!themeId.empty()){
				result = true;
			}
		}
		return result;
	}
public:
	string themeId;
	double price;
	bool isNew;
	bool isSale;
	string typeId;
	string tagId;
	string title;
	int validsecond;
	int isBase;
	string descript;
};
typedef list<LSLCThemeItem> ThemeItemList;

#endif /* LSLCTHEMEITEM_H_ */
