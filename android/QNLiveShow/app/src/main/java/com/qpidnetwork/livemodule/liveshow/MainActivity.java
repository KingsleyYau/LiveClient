package com.qpidnetwork.livemodule.liveshow;

import android.app.Activity;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.magicfly.PeriscopeLayout;
import com.qpidnetwork.livemodule.httprequest.OnRequestLoginCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;

public class MainActivity extends Activity implements View.OnClickListener{

    private PeriscopeLayout mPeriscopeLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        RequestJni.SetWebSite("192.168.88.17:8081");
//        RequestJniAuthorization.Login("P580502", "123456", new OnRequestLoginCallback(){
//            public void onRequestLogin(boolean isSuccess, String errCode, String errMsg, LoginItem item){
//                if(item != null){
//                    Log.i("hunter", "LadyId : " + item.userId + "~~~ FirstName: " + item.userName);
//                }
//            }
//        });
        mPeriscopeLayout = (PeriscopeLayout)findViewById(R.id.periscopLayout);
    }


    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.btnClick) {
            mPeriscopeLayout.addHeart();
        }
    }
}
