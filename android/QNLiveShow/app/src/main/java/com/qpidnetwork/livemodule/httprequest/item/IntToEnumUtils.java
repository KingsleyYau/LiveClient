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
}
