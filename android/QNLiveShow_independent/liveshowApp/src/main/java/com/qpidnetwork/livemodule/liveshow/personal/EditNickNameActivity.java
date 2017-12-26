package com.qpidnetwork.livemodule.liveshow.personal;

import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.statusbar.StatusBarUtil;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/12/25.
 */

public class EditNickNameActivity extends BaseActionBarFragmentActivity {

    private EditText et_nickName;
    private TextView tv_nickNameCharNum;

    private LoginItem loginItem;
    private TextWatcher tw_msgEt;
    private int maxNickNameCharLength = 18;

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
        setTitle(getResources().getString(R.string.live_edit_profile_nickname_tips1),Color.WHITE);
        et_nickName = (EditText) findViewById(R.id.et_nickName);
        if(null == tw_msgEt){
            tw_msgEt = new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                }

                @Override
                public void afterTextChanged(Editable s) {
                    Log.logD(TAG,"afterTextChanged-s:"+s.toString());
                    if(null != et_nickName){
                        if(s.toString().length()>maxNickNameCharLength){
                            int selectedStartIndex = et_nickName.getSelectionStart();
                            int selectedEndIndex = et_nickName.getSelectionEnd();
                            s.delete(selectedStartIndex-1,selectedEndIndex);
                            et_nickName.removeTextChangedListener(tw_msgEt);
                            et_nickName.setText(s.toString());
                            et_nickName.setSelection(s.toString().length());
                            et_nickName.addTextChangedListener(tw_msgEt);
                        }else{
                            tv_nickNameCharNum.setText(getResources().getString(R.string.profile_nickname_charleng_tips,
                                    String.valueOf(s.toString().length()),
                                    String.valueOf(maxNickNameCharLength)));
                        }
                        boolean currClickable = s.toString().length()>=2;
                        setOperaTVTxt(getResources().getString(R.string.profile_nickname_edit_save),
                                getResources().getColor(currClickable ? R.color.profile_save_yes : R.color.profile_save_no));
                        setOperaTVTxtClickable(currClickable);
                    }
                }
            };
        }
        et_nickName.addTextChangedListener(tw_msgEt);
        tv_nickNameCharNum = (TextView) findViewById(R.id.tv_nickNameCharNum);
    }

    private void initData(){
        loginItem = LoginManager.getInstance().getLoginItem();
        if(null != loginItem){
            et_nickName.setText(loginItem.nickName);
            tv_nickNameCharNum.setText(getResources().getString(R.string.profile_nickname_charleng_tips,
                    String.valueOf(loginItem.nickName.length()),
                    String.valueOf(maxNickNameCharLength)));
            boolean currClickable = loginItem.nickName.length()>=2;
            setOperaTVTxtClickable(currClickable);
            setOperaTVTxt(getResources().getString(R.string.profile_nickname_edit_save),
                    getResources().getColor(currClickable ? R.color.profile_save_yes : R.color.profile_save_no));
        }

    }

    @Override
    public void onRightTitleBtnClick() {
        super.onRightTitleBtnClick();
        //TODO:1.哪个接口对应用户昵称信息更新的？(更新成功需要刷新同步loginitem)
    }
}
