package com.qpidnetwork.livemodule.liveshow.personal.chatemoji;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.text.Html;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.ImageSpan;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.ArrayList;
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
    private Map<String,List<ChatEmoji>> allChatEmojies;
    private List<String> emojiTypes;
    private Map<String,Integer> patternResIdMap = new HashMap<>();
    private Map<String,Integer> descResIdMap = new HashMap<>();
    private static ChatEmojiManager instance = null;
    private StringBuilder emojiSb = new StringBuilder();
    private Pattern emojiRegularPattern = null;
    private Pattern emojiDescPattern = null;

    public static final int CHATEMOJI_MODEL_EMOJIIMG = 0;//pattern
    public static final int CHATEMOJI_MODEL_EMOJIDES = 1;//desc

//------------------------------构造&set、get方法---------------------

    public static ChatEmojiManager getInstance(){
        if(null == instance){
            instance = new ChatEmojiManager();
        }
        return instance;
    }

    public List<ChatEmoji> getChatEmojiListByType(String emojiType){
        if(null != allChatEmojies && allChatEmojies.containsKey(emojiType)){
            return allChatEmojies.get(emojiType);
        }
        return null;
    }

    public List<String> getEmojiTypes(){
        return emojiTypes;
    }

    public Map<String,List<ChatEmoji>> getAllChatEmojies(){
        return allChatEmojies;
    }

    private ChatEmojiManager(){
        allChatEmojies = new HashMap<>();
        emojiTypes = new ArrayList<>();
        List<ChatEmoji> standardEmojies = new ArrayList<>();
        standardEmojies.add(new ChatEmoji("/kiss","[吻]",null,0, R.drawable.live_chat_emoji_0,"standard"));
        standardEmojies.add(new ChatEmoji("/se","[色]",null,1,R.drawable.live_chat_emoji_1,"standard"));
        standardEmojies.add(new ChatEmoji("/kxin","[开心]",null,2,R.drawable.live_chat_emoji_2,"standard"));
        standardEmojies.add(new ChatEmoji("/cy","[大哭]",null,3,R.drawable.live_chat_emoji_3,"standard"));
        standardEmojies.add(new ChatEmoji("/dxiao","[大笑]",null,4,R.drawable.live_chat_emoji_4,"standard"));
        standardEmojies.add(new ChatEmoji("/zhk","[张狂]",null,5,R.drawable.live_chat_emoji_5,"standard"));
        standardEmojies.add(new ChatEmoji("/hx","[害羞]",null,6,R.drawable.live_chat_emoji_6,"standard"));
        standardEmojies.add(new ChatEmoji("/dy","[大爷]",null,7,R.drawable.live_chat_emoji_7,"standard"));
        standardEmojies.add(new ChatEmoji("/han","[汗]",null,8,R.drawable.live_chat_emoji_8,"standard"));
        standardEmojies.add(new ChatEmoji("/yw","[疑问]",null,9,R.drawable.live_chat_emoji_9,"standard"));
        standardEmojies.add(new ChatEmoji("/wq","[委屈]",null,10,R.drawable.live_chat_emoji_10,"standard"));
        standardEmojies.add(new ChatEmoji("/shsh","[受伤]",null,11,R.drawable.live_chat_emoji_11,"standard"));
        standardEmojies.add(new ChatEmoji("/qd","[期待]",null,12,R.drawable.live_chat_emoji_12,"standard"));
        standardEmojies.add(new ChatEmoji("/ng","[难过]",null,13,R.drawable.live_chat_emoji_13,"standard"));
        standardEmojies.add(new ChatEmoji("/kun","[困]",null,14,R.drawable.live_chat_emoji_14,"standard"));
        standardEmojies.add(new ChatEmoji("/cry","[哭]",null,15,R.drawable.live_chat_emoji_15,"standard"));
        standardEmojies.add(new ChatEmoji("/kb","[恐怖]",null,16,R.drawable.live_chat_emoji_16,"standard"));
        standardEmojies.add(new ChatEmoji("/jy","[惊讶]",null,17,R.drawable.live_chat_emoji_17,"standard"));
        standardEmojies.add(new ChatEmoji("/tsht","[吐舌头]",null,18,R.drawable.live_chat_emoji_18,"standard"));
        allChatEmojies.put("standard",standardEmojies);
        emojiTypes.add("standard");
        List<ChatEmoji> advancedEmojies = new ArrayList<>();
        advancedEmojies.add(new ChatEmoji("/gzh1","[鼓掌1]",null,19,R.drawable.live_chat_emoji_19,"advanced"));
        advancedEmojies.add(new ChatEmoji("/fh","[废话]",null,20,R.drawable.live_chat_emoji_20,"advanced"));
        advancedEmojies.add(new ChatEmoji("/dnu","[动怒]",null,21,R.drawable.live_chat_emoji_21,"advanced"));
        advancedEmojies.add(new ChatEmoji("/dksh","[打瞌睡]",null,22,R.drawable.live_chat_emoji_22,"advanced"));
        advancedEmojies.add(new ChatEmoji("/dhq","[打哈欠]",null,23,R.drawable.live_chat_emoji_23,"advanced"));
        advancedEmojies.add(new ChatEmoji("/can","[惨]",null,24,R.drawable.live_chat_emoji_24,"advanced"));
        advancedEmojies.add(new ChatEmoji("/bz","[闭嘴]",null,25,R.drawable.live_chat_emoji_25,"advanced"));
        advancedEmojies.add(new ChatEmoji("/bx","[变形]",null,26,R.drawable.live_chat_emoji_26,"advanced"));
        advancedEmojies.add(new ChatEmoji("/pzh","[拍照]",null,27,R.drawable.live_chat_emoji_27,"advanced"));
        advancedEmojies.add(new ChatEmoji("/zhm","[折磨]",null,28,R.drawable.live_chat_emoji_28,"advanced"));
        advancedEmojies.add(new ChatEmoji("/yun","[晕]",null,29,R.drawable.live_chat_emoji_29,"advanced"));
        advancedEmojies.add(new ChatEmoji("/zhd","[炸弹]",null,30,R.drawable.live_chat_emoji_30,"advanced"));
        advancedEmojies.add(new ChatEmoji("/gyin","[勾引]",null,31,R.drawable.live_chat_emoji_31,"advanced"));
        advancedEmojies.add(new ChatEmoji("/ybao","[拥抱]",null,32,R.drawable.live_chat_emoji_32,"advanced"));
        advancedEmojies.add(new ChatEmoji("/gzh2","[鼓掌2]",null,33,R.drawable.live_chat_emoji_33,"advanced"));
        advancedEmojies.add(new ChatEmoji("/qtou","[拳头]",null,34,R.drawable.live_chat_emoji_34,"advanced"));
        advancedEmojies.add(new ChatEmoji("/qiang","[强]",null,35,R.drawable.live_chat_emoji_35,"advanced"));
        advancedEmojies.add(new ChatEmoji("/bquan","[抱拳]",null,36,R.drawable.live_chat_emoji_36,"advanced"));
        advancedEmojies.add(new ChatEmoji("/wsh","[无视]",null,37,R.drawable.live_chat_emoji_37,"advanced"));
        allChatEmojies.put("advanced",advancedEmojies);
        emojiTypes.add("advanced");

        emojiRegularPattern = buildRegularPattern();
        emojiDescPattern = buildDescPattern();
    }

    /**
     * 构建正则表达式-根据快捷键
     * @return
     */
    private Pattern buildRegularPattern() {
        if(null == patternResIdMap){
            patternResIdMap = new HashMap<>();
        }
        StringBuilder patternString = new StringBuilder();

        patternString.append('(');
        if(null != emojiTypes && null != allChatEmojies){
            for (String emojiType : emojiTypes){
                if(allChatEmojies.containsKey(emojiType)){
                    List<ChatEmoji> chatEmojis = allChatEmojies.get(emojiType);
                    if(null == chatEmojis || chatEmojis.size() == 0){
                        continue;
                    }
                    for(ChatEmoji chatEmoji : chatEmojis){
                        patternString.append(Pattern.quote(chatEmoji.regular));
                        patternString.append('|');
                        if(!patternResIdMap.containsKey(chatEmoji.regular)){
                            patternResIdMap.put(chatEmoji.regular,chatEmoji.resId);
                        }
                    }
                }
            }
        }
        patternString.append(')');
        String regex = patternString.toString();
        Log.d(TAG,"buildRegularPattern-regex:"+regex);
        return Pattern.compile(regex);
    }

    /**
     * 构建正则表达式-根据快捷键
     * @return
     */
    private Pattern buildDescPattern() {

        if(null == descResIdMap){
            descResIdMap = new HashMap<>();
        }
        StringBuilder descString = new StringBuilder();

        descString.append('(');
        if(null != emojiTypes && null != allChatEmojies){
            for (String emojiType : emojiTypes){
                if(allChatEmojies.containsKey(emojiType)){
                    List<ChatEmoji> chatEmojis = allChatEmojies.get(emojiType);
                    if(null == chatEmojis || chatEmojis.size() == 0){
                        continue;
                    }
                    for(ChatEmoji chatEmoji : chatEmojis){
                        descString.append(Pattern.quote(chatEmoji.desc));
                        descString.append('|');
                        if(!descResIdMap.containsKey(chatEmoji.desc)){
                            descResIdMap.put(chatEmoji.desc,chatEmoji.resId);
                        }
                    }
                }
            }
        }
        descString.append(')');
        String regex = descString.toString();
        Log.d(TAG,"buildDescPattern-regex:"+regex);
        return Pattern.compile(regex);
    }

//------------------------------用于TextView的显示---------------------
    /**
     * 解析表情富文本
     * @param context
     * @param str
     * @param model
     * @return
     */
    public Spanned parseEmoji(final Context context, String str, int model){
        Spanned spanned = null;
        try {
            Pattern pattern = null;
            if(CHATEMOJI_MODEL_EMOJIIMG == model){
                pattern = emojiRegularPattern;
            }else if(CHATEMOJI_MODEL_EMOJIDES == model){
                pattern = emojiDescPattern;
            }
            String result = ChatEmojiManager.getInstance().
                    parseEmojiToImage(str, pattern,0,model);
            spanned = Html.fromHtml(result,
                    new Html.ImageGetter() {
                        @Override
                        public Drawable getDrawable(String source) {
                            Drawable drawable = context.getResources().getDrawable(
                                    Integer.parseInt(source));
                            drawable.setBounds(0, 0,
                                    drawable.getIntrinsicWidth(),
                                    drawable.getIntrinsicHeight());
                            return drawable;
                        }
                    }, null);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return spanned;
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
                                     int start, int model) throws Exception {
        String resultStr = str;
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
            int resId = 0;
            if(CHATEMOJI_MODEL_EMOJIIMG == model){
                resId = patternResIdMap.get(key);
            }else{
                resId = descResIdMap.get(key);
            }
            if(resId != 0){
                emojiSb.delete(0,emojiSb.length());
                int endStart = matcher.start() + key.length();
                Log.d(TAG,"parseEmojiToImage-start-str:"+str);
                Log.d(TAG,"parseEmojiToImage-str.length:"+str.length());
                Log.d(TAG,"parseEmojiToImage-key:"+key);
                Log.d(TAG,"parseEmojiToImage-matcher.start:"+matcher.start());
                Log.d(TAG,"parseEmojiToImage-key.length:"+key.length());
                Log.d(TAG,"parseEmojiToImage-endStart:"+endStart);
                emojiSb.append(str.substring(0,matcher.start()));
                emojiSb.append("<img src='"+resId+"'/>");
                if(endStart<str.length()){
                    emojiSb.append(str.substring(endStart,str.length()));
                }
                resultStr = emojiSb.toString();
                Log.d(TAG,"parseEmojiToImage-resultStr:"+resultStr);
                Log.d(TAG,"parseEmojiToImage----------------------------------");

                if (endStart < str.length()) {
                    // 如果整个字符串还未验证完,则继续...
                    resultStr = parseEmojiToImage(resultStr, patten, endStart,model);
                }
                break;
            }
        }
        return resultStr;
    }

//------------------------------用于EditText的显示---------------------
    /**
     * 解析表情,直接添加
     * @param context
     * @param chatEmoji
     * @param model
     * @return
     */
    public SpannableString parseEmoji(Context context, ChatEmoji chatEmoji, int model){
        SpannableString spannableString = null;
        if(CHATEMOJI_MODEL_EMOJIIMG == model){
            spannableString = new SpannableString(chatEmoji.regular);
            Bitmap bitmap = BitmapFactory.decodeResource(context.getResources(),
                    chatEmoji.resId);
            ImageSpan imageSpan = new ImageSpan(context, bitmap);
            spannableString.setSpan(imageSpan, 0, chatEmoji.regular.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        }else if(CHATEMOJI_MODEL_EMOJIDES == model){
            spannableString = new SpannableString(chatEmoji.desc);
//            spannableString.setSpan(chatEmoji.desc,0, chatEmoji.regular.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        }
        return spannableString;
    }


    /**
     * 解析表情富文本,识别添加
     * @param context
     * @param str
     * @return
     */
    public SpannableString parseEmojiToImage(Context context, String str){
        str = str.replaceAll("\n", "<br/>");
        Spanned fromHtml = Html.fromHtml(str);
        SpannableString spannableString = new SpannableString(fromHtml);
        try {
            spannableString =  parseEmojiToImage(context,spannableString, emojiRegularPattern,0);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return spannableString;
    }

    /**
     * 对spannableString进行正则判断，如果符合要求，则以表情图片代替
     *
     * @param context
     * @param spannableString
     * @param patten
     * @param start
     * @throws Exception
     */
    private SpannableString parseEmojiToImage(Context context, SpannableString spannableString,
                                              Pattern patten, int start) throws Exception {
        Matcher matcher = patten.matcher(spannableString);
        while (matcher.find()) {
            String key = matcher.group();
            // 返回第一个字符的索引的文本匹配整个正则表达式,ture 则继续递归
            if (TextUtils.isEmpty(key)) {
                continue;
            }

            if (matcher.start() < start) {
                continue;
            }
            int resId = patternResIdMap.get(key);
            if(resId != 0){
                // 通过上面匹配得到的字符串来生成图片资源id
                // Field field=R.drawable.class.getDeclaredField(value);
                // int resId=Integer.parseInt(field.get(null).toString());
                try {
                    Bitmap bitmap = BitmapFactory.decodeResource(context.getResources(), resId);
                    // bitmap = Bitmap.createScaledBitmap(bitmap, 50, 50, true);
                    // 通过图片资源id来得到bitmap,用一个ImageSpan来包装
                    ImageSpan imageSpan = new ImageSpan(context, bitmap);
                    // 计算该表情快捷键字符的长度,也就是要替换的字符串的长度
                    int end = matcher.start() + key.length();
                    // 将该图片替换字符串中规定的位置中
                    spannableString.setSpan(imageSpan, matcher.start(), end, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                    if (end < spannableString.length()) {
                        // 如果整个字符串还未验证完,则继续...
                        spannableString = parseEmojiToImage(context, spannableString, patten, end);
                    }
                    bitmap = null;
                } catch (Exception e) {
                    e.printStackTrace();
                } catch (OutOfMemoryError e) {
                    e.printStackTrace();
                }
                break;
            }
        }
        return spannableString;
    }
}
