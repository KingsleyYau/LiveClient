package com.qpidnetwork.anchor.httprequest.item;

/**
 * Created by Hunter Mun on 2017/9/26.
 */

public class IntToEnumUtils {

    /**
     * Jni整形装Java enum
     * @param errType
     * @return
     */
    public static LiveRoomType intToLiveRoomType(int errType){
        LiveRoomType liveRoomType = LiveRoomType.Unknown;
        if( errType < 0 || errType >= HttpLccErrType.values().length ) {
            liveRoomType = LiveRoomType.Unknown;
        } else {
            liveRoomType = LiveRoomType.values()[errType];
        }
        return liveRoomType;
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
     * Jni整形装Java enum
     * @param errType
     * @return
     */
    public static AnchorKnockType intToAnchorKnockType(int errType){
        AnchorKnockType anchorKnockType = AnchorKnockType.Unknown;
        if( errType < 0 || errType >= AnchorKnockType.values().length ) {
            anchorKnockType = AnchorKnockType.Unknown;
        } else {
            anchorKnockType = AnchorKnockType.values()[errType];
        }
        return anchorKnockType;
    }

    /**
     * 公开直播间类型转换
     * @param liveShowType
     * @return
     */
    public static PublicRoomType intToPublicRoomType(int liveShowType){
        PublicRoomType publicRoomType = PublicRoomType.Unknown;
        if( liveShowType < 0 || liveShowType >= PublicRoomType.values().length ) {
            publicRoomType = PublicRoomType.Unknown;
        } else {
            publicRoomType = PublicRoomType.values()[liveShowType];
        }
        return publicRoomType;
    }

}
