package com.qpidnetwork.livemodule.httprequest.item;

import com.qpidnetwork.livemodule.im.listener.IMClientListener;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Hunter Mun on 2017/9/26.
 */

public class IntToEnumUtils {

    /**
     * Jni整形装Java enum
     * @param interestType
     * @return
     */
    public static InterestType intToInterestType(int interestType){
        InterestType interet = InterestType.unknown;
        if( interestType < 0 || interestType >= InterestType.values().length ) {
            interet = InterestType.unknown;
        } else {
            interet = InterestType.values()[interestType];
        }
        return interet;
    }

    /**
     * 兴趣爱好数组转兴趣enum List
     * @param interests
     * @return
     */
    public static List<InterestType> intArrayToInterestTypeList(int[] interests){
        List<InterestType> interestList = new ArrayList<InterestType>();
        if(interests != null){
            for(int type : interests){
                InterestType temp = intToInterestType(type);
                //屏蔽无效不识别的兴趣
                if(temp != InterestType.unknown) {
                    interestList.add(temp);
                }
            }
        }
        return interestList;
    }

    /**
     * Jni整形装Java enum
     * @param errType
     * @return
     */
    public static HttpLccErrType intToHttpErrorType(int errType){
        HttpLccErrType httpErrorType = HttpLccErrType.HTTP_LCC_ERR_FAIL;
        if( errType < 0 || errType >= HttpLccErrType.values().length ) {
            httpErrorType = HttpLccErrType.HTTP_LCC_ERR_FAIL;
        } else {
            httpErrorType = HttpLccErrType.values()[errType];
        }
        return httpErrorType;
    }

    /**
     * int status 转 enum
     * @param status
     * @return
     */
    public static HangoutInviteStatus intToHangoutInviteStatus(int status){
        HangoutInviteStatus hangoutInviteStatus = HangoutInviteStatus.Unknown;
        if( status < 0 || status >= HangoutInviteStatus.values().length ) {
            hangoutInviteStatus = HangoutInviteStatus.Unknown;
        } else {
            hangoutInviteStatus = HangoutInviteStatus.values()[status];
        }
        return hangoutInviteStatus;
    }

}
