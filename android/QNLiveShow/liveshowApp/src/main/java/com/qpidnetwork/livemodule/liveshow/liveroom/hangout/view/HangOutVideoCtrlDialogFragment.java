package com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view;

import android.app.Dialog;
import android.content.DialogInterface;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.view.bottomSheetDialog.CustomBottomSheetDialog;

/**
 * HangOut直播间控制面板
 * @author Jagger 2019-4-11
 */
public class HangOutVideoCtrlDialogFragment extends DialogFragment implements View.OnClickListener {
    /**
     * HangOut操作对话框TAG
     */
    private static final String DIALOG_TAG = "VideoCtrl";

    /**
     * 启动参数
     */
    private static final String PARAM_MUTE = "PARAM_MUTE";
    private static final String PARAM_SILENT = "PARAM_SILENT";


    //控件
    private ImageView iv_closeVedioControll;
    private ImageView iv_mute;
    private ImageView iv_silent;
    private ImageView iv_exitHangout;

    //变量
    private boolean isMuteOn = false;
    private boolean isSilentOn = false;

    /**
     * 显示
     * 可扩展添加参数
     *
     * @param fragmentManager
     */
    public static void showDialog(FragmentManager fragmentManager, boolean isMuteOn, boolean isSilentOn, OnControllerEventListener dialogClickListener) {
        /**
         * 为了不重复显示dialog，在显示对话框之前移除正在显示的对话框。
         */
        FragmentTransaction ft = fragmentManager.beginTransaction();
        Fragment fragment = fragmentManager.findFragmentByTag(DIALOG_TAG);
        if (null != fragment) {
            ft.remove(fragment).commit();
        }

        HangOutVideoCtrlDialogFragment dialogFragment = HangOutVideoCtrlDialogFragment.newInstance(isMuteOn, isSilentOn);
        dialogFragment.show(fragmentManager, DIALOG_TAG);
        dialogFragment.setCancelable(true);
        dialogFragment.setListener(dialogClickListener);

        fragmentManager.executePendingTransactions();
    }

    public static void dismissDialog(FragmentManager fragmentManager) {
        FragmentTransaction ft = fragmentManager.beginTransaction();
        Fragment fragment = fragmentManager.findFragmentByTag(DIALOG_TAG);
        if (null != fragment) {
            ft.remove(fragment).commit();
        }
        fragmentManager.executePendingTransactions();
    }

    /**
     * 为了参数可保存状态
     *
     * @return
     */
    private static HangOutVideoCtrlDialogFragment newInstance(boolean isMuteOn, boolean isSilentOn) {
        HangOutVideoCtrlDialogFragment instance = new HangOutVideoCtrlDialogFragment();
        Bundle args = new Bundle();
        args.putBoolean(PARAM_MUTE, isMuteOn);
        args.putBoolean(PARAM_SILENT, isSilentOn);
        instance.setArguments(args);
        return instance;
    }

    /**
     * 初始化数据及业务相关
     */
    private void initData() {

        Bundle bundle = getArguments();
        if (bundle != null) {
            if (bundle.containsKey(PARAM_MUTE)) {
                isMuteOn = bundle.getBoolean(PARAM_MUTE);
            }
            if (bundle.containsKey(PARAM_SILENT)) {
                isSilentOn = bundle.getBoolean(PARAM_SILENT);
            }
        }
    }

    /**
     * 2.
     * *应用场景*：一般用于创建替代传统的 Dialog 对话框的场景，UI 简单，功能单一。
     *
     * @param savedInstanceState
     * @return
     */
    @NonNull
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        //创建RecommendDialog核心代码
        View view = inflater.inflate(R.layout.view_liveroom_hangout_vediocontroll_dialog, container, false);
        //启用窗体的扩展特性。
        getDialog().requestWindowFeature(Window.FEATURE_NO_TITLE);

        iv_closeVedioControll = (ImageView) view.findViewById(R.id.iv_closeVedioControll);
        iv_closeVedioControll.setOnClickListener(this);
        iv_mute = (ImageView) view.findViewById(R.id.iv_mute);
        iv_mute.setOnClickListener(this);
        iv_silent = (ImageView) view.findViewById(R.id.iv_silent);
        iv_silent.setOnClickListener(this);
        iv_exitHangout = (ImageView) view.findViewById(R.id.iv_exitHangout);
        iv_exitHangout.setOnClickListener(this);

        return view;
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();

        if (i == R.id.iv_closeVedioControll) {
//            if (null != listener) {
//                listener.onCloseClicked();
//            }

        } else if (i == R.id.iv_mute || i == R.id.ll_mute) {
            isMuteOn = !isMuteOn;
            iv_mute.setSelected(isMuteOn);
            if (null != listener) {
                listener.onMuteStatusChanged(isMuteOn);
            }

        } else if (i == R.id.ll_silent || i == R.id.iv_silent) {
            isSilentOn = !isSilentOn;
            iv_silent.setSelected(isSilentOn);
            if (null != listener) {
                listener.onSilentStatusChanged(isSilentOn);
            }

        } else if (i == R.id.iv_exitHangout || i == R.id.ll_exitHangout) {
            if (null != listener) {
                listener.onExitHangOutClicked();
            }

        }

        dismiss();
    }

    /**
     * 1.
     * *应用场景*：一般用于创建复杂内容弹窗或全屏展示效果的场景，UI 复杂，功能复杂，一般有网络请求等异步操作。
     *
     * @param savedInstanceState
     * @return
     */
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        //Android 6.0新控件 BottomSheetDialog 扩展不能下拉收起 | 底部对话框, style解决高度不足够显示全部内容
        CustomBottomSheetDialog dialog = new CustomBottomSheetDialog(getContext(), R.style.HangoutBottomSheetDialog);
        return dialog;
    }

    /**
     * 3.
     * @param view
     * @param savedInstanceState
     */
    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        initData();

        //根据数据刷新界面
        iv_mute.setSelected(isMuteOn);
        iv_silent.setSelected(isSilentOn);
    }

    /**
     * 4.
     */
    @Override
    public void onStart() {
        super.onStart();

        //话框外部的背景设为透明
        Window window = getDialog().getWindow();
        WindowManager.LayoutParams windowParams = window.getAttributes();
        windowParams.dimAmount = 0.0f;
//        windowParams.height = 500;
        window.setAttributes(windowParams);

        //设置内部背景为透明
        window.findViewById(R.id.design_bottom_sheet).setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));

        //设置状态栏为透明
        window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);

    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        //动态设置高度
        int height = DisplayUtil.getScreenHeight(getContext())-DisplayUtil.getScreenWidth(getContext())- DisplayUtil.getStatusBarHeight(getContext());
        int minHeight = getContext().getResources().getDimensionPixelSize(R.dimen.live_hangout_room_ctrl_min_size);
        if(height < minHeight){
            height = minHeight;
        }

        ViewGroup.LayoutParams layoutParams = getView().getLayoutParams();
        layoutParams.height = height;
        getView().setLayoutParams(layoutParams);
    }

    @Override
    public void onDismiss(DialogInterface dialog) {
        super.onDismiss(dialog);
        if (null != listener) {
            listener.onCloseClicked();
        }
    }

    //-------------------- 监听器 start -----------------------
    private OnControllerEventListener listener;

    public void setListener(OnControllerEventListener listener){
        this.listener = listener;
    }

    /**
     * 控制面板点击事件监听类
     */
    public interface OnControllerEventListener{
        /**
         * 视频控制面板关闭回调
         */
        void onCloseClicked();

        /**
         * 推流-音频输入开关状态切换回调
         * @param onOrOff
         */
        void onMuteStatusChanged(boolean onOrOff);

        /**
         * 拉流-静音开关状态切换回调
         * @param onOrOff
         */
        void onSilentStatusChanged(boolean onOrOff);

        /**
         * 退出HangOut直播间回调
         */
        void onExitHangOutClicked();
    }
    //-------------------- 监听器 end -----------------------
}
