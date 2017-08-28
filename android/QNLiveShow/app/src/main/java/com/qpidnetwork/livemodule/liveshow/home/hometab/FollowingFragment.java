package com.qpidnetwork.livemodule.liveshow.home.hometab;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.R;

public class FollowingFragment extends BaseFragment {


    public FollowingFragment() {
        // Required empty public constructor
        TAG = FollowingFragment.class.getSimpleName();
        Log.d(TAG,TAG+"()");
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate (R.layout.fragment_following_list, container, false);
        return rootView;
    }
}
