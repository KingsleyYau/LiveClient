package com.qpidnetwork.livemodule.utils;

import android.text.Html;
import android.text.Spanned;

import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * Created by Jagger on 2018/2/5.
 */

public class HtmlSpannedHandler {
    private final static String TAG = HtmlSpannedHandler.class.getSimpleName();

    /**
     * * 获取表情文本（HTML格式）
     *
     * @param input   未格式化的文本内容
     * @param giftMsg 是否为发礼物消息
     * @return
     */
    public static Spanned getLiveRoomMsgHTML(CustomerHtmlTagHandler.Builder builder, String input, boolean giftMsg, boolean isHangoutRoom) {
        Log.logD(TAG, "getExpressMsgHTML-input:" + input + " giftMsg:" + giftMsg);
        String msg;
        //
        msg = input.replace("[gift:", "<jimg src=\"gift");

        //原文是:<img src="emojihttps://demo-live.charmdate.com:443/uploadfiles/emoticon/blush.png"/>
        //因为要使用居中对齐,只能在这里转换一次为jimg
        msg = msg.replace("<img src=\"emoji", "<jimg src=\"emoji");

        //为了避免误将实际消息文本中的]替换为">，这里根据消息类型同string资源中对应的格式化字符串匹配检索
        if (giftMsg) {
            if (isHangoutRoom) {
                msg = msg.replaceFirst("]", "\"/>");
            } else {
                msg = msg.replaceFirst("] </font>", "\"> </font>");
            }
        }

        //处理空格
//        msg = msg.replace(" " , "&nbsp;");    //不能这样写,会把类似这种<font color="#000000">中间的空格去掉的
//        String regEx = " {2,}";
//        Pattern pat = Pattern.compile(regEx);
//        Matcher mat = pat.matcher(msg);
//        msg = mat.replaceAll("&nbsp;");
        msg = msg.replace("  ", "&nbsp;&nbsp;");
        //处理换行
        msg = msg.replace("\n", "<br>");

        //转出
        Log.logD(TAG, "getExpressMsgHTML-output:" + msg);

        CustomerHtmlTagHandler customerHtmlTagHandler = new CustomerHtmlTagHandler();
        customerHtmlTagHandler.setBuilder(builder);

        Spanned span = Html.fromHtml(msg, null, customerHtmlTagHandler);
        return span;
    }

    /**
     * 2019/03/20 Hardy
     * 兼容已有的直播间(公开，私密)
     *
     * @param builder
     * @param input
     * @param giftMsg
     * @return
     */
    public static Spanned getLiveRoomMsgHTML(CustomerHtmlTagHandler.Builder builder, String input, boolean giftMsg) {
        return getLiveRoomMsgHTML(builder, input, giftMsg, false);
    }
}
