package com.qpidnetwork.livemodule.liveshow.personal.book;

import android.app.AlertDialog;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Message;
import android.os.health.UidHealthStats;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.WheelView;
import com.qpidnetwork.livemodule.httprequest.OnGetScheduleInviteCreateConfigCallback;
import com.qpidnetwork.livemodule.httprequest.RequstJniSchedule;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteConfig;
import com.qpidnetwork.livemodule.liveshow.ad.ADAnchorAdapter;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 预约私密直播界面
 *　Created by Jagger on 2017/9/21.
 */
public class BookPrivateActivity extends BaseActionBarFragmentActivity {

    private final int REQUEST_CONFIG_SUCCESS = 0;
    private final int REQUEST_CONFIG_FAILED = 1;

    //数据
    private ScheduleInviteConfig mScheduleInviteConfig;
    private String mAnchorId = "alxtest1";
    private UIHandler mUIHandler;
    private List<GiftItem> mGifts = new ArrayList<>();
    private ArrayList<String> mGiftNums = new ArrayList<String>();
    private double mSelectGiftCredit = 0d;
    private ArrayList<String> mDates = new ArrayList<String>();
    private ArrayList<String> mTimes = new ArrayList<String>();

    //控件
    private TextView mTvBookDate , mTvBookTime , mTvBookGiftCredit;
    private RecyclerView mRecyclerView;
    private LinearLayoutManager mLayoutManager;
    private BoolGiftAdapter mAdapter;
    private Switch mSwitchGift;
    private LinearLayout mLinearLayoutGift;
    private Spinner mSpinnerGift;
    private ArrayAdapter mSpinnerAdpter;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_book_private);

        //设置头
        getCustomActionBar().setTitle(getString(R.string.live_book_title), Color.GRAY);

        //
        initUI();

        //
        getData();
    }

    private void initUI(){
        //时间
        mTvBookDate = (TextView)findViewById(R.id.txt_book_date);
        mTvBookDate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showDatePickDialog();
            }
        });
        mTvBookTime = (TextView)findViewById(R.id.txt_book_time);

        mLayoutManager = new LinearLayoutManager(mContext, LinearLayoutManager.HORIZONTAL, false);
        //礼物适配器
        mAdapter = new BoolGiftAdapter(mGifts);
        mAdapter.setOnItemClickListener(new BoolGiftAdapter.OnItemClickListener() {
            @Override
            public void OnItemClick(GiftItem giftItem) {
                //礼物单价
                mSelectGiftCredit = giftItem.credit;
                //处理礼物
                if(mScheduleInviteConfig.bookGiftList.length > 0){
                    for (int i = 0 ; i < mScheduleInviteConfig.bookGiftList.length ; i++){
                        //找到对应的礼物可选数量列表
                        if(mScheduleInviteConfig.bookGiftList[i].giftId.equals(giftItem.id)){
                            mGiftNums.clear();

                            //取出可选礼物数量列表
                            if(mScheduleInviteConfig.bookGiftList[i].giftChooser.length > 0){
                                int position = 0;
                                for(int k = 0 ; k < mScheduleInviteConfig.bookGiftList[i].giftChooser.length  ; k ++){
                                    mGiftNums.add(String.valueOf(mScheduleInviteConfig.bookGiftList[i].giftChooser[k]));

                                    //取出默认选中
                                    if(mScheduleInviteConfig.bookGiftList[i].giftChooser[k] == mScheduleInviteConfig.bookGiftList[i].defaultChoose){
                                        position = k;
                                    }
                                }
                                mSpinnerAdpter.notifyDataSetChanged();
                                mSpinnerGift.setSelection(position);
                                setTotalPrice(position);
                            }
                            break;
                        }
                    }
                }
            }
        });

        //礼物列表
        mRecyclerView = (RecyclerView)findViewById(R.id.rcv_vgift);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mRecyclerView.setAdapter(mAdapter);

        //礼物开关
        mSwitchGift = (Switch)findViewById(R.id.swh_add_gift);
        mSwitchGift.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                //送礼
                if(isChecked){
                    mLinearLayoutGift.setVisibility(View.VISIBLE);
                }else{
                    mLinearLayoutGift.setVisibility(View.GONE);
                }
            }
        });

        //礼物区
        mLinearLayoutGift = (LinearLayout)findViewById(R.id.ll_book_gift);

        //礼物数量
        mSpinnerAdpter = new ArrayAdapter(mContext , android.R.layout.simple_spinner_item , mGiftNums);

        mSpinnerGift = (Spinner)findViewById(R.id.spinner_book_gift_sum);
        mSpinnerGift.setAdapter(mSpinnerAdpter);
        mSpinnerGift.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                setTotalPrice(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        //礼物总价
        mTvBookGiftCredit = (TextView) findViewById(R.id.txt_book_gift_price);

    }

    /**
     * 取数据
     */
    private void getData(){

        mUIHandler = new UIHandler(this){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                if(msg != null){
                    switch (msg.what){
                        case REQUEST_CONFIG_SUCCESS:

                            //处理时间
                            if(mScheduleInviteConfig.bookTimeList.length > 0){
                                mTvBookDate.setText(DateUtil.getDate(mScheduleInviteConfig.bookTimeList[0].time * 1000l));
                                mTvBookTime.setText(DateUtil.getTimeAMPM(mScheduleInviteConfig.bookTimeList[0].time * 1000l));

                                //
                                mDates.clear();
                                for (int i = 0 ; i < mScheduleInviteConfig.bookTimeList.length; i++){
                                    mDates.add(String.valueOf(mScheduleInviteConfig.bookTimeList[i].time));
                                }
                            }

                            //处理礼物
                            if(mScheduleInviteConfig.bookGiftList.length > 0){
                                for (int i = 0 ; i < mScheduleInviteConfig.bookGiftList.length; i++){
                                    mGifts.add(
                                            NormalGiftManager.getInstance().queryLocalGiftDetailById(mScheduleInviteConfig.bookGiftList[i].giftId)
                                    );
                                }
                                mAdapter.notifyDataSetChanged();
                            }

                            break;

                        case REQUEST_CONFIG_FAILED:
                            break;
                    }
                }
            }
        };

        RequstJniSchedule.GetScheduleInviteCreateConfig(mAnchorId, new OnGetScheduleInviteCreateConfigCallback() {
            @Override
            public void onGetScheduleInviteCreateConfig(boolean isSuccess, int errCode, String errMsg, ScheduleInviteConfig scheduleInviteConfig) {

                if(isSuccess){
                    mScheduleInviteConfig = scheduleInviteConfig;
                    mUIHandler.sendEmptyMessage(REQUEST_CONFIG_SUCCESS);
                }else {
                    mUIHandler.sendEmptyMessage(REQUEST_CONFIG_FAILED);
                }

            }
        });
    }

    /**
     * 显示礼物总价
     * @param position
     */
    private void setTotalPrice(int position){
        String sumStr = mGiftNums.get(position);
        double sumCredit =  mSelectGiftCredit * Integer.parseInt(sumStr);
        mTvBookGiftCredit.setText(getString(R.string.live_talent_credits , String.format("%.2f" , sumCredit)));// .valueOf(sumCredit)));
    }

    /**
     * 日期选择器
     */
    private void showDatePickDialog(){
        View outerView = LayoutInflater.from(this).inflate(R.layout.live_wheel_view, null);
        WheelView wv = (WheelView) outerView.findViewById(R.id.wheel_view_wv);
        wv.setOffset(2);
        wv.setItems(mDates);
        wv.setSeletion(0);
        wv.setOnWheelViewListener(new WheelView.OnWheelViewListener() {
            @Override
            public void onSelected(int selectedIndex, String item) {
                Log.d(TAG, "[Dialog]selectedIndex: " + selectedIndex + ", item: " + item);
                mTvBookDate.setText(item);
            }
        });

//        new AlertDialog.Builder(this)
//                .setTitle("WheelView in Dialog")
//                .setView(outerView)
//                .setPositiveButton("OK", null)
//                .show();

        MaterialDialogAlert dialog = new MaterialDialogAlert(mContext);
        dialog.setCancelable(false);
        dialog.setContentView(outerView);
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        }));
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_cancel), new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        }));
        dialog.show();
    }
}
