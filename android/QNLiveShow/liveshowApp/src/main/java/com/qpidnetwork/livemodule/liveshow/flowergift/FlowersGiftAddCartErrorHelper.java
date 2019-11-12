package com.qpidnetwork.livemodule.liveshow.flowergift;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.widget.Button;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.flowergift.checkout.CheckOutActivity;
import com.qpidnetwork.qnbridgemodule.util.UIUtils;

/**
 * Created by Hardy on 2019/10/11.
 * <p>
 * 鲜花礼品添加购物车出错帮助类
 */
public class FlowersGiftAddCartErrorHelper {

    private Context mContext;
    private String anchorId;

    public FlowersGiftAddCartErrorHelper(Context mContext) {
        this.mContext = mContext;
    }

    /**
     * 添加购物车，购物车已满提示
     */
    private void showAddCartFullError(String message) {
        AlertDialog.Builder builder = new AlertDialog.Builder(mContext)
                .setMessage(message)
                // 右
                .setPositiveButton(mContext.getResources().getString(R.string.live_common_btn_checkout), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        //跳转 checkout 订单页
                        CheckOutActivity.lanchAct(mContext, anchorId, "", "");
                    }
                })
                // 左
                .setNegativeButton(mContext.getResources().getString(R.string.live_common_btn_later), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {

                    }
                });
        AlertDialog dialog = builder.create();
        dialog.setCanceledOnTouchOutside(false);
        if (!UIUtils.isActExist(mContext)) {
            return;
        }
        dialog.show();

        // 改变 Button 文本为小写,必须放在 dialog.show() 方法后才调用
        // https://blog.csdn.net/chenkai19951108/article/details/78060964
        Button mNegativeButton = dialog.getButton(AlertDialog.BUTTON_NEGATIVE) ;
        Button mPositiveButton = dialog.getButton(AlertDialog.BUTTON_POSITIVE) ;
        mNegativeButton.setAllCaps(false);
        mPositiveButton.setAllCaps(false);
    }

    /**
     * 添加购物车通用错误提示
     */
    public void showAddCartNormalError(String message) {
        AlertDialog.Builder builder = new AlertDialog.Builder(mContext)
                .setMessage(message)
                .setPositiveButton(mContext.getResources().getString(R.string.common_btn_ok), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {

                    }
                });
        Dialog dialog = builder.create();
        dialog.setCanceledOnTouchOutside(false);
        if (!UIUtils.isActExist(mContext)) {
            return;
        }
        dialog.show();
    }

    public void handlerAddCartError(int errCode, String errMsg, String anchorId) {
        this.anchorId = anchorId;

        // https://www.qoogifts.com.cn/zentaopms2/www/index.php?m=bug&f=view&bugID=21663
        // 2019/10/23 Hardy 最新需求又改，统一使用同一种 ok 按钮弹窗提示
        showAddCartNormalError(errMsg);

//        HttpLccErrType httpError = IntToEnumUtils.intToHttpErrorType(errCode);
////                    if (httpError == HTTP_LCC_ERR_ITEM_TOO_MUCH || httpError == HTTP_LCC_ERR_FULL_CART) {
//        if (httpError == HTTP_LCC_ERR_FULL_CART) {
//            //购物车已满
//            showAddCartFullError(errMsg);
//        } else {
//            showAddCartNormalError(errMsg);
//        }
    }
}
