package com.qpidnetwork.anchor.utils;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/5/24.
 */

public class StringUtil {

    /**
     * 半角转为全角,解决TextView排版错乱问题
     * @param input
     * @return
     */
    public static String toDBC(String input) {
        char[] c = input.toCharArray();
        for (int i = 0; i< c.length; i++) {
            if (c[i] == 12288) {
                c[i] = (char) 32;
                continue;
            }if (c[i]> 65280&& c[i]< 65375)
                c[i] = (char) (c[i] - 65248);
        }
        return new String(c);
    }

    public static String addAtFirst(String str){
        return new StringBuilder("@ ").append(str).toString();
    }

    /**
     * 昵称超过12个字符时从中间截断(Hangout)
     * @param name
     * @return
     */
    public static String truncateName(String name){
        return truncateName(name, 12);
    }

    /**
     * 昵称超过@length个字符时从中截断，前后显示3个字母
     * @param name
     * @param length
     * @return
     */
    public static String truncateName(String name, int length) {
        StringBuffer truncatedName = new StringBuffer();
        if (length > 7 && name.length() > length) {    //因为前后要保留3个字母，所以至少要大于7个字符才会省略
            truncatedName.append(name.subSequence(0, 3));
            truncatedName.append("...");
            truncatedName.append(name.subSequence(name.length()-3, name.length()));
        } else {
            truncatedName.append(name);
        }
        return truncatedName.toString();
    }
}
