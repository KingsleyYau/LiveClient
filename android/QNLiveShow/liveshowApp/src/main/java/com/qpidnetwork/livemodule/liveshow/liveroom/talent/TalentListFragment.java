package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.RecycleViewDivider;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.view.ButtonRaised;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 才艺列表
 */
public class TalentListFragment extends Fragment {
    private String TAG = "Jagger";

    //启动参数
    private static final String PARAM_ROOM_ID = "PARAM_ROOM_ID";
    private static final String PARAM_ART_NICKNAME = "PARAM_ART_NICKNAME";

    //控件
    private TalentsAdapter mAdapter;
    private List<TalentInfoItem> mDatas = new ArrayList<>();
    private ImageView iv_closeTalentPw;
    private RecyclerView rv_talentList;
    private View ll_loading;
    private View ll_errorRetry;
    private View ll_emptyData;
    private TextView tv_listTitle , tv_error_msg;
//    private ButtonRaised btn_reloadTalentList;

    //数据
    private boolean getTalentListSuccess = false;
    private String mRoomId , mArtNickName;
    private TalentsAdapter.onItemClickedListener mOnItemClickedListener;
    public void setOnItemClickedListener( TalentsAdapter.onItemClickedListener listener){
        mOnItemClickedListener = listener;
    }
    private onTitleEventListener mOnTitleEventListener;
    public void setOnTitleEventListener(onTitleEventListener listener){
        mOnTitleEventListener = listener;
    }

    /**
     * 这个界面的事件响应
     */
    public interface onTitleEventListener {
        void onCloseClicked();
    }

    /**
     * 带参数启动方式
     * @param roomId
     * @return
     */
    public static TalentListFragment newInstance(String roomId , String artNickName){
        TalentListFragment fragment = new TalentListFragment();
        Bundle bundle = new Bundle();
        bundle.putString( PARAM_ROOM_ID, roomId);
        bundle.putString( PARAM_ART_NICKNAME, artNickName);
        fragment.setArguments(bundle);
        return fragment;
    }

    /**
     * 4
     * @param savedInstanceState
     */
    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        //取启动参数
        if (getArguments() != null) {
            if (getArguments().containsKey(PARAM_ROOM_ID)) {
                mRoomId = getArguments().getString(PARAM_ROOM_ID);
            }

            if (getArguments().containsKey(PARAM_ART_NICKNAME)) {
                mArtNickName = getArguments().getString(PARAM_ART_NICKNAME);
                tv_listTitle.setText(getString(R.string.live_talent_title , mArtNickName));
            }
        }

        getTalentsData();
    }

    /**
     * 3
     * @param inflater
     * @param container
     * @param savedInstanceState
     * @return
     */
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = LayoutInflater.from(getActivity()).inflate(R.layout.view_live_popupwindow_talents_list,container,false);

        iv_closeTalentPw = (ImageView) view.findViewById(R.id.iv_closeTalentPw);
        iv_closeTalentPw.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(mOnTitleEventListener != null){
                    mOnTitleEventListener.onCloseClicked();
                }
            }
        });
        rv_talentList = (RecyclerView) view.findViewById(R.id.rv_talentList);
        //创建默认的线性LayoutManager
        LinearLayoutManager layoutManager = new LinearLayoutManager(getActivity());
        rv_talentList.setLayoutManager(layoutManager);
        //设置分割线
        rv_talentList.addItemDecoration(new RecycleViewDivider(getActivity(), LinearLayoutManager.VERTICAL, R.drawable.live_divider_talent_list));
        //如果可以确定每个item的高度是固定的，设置这个选项可以提高性能
        rv_talentList.setHasFixedSize(true);
        //创建并设置Adapter
        mAdapter = new TalentsAdapter(mDatas);
        if(mOnItemClickedListener != null){
            mAdapter.setOnRequestClickedListener(mOnItemClickedListener);
        }
        tv_listTitle = (TextView) view.findViewById(R.id.tv_listTitle);
        rv_talentList.setAdapter(mAdapter);
        rv_talentList.setVisibility(View.GONE);
        ll_loading = view.findViewById(R.id.ll_loading);
        ll_loading.setVisibility(View.VISIBLE);
        ll_errorRetry = view.findViewById(R.id.ll_errorRetry);
        ll_errorRetry.setVisibility(View.GONE);
        ll_errorRetry.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                reload();
            }
        });
        ll_emptyData = view.findViewById(R.id.ll_emptyData);
        ll_emptyData.setVisibility(View.GONE);
        ll_emptyData.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                reload();
            }
        });

        tv_error_msg = (TextView) view.findViewById(R.id.tv_error_msg);

        TalentManager.getInstance().registerOnTalentEventListener(new TalentManager.onTalentEventListener() {
            @Override
            public void onGetTalentList(HttpRespObject httpRespObject) {
                getTalentListSuccess = httpRespObject.isSuccess;

                if(!httpRespObject.isSuccess){
                    tv_error_msg.setText(httpRespObject.errMsg);
                }

                refreshData((TalentInfoItem[])httpRespObject.data);
            }

            @Override
            public void onConfirm(TalentInfoItem talent) {

            }
        });
        return view;
    }

    private void refreshDataStatusView(boolean isLoading,boolean isErrRetry,boolean isEmpty){
        Log.d(TAG,"refreshDataStatusView-isLoading:"+isLoading+" isErrRetry:"+isErrRetry+" isEmpty:"+isEmpty);
        ll_errorRetry.setVisibility(isErrRetry ? View.VISIBLE : View.GONE);
        ll_emptyData.setVisibility(isEmpty ? View.VISIBLE : View.GONE);
        ll_loading.setVisibility(isLoading ? View.VISIBLE : View.GONE);
        if(isErrRetry || isEmpty){
            rv_talentList.setVisibility(View.GONE);
        }else{
            rv_talentList.setVisibility(View.VISIBLE);
        }
    }

    private void refreshData(TalentInfoItem[] datas){
        //转为列表，方便数据刷新
        if(datas != null){
            mDatas.clear();
            mDatas.addAll(Arrays.asList(datas));
        }

        mAdapter.notifyDataSetChanged();
        refreshDataStatusView(false,!getTalentListSuccess,null != mDatas && mDatas.size() < 1 && getTalentListSuccess);
    }

    /**
     * 请求才艺列表数据
     */
    private void getTalentsData(){
        Log.d(TAG,"getTalentList-roomId:"+mRoomId);
        getTalentListSuccess = false;
        TalentManager.getInstance().getTalentList();
    }

    /**
     * 重新加载
     */
    private void reload(){
        refreshDataStatusView(true,false,false);
        getTalentsData();
    }
}
