package com.qpidnetwork.liveshow;

import android.app.Activity;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import com.qpidnetwork.framework.widget.magicfly.PeriscopeLayout;
import com.qpidnetwork.httprequest.OnRequestLoginCallback;
import com.qpidnetwork.httprequest.RequestJni;
import com.qpidnetwork.httprequest.RequestJniAuthorization;
import com.qpidnetwork.httprequest.item.LoginItem;

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
        switch (v.getId()){
            case R.id.btnClick: {
                mPeriscopeLayout.addHeart();
            }break;
        }
    }
}
