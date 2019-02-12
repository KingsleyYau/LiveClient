package com.qpidnetwork.qnbridgemodule.util;

import android.text.TextUtils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.NumberFormat;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

public class StringUtil {

    /**
     * 合并多个字符串
     *
     * @param params
     * @return
     */
    public static String mergeMultiString(Object... params) {
        StringBuffer buff = new StringBuffer();
        for (int i = 0; i < params.length; i++) {
            buff.append(params[i]);
        }
        return buff.toString();
    }

    /**
     *
     * @param is
     * @return
     */
    public static String convertStreamToString(InputStream is) {
        String line = null;
        StringBuilder sb = new StringBuilder(8192 * 20);
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new InputStreamReader(is), 8192 * 20);

            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (reader != null) {
                    reader.close();
                }
                if (is != null)
                    is.close();

                reader = null;
                is = null;
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return sb.toString();
    }

    /**
     * 将map中的数据转换成JSON格式 的字符串
     *
     * @param map
     * @return
     */
    @SuppressWarnings({ "rawtypes", "unchecked" })
    public static String formateMapToJson(Map map) {
        StringBuffer buffer = new StringBuffer();
        buffer.append("{");
        Set<?> entrySet = map.entrySet();
        Iterator<?> it = entrySet.iterator();
        while (it.hasNext()) {
            Map.Entry<String, ?> entry = (Map.Entry<String, ?>) it.next();
            buffer.append("\"" + entry.getKey() + "\"");
            buffer.append(":");
            Object val = entry.getValue();
            if (val != null) {
                buffer.append("\"" + val.toString() + "\"");
            }
            buffer.append(",");
        }
        if (buffer.length() > 1) {
            buffer.deleteCharAt(buffer.length() - 1);
            buffer.append("}");
        } else if (buffer.length() == 1) {
            buffer.deleteCharAt(buffer.length() - 1);
        }
        return buffer.toString();
    }

    /**
     * 转换成JSON格式的字符串(其中不含{})
     *
     * @param keyValues
     * @return
     */
    public static String formateStringToJson(Object... keyValues) {
        StringBuffer buffer = new StringBuffer();
        if (keyValues.length > 0) {
            buffer.append("{");
        }
        for (int i = 0; i < keyValues.length; i += 2) {
            buffer.append("\"" + keyValues[i] + "\"");
            buffer.append(":\"");
            buffer.append(keyValues[i + 1] == null ? "" : keyValues[i + 1]);
            buffer.append("\",");
        }
        if (buffer.length() > 1) {
            buffer.deleteCharAt(buffer.length() - 1);
            buffer.append("}");
        } else if (buffer.length() == 1) {
            buffer.deleteCharAt(buffer.length() - 1);
        }

        return buffer.toString();
    }

    public static String[] split(String texts, String seperator) {
        String[] results = new String[0];
        if (texts == null) {
            return results;
        }
        return texts.split(seperator);
    }

    public static String compose(Object[] texts, String seperator) {
        if (texts == null) {
            return "";
        }
        StringBuffer sb = new StringBuffer();
        for (Object text : texts) {
            sb.append((String) text);
            sb.append(",");
        }
        if (texts.length > 0) {
            sb.deleteCharAt(sb.length() - 1);
        }
        return sb.toString();
    }

    /**
     *
     * @param s
     * @return
     */
    public static String UnicodeToGBK2(String s) {
        String[] k = s.split(";");
        String rs = "";
        for (int i = 0; i < k.length; i++) {
            int strIndex = k[i].indexOf("&#");
            String newstr = k[i];
            if (strIndex > -1) {
                String kstr = "";
                if (strIndex > 0) {
                    kstr = newstr.substring(0, strIndex);
                    rs += kstr;
                    newstr = newstr.substring(strIndex);
                }
                int m = Integer.parseInt(newstr.replace("&#", ""));
                char c = (char) m;
                rs += c;
            } else {
                rs += k[i];
            }
        }
        return rs;
    }

    /**
     * A hashing method that changes a string (like a URL) into a hash suitable
     * for using as a disk filename.
     */
    public static String hashKeyForDisk(String key) {
        String cacheKey;
        try {
            final MessageDigest mDigest = MessageDigest.getInstance("MD5");
            mDigest.update(key.getBytes());
            cacheKey = bytesToHexString(mDigest.digest());
        } catch (NoSuchAlgorithmException e) {
            cacheKey = String.valueOf(key.hashCode());
        }
        return cacheKey;
    }

    private static String bytesToHexString(byte[] bytes) {
        // http://stackoverflow.com/questions/332079
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < bytes.length; i++) {
            String hex = Integer.toHexString(0xFF & bytes[i]);
            if (hex.length() == 1) {
                sb.append('0');
            }
            sb.append(hex);
        }
        return sb.toString();
    }

    /**
     * double转字符串去科学计数法设置
     * @param value
     * @return
     */
    public static String  doubleNoScientificNotation(double value){
        NumberFormat nf = NumberFormat.getInstance();
        nf.setGroupingUsed(false);//去掉科学计数法显示
        return nf.format(value);
    }

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

    /**
     * 在指定url后追加参数(标准URI = scheme:[//authority]path[?query][#fragment])
     * @param url
     * @param data 参数集合 key = value
     * @return
     */
    public static String appendUrl(String url, Map<String, String> data) {
        String newUrl = url;
        if(!TextUtils.isEmpty(url)){
            //处理所有参数
            StringBuffer param = new StringBuffer();
            for (String key : data.keySet()) {
                param.append(key + "=" + data.get(key).toString() + "&");
            }
            String paramStr = param.toString();
            paramStr = paramStr.substring(0, paramStr.length() - 1);
            if (url.indexOf("?") >= 0) {
                paramStr = "&" + paramStr;
            } else {
                paramStr = "?" + paramStr;
            }

            StringBuilder sb = new StringBuilder(url);
            if(url.contains("#")){
                sb.insert(url.indexOf("#"), paramStr);
            }else{
                sb.append(paramStr);
            }
            newUrl = sb.toString();
        }

        return newUrl;
    }

}
