package com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.PointF;
import android.net.Uri;
import android.support.v7.widget.CardView;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.common.ResizeOptions;
import com.facebook.imagepipeline.image.ImageInfo;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetUserInfoCallback;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;

import java.util.HashMap;

/**
 * Hangout好友详情弹出框
 *
 * @author Jagger 2019-3-12
 */
public class HangOutFriendsDetailDialog {

    private static HashMap<String, UserInfoItem> sAnchorInfoMap = new HashMap<>();


    public static void showCheckMailSuccessDialog(Context context, HangoutAnchorInfoItem anchorInfoItem) {
        View rootView = View.inflate(context, R.layout.view_live_hang_out_friend_detail, null);
//        final Dialog dialog = DialogUIUtils.showCustomAlert(context, rootView,
//                null,
//                null,
//                Gravity.CENTER, true, true,
//                true,
//                null).show();
//        dialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
//            @Override
//            public void onDismiss(DialogInterface dialog) {
//            }
//        });
//        //VIEW内事件
//        //背景
//        //由于CardView不能填满根布局，所以Dialog实际大小比可视部分要大，点击到根布局时也要关闭
//        LinearLayout ll_root = rootView.findViewById(R.id.ll_root);
//        ll_root.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                dialog.dismiss();
//            }
//        });

        //body
        CardView cv_body = rootView.findViewById(R.id.cv_body);
        cv_body.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //点内容不消失
            }
        });

        //封面图
        //封面图大小，因此时取不出控件大小, 暂时以屏幕宽为准
        SimpleDraweeView iv_anchor = rootView.findViewById(R.id.iv_anchor);
        int bgSize = (int) (DisplayUtil.getScreenWidth(context) * 0.8);//屏幕宽 80% 尽量节省内存

        //对齐方式(左上角对齐)
        PointF focusPoint = new PointF();
        focusPoint.x = 0f;
        focusPoint.y = 0f;

        //占位图，拉伸方式
        GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(context.getResources());
        GenericDraweeHierarchy hierarchy = builder
                .setFadeDuration(300)
                .setPlaceholderImage(R.color.black4)    //占位图
                .setPlaceholderImageScaleType(ScalingUtils.ScaleType.FIT_XY)    //占位图拉伸
                .setActualImageFocusPoint(focusPoint)
                .setActualImageScaleType(ScalingUtils.ScaleType.FOCUS_CROP)     //图片拉伸（配合上面的focusPoint）
                .build();
        iv_anchor.setHierarchy(hierarchy);

        //压缩、裁剪图片
        Uri imageUri = Uri.parse(anchorInfoItem.photoUrl);
        ImageRequest request = ImageRequestBuilder.newBuilderWithSource(imageUri)
                .setResizeOptions(new ResizeOptions(bgSize, bgSize))
                .build();
        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setImageRequest(request)
                .setOldController(iv_anchor.getController())
                .setControllerListener(new BaseControllerListener<ImageInfo>())
                .build();
        iv_anchor.setController(controller);

        //名
        TextView tv_name = rootView.findViewById(R.id.tv_name);
        tv_name.setText(anchorInfoItem.nickName);

        //年龄
        TextView tv_year = rootView.findViewById(R.id.tv_year);
//        tv_year.setText(anchorInfoItem.age + " Years old · " + anchorInfoItem.country);

        // 2019/03/25 Hardy
        boolean isSetSuccess = setAnchorYearView(tv_year, anchorInfoItem.age, anchorInfoItem.country);
        if (!isSetSuccess) {
            UserInfoItem userItem = getAnchorInfo(anchorInfoItem.anchorId);
            if (userItem != null) {
                setAnchorYearView(tv_year, userItem.age, userItem.country);
            } else {
                loadAnchorInfo(tv_year, anchorInfoItem.anchorId);
            }
        }


        //ID
        TextView tv_id = rootView.findViewById(R.id.tv_id);
        tv_id.setText("ID: " + anchorInfoItem.anchorId);

        //Dialog
        Dialog dialog = new Dialog(context,R.style.CustomTheme_SimpleDialog);
//        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(rootView);
        dialog.setCancelable(true);
        dialog.setCanceledOnTouchOutside(true);
        dialog.show();

        //自定义的东西
        //放在show()之后，不然有些属性是没有效果的，比如height和width
        Window dialogWindow = dialog.getWindow();
        WindowManager.LayoutParams p = dialogWindow.getAttributes(); // 获取对话框当前的参数值
        // 设置高度和宽度
        p.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        p.width = (int) (DisplayUtil.getScreenWidth(context) * 0.8); // 宽度设置为屏幕的0.7
        dialogWindow.setAttributes(p);
    }

    private static void loadAnchorInfo(final TextView tv_year, final String targetId) {
        if (TextUtils.isEmpty(targetId)) {
            return;
        }

        LiveRequestOperator.getInstance().GetUserInfo(targetId, new OnGetUserInfoCallback() {
            @Override
            public void onGetUserInfo(boolean isSuccess, int errCode, String errMsg, final UserInfoItem userItem) {
                if (isSuccess && userItem != null && targetId.equals(userItem.userId)) {
                    tv_year.post(new Runnable() {
                        @Override
                        public void run() {
                            put2AnchorInfoMap(userItem.userId, userItem);

                            setAnchorYearView(tv_year, userItem.age, userItem.country);
                        }
                    });
                }
            }
        });
    }

    private static boolean setAnchorYearView(TextView tv_year, int age, String country) {
        boolean isSetSuccess = false;

        if (age > 0 && !TextUtils.isEmpty(country)) {
            isSetSuccess = true;

            tv_year.setText(age + " Years old · " + country);
        }

        return isSetSuccess;
    }

    private static void put2AnchorInfoMap(String userId, UserInfoItem userItem) {
        if (!TextUtils.isEmpty(userId) && userItem != null) {
            sAnchorInfoMap.put(userId, userItem);
        }
    }

    private static UserInfoItem getAnchorInfo(String userId) {
        UserInfoItem userItem = null;

        if (!TextUtils.isEmpty(userId)) {
            userItem = sAnchorInfoMap.get(userId);
        }

        return userItem;
    }
}
