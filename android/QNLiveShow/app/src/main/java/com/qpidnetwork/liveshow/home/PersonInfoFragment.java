package com.qpidnetwork.liveshow.home;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.framework.base.BaseFragment;
import com.qpidnetwork.liveshow.R;

/**
 */
public class PersonInfoFragment extends BaseFragment {


    public PersonInfoFragment() {
        // Required empty public constructor
        TAG = PersonInfoFragment.class.getSimpleName();
        Log.d(TAG,TAG+"()");
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_person_info,container,false);
    }


}
