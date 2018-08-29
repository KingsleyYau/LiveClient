package com.qpidnetwork.livemodule.liveshow.message;

import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;

/**
 * 私信联系人列表界面
 * Created by Hunter on 18/7/19.
 */

public class MessageContactListActivity extends BaseActionBarFragmentActivity{

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setCustomContentView(R.layout.activity_fragment_template);

        //设置头
        setTitle(getString(R.string.my_message_title), R.color.theme_default_black);

        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.replace(R.id.flContainer, new MessageContactListFragment());
        transaction.commit();
    }
}
