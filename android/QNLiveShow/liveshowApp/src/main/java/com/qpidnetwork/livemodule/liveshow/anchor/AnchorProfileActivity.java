package com.qpidnetwork.livemodule.liveshow.anchor;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;

/**
 * Created by Hunter Mun on 2017/10/13.
 */

public class AnchorProfileActivity extends BaseActionBarFragmentActivity{

    private static final String ANCHOR_ID = "anchorId";

    public static void launchActivity(Context context, String anchorId){
        Intent intent = new Intent(context, AnchorProfileActivity.class);
        intent.putExtra(ANCHOR_ID, anchorId);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
    }
}
