package com.qpidnetwork.livemodule.liveshow.personal;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmoji;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.EmojiTabScrollLayout;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/8/2.
 */

public class TestChatEmojiActivity extends BaseActionBarFragmentActivity {

    private ChatEmoji choosedChatEmoji = null;
    private TextView tv_showEmojiContent;
    private EditText et_chat;
    private ImageView iv_emoji;
    private Button btn_send;
    private EmojiTabScrollLayout tapisl_content;
    private StringBuilder sb;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        TAG = TestChatEmojiActivity.class.getSimpleName();
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_personal_chat);
        initView();
    }

    private void initView(){
        sb = new StringBuilder("");
        tapisl_content = (EmojiTabScrollLayout)findViewById(R.id.tapisl_content);
        tapisl_content.setTabTitles(ChatEmojiManager.getInstance().getEmojiTypes());
        tapisl_content.setItemMap(ChatEmojiManager.getInstance().getAllChatEmojies());
        //xml来控制
        tapisl_content.setViewStatusChangedListener(
                new EmojiTabScrollLayout.ViewStatusChangeListener() {
            @Override
            public void onTabClick(int position, String title) {
                boolean isUnusable = !TextUtils.isEmpty(title) && title.equals("advanced");
                    tapisl_content.setUnusableTip(
                            isUnusable ? getResources().getString(R.string.tip_emoji_unusable) : "");
            }

            @Override
            public void onGridViewItemClick(View itemChildView,int position, String title, Object obj) {
                choosedChatEmoji = (ChatEmoji) obj;
                //1.解析表情,将对应的spannableString append到et_chat中
                et_chat.append(ChatEmojiManager.getInstance().
                        parseEmoji(TestChatEmojiActivity.this
                                ,choosedChatEmoji
                                ,ChatEmojiManager.CHATEMOJI_MODEL_EMOJIDES));
                //2.需要一个StringBuilder来记录所有的et中的输入内容，并在send按钮按下时将sb.toString发送出去
                Toast.makeText(TestChatEmojiActivity.this,
                        "position:"+position+" title:"+title+" id:"+choosedChatEmoji.id,
                        Toast.LENGTH_SHORT).show();
                //3.在显示区域，需要对接收到的str进行正则匹配，显示快捷键对应表情
            }
        });
        tapisl_content.notifyDataChanged();

        tv_showEmojiContent = (TextView) findViewById(R.id.tv_showEmojiContent);
        et_chat = (EditText) findViewById(R.id.et_chat);
        et_chat.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                Log.d(TAG,"beforeTextChanged-s:"+s.toString()+" start:"+start+" count:"+count+" after:"+after);
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                Log.d(TAG,"onTextChanged-s:"+s.toString()+" start:"+start+" before:"+before+" count:"+count);
            }

            @Override
            public void afterTextChanged(Editable s) {
                Log.d(TAG,"afterTextChanged-s:"+s.toString());
            }
        });
        iv_emoji = (ImageView) findViewById(R.id.iv_emoji);
        iv_emoji.setOnClickListener(this);
        btn_send = (Button) findViewById(R.id.btn_send);
        btn_send.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.iv_emoji:
                if(View.GONE == tapisl_content.getVisibility()){
                    tapisl_content.setVisibility(View.VISIBLE);
                }else{
                    tapisl_content.setVisibility(View.GONE);
                }
                break;
            case R.id.btn_send:
                tapisl_content.setVisibility(View.GONE);
                final String str =et_chat.getText().toString();
                Log.d(TAG,"onClick-et_chat.getText:"+str);
                tv_showEmojiContent.setText(ChatEmojiManager.getInstance().parseEmoji(
                        str,ChatEmojiManager.CHATEMOJI_MODEL_EMOJIIMG,0,0));
                et_chat.setText("");
                break;
            default:
                super.onClick(v);
                break;
        }

    }
}
