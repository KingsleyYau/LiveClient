package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.statusbar.StatusBarUtil;
import com.qpidnetwork.livemodule.httprequest.item.ManBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.authorization.MainBaseInfoManager;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * Description:昵称编辑界面
 * <p>
 * Created by Harry on 2017/12/25.
 */

public class EditNickNameActivity extends BaseActionBarFragmentActivity {

    private EditText et_nickName;
    private TextView tv_nickNameCharNum;

    private ManBaseInfoItem manBaseInfoItem;
    private TextWatcher tw_msgEt;
    private int maxNickNameCharLength = 20;
    private int lastNicknameStart = 0;
    private int lastNicknameNumb = 0;
    private boolean hasNicknameChanged = false;
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_edit_nickname);

        initView();
        initData();
    }

    private void initView(){
        //状态栏颜色
        StatusBarUtil.setColor(this, Color.parseColor("#5d0e86"),0);
        setTitle(getResources().getString(R.string.profile_nickname_edit_title),Color.WHITE);
        et_nickName = (EditText) findViewById(R.id.et_nickName);
        if(null == tw_msgEt){
            tw_msgEt = new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    Log.logD(TAG,"onTextChanged-s:"+s.toString()+" start:"+start+" before:"+before+" count:"+count);
                    lastNicknameStart = start;
                    lastNicknameNumb = count;
                }

                @Override
                public void afterTextChanged(Editable s) {
                    Log.logD(TAG,"afterTextChanged-s:"+s.toString());
                    if(null != et_nickName){
                        if(s.toString().length()>maxNickNameCharLength){
                            int outNumb = s.toString().length() -maxNickNameCharLength;
                            int outStart = lastNicknameStart+lastNicknameNumb-outNumb;
                            s.delete(outStart,lastNicknameStart+lastNicknameNumb);
                            Log.logD(TAG,"afterTextChanged-outNumb:"+outNumb+" outStart:"+outStart+" s:"+s);

                            et_nickName.removeTextChangedListener(tw_msgEt);
                            et_nickName.setText(s.toString());
                            et_nickName.setSelection(outStart);
                            et_nickName.addTextChangedListener(tw_msgEt);
                        }else{
                            tv_nickNameCharNum.setText(getResources().getString(R.string.profile_nickname_charleng_tips,
                                    String.valueOf(s.toString().length()),
                                    String.valueOf(maxNickNameCharLength)));
                        }
                        boolean currClickable = s.toString().length()>=2;
                        setOperaTVTxt(getResources().getString(R.string.profile_nickname_edit_save), getResources().getColor(currClickable ?
                                R.color.profile_save_yes : R.color.profile_save_no));
                        setOperaTVTxtClickable(currClickable);
                    }
                }
            };
        }
        et_nickName.addTextChangedListener(tw_msgEt);
        tv_nickNameCharNum = (TextView) findViewById(R.id.tv_nickNameCharNum);
    }

    private void initData(){
        manBaseInfoItem = MainBaseInfoManager.getInstance().getLocalMainBaseInfo();
        if(null != manBaseInfoItem){
            et_nickName.setText(manBaseInfoItem.nickName);
            tv_nickNameCharNum.setText(getResources().getString(R.string.profile_nickname_charleng_tips,
                    String.valueOf(manBaseInfoItem.nickName.length()),
                    String.valueOf(maxNickNameCharLength)));
            boolean currClickable = manBaseInfoItem.nickName.length()>=2;
            setOperaTVTxtClickable(currClickable);
            setOperaTVTxt(getResources().getString(R.string.profile_nickname_edit_save),
                    getResources().getColor(currClickable ? R.color.profile_save_yes : R.color.profile_save_no));
        }




    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if(i == R.id.iv_commBack){
            exitNicknameModel();
        }else{
            super.onClick(v);
        }

    }

    @Override
    public void onRightTitleBtnClick() {
        super.onRightTitleBtnClick();
        String editNickname = et_nickName.getText().toString();
        Log.d(TAG,"onRightTitleBtnClick-afterNickname:"+editNickname+" beforeNickname:"+manBaseInfoItem.nickName);
        if(TextUtils.isEmpty(editNickname)){
            //昵称输入为空
            return;
        }
        if(editNickname.equals(manBaseInfoItem.nickName)){
            //昵称未更改
            hasNicknameChanged = false;
            exitNicknameModel();
            return;
        }

        for (int cha : editNickname.toCharArray()){
            if ( cha == ' ' || cha == '\t' || cha == '\r' || cha == '\n' ){
                showToast(R.string.profile_nickname_edit_tips);
                return;
            }
        }

            //昵称有更改
        showLoadingDialog();
        MainBaseInfoManager.getInstance().updateMainBaseInfo(editNickname, new MainBaseInfoManager.OnUpdateMainBaseInfoListener() {
            @Override
            public void onUpdateMainBaseInfo(final boolean isSuccess, int errCode, final String errMsg) {
                runOnUiThread(new Thread(){
                    @Override
                    public void run() {
                        hideLoadingDialog();
                        if(isSuccess){
                            hasNicknameChanged = true;
                            exitNicknameModel();
                        }else{
                            showToast(errMsg);
                        }
                    }
                });

            }
        });

        //GA统计，点击保存昵称
        onAnalyticsEvent(getResources().getString(R.string.Live_PersonalCenter_Category),
                getResources().getString(R.string.Live_PersonalCenter_Action_Save_Nickname),
                getResources().getString(R.string.Live_PersonalCenter_Label_Save_Nickname));
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if(keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN){
            //拦截返回键
            exitNicknameModel();
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 退出昵称编辑界面
     */
    private void exitNicknameModel(){
        Intent data = new Intent();
        data.putExtra("hasNicknameChanged",hasNicknameChanged);
        setResult(0,data);
        finish();
    }
}
