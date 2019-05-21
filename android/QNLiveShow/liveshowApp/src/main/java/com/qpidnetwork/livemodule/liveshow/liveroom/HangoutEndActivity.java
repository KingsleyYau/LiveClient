package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.ListUtils;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;

import java.util.ArrayList;

/**
 * 2019/03/21 Hardy
 * Hangout 多人互动结束页
 */
public class HangoutEndActivity extends BaseFragmentActivity {

    private static final String TRANSITION_ANCHOR_INFO = "anchorInfo";
    private static final String HANGOUT_END_TYPE = "hangoutEndType";

    private LinearLayout mLlAnchorRootView;

    private ImageView mIvClose;
    private TextView mTvDesc;
    private TextView mTvAddCredits;
    private LinearLayout mLlStartAgain;

    //data
    private HangoutEndType hangoutEndType;
    private ArrayList<IMUserBaseInfoItem> mAnchorList;

    private LayoutInflater layoutInflater;

    /**
     * 结束类型
     * 1、正常结束
     * 2、后台放置，超过1分钟
     * 3、信用点不够
     */
    public enum HangoutEndType {
        NORMAL,
        OVER_ONE_MINUTE,
        ADD_CREDITS
    }

    /**
     * @param context
     * @param anchorInfo        主播的数组，第一个 index ，必须为“主”主播
     * @param hangoutEndType    结束类型
     */
    public static void startAct(Context context, ArrayList<IMUserBaseInfoItem> anchorInfo, HangoutEndType hangoutEndType) {
        Intent intent = new Intent(context, HangoutEndActivity.class);
        //add by Jagger 2019-4-9
        //如果这个activity已经启动了，就不产生新的activity，而只是把这个activity实例加到栈顶来就可以了。
        intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);

        intent.putParcelableArrayListExtra(TRANSITION_ANCHOR_INFO, anchorInfo);
        intent.putExtra(HANGOUT_END_TYPE, hangoutEndType.ordinal());

        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_hangout_end);

        parseIntentData();
        initView();
        initData();
    }

    private void parseIntentData() {
        Intent intent = getIntent();
        if (intent != null) {
            // 数据
            mAnchorList = intent.getParcelableArrayListExtra(TRANSITION_ANCHOR_INFO);

            // 结束类型
            int type = intent.getIntExtra(HANGOUT_END_TYPE, HangoutEndType.NORMAL.ordinal());
            if (type == HangoutEndType.OVER_ONE_MINUTE.ordinal()) {
                hangoutEndType = HangoutEndType.OVER_ONE_MINUTE;
            } else if (type == HangoutEndType.ADD_CREDITS.ordinal()) {
                hangoutEndType = HangoutEndType.ADD_CREDITS;
            } else {
                hangoutEndType = HangoutEndType.NORMAL;
            }
        }
    }

    private void initView() {
        mLlAnchorRootView = findViewById(R.id.act_hangout_end_ll_anchor_root);

        mIvClose = (ImageView) findViewById(R.id.act_hangout_end_iv_close);
        mTvDesc = (TextView) findViewById(R.id.act_hangout_end_tv_desc);
        mTvAddCredits = (TextView) findViewById(R.id.act_hangout_end_tv_add_credits);
        mLlStartAgain = (LinearLayout) findViewById(R.id.act_hangout_end_ll_start_again);

        mIvClose.setOnClickListener(this);
        mTvAddCredits.setOnClickListener(this);
        mLlStartAgain.setOnClickListener(this);

        layoutInflater = LayoutInflater.from(mContext);
    }

    private void initData() {
        // 女士资料
        if (ListUtils.isList(mAnchorList)) {
            int size = mAnchorList.size();

            for (int i = 0; i < size; i++) {
                IMUserBaseInfoItem item = mAnchorList.get(i);
                if (item != null) {
                    mLlAnchorRootView.addView(makeAnchorView(item, i == 0));
                }
            }
        }

        // 结束类型
        switch (hangoutEndType) {
            case ADD_CREDITS:
                mTvDesc.setText(R.string.hangout_end_add_credits);
                mTvAddCredits.setVisibility(View.VISIBLE);
                break;

            case OVER_ONE_MINUTE:
                mTvDesc.setText(R.string.hangout_end_over_one_minutes);
                mTvAddCredits.setVisibility(View.GONE);
                break;

            default:
                mTvDesc.setText(R.string.hangout_end_normal_tip);
                mTvAddCredits.setVisibility(View.GONE);
                break;
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();
        if (id == R.id.act_hangout_end_iv_close) {
            finish();
        } else if (id == R.id.act_hangout_end_tv_add_credits) {

            //打开买点页面
            //edit by Jagger 2018-9-21 使用URL方式跳转
            String urlAddCredit = URL2ActivityManager.createAddCreditUrl("", "B30", "");
            new AppUrlHandler(mContext).urlHandle(urlAddCredit);

        } else if (id == R.id.act_hangout_end_ll_start_again) {
            // 2019/3/21 start again
            //过渡页
            if(mAnchorList != null && mAnchorList.size() > 0) {
                ArrayList<IMUserBaseInfoItem> tempAnchorList = new ArrayList<IMUserBaseInfoItem>();
                tempAnchorList.add(mAnchorList.get(0));
                Intent intent = HangoutTransitionActivity.getIntent(
                        mContext,
                        tempAnchorList,
                        "",
                        "",
                        "");
                startActivity(intent);
            }
            finish();
        }
    }


    private View makeAnchorView(IMUserBaseInfoItem item, boolean isFirstAnchor) {
        View view = layoutInflater.inflate(R.layout.layout_hang_out_end_anchor, mLlAnchorRootView, false);

        CircleImageView mIvIcon = view.findViewById(R.id.act_hangout_end_iv_anchor_icon);
        TextView mTvName = view.findViewById(R.id.act_hangout_end_tv_anchor_name);

        mTvName.setText(item.nickName);
        PicassoLoadUtil.loadUrl(mIvIcon, item.photoUrl, R.drawable.ic_default_photo_man);

        if (!isFirstAnchor) {
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) view.getLayoutParams();
            params.leftMargin = mContext.getResources().getDimensionPixelSize(R.dimen.live_size_30dp);
            view.setLayoutParams(params);
        }

        return view;
    }
}

