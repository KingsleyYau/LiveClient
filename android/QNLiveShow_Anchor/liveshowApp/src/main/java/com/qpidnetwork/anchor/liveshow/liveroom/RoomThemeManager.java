package com.qpidnetwork.anchor.liveshow.liveroom;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.view.View;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;

/**
 * Description:房间主题管理类
 * <p>
 * Created by Harry on 2017/9/7.
 */

public class RoomThemeManager {

    private String TAG = RoomThemeManager.class.getSimpleName();

    /**
     * 直播间-顶部状态栏(通知栏)背景色
     * @param liveRoomType
     * @return
     */
    public int getRootViewTopColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int statusBarColor = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            statusBarColor = Color.parseColor("#3FFFFFFF");
        }else {
            statusBarColor = Color.parseColor("#252525");
        }

        return statusBarColor;
    }

    public int getRoomCarViewBgDrawableResId(IMRoomInItem.IMLiveRoomType liveRoomType){
        int bgResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            bgResId = R.drawable.bg_entrance_car_master_public;
        }else{
            bgResId = R.drawable.bg_entrance_car_master_private;
        }
        return bgResId;
    }

    public int getRoomCarViewTxtColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int txtColor = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            txtColor = Color.parseColor("#FFFFD205");
        }else{
            txtColor = Color.WHITE;
        }
        return txtColor;
    }

    /**直播间-消息列表-顶部渐进色
     * @param liveRoomType
     * @return
     */
    public int getRoomMsgListTopGradualColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int color = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            color = Color.WHITE;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType || IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType){
            color = Color.parseColor("#2b2b2b");
        }else if(IMRoomInItem.IMLiveRoomType.HangoutRoom == liveRoomType){
            color = Color.parseColor("#252525");
        }
        return color;
    }

    /**直播间-软键盘弹起-表情列表开关按钮样式
     * @param liveRoomType
     * @return
     */
    public int getRoomInputEmojiSwitchVisiable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            return View.GONE;
        }
        return View.VISIBLE;
    }

    /**
     * 系统公告:带连接或者不带连接公告颜色
     * @param liveRoomType
     * @return
     */
    public int getRoomMsgListSysNoticeNormalTxtColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int txtColor = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            txtColor = Color.parseColor("#FFFFFF");
        }else{
            txtColor = Color.parseColor("#FFFFFF");
        }
        return txtColor;
    }

    /**
     * 直播间消息列表-礼物消息类型对应的资源id
     * @param liveRoomType
     * @param isAnchor
     * @return
     */
    public int getRoomMsgListGiftMsgStrResId(IMRoomInItem.IMLiveRoomType liveRoomType, boolean isAnchor,
                                             GiftItem giftItem, boolean isSecretly, boolean hasRecvNickName){
        int strResId = 0;
        if(null != liveRoomType){
            if(liveRoomType == IMRoomInItem.IMLiveRoomType.PaidPublicRoom
                    || liveRoomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom){
                //公开直播间
                if(isAnchor){
                    strResId = R.string.livemsg_temp_gift_public_anchor;
                }else{
                    strResId = R.string.livemsg_temp_gift_public;
                }
            }else if(liveRoomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom
                    || liveRoomType == IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom){
                //私密直播间
                if(isAnchor){
                    strResId = R.string.livemsg_temp_gift_private_anchor;
                }else{
                    strResId = R.string.livemsg_temp_gift_private_man;
                }
            }else if(liveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom){
                //HangOut直播间
                if(null != giftItem){
                    if(giftItem.giftType == GiftItem.GiftType.Celebrate){
                        strResId = isAnchor ? R.string.livemsg_temp_gift_hangout_celeb_anchor : R.string.livemsg_temp_gift_hangout_celeb_man;
                    }else if(giftItem.giftType == GiftItem.GiftType.Bar){
                        if(isAnchor){
                            strResId = R.string.livemsg_temp_gift_hangout_bar_anchor;
                        }else{
                            strResId = isSecretly ? R.string.livemsg_temp_gift_hangout_bar_man_secretly : R.string.livemsg_temp_gift_hangout_bar_man;
                        }

                    }else{
                        if(isAnchor){
                            strResId = R.string.livemsg_temp_gift_hangout_giftstore_anchor;
                        }else{
                            strResId = isSecretly ? R.string.livemsg_temp_gift_hangout_giftstore_man_secretly : R.string.livemsg_temp_gift_hangout_giftstore_man;
                        }
                    }
                }else {
                    if(hasRecvNickName){//本地礼物详情不存在，toUid不为空，按照普通礼物消息类型展示
                        if(isAnchor){
                            strResId = R.string.livemsg_temp_gift_hangout_giftstore_anchor;
                        }else{
                            strResId = isSecretly ? R.string.livemsg_temp_gift_hangout_giftstore_man_secretly : R.string.livemsg_temp_gift_hangout_giftstore_man;
                        }
                    }else{//本地礼物详情不存在，toUid为空，按照庆祝礼物消息类型展示
                        strResId = isAnchor ? R.string.livemsg_temp_gift_hangout_celeb_anchor : R.string.livemsg_temp_gift_hangout_celeb_man;
                    }
                }
            }
        }
        return strResId;
    }

    /**
     * 直播间消息列表-礼物消息类型对应的资源id
     * @param liveRoomType
     * @param hasCar
     * @return
     */
    public int getRoomMsgListRoomInMsgStrResId(IMRoomInItem.IMLiveRoomType liveRoomType, boolean hasCar, boolean isMan){
        int strResId = 0;
        if(null != liveRoomType){
            if(liveRoomType == IMRoomInItem.IMLiveRoomType.PaidPublicRoom
                    || liveRoomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom){
                //公开直播间
                if(hasCar){
                    strResId = R.string.livemsg_temp_roomin_public_hascar;
                }else{
                    strResId = R.string.livemsg_temp_roomin_public_nocar;
                }
            }else if(liveRoomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom
                    || liveRoomType == IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom){
                //私密直播间
                if(hasCar){
                    strResId = R.string.livemsg_temp_roomin_private_hascar;
                }else{
                    strResId = R.string.livemsg_temp_roomin_private_nocar;
                }
            }else if(liveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom){
                //HangOut直播间
                strResId = isMan ? R.string.livemsg_temp_roomin_hangout_man : R.string.livemsg_temp_roomin_hangout_anchor;
            }
        }
        return strResId;
    }

    /**
     * 直播间消息列表-普通文本消息/弹幕资源ID
     * @param liveRoomType
     * @param isAnchor
     * @return
     */
    public int getRoomMsgListNormalStrResId(IMRoomInItem.IMLiveRoomType liveRoomType, boolean isAnchor){
        int strResId = 0;
        if(null != liveRoomType){
            if(liveRoomType == IMRoomInItem.IMLiveRoomType.PaidPublicRoom
                    || liveRoomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom){
                if(isAnchor){
                    strResId = R.string.livemsg_temp_normal_public_anchor;
                }else{
                    //观众的消息
                    strResId = R.string.livemsg_temp_normal_public_man;
                }
            }else if(liveRoomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom
                    || liveRoomType == IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom){
                if(isAnchor){
                    strResId = R.string.livemsg_temp_normal_private_anchor;
                }else{
                    strResId = R.string.livemsg_temp_normal_private_man;
                }
            }else if(liveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom){
                if(isAnchor){
                    strResId = R.string.livemsg_temp_normal_hangout_anchor;
                }else{
                    strResId = R.string.livemsg_temp_normal_hangout_man;
                }
            }
        }
        return strResId;
    }

    /**
     * 直播间消息列表-推荐主播消息资源ID
     * @param liveRoomType
     * @return
     */
    public int getRoomMsgListRecommendedStrResId(IMRoomInItem.IMLiveRoomType liveRoomType){
        int strResId = 0;

        if(liveRoomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom
                || liveRoomType == IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom){
            strResId = R.string.livemsg_temp_private_recommend;
        }else if(liveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom) {
            strResId = R.string.livemsg_temp_hangout_recommend;
        }
        return strResId;
    }

    public Drawable getRoomMsgListGiftItemBgDrawable(Context context, IMRoomInItem.IMLiveRoomType liveRoomType, boolean isSecretly){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable=context.getResources().getDrawable(R.drawable.bg_live_msg_item_gift_public);
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType){
            drawable=context.getResources().getDrawable(R.drawable.bg_live_msg_item_gift_private);
        }else if(IMRoomInItem.IMLiveRoomType.HangoutRoom == liveRoomType){
            if(isSecretly){
                drawable=context.getResources().getDrawable(R.drawable.bg_live_msg_item_gift_hangout_secretly);
            }else{
                drawable=context.getResources().getDrawable(R.drawable.bg_live_msg_item_gift_hangout);
            }
        }
        return drawable;
    }

    /**
     * 直播间-弹幕浮层-背景色
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomBarrageBgDrawable(IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#deffffff"));
        }else{
            drawable = new ColorDrawable(Color.parseColor("#E5252525"));
        }

        return drawable;
    }

    //----------------------------- 全屏直播间样式 start -------------------------------

    /**
     * 全屏直播间--我的相关系统信息--背景
     * @param context
     * @param liveRoomType
     * @return
     */
    public Drawable getFullScreenRoomMineSysMsgItemBgDrawable(Context context, IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable=context.getResources().getDrawable(R.drawable.bg_full_screen_item_4_mine_sys_msg);
        }else{
            drawable=context.getResources().getDrawable(R.drawable.bg_full_screen_item_4_mine_sys_msg);
        }
        return drawable;
    }

    /**
     * 全屏直播间--普通信息--背景
     * @param context
     * @param liveRoomType
     * @return
     */
    public Drawable getFullScreenRoomNorMsgItemBgDrawable(Context context, IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable=context.getResources().getDrawable(R.drawable.bg_full_screen_item_4_nor_msg);
        }else{
            drawable=context.getResources().getDrawable(R.drawable.bg_full_screen_item_4_nor_msg);
        }
        return drawable;
    }

    /**
     * 全屏直播间--警告信息--背景
     * @param context
     * @param liveRoomType
     * @return
     */
    public Drawable getFullScreenRoomWarningMsgItemBgDrawable(Context context, IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable=context.getResources().getDrawable(R.drawable.bg_full_screen_item_4_warning_msg);
        }else{
            drawable=context.getResources().getDrawable(R.drawable.bg_full_screen_item_4_warning_msg);
        }
        return drawable;
    }

    /**
     * 全屏直播间--警告信息--背景
     * @param context
     * @param liveRoomType
     * @return
     */
    public Drawable getFullScreenRoomNickNameBgDrawable(Context context, IMRoomInItem.IMLiveRoomType liveRoomType, boolean isAnchor){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            if(isAnchor){
                drawable=context.getResources().getDrawable(R.drawable.bg_full_screen_item_4_art_nick_name_bg);
            }else{
                drawable=context.getResources().getDrawable(R.drawable.bg_full_screen_item_4_men_nick_name_bg);
            }

        }else{
            if(isAnchor){
                drawable=context.getResources().getDrawable(R.drawable.bg_full_screen_item_4_art_nick_name_bg);
            }else{
                drawable=context.getResources().getDrawable(R.drawable.bg_full_screen_item_4_men_nick_name_bg);
            }
        }
        return drawable;
    }

    /**
     * 全屏直播间--消息列表--试聊卷资源id
     * @param liveRoomType
     * @return
     */
//    public int getFullScreenRoomVoucherMsgStrResId(IMRoomInItem.IMLiveRoomType liveRoomType){
//        int strResId = 0;
//        if(null != liveRoomType){
//            if(liveRoomType == IMRoomInItem.IMLiveRoomType.PaidPublicRoom
//                    || liveRoomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom){
//                //公开直播间
//                strResId = R.string.livemsg_voucher_private;
//            }else{
//                //私密直播间
//                strResId = R.string.livemsg_voucher_private;
//            }
//        }
//        return strResId;
//    }

    /**
     * 全屏直播间--消息列表--试聊卷背景
     * @param context
     * @param liveRoomType
     * @return
     */
    public Drawable getFullScreenRoomVoucherMsgItemBgDrawable(Context context, IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable=context.getResources().getDrawable(R.drawable.bg_full_screen_item_4_voucher_msg);
        }else{
            drawable=context.getResources().getDrawable(R.drawable.bg_full_screen_item_4_voucher_msg);
        }
        return drawable;
    }

    //----------------------------- 全屏直播间样式 end -------------------------------
}
