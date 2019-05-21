package com.qpidnetwork.livemodule.framework.base;

import android.app.Dialog;
import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;

import com.dou361.dialogui.DialogUIUtils;

/**
 * 用于navigation的Fragment基类
 *
 * @author Jagger 2019-1-30
 */
public class BaseNavFragment extends BaseFragment {

    public static String FLAG_REQUEST_BUNDLE;

    private OnFragmentInteractionListener mListener;

    private Dialog mDialogLoading;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FLAG_REQUEST_BUNDLE = this.getClass().getSimpleName();
    }

    // TODO: Rename method, update argument and hook method into UI event
    public void onButtonPressed(Uri uri) {
        if (mListener != null) {
            mListener.onFragmentInteraction(uri);
        }
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    protected void showLoading(String tips){
        if(mDialogLoading != null && mDialogLoading.isShowing()){
            return;
        }
        mDialogLoading = DialogUIUtils.showLoading(getActivity(),tips,true,false,false,false).show();
    }

    protected void hideLoading(){
        DialogUIUtils.dismiss(mDialogLoading);
    }

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnFragmentInteractionListener {
        void onFragmentInteraction(Uri uri);

        /**
         * 通知 act 一键退出当前页面
         */
        void onFinishAct();

        /**
         * Fragment向Activity主动请求参数
         * @param flag
         * @return
         */
        Bundle onRequestBundle(String flag);
    }

    protected void onFinishAct() {
        if (mListener != null) {
            mListener.onFinishAct();
        }
    }

    /**
     * Fragment向Activity主动请求参数
     */
    protected void getActivityBundle(){
        if (mListener != null) {
            Bundle bundle = mListener.onRequestBundle(FLAG_REQUEST_BUNDLE);
            if(bundle != null){
                this.setArguments(bundle);
                onGetActivityBundle();
            }
        }
    }

    /**
     * 从Activity取得参数
     */
    protected void onGetActivityBundle(){}
}
