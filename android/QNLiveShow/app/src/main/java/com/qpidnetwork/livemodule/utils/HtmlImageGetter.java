package com.qpidnetwork.livemodule.utils;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.Html;
import android.text.Spanned;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.regex.Pattern;

/**
 * Created by Hunter Mun on 2017/7/5.
 */

public class HtmlImageGetter implements Html.ImageGetter {

    private final String TAG = HtmlImageGetter.class.getSimpleName();

    public enum HtmlImageType{
        Normal,
        AdvanceGift,
        Level
    }

    private Context context;
    //	private TypedArray expressionsIcon;
    private Pattern p;

    private int imgWidth;
    private int imgHeight;

    public HtmlImageGetter(Context context) {
        this.context = context;
        this.p = Pattern.compile("\\[img:[0-9]+\\]");
    }

    public HtmlImageGetter(Context context, int imgWidth, int imgHeight) {
        this(context);
        this.imgWidth = imgWidth;
        this.imgHeight = imgHeight;
    }

    @SuppressWarnings("deprecation")
    @Override
    public Drawable getDrawable(String source) {
        // String key = source;
        Log.i(TAG, "HtmlImageGetter getDrawable source: " + source);
        Drawable drawable = null;

        HtmlImageType imageType = getImageType(source);

        try {
            switch (imageType){
                case AdvanceGift:{
                    String giftId = source.substring(1, source.length());
                    drawable = getGiftDrawable(giftId);
                    if(drawable == null){
                        //使用礼物默认图片
                        drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_gift_qiqiu);
                    }
                }break;
                case Level:{
                    String level = source.substring(1, source.length());
                    drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_gift_qiqiu);
                }break;
                case Normal:{
                    drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_gift_qiqiu);
                }break;
                default:{
                    drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_gift_qiqiu);
                }break;
            }
            drawable.setBounds(0, 0, (imgWidth == 0 ? drawable.getIntrinsicWidth() : imgWidth),
                    (imgHeight == 0 ? drawable.getIntrinsicHeight() : imgHeight));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return drawable;
    }

    /**
     * 根据giftId读取本地图片
     * @param giftId
     * @return
     */
    private Drawable getGiftDrawable(String giftId){
        Drawable drawable = null;
        GiftItem giftItem = NormalGiftManager.getInstance().queryLocalGiftDetailById(giftId);
        if(giftItem != null && !TextUtils.isEmpty(giftItem.smallImgUrl)){
            String smallImageLocalPath = FileCacheManager.getInstance().getGiftLocalPath(giftId, giftItem.smallImgUrl);
            if(SystemUtils.fileExists(smallImageLocalPath)){
                FileInputStream is = null;
                try {
                    is = new FileInputStream(smallImageLocalPath);
//                    drawable = Drawable.createFromStream(is, "");
                    drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_gift_qiqiu);
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                }finally {
                    if(is != null){
                        //解决InputStream由于未关闭导致内存泄漏问题
                        try {
                            is.close();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }
        return drawable;
    }

    /**
     * 设置图片尺寸
     *
     * @param drawable
     * @param widthID
     * @param heightID
     */
    private void doSetPicSize(HtmlImageType type, Drawable drawable, int widthID, int heightID) {
        int width = context.getResources().getDimensionPixelSize(widthID);
        int height = context.getResources().getDimensionPixelSize(heightID);
        if (drawable != null) {
            if (type == HtmlImageType.Normal) {
                drawable.setBounds(20, 0, (width == 0 ? drawable.getIntrinsicWidth() : width),
                        (height == 0 ? drawable.getIntrinsicHeight() : height));
            } else {
                drawable.setBounds(0, 0, (width == 0 ? drawable.getIntrinsicWidth() : width),
                        (height == 0 ? drawable.getIntrinsicHeight() : height));
            }
        }
    }

    private HtmlImageType getImageType(String source){
        HtmlImageType imageType = HtmlImageType.Normal;
        if (source.startsWith("e")) {
            imageType = HtmlImageType.AdvanceGift;
        } else if (source.startsWith("l")) {// 高级表情
            imageType = HtmlImageType.Level;
        }
        return imageType;
    }

    /**
     * 获取表情文本（HTML格式）
     *
     * @param input
     * @return
     */
    public Spanned getExpressMsgHTML(String input) {

        String msg = input.replace("[gift:", "<img src=\"e");
        msg = msg.replace("]", "\">");
        msg = msg.replace("[level:", "<img src=\"l");
        msg = msg.replace("[s:", "<img src=\"");
        Spanned span = Html.fromHtml(msg, this, null);
        return span;
    }

}
