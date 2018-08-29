package com.qpidnetwork.livemodule.utils;

import android.content.Context;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.text.Html;
import android.text.Spanned;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;

import java.util.regex.Pattern;

/**
 * Created by Hunter Mun on 2017/7/5.
 */

public class HtmlImageGetter implements Html.ImageGetter {

    private final String TAG = HtmlImageGetter.class.getSimpleName();

    public enum HtmlImageType{
        Unknow,
        Gift,
        Emoji,
        AnchorA,
        AnchorB,
        TicketTag
    }

    private Context context;
    //	private TypedArray expressionsIcon;
    private Pattern p;

    private int giftImgWidth;
    private int giftImgHeight;
    private int anchorFlagImgWidth = 0;
    private int anchorFlagImgHeight = 0;

    public HtmlImageGetter(Context context) {
        this.context = context;
        this.p = Pattern.compile("\\[img:[0-9]+\\]");
    }

    public HtmlImageGetter(Context context,int giftImgWidth,int giftImgHeight,int anchorFlagImgWidth,int anchorFlagImgHeight) {
        this(context);
        this.giftImgWidth = giftImgWidth;
        this.giftImgHeight = giftImgHeight;
        this.anchorFlagImgWidth = anchorFlagImgWidth;
        this.anchorFlagImgHeight = anchorFlagImgHeight;
        Log.d(TAG,"HtmlImageGetter-anchorFlagImgWidth:"+anchorFlagImgWidth+" anchorFlagImgHeight:"+anchorFlagImgHeight);
    }

    @SuppressWarnings("deprecation")
    @Override
    public Drawable getDrawable(String source) {
        Log.d(TAG, "getDrawable-source: " + source);
        Drawable drawable = null;
        HtmlImageType imageType = getImageType(source);
        Log.d(TAG,"getDrawable-imageType:"+imageType);
        try {
            switch (imageType){
                case Gift:{
                    String giftId = source.substring(4, source.length());
                    Log.d(TAG,"getDrawable-Gift-giftId:"+giftId);
                    drawable = getGiftDrawable(giftId);
                    if(drawable == null){
                        //使用礼物默认图片
                        drawable = context.getResources().getDrawable(R.drawable.ic_default_gift);
                        drawable.setBounds(0, 0, (giftImgWidth == 0 ? drawable.getIntrinsicWidth() : giftImgWidth),
                                (giftImgHeight == 0 ? drawable.getIntrinsicHeight() : giftImgHeight));
                    }

                }break;
                case Emoji:{
                    String emojiUrl = source.substring(5,source.length());
                    Log.d(TAG,"getDrawable-Emoji-emojiUrl:"+emojiUrl);
                    if(!TextUtils.isEmpty(emojiUrl)){
                        drawable = getEmojiDrawable(emojiUrl);
                    }
                }break;
                case AnchorA:
                    drawable = context.getResources().getDrawable(R.drawable.ic_live_room_msgitem_anchor_flag_public);
                    drawable.setBounds(0, 0, (anchorFlagImgWidth == 0 ? drawable.getIntrinsicWidth() : anchorFlagImgWidth),
                            (anchorFlagImgHeight == 0 ? drawable.getIntrinsicHeight() : anchorFlagImgHeight));
                    break;
                case AnchorB:
                    drawable = context.getResources().getDrawable(R.drawable.ic_live_room_msgitem_anchor_flag_private);
                    drawable.setBounds(0, 0, (anchorFlagImgWidth == 0 ? drawable.getIntrinsicWidth() : anchorFlagImgWidth),
                            (anchorFlagImgHeight == 0 ? drawable.getIntrinsicHeight() : anchorFlagImgHeight));
                    break;
                case TicketTag:
                    drawable = context.getResources().getDrawable(R.drawable.list_program_ticket);
                    drawable.setBounds(0, 0, (anchorFlagImgWidth == 0 ? drawable.getIntrinsicWidth() : anchorFlagImgWidth),
                            (anchorFlagImgHeight == 0 ? drawable.getIntrinsicHeight() : anchorFlagImgHeight));
                    break;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return drawable;
    }

    private Drawable getEmojiDrawable(String source){
        Log.d(TAG,"getEmojiDrawable-source:"+source+" giftImgWidth:"+giftImgWidth+" giftImgHeight:"+giftImgHeight);
        String id = ChatEmojiManager.getInstance().emotionIdUrlMaps.get(source);
        String localPath = FileCacheManager.getInstance().parseEmotionImgLocalPath(id,source);
        Drawable drawable = null;
        if(SystemUtils.fileExists(localPath)){
            drawable = new BitmapDrawable(ImageUtil.decodeSampledBitmapFromFile(localPath,
                    giftImgWidth,
                    giftImgHeight));
            drawable.setBounds(0, 0, giftImgWidth,giftImgHeight);
        }
        return drawable;
    }

    /**
     * 根据giftId读取本地图片
     * @param giftId
     * @return
     */
    private Drawable getGiftDrawable(String giftId){
        Log.d(TAG,"getGiftDrawable-giftId:"+giftId+" giftImgWidth:"+giftImgWidth+" giftImgHeight:"+giftImgHeight);
        Drawable drawable = null;
        GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(giftId);
        if(giftItem != null && !TextUtils.isEmpty(giftItem.smallImgUrl)){
            String smallImageLocalPath = FileCacheManager.getInstance().getGiftLocalPath(giftId, giftItem.smallImgUrl);
            Log.d(TAG,"getGiftDrawable-smallImageLocalPath:"+smallImageLocalPath);
            boolean fileExists = SystemUtils.fileExists(smallImageLocalPath);
            Log.d(TAG,"getGiftDrawable-fileExists:"+fileExists);
            if(fileExists){
                drawable = new BitmapDrawable(ImageUtil.decodeSampledBitmapFromFile(smallImageLocalPath,
                        giftImgWidth,
                        giftImgHeight));
                drawable.setBounds(0, 0, giftImgWidth,giftImgHeight);
            }
        }
        return drawable;
    }

    private HtmlImageType getImageType(String source){
        Log.d(TAG,"getImageType-source:"+source);
        HtmlImageType imageType = HtmlImageType.Unknow;
        if (source.startsWith("gift")) {
            imageType = HtmlImageType.Gift;
        } else if (source.startsWith("emoji")){
            imageType = HtmlImageType.Emoji;
        }else if (source.equals("anchor1")){
            imageType = HtmlImageType.AnchorA;
        }else if (source.equals("anchor2")){
            imageType = HtmlImageType.AnchorB;
        }else if (source.equals("ticket")){
            imageType = HtmlImageType.TicketTag;
        }
        return imageType;
    }

    /**
     * * 获取表情文本（HTML格式）
     * @param input 未格式化的文本内容
     * @param giftMsg 是否为发礼物消息
     * @return
     */
    public Spanned getExpressMsgHTML(String input, boolean giftMsg) {
        Log.logD(TAG,"getExpressMsgHTML-input:"+input+" giftMsg:"+giftMsg);
        String msg = null;
        msg = input.replace("[gift:", "<jimg src=\"gift");
        //为了避免误将实际消息文本中的]替换为">，这里根据消息类型同string资源中对应的格式化字符串匹配检索
        if(giftMsg){
            msg = msg.replaceFirst("] </font>", "\"> </font>");
        }
        Log.logD(TAG,"getExpressMsgHTML-output:"+msg);

        Spanned span = Html.fromHtml(msg, this, null);

        return span;
    }
}
