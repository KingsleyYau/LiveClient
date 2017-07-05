package com.qpidnetwork.liveshow.authorization;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.View;

import com.qpidnetwork.liveshow.R;

/**
 * Description:发送短信验证码
 * <p>
 * Created by Harry on 2017/5/22.
 */

public class ModifyPasswrodSendVerifCodeActivity extends BaseVerificationCodeActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = getClass().getSimpleName();
        super.onCreate(savedInstanceState);
        sendVerifCode();
//        startTimeCountAnima(maxTimeCount,0l);
    }


    public void onClick(View view){
        switch (view.getId()){
            case R.id.tv_tipTimeCount:
                sendVerifCode();
                break;
            case R.id.tv_nextOperate:
                if(checkInput()){
                    showToast("重设密码操作");
                    setResult(ModifyPasswordByMobileActivity.RSP_MOBILE_MODIFYPASSWORD_SUCCESSED);
                    this.finish();
                }
                break;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    /**
     * 返回当前activity的视图布局ID
     *
     * @return
     */
    @Override
    public int getActivityViewId() {
        return super.getActivityViewId();
    }

}
