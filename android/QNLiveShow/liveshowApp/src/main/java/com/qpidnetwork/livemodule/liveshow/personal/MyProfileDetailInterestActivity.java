package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveDomainRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetMyProfileCallback;
import com.qpidnetwork.livemodule.httprequest.OnUpdateMyProfileCallback;
import com.qpidnetwork.livemodule.httprequest.item.LSProfileItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.MyProfileInterestUtil;
import com.qpidnetwork.livemodule.utils.NetworkUtil;
import com.qpidnetwork.livemodule.view.MaterialAppBar;
import com.qpidnetwork.livemodule.view.wrap.WrapBaseAdapter;
import com.qpidnetwork.livemodule.view.wrap.WrapListView;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.util.ArrayList;
import java.util.List;

/**
 * MyProfile模块
 *
 * @author Max.Chiu
 */
public class MyProfileDetailInterestActivity extends BaseFragmentActivity implements OnClickListener {

    public static final String INTEREST = "interest";

    public class CheckItem {

        public CheckItem() {

        }

        public CheckItem(
                String id,
                String name,
                int imageResId,
                boolean isSigned) {
            this.id = id;
            this.name = name;
            this.isSigned = isSigned;

            this.imageResId = imageResId;
        }

        public String id;
        public String name;
        public boolean isSigned;

        // 2018/10/31 Hardy
        public int imageResId;
    }

    private class InterestLabelAdapter extends WrapBaseAdapter implements OnClickListener {

        private Context mContext;
        private List<CheckItem> mList;

        public InterestLabelAdapter(Context context, List<CheckItem> list) {
            this.mContext = context;
            this.mList = list;
        }

        @Override
        protected int getCount() {
            return mList.size();
        }

        @Override
        protected CheckItem getItem(int position) {
            return mList.get(position);
        }

        @Override
        protected int getItemId(int position) {
            return position;
        }

        @Override
        protected View getView(final int position, View convertView, ViewGroup parent) {
            ViewHolder holder;
            if (convertView == null) {
                holder = new ViewHolder();
//                convertView = LayoutInflater.from(mContext).inflate(R.layout.adapter_label_item_live, null);
//                holder.cvLabel = (CardView) convertView.findViewById(R.id.cvLabel);
                convertView = LayoutInflater.from(mContext).inflate(R.layout.adapter_interest_label, parent, false);
                holder.cvLabel = convertView.findViewById(R.id.llLabelRootView);

                holder.ivLabelCheck = (ImageView) convertView.findViewById(R.id.ivLabelCheck);
                holder.tvLabelDesc = (TextView) convertView.findViewById(R.id.tvLabelDesc);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }

            CheckItem item = getItem(position);

//            if (item.isSigned) {
//                holder.cvLabel.setCardBackgroundColor(mContext.getResources().getColor(R.color.green));
//                holder.ivLabelCheck.setImageResource(R.drawable.ic_done_white_18dp);
//                holder.tvLabelDesc.setTextColor(Color.WHITE);
//            } else {
//                holder.cvLabel.setCardBackgroundColor(mContext.getResources().getColor(R.color.standard_grey));
//                holder.ivLabelCheck.setImageResource(R.drawable.ic_add_grey600_18dp);
//                holder.tvLabelDesc.setTextColor(mContext.getResources().getColor(R.color.text_color_dark));
//            }
            holder.tvLabelDesc.setText(item.name);
//            holder.cvLabel.setCardElevation(0f);
            holder.cvLabel.setTag(position);
            holder.cvLabel.setOnClickListener(this);

            // 2018/10/31 Hardy
            holder.ivLabelCheck.setImageResource(item.imageResId);
            holder.cvLabel.setBackgroundResource(item.isSigned ? R.drawable.bg_interest_label_select : R.drawable.bg_interest_label_unselect);

            return convertView;
        }

        /**
         * 获取已选标签Id列表
         *
         * @return
         */
        public ArrayList<String> getChoosedLabelsId() {
            ArrayList<String> ids = new ArrayList<String>();
            if (mList != null) {
                for (CheckItem item : mList) {
                    if (item.isSigned) {
                        ids.add(item.id);
                    }
                }
            }
            return ids;
        }

        private class ViewHolder {
//            CardView cvLabel;
            View cvLabel;

            ImageView ivLabelCheck;
            TextView tvLabelDesc;
        }

        @Override
        public void onClick(View v) {
            int position = (int) v.getTag();
            if (mList.get(position).isSigned) {
                mList.get(position).isSigned = false;
            } else {
                mList.get(position).isSigned = true;
            }
            notifyDataSetChanged();
        }

    }

    private enum RequestFlag {
        REQUEST_UPDATE_PROFILE_SUCCESS,
        REQUEST_PROFILE_SUCCESS,
        REQUEST_FAIL,
    }

    // Hardy
    private LSProfileItem mProfileItem;
    private ArrayList<String> uploadChooseLabelIdList;

    /**
     * 兴趣爱好
     */
    private WrapListView wrapListView;
    private List<CheckItem> mList = new ArrayList<CheckItem>();
    private InterestLabelAdapter intrestLabelAdapter = new InterestLabelAdapter(this, mList);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mContext = this;

        InitView();

        // 刷新界面
        ArrayList<String> intrestList = getIntent().getExtras().getStringArrayList(INTEREST);
        ReloadData(intrestList);


        // Hardy
        // 创建界面时候，获取缓存数据
        mProfileItem = MyProfilePerfenceLive.GetProfileItem(mContext);
        if (mProfileItem == null) {
            GetMyProfile();
        }
    }

    /**
     * 初始化界面
     */
    public void InitView() {
//        setContentView(R.layout.activity_my_profile_detail_intrest);
        setContentView(R.layout.activity_my_profile_detail_intrest_live);

        wrapListView = (WrapListView) findViewById(R.id.wrapListView);
        wrapListView.setDividerWidth(10);
        wrapListView.setDividerHeight(20);
        wrapListView.setAdapter(intrestLabelAdapter);

        MaterialAppBar appbar = (MaterialAppBar) findViewById(R.id.appbar);
        appbar.setTouchFeedback(MaterialAppBar.TOUCH_FEEDBACK_HOLO_LIGHT);
        appbar.addButtonToLeft(android.R.id.button1, "", R.drawable.ic_arrow_back_grey600_24dp);
        appbar.addButtonToRight(android.R.id.button2, "", R.drawable.ic_done_grey600_24dp);
        appbar.setTitle(getString(R.string.my_interest), getResources().getColor(R.color.text_color_dark));
        appbar.setOnButtonClickListener(this);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case android.R.id.button1:
                setResult(RESULT_CANCELED, null);
                finish();
                break;
            case android.R.id.button2:
                if (!NetworkUtil.isNetworkConnected(this)) {
                    showTipToast(getResources().getString(R.string.common_connect_error_description));
                    return;
                }

                // 2018/9/25 Hardy
                uploadChooseLabelIdList = intrestLabelAdapter.getChoosedLabelsId();
                mProfileItem.interests = uploadChooseLabelIdList;
                uploadProfile();
                break;
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

//        RequestBaseResponse obj = (RequestBaseResponse) msg.obj;
        HttpRespObject obj = (HttpRespObject) msg.obj;
        switch (RequestFlag.values()[msg.what]) {
            case REQUEST_PROFILE_SUCCESS:
                hideProgressDialog();
                // 缓存数据
                mProfileItem = (LSProfileItem) obj.data;
                MyProfilePerfenceLive.SaveProfileItem(mContext, mProfileItem);

                // 刷新界面
                ReloadData(mProfileItem.interests);
                break;

            case REQUEST_UPDATE_PROFILE_SUCCESS:
                showToastDone("Done");

                // 缓存数据
                MyProfilePerfenceLive.SaveProfileItem(mContext, mProfileItem);

                wrapListView.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        handlerUnloadSuccess();
                    }
                }, 1000);
                break;

            case REQUEST_FAIL: {
                hideProgressDialog();
                showTipToast(obj.errMsg);
            }
            break;
            default:
                break;
        }
    }

    private void showTipToast(String val) {
        ToastUtil.showToast(this, val);
    }


    /**
     * 获取个人信息
     */
    public void GetMyProfile() {
        // 此处应有菊花
        showProgressDialog("Loading...");
//        RequestOperator.getInstance().GetMyProfile(new OnGetMyProfileCallback() {
//        LiveRequestOperator.getInstance().GetMyProfile(new OnGetMyProfileCallback() {
        LiveDomainRequestOperator.getInstance().GetMyProfile(new OnGetMyProfileCallback() {
            @Override
            public void onGetMyProfile(boolean isSuccess, int errno, String errmsg,
                                       LSProfileItem item) {
                Message msg = Message.obtain();
//                RequestBaseResponse obj = new RequestBaseResponse(isSuccess, errno, errmsg, item);
                HttpRespObject obj = new HttpRespObject(isSuccess, errno, errmsg, item);
                if (isSuccess) {
                    // 获取个人信息成功
                    msg.what = RequestFlag.REQUEST_PROFILE_SUCCESS.ordinal();
                } else {
                    // 获取个人信息失败
                    msg.what = RequestFlag.REQUEST_FAIL.ordinal();
                }
                msg.obj = obj;
                sendUiMessage(msg);
            }
        });
    }

    private void uploadProfile() {
        showToastProgressing("Loading...");
//        RequestOperator.getInstance().UpdateProfile(
//        LiveRequestOperator.getInstance().UpdateProfile(
        LiveDomainRequestOperator.getInstance().UpdateProfile(
                mProfileItem.weight,
                mProfileItem.height,
                mProfileItem.language,
                mProfileItem.ethnicity,
                mProfileItem.religion,
                mProfileItem.education,
                mProfileItem.profession,
                mProfileItem.income,
                mProfileItem.children,
                mProfileItem.smoke,
                mProfileItem.drink,
                mProfileItem.resume,
                mProfileItem.interests.toArray(new String[mProfileItem.interests.size()]),
                mProfileItem.zodiac,
                new OnUpdateMyProfileCallback() {

                    @Override
                    public void onUpdateMyProfile(boolean isSuccess, int errno,
                                                  String errmsg, boolean rsModified) {
                        Message msg = Message.obtain();
//                        RequestBaseResponse obj = new RequestBaseResponse(isSuccess, errno, errmsg, null);
                        HttpRespObject obj = new HttpRespObject(isSuccess, errno, errmsg, null);
                        if (isSuccess) {
                            // 上传个人信息成功
                            msg.what = RequestFlag.REQUEST_UPDATE_PROFILE_SUCCESS.ordinal();
                        } else {
                            // 上传个人信息失败
                            msg.what = RequestFlag.REQUEST_FAIL.ordinal();
                        }
                        msg.obj = obj;
                        sendUiMessage(msg);
                    }
                });

    }

    private void handlerUnloadSuccess() {
        Intent intent = new Intent();
        intent.putExtra(INTEREST, uploadChooseLabelIdList);
        setResult(RESULT_OK, intent);
        finish();
    }


    /**
     * 刷新界面
     */
    public void ReloadData(ArrayList<String> intrestList) {
        String[] array = getResources().getStringArray(R.array.interest_live);

        for (String id : array) {
            boolean bFlag = false;
            if (intrestList != null) {
                for (String checkName : intrestList) {
                    if (id.compareTo(checkName) == 0) {
                        bFlag = true;
                        break;
                    }
                }
            }
//            CheckItem item = new CheckItem(id, InterestToString(id), bFlag);
            CheckItem item = new CheckItem(id, MyProfileInterestUtil.formatId2String(mContext, id),
                    MyProfileInterestUtil.formatId2ImageResId(id), bFlag);

            mList.add(item);
        }

        intrestLabelAdapter.notifyDataSetChanged();
    }

    /**
     * 获取兴趣爱好字符串
     *
     * @param name 兴趣爱好Id
     * @return
     */
    private String InterestToString(String name) {
        String result = "";
        switch (name) {
            case "1": {
                result = getResources().getString(R.string.my_profile_going_to_restaurants);
            }
            break;
            case "2": {
                result = getResources().getString(R.string.my_profile_cooking);
            }
            break;
            case "3": {
                result = getResources().getString(R.string.my_profile_travel);
            }
            break;
            case "4": {
                result = getResources().getString(R.string.my_profile_hiking_outdoor_activities);
            }
            break;
            case "5": {
                result = getResources().getString(R.string.my_profile_dancing);
            }
            break;
            case "6": {
                result = getResources().getString(R.string.my_profile_watching_movies);
            }
            break;
            case "7": {
                result = getResources().getString(R.string.my_profile_shopping);
            }
            break;
            case "8": {
                result = getResources().getString(R.string.my_profile_having_pets);
            }
            break;
            case "9": {
                result = getResources().getString(R.string.my_profile_reading);
            }
            break;
            case "10": {
                result = getResources().getString(R.string.my_profile_sports_exercise);
            }
            break;
            case "11": {
                result = getResources().getString(R.string.my_profile_playing_cards_chess);
            }
            break;
            case "12": {
                result = getResources().getString(R.string.my_profile_Music_play_instruments);
            }
            break;
            default:
                break;
        }
        return result;
    }
}
