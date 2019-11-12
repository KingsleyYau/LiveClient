/*
 * IMConvertEnum.cpp
 *
 *  Created on: 2019-11-08
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#include "IMConvertEnum.h"
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>


int GetIntWithIMDeviceType(IMDeviceType type) {
    int value = 0;
    
    switch (type) {
        case IMDEVICETYPE_PC:
            value = IMDEVICETYPE_CODE_PC;
            break;
        case IMDEVICETYPE_APP:
            value = IMDEVICETYPE_CODE_APP;
            break;
        default:
            break;
    }
    return value;
}


IMDeviceType GetIMDeviceTypeWithInt(int value) {
    IMDeviceType type = IMDEVICETYPE_UNKNOW;
    if(value == IMDEVICETYPE_CODE_PC){
        type = IMDEVICETYPE_PC;
    }else if(value == IMDEVICETYPE_CODE_APP){
        type = IMDEVICETYPE_APP;
    }
    return type;
}
