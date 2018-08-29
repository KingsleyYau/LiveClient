package com.qpidnetwork.anchor.utils;

import android.text.Html;
import android.text.Spanned;

/**
 * Created by Jagger on 2018/2/5.
 */

public class HtmlSpannedHandler {
    private final static String TAG = HtmlSpannedHandler.class.getSimpleName();

    /**
     * * 获取表情文本（HTML格式）
     * @param input 未格式化的文本内容
     * @param giftMsg 是否为发礼物消息
     * @return
     */
    public static Spanned getLiveRoomMsgHTML(CustomerHtmlTagHandler.Builder builder ,String input,
                                             boolean giftMsg, boolean hasCarRoomIn ) {
        Log.logD(TAG,"getExpressMsgHTML-input:"+input+" giftMsg:"+giftMsg);
        String msg ;
        //
        msg = input.replace("[gift:", "<jimg src=\"gift");
        msg = msg.replace("[rider:", "<jimg src=\"rider");
        //原文是:<img src="emojihttps://demo-live.charmdate.com:443/uploadfiles/emoticon/blush.png"/>
        //因为要使用居中对齐,只能在这里转换一次为jimg
        msg = msg.replace("<img src=\"emoji", "<jimg src=\"emoji");

        //为了避免误将实际消息文本中的]替换为">，这里根据消息类型同string资源中对应的格式化字符串匹配检索
        if(giftMsg || hasCarRoomIn){
            msg = msg.replaceFirst("]", "\"/>");
        }

        //转出
        Log.logD(TAG,"getExpressMsgHTML-output:"+msg);

        CustomerHtmlTagHandler customerHtmlTagHandler = new CustomerHtmlTagHandler();
        customerHtmlTagHandler.setBuilder(builder);

        Spanned span = Html.fromHtml(msg, null, customerHtmlTagHandler);
        return span;
    }
}
