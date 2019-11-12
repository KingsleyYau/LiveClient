package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.app.Dialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.BaseCommonLiveRoomActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;
import com.qpidnetwork.qnbridgemodule.view.blur_500px.BlurringView;
import com.qpidnetwork.qnbridgemodule.view.bottomSheetDialog.CustomBottomSheetDialog;
import com.qpidnetwork.qnbridgemodule.view.viewPage.NoScrollViewPager;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import io.reactivex.Flowable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;

/**
 * 才艺列表对话框
 */
public class TalentDialogFragment extends DialogFragment implements TalentListFragment.onTitleEventListener, TalentsAdapter.onItemClickedListener , TalentDetailFragment.onDetailEventListener{

    /**
     * 才艺列表对话框TAG
     */
    private static final String DIALOG_TALENT_TAG = "RecommendList";

    /**
     * 启动参数
     */
    private static final String PARAM_ROOM_ID = "PARAM_ROOM_ID";
    private static final String PARAM_ANCHOR_URL = "PARAM_ANCHOR_URL";
    private static final String PARAM_ANCHOR_NICKNAME = "PARAM_ANCHOR_NICKNAME";

    private final int STEP_REFRESH_BLURRINGVIEW = 2 * 1000;

    //变量
    private String mRoomId , mAnchorAvatarURL, mAnchorAvatarNickName;
    private TalentInfoItem mTalentInfoItem4ListSelected , mTalentInfoItemRequest;
    private static onDialogEventListener mOnDialogEventListener;
    private TalentListFragment mTalentListFragment;
    private TalentDetailFragment mTalentDetailFragment;
    private Disposable mDisposable;
    private TalentManager.onTalentEventListener mTalentEventListener;

    //控件
    private NoScrollViewPager mViewPagerContent;
    private TalentPopWinFragmentPagerAdapter mAdapter;
    private BlurringView mBlurringViewContent , mBlurringViewBottom;
    private View mBlurredViewContent , mBlurredViewBottom;
    private Button mBtnRequest;
    private TextView tv_talentCredits;
    private LinearLayout mLinearLayoutBottom;

    /**
     * 设置事件监听
     * @param listener
     */
    public static void setOnDialogEventListener(onDialogEventListener listener){
        mOnDialogEventListener = listener;
    }

    /**
     * 这个界面的事件响应
     */
    public interface onDialogEventListener {
        void onRequestClicked(TalentInfoItem talent);
    }

    /**
     * 显示
     * 可扩展添加参数
     * @param fragmentManager
     */
    public static void showDialog(FragmentManager fragmentManager , String roomId, String anchorUrl , String anchorNickName){
        /**
         * 为了不重复显示dialog，在显示对话框之前移除正在显示的对话框。
         */
        FragmentTransaction ft = fragmentManager.beginTransaction();
        Fragment fragment = fragmentManager.findFragmentByTag(DIALOG_TALENT_TAG);
        if (null != fragment) {
            ft.remove(fragment).commit();
        }

        TalentDialogFragment dialogFragment = TalentDialogFragment.newInstance(roomId , anchorUrl , anchorNickName);
        dialogFragment.show(fragmentManager, DIALOG_TALENT_TAG);
//        dialogFragment.setCancelable(false);

        fragmentManager.executePendingTransactions();
    }


    public static void dismissDialog(FragmentManager fragmentManager ){
        FragmentTransaction ft = fragmentManager.beginTransaction();
        Fragment fragment = fragmentManager.findFragmentByTag(DIALOG_TALENT_TAG);
        if (null != fragment) {
            ft.remove(fragment).commit();
        }
        fragmentManager.executePendingTransactions();
    }

    /**
     * 为了参数可保存状态
     * @return
     */
    private static TalentDialogFragment newInstance(String roomId, String anchorUrl,String anchorNickName){
        TalentDialogFragment instance = new TalentDialogFragment();
        Bundle args = new Bundle();
        args.putString(PARAM_ROOM_ID , roomId);
        args.putString(PARAM_ANCHOR_URL , anchorUrl);
        args.putString(PARAM_ANCHOR_NICKNAME , anchorNickName);

        instance.setArguments(args);
        return instance;
    }

    /**
     * *应用场景*：一般用于创建替代传统的 Dialog 对话框的场景，UI 简单，功能单一。
     * @param savedInstanceState
     * @return
     */
    @NonNull
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {

        Bundle bundle = getArguments();
        if (bundle != null) {
            if (bundle.containsKey(PARAM_ROOM_ID)) {
                mRoomId = bundle.getString(PARAM_ROOM_ID);
            }
            if (bundle.containsKey(PARAM_ANCHOR_URL)) {
                mAnchorAvatarURL = bundle.getString(PARAM_ANCHOR_URL);
            }
            if (bundle.containsKey(PARAM_ANCHOR_NICKNAME)) {
                mAnchorAvatarNickName = bundle.getString(PARAM_ANCHOR_NICKNAME);
            }
        }

        //创建RecommendDialog核心代码
        View view = inflater.inflate(R.layout.view_live_popupwindow_talents,container,false);
        //启用窗体的扩展特性。
        getDialog().requestWindowFeature(Window.FEATURE_NO_TITLE);
        //对话框内部的背景设为透明
        getDialog().getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));

        //毛玻璃
        mBlurringViewContent = (BlurringView)view.findViewById(R.id.blurring_view_content);
        mBlurringViewBottom  = (BlurringView)view.findViewById(R.id.blurring_view_bottom);
        //注：这是针对BaseCommonLiveRoomActivity做的毛玻璃效果
        if(getActivity() != null &&  getActivity() instanceof BaseCommonLiveRoomActivity){
            mBlurredViewContent = getActivity().findViewById(R.id.fl_msglist);
            mBlurringViewContent.setBlurredView(mBlurredViewContent);

            mBlurredViewBottom = getActivity().findViewById(R.id.ll_bottom_audience);
            mBlurringViewBottom.setBlurredView(mBlurredViewBottom);
        }

        //viewPage
        mViewPagerContent = (NoScrollViewPager) view.findViewById(R.id.vpContent);
        //初始化viewpager
        mAdapter = new TalentPopWinFragmentPagerAdapter(getChildFragmentManager() , getFragments());
        mViewPagerContent.setAdapter(mAdapter);
        //防止间隔点击会出现回收，导致Fragment onresume走出现刷新异常
        mViewPagerContent.setOffscreenPageLimit(1);

        mLinearLayoutBottom = (LinearLayout) view.findViewById(R.id.ll_bottom);
        //发送才艺请求
        mBtnRequest = (Button) view.findViewById(R.id.btnRequest);
        mBtnRequest.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
//                mBlurringViewContent.invalidate();
                if(mOnDialogEventListener != null){
                    if(mTalentInfoItemRequest != null){
                        mOnDialogEventListener.onRequestClicked(mTalentInfoItemRequest);
                    }else {
                        //提示要选中一个才艺
                        ToastUtil.showToast(getContext(), R.string.live_talent_no_select);
                    }
                }
            }
        });

        //底部文字
        tv_talentCredits = (TextView)view.findViewById(R.id.tv_talentCredits);
        SpannableString spanText=new SpannableString(getString(R.string.live_talent_details));
        spanText.setSpan(new ClickableSpan() {
            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor( getResources().getColor(R.color.black3));       //设置文件颜色
                ds.setUnderlineText(true);      //设置下划线
            }
            @Override
            public void onClick(View widget) {
                onClickedDetailsText();
            }
        }, 0  , spanText.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        tv_talentCredits.setHighlightColor(Color.TRANSPARENT); //设置点击后的颜色为透明，否则会一直出现高亮
//        tv_talentCredits.append(" ");
        tv_talentCredits.append(spanText);
        tv_talentCredits.setMovementMethod(LinkMovementMethod.getInstance());//开始响应点击事件

        //根据数据决定下半部分是否显示
        mTalentEventListener = new TalentManager.onTalentEventListener() {
            @Override
            public void onGetTalentList(HttpRespObject httpRespObject) {
                if(!httpRespObject.isSuccess || httpRespObject.data == null || ((TalentInfoItem[])httpRespObject.data).length == 0){
                    mLinearLayoutBottom.setVisibility(View.GONE);
                }else {
                    mLinearLayoutBottom.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void onConfirm(TalentInfoItem talent) {

            }
        };
        TalentManager.getInstance().registerOnTalentEventListener(mTalentEventListener);
        return view;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        if(mDisposable!=null&&!mDisposable.isDisposed()){
            mDisposable.dispose();
        }

        TalentManager.getInstance().unregisterOnTalentEventListener(mTalentEventListener);
    }

    /**
     * 定时刷新毛玻璃
     */
    private void refreshBlurringView(){
        if(mDisposable != null && !mDisposable.isDisposed()){
            return;
        }

        mDisposable = Flowable.interval(STEP_REFRESH_BLURRINGVIEW, TimeUnit.MILLISECONDS)
                .onBackpressureLatest() //加上背压策略
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<Long>() {
                    @Override
                    public void accept(@NonNull Long aLong) throws Exception {
                        if(mBlurredViewContent != null){
                            mBlurringViewContent.invalidate();
                        }
                    }
                });
    }

    /**
     * 点击连接
     */
    private void onClickedDetailsText(){
        View rootView = View.inflate(getActivity(), R.layout.dialog_talent_detail_tips, null);
        final Dialog dialog = DialogUIUtils.showCustomAlert(getContext(), rootView,
                null,
                null,
                Gravity.CENTER, true, true,
                null).show();
        //VIEW内事件
        ImageView imgClose = (ImageView)rootView.findViewById(R.id.iv_closeSimpleTips);
        imgClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DialogUIUtils.dismiss(dialog);
            }
        });
    }

    /**
     * *应用场景*：一般用于创建复杂内容弹窗或全屏展示效果的场景，UI 复杂，功能复杂，一般有网络请求等异步操作。
     * @param savedInstanceState
     * @return
     */
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        //Android 6.0新控件 BottomSheetDialog | 底部对话框
        CustomBottomSheetDialog dialog = new CustomBottomSheetDialog(getContext());
        return dialog;
    }

    @Override
    public void onStart() {
        super.onStart();

        //话框外部的背景设为透明
        Window window = getDialog().getWindow();
        WindowManager.LayoutParams windowParams = window.getAttributes();
        windowParams.dimAmount = 0.0f;

        window.setAttributes(windowParams);

        //定时刷新毛玻璃
        refreshBlurringView();
    }

    /**
     * 添加Fragments
     * @return
     */
    private List<Fragment> getFragments() {
        mTalentListFragment = TalentListFragment.newInstance(mRoomId , mAnchorAvatarNickName);
        mTalentListFragment.setOnItemClickedListener(this);
        mTalentListFragment.setOnTitleEventListener(this);

        mTalentDetailFragment = TalentDetailFragment.newInstance();
        mTalentDetailFragment.setOnDetailEventListener(this);

        List<Fragment> fList = new ArrayList<>();
        fList.add(mTalentListFragment);
        fList.add(mTalentDetailFragment);
        return fList;
    }

    @Override
    public void onDetailClicked(TalentInfoItem talent) {
        mTalentDetailFragment.setTalentInfoItem(talent);
        mTalentDetailFragment.setAnchorURL(mAnchorAvatarURL);
        mViewPagerContent.setCurrentItem(1);
        //转入详细时，将默认的才艺改为在看详细的才艺
        mTalentInfoItemRequest = talent;
    }

    @Override
    public void onSelected(TalentInfoItem talent) {
        mTalentInfoItem4ListSelected = talent;
        mTalentInfoItemRequest = talent;
    }

    @Override
    public void onBackClicked() {
        mViewPagerContent.setCurrentItem(0);

        //转入列表时，将默认的才艺改为在列表选中的才艺
        if(mTalentInfoItem4ListSelected != null){
            mTalentInfoItemRequest = mTalentInfoItem4ListSelected;
        }
    }

    @Override
    public void onCloseClicked() {
        dismiss();
    }
}
