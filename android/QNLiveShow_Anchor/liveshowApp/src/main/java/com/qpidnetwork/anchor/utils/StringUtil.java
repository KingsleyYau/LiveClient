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
}
