/*
 * LSLCLadyCall.h
 *
 *  Created on: 2015-3-2
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCLADYCALL_H_
#define LSLCLADYCALL_H_

#include <string>
using namespace std;


#include <json/json/json.h>

#include "../LSLiveChatRequestLadyDefine.h"

class LSLCLadyCall {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
			if( root[LADY_WOMAN_ID].isString() ) {
				womanid = root[LADY_WOMAN_ID].asString();
			}

			if( root[LADY_LOVECALLID].isString() ) {
				lovecallid = root[LADY_LOVECALLID].asString();
			}

			if( root[LADY_LC_CENTERNUMBER].isString() ) {
				lc_centernumber = root[LADY_LC_CENTERNUMBER].asString();
			}
		}
	}

	LSLCLadyCall() {
		womanid = "";
		lovecallid = "";
		lc_centernumber = "";
	}
	virtual ~LSLCLadyCall() {

	}

	/**
	 * 4.7.获取女士Direct Call TokenID成功回调
	 * @param womanid				被呼叫女士ID
	 * @param lovecallid			被呼叫女士TokenID
	 * @param lc_centernumber		call center number
	 */

	string womanid;
	string lovecallid;
	string lc_centernumber;

};

#endif /* LSLCLADYCALL_H_ */
