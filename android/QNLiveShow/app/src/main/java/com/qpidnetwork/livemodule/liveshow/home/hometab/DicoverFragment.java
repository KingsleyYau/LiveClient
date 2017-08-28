package com.qpidnetwork.livemodule.liveshow.home.hometab;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.R;

/**
 */
public class DicoverFragment extends BaseFragment {


    public DicoverFragment() {
        // Required empty public constructor
        TAG = DicoverFragment.class.getSimpleName();
        Log.d(TAG,TAG+"()");
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate (R.layout.fragment_dicover_list, container, false);
        return rootView;
    }
}
