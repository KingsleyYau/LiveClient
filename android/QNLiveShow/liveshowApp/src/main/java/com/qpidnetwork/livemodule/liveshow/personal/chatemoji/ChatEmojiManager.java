package com.qpidnetwork.livemodule.liveshow.personal.chatemoji;

import android.content.Context;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.text.Html;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.ImageSpan;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetEmotionListCallback;
import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory;
import com.qpidnetwork.livemodule.httprequest.item.EmotionItem;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpReqStatus;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.ImageSpanJ;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Description:表情工具类,包括正则表达式解析，获取服务器表情配置，加载/表情文件
 * <p>
 * Created by Harry on 2017/8/2.
 */

public class ChatEmojiManager {
    private final String TAG = ChatEmojiManager.class.getSimpleName();
    private EmotionCategory[] emotionCategories;
    private Map<String,EmotionItem> emotionSignMaps = new HashMap<>();
    public Map<String,String> emotionIdUrlMaps = new HashMap<>();
    private Map<String,EmotionCategory> tagEmotionMap = new HashMap<>();
    private List<String> emotionTagNames = new ArrayList<>();
    private static ChatEmojiManager instance = null;
    private StringBuilder emojiSb = new StringBuilder();
    public HttpReqStatus emojiListReqStatus = HttpReqStatus.NoReq;
    private Pattern emojiSignPattern = null;
    public static final int PATTERN_MODEL_EVERYSIGN = 0;//0-逐个规则
    public static final int PATTERN_MODEL_SIMPLESIGN = 1;//1-模糊规则
//------------------------------构造&set、get方法---------------------

    private ChatEmojiManager(){
    }

    public static ChatEmojiManager getInstance(){
        if(null == instance){
            instance = new ChatEmojiManager();
        }
        return instance;
    }

    public List<String> getEmotionTagNames(){
        return emotionTagNames;
    }

    public Map<String,EmotionCategory> getTagEmotionMap(){
        return tagEmotionMap;
    }

    public List<EmotionItem> getLocalEmojiListByType(String emojiType){
//        Log.d(TAG,"getLocalEmojiListByType-emojiType:"+emojiType);
        if(null != emotionCategories){
            for (EmotionCategory emotionCategory : emotionCategories){
                if(emotionCategory.emotionTagName.equals(emojiType) && null != emotionCategory.emotionList){
                    return Arrays.asList(emotionCategory.emotionList);
                }
            }
        }
        return null;
    }

    /**
     * 获取并本地缓存表情配置
     * @param callback
     */
    public void getEmojiList(final OnGetEmotionListCallback callback){
//        Log.d(TAG,"getEmojiList");
        if(emojiListReqStatus == HttpReqStatus.ReqSuccess && emotionCategories != null){
            if(null != callback){
                callback.onGetEmotionList(true,0,null,emotionCategories);
            }
        }

        if(HttpReqStatus.Reqing != emojiListReqStatus){
            emojiListReqStatus = HttpReqStatus.Reqing;

            LiveRequestOperator.getInstance().GetEmotionList(new OnGetEmotionListCallback() {
                @Override
                public void onGetEmotionList(boolean isSuccess, int errCode, String errMsg, EmotionCategory[] emotionCategoryList) {
                    Log.d(TAG,"getEmojiList-onGetEmotionList-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
                    if(isSuccess){
                        emojiListReqStatus = HttpReqStatus.ReqSuccess;
                        if(null != emotionCategoryList){
                            emotionCategories =  emotionCategoryList;
                            emotionSignMaps.clear();
                            emotionIdUrlMaps.clear();
                            tagEmotionMap.clear();
                            emotionTagNames.clear();
                            for(EmotionCategory emotionCategory : emotionCategoryList){
                                if(null != emotionCategory.emotionList){
                                    for(EmotionItem emotionItem : emotionCategory.emotionList){
                                        //前端对应的正则规则: \|\[\w*\]\|
                                        emotionSignMaps.put(emotionItem.emoSign,emotionItem);
                                        emotionIdUrlMaps.put(emotionItem.emoIconUrl,emotionItem.emotionId);
                                        downEmotionImg(emotionItem);
                                    }
                                }
                                if(!emotionTagNames.contains(emotionCategory.emotionTagName)){
                                    emotionTagNames.add(emotionCategory.emotionTagName);
                                }
                                if(!tagEmotionMap.containsKey(emotionCategory.emotionTagName)){
                                    tagEmotionMap.put(emotionCategory.emotionTagName,emotionCategory);
                                }
                            }
                        }
                    }else{
                        emojiListReqStatus = HttpReqStatus.ResFailed;
                    }
                    if(null != callback){
                        callback.onGetEmotionList(isSuccess,errCode,errMsg,emotionCategoryList);
                    }
                }
            });
        }
    }

    private void downEmotionImg(EmotionItem emotionItem){
        if(!TextUtils.isEmpty(emotionItem.emoIconUrl)){
            //图片下载
            final String localPath = FileCacheManager.getInstance().parseEmotionImgLocalPath(
                    emotionItem.emotionId, emotionItem.emoIconUrl);
            if(!SystemUtils.fileExists(localPath)){
                FileDownloadManager.getInstance().start(emotionItem.emoIconUrl, localPath, null);
            }
        }
    }

    /**
     * 构建正则表达式-根据快捷键
     * @return
     */
    private Pattern buildRegularPattern() {
        Log.d(TAG,"buildRegularPattern");
        if(null == emotionSignMaps){
            emotionSignMaps = new HashMap<>();
        }
        StringBuilder patternString = new StringBuilder();

        patternString.append('(');
        for(EmotionCategory emotionCategory : emotionCategories){
            EmotionItem[] emotionItems = emotionCategory.emotionList;
            if(null != emotionItems){
                for(int index=0;index<emotionItems.length; index++){
                    EmotionItem emotionItem = emotionItems[index];
                    patternString.append(Pattern.quote(emotionItem.emoSign));
                    if(index != emotionItems.length-1){
                        patternString.append('|');
                    }
                }
            }

        }
        patternString.append(')');
        String emoSign = patternString.toString();
        Log.d(TAG,"buildRegularPattern-emoSign:"+emoSign);
        return Pattern.compile(emoSign);
    }


//------------------------------用于TextView的显示---------------------

    /**
     * 解析表情富文本
     * @param str
     * @param model
     * @param width
     * @param height
     * @return
     */
    public Spanned parseEmoji(final Context context, final String str, int model, final int width, final int height){
        Log.logD(TAG,"parseEmoji-str:"+str+" model:"+model+" width:"+width+" height:"+height);
        Spanned spanned = null;
        if(PATTERN_MODEL_EVERYSIGN == model){
            emojiSignPattern = buildRegularPattern();
        }else{//\|\[\w*\]\|
            emojiSignPattern = Pattern.compile("\\|\\[\\w*\\]\\|");
        }

        try {
            String result = ChatEmojiManager.getInstance().
                    parseEmojiToImage(str, emojiSignPattern,0);
            android.util.Log.d("Jagger","parseEmoji-result:"+result);
            spanned = Html.fromHtml(result, new Html.ImageGetter() {
                        @Override
                        public Drawable getDrawable(String source) {
                            android.util.Log.i("Jagger","parseEmoji-getDrawable:"+source);
                            String id = emotionIdUrlMaps.get(source);
                            String localPath = FileCacheManager.getInstance().parseEmotionImgLocalPath(id,source);
                            Drawable drawable = null;
                            if(SystemUtils.fileExists(localPath)){
                                drawable = new BitmapDrawable(ImageUtil.decodeSampledBitmapFromFile(
                                        localPath,width == 0 ? DisplayUtil.dip2px(context,14f) : width,
                                        height == 0 ? DisplayUtil.dip2px(context,14f) : height));
                                drawable.setBounds(0, 0, (width == 0 ? drawable.getIntrinsicWidth() : width),
                                        (height == 0 ? drawable.getIntrinsicHeight() : height));
                            }

                            return drawable;
                        }
                    }, null);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return spanned;
    }

    /**
     * 选择表情
     * add by Jagger 2018-7-30
     * 返回SpannableString，在Edit中能取出表情符号（|[aa]|）,发送就没问题了。
     * 但parseEmoji方法返回Spanned，在Edit中不能取出表情符号（|[aa]|），也就没办法发送表情了
     * @param emojiTagStr
     */
    @SuppressWarnings("deprecation")
    public SpannableString parseEmoji2SpannableString(final Context context, final String emojiTagStr, final int width, final int height){
        SpannableString ss = null;

        //本地取出表情图片
        Drawable drawable = parseEmojiTagToDrawable(context , emojiTagStr , width , height);

        //替换
        if (drawable != null) {
            drawable.setBounds(0, 0, width, height);
            ImageSpanJ imgSpan = new ImageSpanJ(drawable, ImageSpanJ.ALIGN_VCENTER);
            ss = new SpannableString(emojiTagStr);
            ss.setSpan(imgSpan, 0, emojiTagStr.length(),
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        }

        return ss;
    }

    /**
     * 对spannableString进行正则判断，如果符合要求，则以表情图片代替
     *
     * @param str
     * @param patten
     * @param start
     * @throws Exception
     */
    private String parseEmojiToImage(String str, Pattern patten,
                                     int start) throws Exception {
        Log.logD(TAG,"parseEmojiToImage-str:"+str+" start:"+start);
        String resultStr = str;
        if(null != emotionSignMaps){
            Matcher matcher = patten.matcher(str);
            while (matcher.find()) {
                String key = matcher.group();
                // 返回第一个字符的索引的文本匹配整个正则表达式,ture 则继续递归
                if (TextUtils.isEmpty(key)) {
                    continue;
                }

                if (matcher.start() < start) {
                    continue;
                }
                if(emotionSignMaps.containsKey(key)){
                    EmotionItem emotionItem = emotionSignMaps.get(key);
                    String emoIconUrl = emotionItem.emoIconUrl;
                    emojiSb.delete(0,emojiSb.length());
                    int endStart = matcher.start() + key.length();
//                    Log.d(TAG,"parseEmojiToImage-start-str:"+str);
//                    Log.d(TAG,"parseEmojiToImage-str.length:"+str.length());
//                    Log.d(TAG,"parseEmojiToImage-key:"+key);
//                    Log.d(TAG,"parseEmojiToImage-matcher.start:"+matcher.start());
//                    Log.d(TAG,"parseEmojiToImage-key.length:"+key.length());
//                    Log.d(TAG,"parseEmojiToImage-endStart:"+endStart);
                    emojiSb.append(str.substring(0,matcher.start()));
                    emojiSb.append("<img src=\""+emoIconUrl+"\"/>");
                    if(endStart<str.length()){
                        emojiSb.append(str.substring(endStart,str.length()));
                    }
                    resultStr = emojiSb.toString();
//                    Log.d(TAG,"parseEmojiToImage-resultStr:"+resultStr);
//                    Log.d(TAG,"parseEmojiToImage----------------------------------");
                    if (endStart < str.length()) {
                        // 如果整个字符串还未验证完,则继续...
                        resultStr = parseEmojiToImage(resultStr, patten, endStart);
                    }
                }
                break;
            }
        }
        return resultStr;
    }

    public String parseEmojiStr(final Context context, final String str, int model){
        Log.logD(TAG,"parseEmojiStr-str:"+str+" model:"+model);
        if(PATTERN_MODEL_EVERYSIGN == model){
            emojiSignPattern = buildRegularPattern();
        }else{//\|\[\w*\]\|
            emojiSignPattern = Pattern.compile("\\|\\[\\w*\\]\\|");
        }
        String result = null;
        try {
            result = ChatEmojiManager.getInstance().
                    parseEmojiToImageSrcWithTag(str, emojiSignPattern,0);
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.logD(TAG,"parseEmojiStr-result:"+result);
        return result;
    }

    /**
     * 对spannableString进行正则判断，如果符合要求，则以表情图片代替
     *
     * @param str
     * @param patten
     * @param start
     * @throws Exception
     */
    private String parseEmojiToImageSrcWithTag(String str, Pattern patten, int start) throws Exception {
        Log.logD(TAG,"parseEmojiToImageSrcWithTag-str:"+str+" start:"+start);
        String resultStr = str;
        if(null != emotionSignMaps){
            Matcher matcher = patten.matcher(str);
            while (matcher.find()) {
                String key = matcher.group();
                // 返回第一个字符的索引的文本匹配整个正则表达式,ture 则继续递归
                if (TextUtils.isEmpty(key)) {
                    continue;
                }

                if (matcher.start() < start) {
                    continue;
                }
                if(emotionSignMaps.containsKey(key)){
                    EmotionItem emotionItem = emotionSignMaps.get(key);
//                    String emoIconUrl = emotionItem.emoIconUrl;
                    emojiSb.delete(0,emojiSb.length());
                    int endStart = matcher.start() + key.length();
//                    Log.d(TAG,"parseEmojiToImageSrcWithTag-start-str:"+str);
//                    Log.d(TAG,"parseEmojiToImageSrcWithTag-str.length:"+str.length());
//                    Log.d(TAG,"parseEmojiToImageSrcWithTag-key:"+key);
//                    Log.d(TAG,"parseEmojiToImageSrcWithTag-matcher.start:"+matcher.start());
//                    Log.d(TAG,"parseEmojiToImageSrcWithTag-key.length:"+key.length());
//                    Log.d(TAG,"parseEmojiToImageSrcWithTag-endStart:"+endStart);
                    emojiSb.append(str.substring(0,matcher.start()));
                    emojiSb.append("<img src=\"emoji"+emotionItem.emoIconUrl+"\"/>");
                    if(endStart<str.length()){
                        emojiSb.append(str.substring(endStart,str.length()));
                    }
                    resultStr = emojiSb.toString();
//                    Log.d(TAG,"parseEmojiToImageSrcWithTag-resultStr:"+resultStr);
//                    Log.d(TAG,"parseEmojiToImageSrcWithTag----------------------------------");
                    if (endStart < str.length()) {
                        // 如果整个字符串还未验证完,则继续...
                        resultStr = parseEmojiToImageSrcWithTag(resultStr, patten, endStart);
                    }
                }
                break;
            }
        }
        return resultStr;
    }

    /**
     * 根据表情tag(如：|[aa]|)在本地取出图片
     * @param context
     * @param emojiTag
     * @param width
     * @param height
     * @return
     */
    private Drawable parseEmojiTagToDrawable(final Context context, String emojiTag, final int width, final int height){
        EmotionItem emotionItem = emotionSignMaps.get(emojiTag);
        String localPath = FileCacheManager.getInstance().parseEmotionImgLocalPath(emotionItem.emotionId,emotionItem.emoUrl);
        Drawable drawable = null;
        if(SystemUtils.fileExists(localPath)){
            drawable = new BitmapDrawable(ImageUtil.decodeSampledBitmapFromFile(
                    localPath,width == 0 ? DisplayUtil.dip2px(context,14f) : width,
                    height == 0 ? DisplayUtil.dip2px(context,14f) : height));
            drawable.setBounds(0, 0, (width == 0 ? drawable.getIntrinsicWidth() : width),
                    (height == 0 ? drawable.getIntrinsicHeight() : height));
        }
        return drawable;
    }

//------------------------------用于EditText的显示---------------------
    //Note:目前edittext表情暂时显示为规则描述文本,后续根据产品需求再定是否显示表情图片
}
