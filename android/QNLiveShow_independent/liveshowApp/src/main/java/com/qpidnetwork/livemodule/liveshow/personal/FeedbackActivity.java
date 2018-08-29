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
import com.qpidnetwork.livemodule.httprequest.OnRequestLSSubmitFeedBackCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.regex.Pattern;

/**
 * Description:反馈
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

    private View ll_submitSuc;
    private int lastTxtChangedStart = 0;
    private int lastTxtChangedNumb = 0;
    private final int maxFeedbackContentCharLength = 300;
    private boolean isSubmiting = false;

    //邮箱地址正则匹配规则,参考http://blog.csdn.net/android_freshman/article/details/53909371
    public static final String REGEX_EMAIL = "^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}$";

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
                Log.logD(TAG,"onTextChanged-s:"+s.toString()+" start:"+start+" before:"+before+" count:"+count);
                lastTxtChangedStart = start;
                lastTxtChangedNumb = count;
            }

            @Override
            public void afterTextChanged(Editable s) {
                if(s.toString().length() > maxFeedbackContentCharLength){
                    int outNumb = s.toString().length() -maxFeedbackContentCharLength;
                    int outStart = lastTxtChangedStart+lastTxtChangedNumb-outNumb;
                    s.delete(outStart,lastTxtChangedStart+lastTxtChangedNumb);
                    et_feedbackContent.removeTextChangedListener(tw_feedbackContentEt);
                    et_feedbackContent.setText(s.toString());
                    et_feedbackContent.setSelection(outStart);
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
        btn_commitFeedback.setOnClickListener(this);
        changeSubmitBtnStyle();

        ll_submitSuc = findViewById(R.id.ll_submitSuc);
        ll_submitSuc.setVisibility(View.GONE);
    }

    /**
     * 更改提交按钮样式
     */
    private void changeSubmitBtnStyle(){
        boolean clickable = !TextUtils.isEmpty(et_feedbackContent.getText().toString())
                &&  !TextUtils.isEmpty(et_email.getText().toString());
        btn_commitFeedback.setClickable(clickable);
        btn_commitFeedback.setBackgroundDrawable(getResources().getDrawable(
                clickable ? R.drawable.bg_interactive_video_confirm : R.drawable.bg_interactive_video_cancel));
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.btn_commitFeedback:
                Log.d(TAG,"onClick-isSubmiting0:"+isSubmiting);
                if(isSubmiting){
                    return;
                }
                isSubmiting = true;
                Log.d(TAG,"onClick-isSubmiting1:"+isSubmiting);
                btn_commitFeedback.setClickable(false);
                btn_commitFeedback.setBackgroundDrawable(getResources().getDrawable(R.drawable.bg_interactive_video_cancel));
                onSubmitFeedbackClick();
                break;
            default:
                super.onClick(v);
                break;
        }
    }

    /**
     * 提交反馈
     */
    public void onSubmitFeedbackClick(){
        Log.d(TAG,"onSubmitFeedbackClick-isSubmiting0:"+isSubmiting);
        String feedbackContent = et_feedbackContent.getText().toString();
        String email = et_email.getText().toString();
        //邮箱规则校验
        if(!Pattern.matches(REGEX_EMAIL, email)){
            showToast(getResources().getString(R.string.live_sign_up_email_address_tips));
            btn_commitFeedback.setClickable(true);
            btn_commitFeedback.setBackgroundDrawable(getResources().getDrawable(R.drawable.bg_interactive_video_confirm));
            isSubmiting = false;
            Log.d(TAG,"onSubmitFeedbackClick-isSubmiting1:"+isSubmiting);
            return;
        }

        showLoadingDialog();
        RequestJniOther.SubmitFeedBack(email, feedbackContent, new OnRequestLSSubmitFeedBackCallback() {
            @Override
            public void onSubmitFeedBack(final boolean isSuccess, int errCode, final String errMsg) {
                Log.d(TAG,"onSubmitFeedBack-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
                runOnUiThread(new Thread(){
                    @Override
                    public void run() {
                        hideLoadingDialog();
                        if(isSuccess){
                            ll_submitSuc.setVisibility(View.VISIBLE);
                        }else{
                            isSubmiting = false;
                            btn_commitFeedback.setClickable(true);
                            btn_commitFeedback.setBackgroundDrawable(getResources().getDrawable(
                                    R.drawable.bg_interactive_video_confirm));
                            Log.d(TAG,"onSubmitFeedbackClick-isSubmiting2:"+isSubmiting);
                            showToast(errMsg);
                        }
                    }
                });
            }
        });

        //GA统计，点击提交反馈
        onAnalyticsEvent(getResources().getString(R.string.Live_PersonalCenter_Category),
                getResources().getString(R.string.Live_PersonalCenter_Action_Submit_Feedback),
                getResources().getString(R.string.Live_PersonalCenter_Label_Submit_Feedback));
    }
}
