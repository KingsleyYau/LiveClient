package com.qpidnetwork.livemodule.liveshow.personal.book;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Bundle;
import android.os.Message;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Html;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.WheelView;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetScheduleInviteCreateConfigCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteBookTimeItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteConfig;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_NO_CREDIT;

/**
 * 预约私密直播界面
 *　Created by Jagger on 2017/9/21.
 */
public class BookPrivateActivity extends BaseActionBarFragmentActivity {

    private static final String ANCHOR_ID = "anchorId";
    private static final String ANCHOR_NAME = "anchorName";

    //Activiyt Result
    private final int RESULT_ADD_MOBILE = 10;
    //请求返回
    private final int REQUEST_CONFIG_SUCCESS = 0;
    private final int REQUEST_CONFIG_FAILED = 1;
    private final int REQUEST_SUMMIT_SUCCESS = 2;
    private final int REQUEST_SUMMIT_FAILED = 3;


    //数据
    private ScheduleInviteConfig mScheduleInviteConfig;
    private String mAnchorId = "";
    private String mAnchorName = "";
    private List<GiftItem> mGifts = new ArrayList<>();
    private ArrayList<String> mGiftNums = new ArrayList<String>();
    private double mSelectGiftCredit = 0d;
    private LinkedHashMap<String , List<TimeDetail>> mMapDates = new LinkedHashMap<>(); //把时间封装，方便联动(有序)
    private ArrayList<String> mDates = new ArrayList<String>();         //日期滚轮显示的数据
    private ArrayList<String> mTimes = new ArrayList<String>();         //时间滚轮显示的数据
    private int mPostionDatePick = 0;                                   //日期选中索引
    private int mPostionTimePick = 0;                                   //时间选中索引
    private String mTimeID = "";                                        //选择的日期的ID，用于提交
    private int mTimestamp = 0;                                         //选择的具体时间，用于提交
    private boolean mIsAddGift = true;                               //标记是否带礼物
    private String mGiftID = "",mGiftURL = "";
    private int mGiftSum = 0;
    private String mPhone = "";

    //控件
    private TextView mTvBookDate , mTvBookTime , mTvBookGiftCredit , mTvBookNumber ,mTvChangeNumber , mTvTipsTotalPirce , mTvNoteTips;
    private RecyclerView mRecyclerView;
    private LinearLayoutManager mLayoutManager;
    private BoolGiftAdapter mAdapter;
    private Switch mSwitchGift , mSwitchSMS;
    private LinearLayout mLinearLayoutGift , mLinearLayoutAddGift;
    private Spinner mSpinnerGift;
    private ArrayAdapter mSpinnerAdpter;
    private ButtonRaised mBtnBook;

    private class TimeDetail{
        public String timeStr;//日期（MMM dd|h:mm aa）
        public String timeId;
        public int timestamp; //预约时间　（秒数）
    }

    public static Intent getIntent(Context context, String anchorId, String anchorName){
        Intent intent = new Intent(context, BookPrivateActivity.class);
        intent.putExtra(ANCHOR_ID, anchorId);
        intent.putExtra(ANCHOR_NAME, anchorName);
        return intent;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_book_private);

        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(ANCHOR_ID)){
                mAnchorId = bundle.getString(ANCHOR_ID);
            }
            if(bundle.containsKey(ANCHOR_NAME)){
                mAnchorName = bundle.getString(ANCHOR_NAME);
            }
        }

        //设置头
        setTitle(getString(R.string.live_book_title), Color.WHITE);

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
        mTvBookTime.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showTimePickDialog();
            }
        });

        mLayoutManager = new LinearLayoutManager(mContext, LinearLayoutManager.HORIZONTAL, false);
        //礼物适配器
        mAdapter = new BoolGiftAdapter(mGifts);
        mAdapter.setOnItemClickListener(new BoolGiftAdapter.OnItemClickListener() {
            @Override
            public void OnItemClick(GiftItem giftItem) {
                //礼物单价
                mSelectGiftCredit = giftItem.credit;
                //
                onGiftSelected(giftItem);
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
                    setGitfEnable(true);
                }else{
                    setGitfEnable(false);
                }
            }
        });

        //礼物区
        mLinearLayoutGift = (LinearLayout)findViewById(R.id.ll_book_gift);
        mLinearLayoutAddGift = (LinearLayout)findViewById(R.id.ll_book_add_gift);
        mLinearLayoutAddGift.setVisibility(View.GONE);

        //礼物数量
        mSpinnerAdpter = new ArrayAdapter(mContext , android.R.layout.simple_spinner_item , mGiftNums);
        mSpinnerAdpter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

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

        //礼物总价(Total Price:)
        mTvTipsTotalPirce = (TextView) findViewById(R.id.txt_book_gift_tips);
        mTvTipsTotalPirce.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG); //下划线
        mTvTipsTotalPirce.getPaint().setAntiAlias(true);//抗锯齿

        //礼物总价
        mTvBookGiftCredit = (TextView) findViewById(R.id.txt_book_gift_price);
        mTvBookGiftCredit.setText(getString(R.string.live_talent_credits , String.format("%.2f" , 0f)));

        //电话号码
        mTvBookNumber = (TextView) findViewById(R.id.txt_book_number);

        mTvChangeNumber = (TextView) findViewById(R.id.txt_book_change_number);
        mTvChangeNumber.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent();
                i.setClass(mContext , AddMobileActivity.class);
                startActivityForResult(i,RESULT_ADD_MOBILE);
            }
        });

        //短信开关
        mSwitchSMS = (Switch)findViewById(R.id.swh_sms);
        mSwitchSMS.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                //SMS
                if(isChecked){
//                    mLinearLayoutGift.setVisibility(View.VISIBLE);
                }else{
//                    mLinearLayoutGift.setVisibility(View.GONE);
                }
            }
        });

        //提交
        mBtnBook = (ButtonRaised) findViewById(R.id.btn_book);
        mBtnBook.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onSummit();
            }
        });

        //Note
        mTvNoteTips = (TextView) findViewById(R.id.tv_book_live_note);

    }

    /**
     * 取数据
     */
    private void getData(){
        LiveRequestOperator.getInstance().GetScheduleInviteCreateConfig(mAnchorId, new OnGetScheduleInviteCreateConfigCallback() {
            @Override
            public void onGetScheduleInviteCreateConfig(boolean isSuccess, int errCode, String errMsg, ScheduleInviteConfig scheduleInviteConfig) {
                if(isSuccess){
                    mScheduleInviteConfig = filterInvalidBookTime(scheduleInviteConfig);
                    sendEmptyUiMessage(REQUEST_CONFIG_SUCCESS);
                }else {
                    sendEmptyUiMessage(REQUEST_CONFIG_FAILED);
                }

            }
        });
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        if(msg != null){
            switch (msg.what){
                case REQUEST_CONFIG_SUCCESS:
                    //取预约信息成功
                    if(mScheduleInviteConfig == null){
                        return;
                    }

                    //更新描述
                    if(mTvNoteTips != null){
                        mTvNoteTips.setText(Html.fromHtml(String.format(getResources().getString(R.string.live_note_tips), String.valueOf(mScheduleInviteConfig.bookDeposit))));
                    }

                    //处理时间
                    if(mScheduleInviteConfig.bookTimeList != null && mScheduleInviteConfig.bookTimeList.length > 0){
                        //界面显示头一个日期时间
                        mTvBookDate.setText(DateUtil.getDate(mScheduleInviteConfig.bookTimeList[0].time * 1000l));
                        mTvBookTime.setText(DateUtil.getTimeAMPM(mScheduleInviteConfig.bookTimeList[0].time * 1000l));
                        mTimeID = mScheduleInviteConfig.bookTimeList[0].timeId;
                        mTimestamp = mScheduleInviteConfig.bookTimeList[0].time;

                        //生成日期时间配对表
                        setMapDates();

                        //设置日期选项列表
                        setDateList();

                        //设置时间选项列表
                        setTimeList();
                    }else{
                        mTvBookDate.setText("");
                        mTvBookTime.setText("");
                        mBtnBook.setButtonBackground(getResources().getColor(R.color.black3));
                        mBtnBook.setEnabled(false);
                    }

                    //处理礼物
                    if(mScheduleInviteConfig.bookGiftList != null && mScheduleInviteConfig.bookGiftList.length > 0){
                        mLinearLayoutAddGift.setVisibility(View.VISIBLE);

                        for (int i = 0 ; i < mScheduleInviteConfig.bookGiftList.length; i++){
                            GiftItem item = NormalGiftManager.getInstance().queryLocalGiftDetailById(mScheduleInviteConfig.bookGiftList[i].giftId);
                            if(item != null){
                                mGifts.add(item);
                            }
                        }
                        mAdapter.notifyDataSetChanged();
                        if(mGifts.size() > 0) {
                            mAdapter.setSelection(0);
                        }
                    }

                    //处理电话号码
                    if(mScheduleInviteConfig.bookPhone == null || TextUtils.isEmpty(mScheduleInviteConfig.bookPhone.phoneNo)){
                        mPhone = "";
                        setSMSEnable(false);
                    }else{
                        mPhone = mScheduleInviteConfig.bookPhone.areaCode + "-" + mScheduleInviteConfig.bookPhone.phoneNo;
                        setSMSEnable(true);
                    }

                    break;

                case REQUEST_CONFIG_FAILED:
                    //取预约信息失败

                    break;
                case REQUEST_SUMMIT_SUCCESS:
                    //预约成功
                    onBookSuccess();
                    break;
                case REQUEST_SUMMIT_FAILED:
                    //预约失败
                    HttpRespObject response = (HttpRespObject)msg.obj;
                    if(IntToEnumUtils.intToHttpErrorType(response.errCode) == HTTP_LCC_ERR_NO_CREDIT){
                        showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                    }else{
                        Toast.makeText(mContext , response.errMsg , Toast.LENGTH_LONG).show();
                    }
                    break;
                default:
                    break;

            }
        }
    }

    /**
     * 生成日期时间配对表
     */
    private void setMapDates(){
        Arrays.sort(mScheduleInviteConfig.bookTimeList);

        for (int i = 0 ; i < mScheduleInviteConfig.bookTimeList.length; i++){
            //转为一个指定的格式
            String dateDeail = DateUtil.getDateDetail(mScheduleInviteConfig.bookTimeList[i].time * 1000l);
            //拆分
            String[] dateDeailArray = dateDeail.split("\\|");
            //取出日期作为KEY
            String date = dateDeailArray[0];
            //时间和ID作为VALUE
            TimeDetail timeDetail = new TimeDetail();
            timeDetail.timeStr = dateDeailArray[1];
            timeDetail.timeId = mScheduleInviteConfig.bookTimeList[i].timeId;
            timeDetail.timestamp = mScheduleInviteConfig.bookTimeList[i].time;

            //返回的数据排序有问题，例如会把12:00 AM　排在3:00 AM之前
            Log.d("Jagger", "setMapDates: " + dateDeail + "  " + timeDetail.timeStr + ",timestamp:" + timeDetail.timestamp);

            if(mMapDates.containsKey(date)){
                mMapDates.get(date).add(timeDetail);
            }else{
                List<TimeDetail> tempTimeDetailList = new ArrayList<>();
                tempTimeDetailList.add(timeDetail);
                mMapDates.put(date , tempTimeDetailList);
            }
        }

    }

    /**
     * 设置日期选项列表
     */
    private void setDateList(){
        mDates.clear();

        Iterator<Map.Entry<String , List<TimeDetail>>> iterator = mMapDates.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String , List<TimeDetail>> entry = iterator.next();
            String dateStr = entry.getKey();
            mDates.add(dateStr);
        }
    }

    /**
     * 设置时间选项列表
     */
    private void setTimeList(){
        mTimes.clear();
        for (TimeDetail timeDetail:mMapDates.get(mDates.get(mPostionDatePick)) ) {
            mTimes.add(timeDetail.timeStr);
        }
    }

    /**
     * 当日期被选中时
     */
    private void onDateSelected(){
        setTimeList();
        mTvBookDate.setText(mDates.get(mPostionDatePick));
    }

    /**
     * 当时间被选中时
     */
    private void onTimeSelected(){
        mTvBookTime.setText(mTimes.get(mPostionTimePick));
        //
        TimeDetail timeDetail = mMapDates.get(mDates.get(mPostionDatePick)).get(mPostionTimePick);
        mTimeID = timeDetail.timeId;
        mTimestamp = timeDetail.timestamp;
    }

    /**
     * 当礼物被选中
     * @param giftItem
     */
    private void onGiftSelected(GiftItem giftItem){
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

                    //
                    mGiftID = giftItem.id;
                    mGiftURL = giftItem.smallImgUrl;

                    break;
                }
            }
        }
    }

    /**
     * 显示礼物总价
     * @param position
     */
    private void setTotalPrice(int position){
        mGiftSum = Integer.parseInt(mGiftNums.get(position));
        double sumCredit =  mSelectGiftCredit * mGiftSum;
        mTvBookGiftCredit.setText(getString(R.string.live_talent_credits , String.format("%.2f" , sumCredit)));
    }

    /**
     * 设置礼物界面是否可用
     * @param enable
     */
    private void setGitfEnable(boolean enable){
        if(enable){
            mLinearLayoutGift.setVisibility(View.VISIBLE);
            mIsAddGift = true;
        }else {
            mLinearLayoutGift.setVisibility(View.GONE);
            mIsAddGift = false;
        }
    }

    /**
     * SMS是否可用
     * @param enable
     */
    private void setSMSEnable(boolean enable){
        if(enable){
            mSwitchSMS.setChecked(true);
            mSwitchSMS.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    return false;
                }
            });

            mTvChangeNumber.setText(R.string.live_book_change_num);
            mTvBookNumber.setVisibility(View.VISIBLE);
            mTvBookNumber.setText(mPhone);
        }else {
            //无验证号码时不可选，点击提示
            mSwitchSMS.setChecked(false);
            mSwitchSMS.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    Toast.makeText(mContext , getString(R.string.live_book_add_number_tips1) , Toast.LENGTH_SHORT).show();
                    return true;
                }
            });

            mTvChangeNumber.setText(R.string.live_book_add_num);
            mTvBookNumber.setVisibility(View.GONE);
        }
    }

    /**
     * 日期选择器
     */
    private void showDatePickDialog(){
        if(mDates.size() == 0) {
            Toast.makeText(mContext , getString(R.string.live_book_no_time_tips) , Toast.LENGTH_LONG).show();
            return;
        }

        View outerView = LayoutInflater.from(this).inflate(R.layout.live_wheel_view, null);
        WheelView wv = (WheelView) outerView.findViewById(R.id.wheel_view_wv);
        wv.setOffset(1);
        wv.setItems(mDates);
        wv.setSeletion(mPostionDatePick);
        wv.setOnWheelViewListener(new WheelView.OnWheelViewListener() {
            @Override
            public void onSelected(int selectedIndex, String item) {
                mPostionDatePick = selectedIndex;
            }
        });

        MaterialDialogAlert dialog = new MaterialDialogAlert(mContext);
        dialog.setCancelable(false);
        dialog.setCustomView(outerView);
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //设置时间列表
                onDateSelected();

                //默认选中　第一个时间
                mPostionTimePick = 0;
                onTimeSelected();
            }
        }));
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_cancel), new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        }));
        dialog.show();
    }

    /**
     * 时间选择器
     */
    private void showTimePickDialog(){
        if(mTimes.size() == 0) {
            Toast.makeText(mContext , getString(R.string.live_book_no_time_tips) , Toast.LENGTH_LONG).show();
            return;
        }

        View outerView = LayoutInflater.from(this).inflate(R.layout.live_wheel_view, null);
        WheelView wv = (WheelView) outerView.findViewById(R.id.wheel_view_wv);
        wv.setOffset(1);
        wv.setItems(mTimes);
        wv.setSeletion(mPostionTimePick);
        wv.setOnWheelViewListener(new WheelView.OnWheelViewListener() {
            @Override
            public void onSelected(int selectedIndex, String item) {
                mPostionTimePick = selectedIndex;
            }
        });

        MaterialDialogAlert dialog = new MaterialDialogAlert(mContext);
        dialog.setCancelable(false);
        dialog.setCustomView(outerView);
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onTimeSelected();
            }
        }));
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_cancel), new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        }));
        dialog.show();
    }

    /**
     * 提交
     */
    private void onSummit(){
        if(!mIsAddGift){
            mGiftID = "";
            mGiftSum = 0;
        }

        LiveRequestOperator.getInstance().CreateScheduleInvite(mAnchorId, mTimeID, mTimestamp, mGiftID, mGiftSum, mSwitchSMS.isChecked(), new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                if(isSuccess){
                    sendEmptyUiMessage(REQUEST_SUMMIT_SUCCESS);
                }else{
                    Message msg = new Message();
                    msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, null);
                    msg.what = REQUEST_SUMMIT_FAILED;
                    sendUiMessage(msg);
                }
            }
        });
    }

    /**
     * 预约成功事件
     */
    private void onBookSuccess(){
        Intent i = new Intent();
        i.putExtra(BookSuccessActivity.KEY_BROADCASTER_NAME , mAnchorName);
        i.putExtra(BookSuccessActivity.KEY_BOOK_TIME , DateUtil.getDateStr(mTimestamp *1000l , DateUtil.FORMAT_MMDDhmmaa));
        i.putExtra(BookSuccessActivity.KEY_GIFT_SUM , mGiftSum);
        i.putExtra(BookSuccessActivity.KEY_GIFT_URL , mGiftURL);
        i.setClass(mContext , BookSuccessActivity.class);
        startActivity(i);

        finish();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {
            case RESULT_ADD_MOBILE:
                //验证成功
                if( resultCode == RESULT_OK ) {
                    mPhone = data.getStringExtra(AddMobileActivity.RESULT_FULL_NUMBER);
                    setSMSEnable(true);
                }
                break;
            default:break;
        }
    }

    /**
     * 过滤去掉无法预约的事件区间
     * @param scheduleInviteConfig
     */
    private ScheduleInviteConfig filterInvalidBookTime(ScheduleInviteConfig scheduleInviteConfig){
        if(scheduleInviteConfig != null && (scheduleInviteConfig.bookTimeList != null)
                && (scheduleInviteConfig.bookTimeList.length > 0)){
            List<ScheduleInviteBookTimeItem> tempList = new ArrayList<ScheduleInviteBookTimeItem>();
            for(ScheduleInviteBookTimeItem item : scheduleInviteConfig.bookTimeList){
                if(item.bookTimeStatus == ScheduleInviteBookTimeItem.BookTimeStatus.Bookable){
                    //可预约
                    tempList.add(item);
                }
            }
            ScheduleInviteBookTimeItem[] tempArray = new ScheduleInviteBookTimeItem[tempList.size()];

            scheduleInviteConfig.bookTimeList = tempList.toArray(tempArray);
        }
        return scheduleInviteConfig;
    }
}
