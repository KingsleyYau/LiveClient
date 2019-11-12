package com.qpidnetwork.livemodule.liveshow.sayhi.view;

import android.content.Context;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.SayHiSendInfoItem;
import com.qpidnetwork.livemodule.view.dialog.CommonMultipleBtnTipDialog;

/**
 * Created  by Oscar
 */
public class MultipleBtnDialogFactory {

    public static String TAB_BTN_SAY_HI = "TAB_BTN_SAY_HI";
    public static String TAB_BTN_SAY_HI_LIST_RES = "TAB_BTN_SAY_HI_LIST_RES";
    public static String TAB_BTN_SAY_HI_LIST_ALL = "TAB_BTN_SAY_HI_LIST_ALL";
    public static String TAB_BTN_CHAT = "TAB_BTN_CHAT";
    public static String TAB_BTN_MAIL = "TAB_BTN_MAIL";
    public static String TAB_BTN_FOLLOW = "TAB_BTN_FOLLOW";
    public static String TAB_BTN_ONE_ON_ONE = "TAB_BTN_ONE_ON_ONE";

    /**
     * SayHi发送成功弹出Dialog 模板
     *
     * @param itemClickListener
     */
    public static CommonMultipleBtnTipDialog createSayHiSendSuccessDialog(Context context,
                                                                          SayHiSendInfoItem sayHiSendInfoItem,
                                                                          CommonMultipleBtnTipDialog.OnDialogItemClickListener itemClickListener) {


        CommonMultipleBtnTipDialog dialog = new CommonMultipleBtnTipDialog(context);
        dialog.setBgDrawable(R.drawable.sayhi_dialog_bg);
        dialog.setTitle(context.getString(R.string.sayhi_dialog_successfully_title));
        dialog.setTitleIcon(R.drawable.say_hi_dialog_successfully);
        dialog.setMessage(context.getString(R.string.sayhi_dialog_successfully_message));
        dialog.setItemClickCallback(itemClickListener);
        if(sayHiSendInfoItem.onlineStatus == AnchorOnlineStatus.Online) {
            dialog.addItem(TAB_BTN_CHAT, context.getString(R.string.sayhi_dialog_item_wechat), R.drawable.say_hi_dialog_item_wechat);
        }
        dialog.addItem(TAB_BTN_MAIL, context.getString(R.string.sayhi_dialog_item_mail), R.drawable.say_hi_dialog_item_mail);

        return dialog;
    }

    /**
     * SayHi发送失败(发送过)弹出Dialog 模板
     *
     * @param itemClickListener
     */
    public static CommonMultipleBtnTipDialog createSayHiHasSendFailDialog(Context context,
                                                                          SayHiSendInfoItem sayHiSendInfoItem,
                                                                          String ladyName,
                                                                          CommonMultipleBtnTipDialog.OnDialogItemClickListener itemClickListener) {


        CommonMultipleBtnTipDialog dialog = new CommonMultipleBtnTipDialog(context);
        dialog.setBgDrawable(R.drawable.sayhi_dialog_bg);
        dialog.setTitle(context.getString(R.string.sayhi_dialog_fail_title, ladyName));
        dialog.setTitleSize(18f);
        dialog.setMessage(context.getString(R.string.sayhi_dialog_fail_has_send_message, ladyName));
        dialog.setSubTitle(context.getString(R.string.sayhi_dialog_fail_sub_title));
        dialog.setItemClickCallback(itemClickListener);
        dialog.addItem(TAB_BTN_SAY_HI, context.getString(R.string.sayhi_dialog_item_say_hi), R.drawable.say_hi_dialog_item_say_hi);
        if(sayHiSendInfoItem.onlineStatus == AnchorOnlineStatus.Online) {
            dialog.addItem(TAB_BTN_CHAT, context.getString(R.string.sayhi_dialog_item_wechat), R.drawable.say_hi_dialog_item_wechat);
        }
        dialog.addItem(TAB_BTN_MAIL, context.getString(R.string.sayhi_dialog_item_mail), R.drawable.say_hi_dialog_item_mail);

        return dialog;
    }


    /**
     * SayHi发送失败(已有联系)弹出Dialog 模板
     *
     * @param itemClickListener
     */
    public static CommonMultipleBtnTipDialog createSayHiHasContactFailDialog(Context context,
                                                                             SayHiSendInfoItem sayHiSendInfoItem,
                                                                             String ladyName,
                                                                             CommonMultipleBtnTipDialog.OnDialogItemClickListener itemClickListener) {

        CommonMultipleBtnTipDialog dialog = new CommonMultipleBtnTipDialog(context);
        dialog.setTitle(context.getString(R.string.sayhi_dialog_fail_title, ladyName));
        dialog.setTitleSize(18f);
        dialog.setMessage(context.getString(R.string.sayhi_dialog_fail_has_contact_message, ladyName));
        dialog.setSubTitle(context.getString(R.string.sayhi_dialog_fail_sub_title));
        dialog.setItemClickCallback(itemClickListener);

        if(sayHiSendInfoItem.onlineStatus == AnchorOnlineStatus.Online) {
            dialog.addItem(TAB_BTN_CHAT, context.getString(R.string.sayhi_dialog_item_wechat), R.drawable.say_hi_dialog_item_wechat);
            dialog.addItem(TAB_BTN_ONE_ON_ONE, context.getString(R.string.sayhi_dialog_item_one_on_one), R.drawable.say_hi_dialog_item_one_on_one);
        }
        dialog.addItem(TAB_BTN_MAIL, context.getString(R.string.sayhi_dialog_item_mail), R.drawable.say_hi_dialog_item_mail);

        return dialog;
    }

    /**
     * SayHi发送失败(日发送量达到上限)弹出Dialog 模板
     *
     * @param itemClickListener
     */
    public static CommonMultipleBtnTipDialog createSayHiDayLimitFailDialog(Context context,
                                                                       SayHiSendInfoItem sayHiSendInfoItem,
                                                                       String ladyName,
                                                                       CommonMultipleBtnTipDialog.OnDialogItemClickListener itemClickListener) {

        CommonMultipleBtnTipDialog dialog = new CommonMultipleBtnTipDialog(context);
        dialog.setBgDrawable(R.drawable.sayhi_dialog_bg);
        dialog.setTitle(context.getString(R.string.sayhi_dialog_fail_title, ladyName));
        dialog.setTitleSize(18f);
        dialog.setMessage(context.getString(R.string.sayhi_dialog_fail_day_limit_send_message, ladyName));
        dialog.setSubTitle(context.getString(R.string.sayhi_dialog_fail_sub_title));
        dialog.setItemClickCallback(itemClickListener);

        if(!sayHiSendInfoItem.isFollow) {
            dialog.addItem(TAB_BTN_FOLLOW, context.getString(R.string.sayhi_dialog_item_follow), R.drawable.say_hi_dialog_item_follow, false);
        }
        if(sayHiSendInfoItem.onlineStatus == AnchorOnlineStatus.Online) {
            dialog.addItem(TAB_BTN_CHAT, context.getString(R.string.sayhi_dialog_item_wechat), R.drawable.say_hi_dialog_item_wechat);
        }
        dialog.addItem(TAB_BTN_MAIL, context.getString(R.string.sayhi_dialog_item_mail), R.drawable.say_hi_dialog_item_mail);

        return dialog;
    }

    /**
     * SayHi发送失败(总发送受限--已有主的播回复)弹出Dialog 模板
     *
     * @param itemClickListener
     */
    public static CommonMultipleBtnTipDialog createSayHiLimitSendFeedBackFailDialog(Context context,
                                                                                    SayHiSendInfoItem sayHiSendInfoItem,
                                                                                    String ladyName,
                                                                                    CommonMultipleBtnTipDialog.OnDialogItemClickListener itemClickListener) {

        CommonMultipleBtnTipDialog dialog = new CommonMultipleBtnTipDialog(context);
        dialog.setBgDrawable(R.drawable.sayhi_dialog_bg);
        dialog.setTitle(context.getString(R.string.sayhi_dialog_fail_title, ladyName));
        dialog.setTitleSize(18f);
        dialog.setMessage(context.getString(R.string.sayhi_dialog_fail_limit_send_feedback_message));
        dialog.setSubTitle(context.getString(R.string.sayhi_dialog_fail_sub_title));
        dialog.setItemClickCallback(itemClickListener);
        dialog.addItem(TAB_BTN_SAY_HI_LIST_RES, context.getString(R.string.sayhi_dialog_item_say_hi_responses), R.drawable.say_hi_dialog_item_say_hi);
        if(!sayHiSendInfoItem.isFollow) {
            dialog.addItem(TAB_BTN_FOLLOW, context.getString(R.string.sayhi_dialog_item_follow), R.drawable.say_hi_dialog_item_follow, false);
        }

        return dialog;
    }

    /**
     * SayHi发送失败(总发送受限--未有主的播回复)弹出Dialog 模板
     *
     * @param itemClickListener
     */
    public static CommonMultipleBtnTipDialog createSayHiLimitSendNoFeedBackFailDialog(Context context,
                                                                                      SayHiSendInfoItem sayHiSendInfoItem,
                                                                                      String ladyName,
                                                                                      CommonMultipleBtnTipDialog.OnDialogItemClickListener itemClickListener) {


        CommonMultipleBtnTipDialog dialog = new CommonMultipleBtnTipDialog(context);
        dialog.setBgDrawable(R.drawable.sayhi_dialog_bg);
        dialog.setTitle(context.getString(R.string.sayhi_dialog_fail_title, ladyName));
        dialog.setTitleSize(18f);
        dialog.setMessage(context.getString(R.string.sayhi_dialog_fail_limit_send_nofeedback_message));
        dialog.setSubTitle(context.getString(R.string.sayhi_dialog_fail_sub_title));
        dialog.setItemClickCallback(itemClickListener);
        dialog.addItem(TAB_BTN_SAY_HI_LIST_ALL, context.getString(R.string.sayhi_dialog_item_my_say_hi_responses), R.drawable.say_hi_dialog_item_say_hi);
        if(!sayHiSendInfoItem.isFollow) {
            dialog.addItem(TAB_BTN_FOLLOW, context.getString(R.string.sayhi_dialog_item_follow), R.drawable.say_hi_dialog_item_follow, false);
        }

        return dialog;
    }

    /**
     * SayHi发送失败(会员或主播没有开启SayHi权限 或 其他的未知错误)弹出Dialog 模板
     *
     * @param itemClickListener
     */
    public static CommonMultipleBtnTipDialog createSayHiAuthFailDialog(Context context,
                                                                            SayHiSendInfoItem sayHiSendInfoItem,
                                                                            String ladyName,
                                                                            CommonMultipleBtnTipDialog.OnDialogItemClickListener itemClickListener) {

        CommonMultipleBtnTipDialog dialog = new CommonMultipleBtnTipDialog(context);
        dialog.setBgDrawable(R.drawable.sayhi_dialog_bg);
        dialog.setTitle(context.getString(R.string.sayhi_dialog_fail_title, ladyName));
        dialog.setTitleSize(18f);
        dialog.setMessage(context.getString(R.string.sayhi_dialog_fail_auth_message));
        dialog.setSubTitle(context.getString(R.string.sayhi_dialog_fail_sub_title));
        dialog.setItemClickCallback(itemClickListener);

        if(!sayHiSendInfoItem.isFollow) {
            dialog.addItem(TAB_BTN_FOLLOW, context.getString(R.string.sayhi_dialog_item_follow), R.drawable.say_hi_dialog_item_follow, false);
        }
        if(sayHiSendInfoItem.onlineStatus == AnchorOnlineStatus.Online) {
            dialog.addItem(TAB_BTN_CHAT, context.getString(R.string.sayhi_dialog_item_wechat), R.drawable.say_hi_dialog_item_wechat);
        }
        dialog.addItem(TAB_BTN_MAIL, context.getString(R.string.sayhi_dialog_item_mail), R.drawable.say_hi_dialog_item_mail);

        return dialog;
    }
}
