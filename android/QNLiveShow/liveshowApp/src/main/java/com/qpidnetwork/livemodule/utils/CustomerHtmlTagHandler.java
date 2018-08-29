package com.qpidnetwork.livemodule.utils;

import android.content.Context;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.text.Editable;
import android.text.Html;
import android.text.Spanned;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;

import org.xml.sax.XMLReader;

import java.lang.reflect.Field;
import java.util.Collection;
import java.util.Stack;

/**
 * 自定义Html标签处理类
 * Created by Jagger on 2018/2/2.
 */

public class CustomerHtmlTagHandler implements Html.TagHandler {

    public static class Builder {
        private Context context;
        private int giftImgWidth;
        private int giftImgHeight;
        private int anchorFlagImgWidth = 0;
        private int anchorFlagImgHeight = 0;

        public Context getContext() {
            return context;
        }

        public Builder setContext(Context context) {
            this.context = context;
            return this;
        }

        public int getGiftImgWidth() {
            return giftImgWidth;
        }

        public Builder setGiftImgWidth(int giftImgWidth) {
            this.giftImgWidth = giftImgWidth;
            return this;
        }

        public int getGiftImgHeight() {
            return giftImgHeight;
        }

        public Builder setGiftImgHeight(int giftImgHeight) {
            this.giftImgHeight = giftImgHeight;
            return this;
        }

        public int getAnchorFlagImgWidth() {
            return anchorFlagImgWidth;
        }

        public Builder setAnchorFlagImgWidth(int anchorFlagImgWidth) {
            this.anchorFlagImgWidth = anchorFlagImgWidth;
            return this;
        }

        public int getAnchorFlagImgHeight() {
            return anchorFlagImgHeight;
        }

        public Builder setAnchorFlagImgHeight(int anchorFlagImgHeight) {
            this.anchorFlagImgHeight = anchorFlagImgHeight;
            return this;
        }
    }

    private String TAG = "CustomerHtmlTagHandler";
    private Builder mBuilder;

    /**
     * html 标签的开始下标
     */
    private Stack<Integer> startIndex;

    /**
     * html的标签的属性值 value，如:<jimg src='icon1'></jimg> 中src的值
     */
    private Stack<String> propertyValue;

    public void setBuilder(Builder b){
        this.mBuilder = b;
    }

    @Override
    public void handleTag(boolean opening, String tag, Editable output, XMLReader xmlReader) {
//        Log.e("Jagger","handleTag:"+tag + ",output:" + output);
        if (opening) {
            handlerStartTAG(tag, output, xmlReader);
        } else {
            handlerEndTAG(tag, output);
        }
    }

    /**
     * 处理开始的标签位
     *
     * @param tag
     * @param output
     * @param xmlReader
     */
    private void handlerStartTAG(String tag, Editable output, XMLReader xmlReader) {
        //<jimg>
        if (tag.equalsIgnoreCase("jimg")) {
            handlerStartJImg(output, xmlReader);
        }
    }

    /**
     * 处理结尾的标签位
     *
     * @param tag
     * @param output
     */
    private void handlerEndTAG(String tag, Editable output) {
        //</jimg>
        if (tag.equalsIgnoreCase("jimg")) {
            handlerEndJImg(output);
        }
    }

    /**
     * <jimg>
     * @param output
     * @param xmlReader
     */
    private void handlerStartJImg(Editable output, XMLReader xmlReader) {
//        Log.i("Jagger" , "handlerStartJImg --> output:" + output.toString());

//        if (startIndex == null) {
//            startIndex = new Stack<>();
//        }
//        startIndex.push(output.length());
//
//        if (propertyValue == null) {
//            propertyValue = new Stack<>();
//        }
//
//        String value4src = getProperty(xmlReader, "src");
//        if(!TextUtils.isEmpty(value4src)){
//            propertyValue.push(value4src);
//        }

        //图片就是要在Start里处理, 参考系统Html.java类,startImg方法
        try {

            String jimgSrc = getProperty(xmlReader, "src");
//            Log.i("Jagger" , "handlerEndJImg:" + jimgSrc + ",output:" + output.toString());
            ImageSpanJ imageSpan = new ImageSpanJ(getDrawable(jimgSrc), DynamicDrawableSpanJ.ALIGN_VCENTER);

            int len = output.length();
            output.append("\uFFFC");

            output.setSpan(imageSpan, len, output.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * </jimg>
     * 对标签进行处理
     * @param output
     */
    private void handlerEndJImg(Editable output) {

//        if (!isEmpty(propertyValue)) {
//            try {
//
//                String jimgSrc = propertyValue.pop();
//                Log.i("Jagger" , "handlerEndJImg:" + jimgSrc + ",output:" + output.toString());
//                ImageSpan imageSpan = new ImageSpan(getDrawable(jimgSrc), DynamicDrawableSpan.ALIGN_BASELINE);
//
//                int s = startIndex.pop();
//                int e = 1;//output.length();
//                Log.i("Jagger" , "s:" + s + ",e:" + e);
//
//                output.setSpan(imageSpan, s, e, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
//
////                int value = Integer.parseInt(propertyValue.pop());
////                output.setSpan(new AbsoluteSizeSpan(sp2px(MainApplication.getInstance(), value)), startIndex.pop(), output.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
//            } catch (Exception e) {
//                e.printStackTrace();
//            }
//        }
    }

    /**
     * 利用反射获取html标签的属性值
     *
     * @param xmlReader
     * @param property
     * @return
     */
    private String getProperty(XMLReader xmlReader, String property) {
        try {
            Field elementField = xmlReader.getClass().getDeclaredField("theNewElement");
            elementField.setAccessible(true);
            Object element = elementField.get(xmlReader);
            Field attsField = element.getClass().getDeclaredField("theAtts");
            attsField.setAccessible(true);
            Object atts = attsField.get(element);
            Field dataField = atts.getClass().getDeclaredField("data");
            dataField.setAccessible(true);
            String[] data = (String[]) dataField.get(atts);
            Field lengthField = atts.getClass().getDeclaredField("length");
            lengthField.setAccessible(true);
            int len = (Integer) lengthField.get(atts);

            for (int i = 0; i < len; i++) {
                // 这边的property换成你自己的属性名就可以了
                if (property.equals(data[i * 5 + 1])) {
                    return data[i * 5 + 4];
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 集合是否为空
     *
     * @param collection
     * @return
     */
    public static boolean isEmpty(Collection collection) {
        return collection == null || collection.isEmpty();
    }

    //------------------------------------jimg图片处理---------------------------------------------

    public Drawable getDrawable(String source) {
        Log.d(TAG, "getDrawable-source: " + source);
        Drawable drawable = null;
        HtmlImageGetter.HtmlImageType imageType = getImageType(source);
        Log.d(TAG,"getDrawable-imageType:"+imageType);
        try {
            switch (imageType){
                case Gift:{
                    String giftId = source.substring(4, source.length());
                    Log.d(TAG,"getDrawable-Gift-giftId:"+giftId);
                    drawable = getGiftDrawable(giftId);
                    if(drawable == null){
                        //使用礼物默认图片
                        drawable = this.mBuilder.getContext().getResources().getDrawable(R.drawable.ic_default_gift);
                        drawable.setBounds(0, 0, (this.mBuilder.getGiftImgWidth() == 0 ? drawable.getIntrinsicWidth() : this.mBuilder.getGiftImgWidth()),
                                (this.mBuilder.getGiftImgHeight() == 0 ? drawable.getIntrinsicHeight() : this.mBuilder.getGiftImgHeight()));
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
                    drawable = this.mBuilder.getContext().getResources().getDrawable(R.drawable.ic_live_room_msgitem_anchor_flag_public);
                    drawable.setBounds(0, 0, (this.mBuilder.getAnchorFlagImgWidth() == 0 ? drawable.getIntrinsicWidth() : this.mBuilder.getAnchorFlagImgWidth()),
                            (this.mBuilder.getAnchorFlagImgHeight() == 0 ? drawable.getIntrinsicHeight() : this.mBuilder.getAnchorFlagImgHeight()));
                    break;
                case AnchorB:
                    drawable = this.mBuilder.getContext().getResources().getDrawable(R.drawable.ic_live_room_msgitem_anchor_flag_private);
                    drawable.setBounds(0, 0, (this.mBuilder.getAnchorFlagImgWidth() == 0 ? drawable.getIntrinsicWidth() : this.mBuilder.getAnchorFlagImgWidth()),
                            (this.mBuilder.getAnchorFlagImgHeight() == 0 ? drawable.getIntrinsicHeight() : this.mBuilder.getAnchorFlagImgHeight()));
                    break;
                case TicketTag:
                    drawable = this.mBuilder.getContext().getResources().getDrawable(R.drawable.ic_hasticket);
                    drawable.setBounds(0, 0, (this.mBuilder.getGiftImgWidth() == 0 ? drawable.getIntrinsicWidth() : this.mBuilder.getGiftImgWidth()),
                            (this.mBuilder.getGiftImgHeight() == 0 ? drawable.getIntrinsicHeight() : this.mBuilder.getGiftImgHeight()));
                    break;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return drawable;
    }

    private Drawable getEmojiDrawable(String source){
        Log.d(TAG,"getEmojiDrawable-source:"+source+" giftImgWidth:"+this.mBuilder.getGiftImgWidth()+" giftImgHeight:"+this.mBuilder.getGiftImgHeight());
        String id = ChatEmojiManager.getInstance().emotionIdUrlMaps.get(source);
        String localPath = FileCacheManager.getInstance().parseEmotionImgLocalPath(id,source);
        Drawable drawable = null;
        if(SystemUtils.fileExists(localPath)){
            drawable = new BitmapDrawable(ImageUtil.decodeSampledBitmapFromFile(localPath,
                    this.mBuilder.getGiftImgWidth(),
                    this.mBuilder.getGiftImgHeight()));
            drawable.setBounds(0, 0, this.mBuilder.getGiftImgWidth(),this.mBuilder.getGiftImgHeight());
        }
        return drawable;
    }

    /**
     * 根据giftId读取本地图片
     * @param giftId
     * @return
     */
    private Drawable getGiftDrawable(String giftId){
        Log.d(TAG,"getGiftDrawable-giftId:"+giftId+" giftImgWidth:"+this.mBuilder.getGiftImgWidth()+" giftImgHeight:"+this.mBuilder.getGiftImgHeight());
        Drawable drawable = null;
        GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(giftId);
        if(giftItem != null && !TextUtils.isEmpty(giftItem.smallImgUrl)){
            String smallImageLocalPath = FileCacheManager.getInstance().getGiftLocalPath(giftId, giftItem.smallImgUrl);
            Log.d(TAG,"getGiftDrawable-smallImageLocalPath:"+smallImageLocalPath);
            boolean fileExists = SystemUtils.fileExists(smallImageLocalPath);
            Log.d(TAG,"getGiftDrawable-fileExists:"+fileExists);
            if(fileExists){
                drawable = new BitmapDrawable(ImageUtil.decodeSampledBitmapFromFile(smallImageLocalPath,
                        this.mBuilder.getGiftImgWidth(),
                        this.mBuilder.getGiftImgHeight()));
                drawable.setBounds(0, 0, this.mBuilder.getGiftImgWidth(),this.mBuilder.getGiftImgHeight());
            }
        }
        return drawable;
    }

    private HtmlImageGetter.HtmlImageType getImageType(String source){
        Log.d(TAG,"getImageType-source:"+source);
        HtmlImageGetter.HtmlImageType imageType = HtmlImageGetter.HtmlImageType.Unknow;
        if (source.startsWith("gift")) {
            imageType = HtmlImageGetter.HtmlImageType.Gift;
        } else if (source.startsWith("emoji")){
            imageType = HtmlImageGetter.HtmlImageType.Emoji;
        }else if (source.equals("anchor1")){
            imageType = HtmlImageGetter.HtmlImageType.AnchorA;
        }else if (source.equals("anchor2")){
            imageType = HtmlImageGetter.HtmlImageType.AnchorB;
        }else if (source.equals("ticket")){
            imageType = HtmlImageGetter.HtmlImageType.TicketTag;
        }
        return imageType;
    }
}
