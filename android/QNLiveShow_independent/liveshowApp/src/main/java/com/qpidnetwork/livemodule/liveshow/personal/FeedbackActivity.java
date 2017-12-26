package com.qpidnetwork.livemodule.liveshow.personal;

import android.graphics.Color;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/12/25.
 */

public class FeedbackActivity extends BaseActionBarFragmentActivity {

    private TextWatcher tw_feedbackContentEt;
    private TextWatcher tw_emailEt;
    private EditText et_feedbackContent;
    private EditText et_email;
    private TextView tv_feedbackLengthLimit;
    private Button btn_commitFeedback;
    private final int maxFeedbackContentCharLength = 300;

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        TAG = FeedbackActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_feedback);
        setTitle(getResources().getString(R.string.settings_feedback), Color.WHITE);

        initView();

    }

    private void initView(){
        et_feedbackContent = (EditText) findViewById(R.id.et_feedbackContent);
        tw_feedbackContentEt = new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if(s.toString().length() > maxFeedbackContentCharLength){
                    int selectedStartIndex = et_feedbackContent.getSelectionStart();
                    int selectedEndIndex = et_feedbackContent.getSelectionEnd();
                    s.delete(selectedStartIndex-1,selectedEndIndex);
                    et_feedbackContent.removeTextChangedListener(tw_feedbackContentEt);
                    et_feedbackContent.setText(s.toString());
                    et_feedbackContent.setSelection(s.toString().length());
                    et_feedbackContent.addTextChangedListener(tw_feedbackContentEt);
                }
                tv_feedbackLengthLimit.setText(getResources().getString(R.string.settings_feedback_length_limit,
                        String.valueOf(s.toString().length()),
                        String.valueOf(maxFeedbackContentCharLength)));
                changeSubmitBtnStyle();
            }
        };
        et_feedbackContent.addTextChangedListener(tw_feedbackContentEt);
        et_email = (EditText) findViewById(R.id.et_email);
        tw_emailEt = new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                changeSubmitBtnStyle();
            }
        };
        et_email.addTextChangedListener(tw_emailEt);

        tv_feedbackLengthLimit = (TextView) findViewById(R.id.tv_feedbackLengthLimit);
        tv_feedbackLengthLimit.setText(getResources().getString(R.string.settings_feedback_length_limit,
                String.valueOf(0),String.valueOf(maxFeedbackContentCharLength)));

        btn_commitFeedback = (Button) findViewById(R.id.btn_commitFeedback);
        changeSubmitBtnStyle();
    }

    private void changeSubmitBtnStyle(){
        boolean clickable = !TextUtils.isEmpty(et_feedbackContent.getText().toString())
                &&  !TextUtils.isEmpty(et_email.getText().toString());
        btn_commitFeedback.setClickable(clickable);
        btn_commitFeedback.setBackgroundDrawable(getResources().getDrawable(
                clickable ? R.drawable.bg_interactive_video_confirm : R.drawable.bg_interactive_video_cancel));
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int id = v.getId();
        if(id == R.id.btn_commitFeedback){
            //TODO:接口调用http 6.13
            Log.d(TAG,"onSubmitFeedback");
        }
    }
}
