package com.qpidnetwork.livemodule.framework.base;


import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

/**
 *
 */
public abstract class BaseFragment extends Fragment implements View.OnClickListener{
    public String TAG = BaseFragment.class.getSimpleName();

    public BaseFragment(){
        Log.d(TAG,TAG+"()");
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG,"onCreate");

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        Log.d(TAG,"onCreateView");
        super.onCreateView(inflater,container,savedInstanceState);
        return null;
    }

    @Override
    public void onClick(View v) {
        Log.d(TAG,"onClick");
    }
}
