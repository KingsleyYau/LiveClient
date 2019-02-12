package com.qpidnetwork.livemodule.view;


import android.annotation.SuppressLint;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.util.AttributeSet;
import android.widget.EditText;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author Jagger 2018-11-6
 * 自定义EditText
 * 用于直播私信,把粘贴板中的换行和连续换行转换为一个空格
 */
@SuppressLint("AppCompatCustomView")
public class CustomEditText extends EditText {
    public CustomEditText(Context context) {
        super(context);
    }

    public CustomEditText(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public CustomEditText(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }


    @Override
    public boolean onTextContextMenuItem(int id) {
        if (id == android.R.id.paste) {
            doHandleClipboard();
        }
        return super.onTextContextMenuItem(id);
    }

    /**
     * 处理粘贴板数据
     */
    private void doHandleClipboard(){
        ClipboardManager clip = (ClipboardManager) getContext().getSystemService(Context.CLIPBOARD_SERVICE);
        //取出剪贴板中Content
        String contentOld = clip.getPrimaryClip().getItemAt(0).getText().toString();
//            Log.i("Jagger" , "onTextContextMenuItem contentOl:" + contentOld);

        //”\n”匹配换行符;
        //+	一次或多次匹配前面的字符或子表达式,+ 等效于 {1,}
        String regEx = "\n+";
        Pattern pat = Pattern.compile(regEx);
        Matcher mat = pat.matcher(contentOld);
        String contentNew = mat.replaceAll(" ");

//            Log.i("Jagger" , "onTextContextMenuItem contentNew:" + contentNew);

        //改变剪贴板中Content
        ClipData myClip = ClipData.newPlainText("text", contentNew);
        clip.setPrimaryClip(myClip);
    }
}
