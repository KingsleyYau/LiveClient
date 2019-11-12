package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveDomainRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetMyProfileCallback;
import com.qpidnetwork.livemodule.httprequest.OnUpdateMyProfileCallback;
import com.qpidnetwork.livemodule.httprequest.item.LSProfileItem;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Children;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Education;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Height;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Income;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Language;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Profession;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Smoke;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Weight;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Zodiac;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.MyProfileInterestUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.utils.UserInfoUtil;
import com.qpidnetwork.livemodule.view.MaterialDialogSingleChoice;
import com.qpidnetwork.livemodule.view.ProfileItemView;
import com.qpidnetwork.livemodule.view.wrap.WrapBaseAdapter;
import com.qpidnetwork.livemodule.view.wrap.WrapListView;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;


/**
 * Hardy    2018/09/21
 * 拷贝自 QN 的 MyProfileDetailNewActivity
 */
//public class MyProfileDetailNewLiveActivity extends BaseFragmentActivity implements MaterialThreeButtonDialog.OnClickCallback {
//public class MyProfileDetailNewLiveActivity extends BaseFragmentActivity {
public class MyProfileDetailNewLiveActivity extends BaseUserIconUploadActivity {


    private class InterestLabelAdapter extends WrapBaseAdapter {

        private Context mContext;
        private List<String> mList;

        public InterestLabelAdapter(Context context, List<String> list) {
            this.mContext = context;
            this.mList = list;
        }

        @Override
        protected int getCount() {
            return mList.size();
        }

        @Override
        protected String getItem(int position) {
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
//                holder.elementContainer = (LinearLayout) convertView.findViewById(R.id.element_container);
//                holder.cvLabel = (CardView) convertView.findViewById(R.id.cvLabel);
                convertView = LayoutInflater.from(mContext).inflate(R.layout.adapter_interest_label, parent, false);
                holder.cvLabel = convertView.findViewById(R.id.llLabelRootView);

                holder.ivLabelCheck = (ImageView) convertView.findViewById(R.id.ivLabelCheck);
//                holder.ivLabelCheck.setVisibility(View.GONE);
                holder.tvLabelDesc = (TextView) convertView.findViewById(R.id.tvLabelDesc);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }

//            String name = getItem(position);
//            holder.cvLabel.setCardElevation(0);
//            holder.cvLabel.setCardBackgroundColor(mContext.getResources().getColor(R.color.thin_grey));
//            holder.elementContainer.setLayoutParams(new CardView.LayoutParams(LayoutParams.WRAP_CONTENT,
//                    (int) (24.0f * mContext.getResources().getDisplayMetrics().density)));
//            holder.tvLabelDesc.setTextColor(mContext.getResources().getColor(R.color.text_color_dark));
//            holder.tvLabelDesc.setTextSize(14.0f);
//            holder.tvLabelDesc.setText(name);

            String id = getItem(position);
            holder.tvLabelDesc.setText(MyProfileInterestUtil.formatId2String(mContext, id));
            holder.ivLabelCheck.setImageResource(MyProfileInterestUtil.formatId2ImageResId(id));

            return convertView;
        }

        private class ViewHolder {
            //            CardView cvLabel;
//            LinearLayout elementContainer;
            View cvLabel;

            ImageView ivLabelCheck;
            TextView tvLabelDesc;
        }

    }

    /**
     * 兴趣爱好
     */
    private WrapListView wrapListView;
    private List<String> mList = new ArrayList<String>();
    private InterestLabelAdapter interestLabelAdapter = new InterestLabelAdapter(this, mList);

    /**
     * 编辑个人简介
     */
    private static final int RESULT_SELF_INTRO = 0;
    /**
     * 编辑匹配女士
     */
    private static final int RESULT_MATCH_CRITERIA = 1;
    /**
     * 编辑兴趣爱好
     */
    private static final int RESULT_INTEREST = 2;

    /**
     * 关于最大显示字符
     */
    private static final int MAX_ABOUT_LENGTH = 200;

//    /**
//     * 拍照
//     */
//    private static final int RESULT_LOAD_IMAGE_CAPTURE = 3;
//    /**
//     * 相册
//     */
//    private static final int RESULT_LOAD_IMAGE_ALBUMN = 4;
//    /**
//     * 裁剪图片
//     */
//    private static final int RESULT_LOAD_IMAGE_CUT = 5;
//
//    /**
//     * 改变头像的广播
//     */
//    public static final String BROADCAST_ACTION_IMAGE_ICON_CHANGE = "BROADCAST_ACTION_MY_PROFILE_DETAIL_IMAGE_ICON_CHANGE";

    private enum RequestFlag {
        REQUEST_UPDATE_PROFILE_SUCCESS,
        REQUEST_PROFILE_SUCCESS,
        REQUEST_QUERYLADYMATCH_SUCCESS,
        REQUEST_FAIL,

        // hardy
        REQUEST_UPDATE_PROFILE_IMAGE_SUCCESS
    }


    /**
     * 上下文
     */
    private Context mContext;

    /**
     * 个人信息
     */
    private LSProfileItem mProfileTempItem;
    /**
     * 个人信息
     */
    private LSProfileItem mProfileItem;

//    /**
//     * 女士匹配条件
//     */
//    private LadyMatch mLadyMatch;

    private View rootView;
    /**
     * 用户头像
     */
    private ImageView imageViewHeader;
//    private ImageViewLoader loader;
    private ImageButton mIvIconUpload;

    /**
     * 用户名称
     */
    private TextView textViewName;

    /**
     * 国家/年龄
     */
    private TextView textViewAge;
    private TextView textViewCountry;

    /**
     * 个人简介
     */
    private TextView textViewSelfInfo;

    /**
     * 匹配说明
     */
//    private TextView textViewMatchCriteria;

    /**
     * 展开个人资料
     */
//    private Button buttonMoreSelfInfo;

    /**
     * 是否已经展开个人资料
     */
//    private boolean mMore = false;

    /**
     * 详细资料项目
     */

//    private MyProfileDetailEditItemView titleMyselfIntro;
    //    private MyProfileDetailEditItemView titleMyInterests;
//    private MyProfileDetailEditItemView titleMyMatchCriteria;

//    private MyProfileDetailEditItemView layoutMemberId;
//    private MyProfileDetailEditItemView layoutHeight;
//    private MyProfileDetailEditItemView layoutWeight;
//    private MyProfileDetailEditItemView layoutSmoke;
//    private MyProfileDetailEditItemView layoutDrink;
//    private MyProfileDetailEditItemView layoutEducation;
//    private MyProfileDetailEditItemView layoutProfession;
//    private MyProfileDetailEditItemView layoutEthnicity;
//    private MyProfileDetailEditItemView layoutReligion;
//    private MyProfileDetailEditItemView layoutPrimaryLanguage;
//    private MyProfileDetailEditItemView layoutHaveChildren;
//    private MyProfileDetailEditItemView layoutCurrentIncome;
//    private MyProfileDetailEditItemView layoutZodiac;

    // Hardy
    private TextView mTvInterestNoData;
    private ProfileItemView titleMyInterests;

    private TextView mTvAboutYouNoData;
    private ProfileItemView titleMyselfIntro;

    private ProfileItemView titleYourInformation;

    private ProfileItemView layoutMemberId;
    private ProfileItemView layoutHeight;
    private ProfileItemView layoutWeight;
    private ProfileItemView layoutSmoke;
    private ProfileItemView layoutEducation;
    private ProfileItemView layoutProfession;
    private ProfileItemView layoutPrimaryLanguage;
    private ProfileItemView layoutHaveChildren;
    private ProfileItemView layoutCurrentIncome;
    private ProfileItemView layoutZodiac;


    public static void startAct(Context context) {
        Intent intent = new Intent(context, MyProfileDetailNewLiveActivity.class);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mContext = this;
//        loader = new ImageViewLoader(this);

        InitView();

        // 创建界面时候，获取缓存数据
        mProfileItem = MyProfilePerfenceLive.GetProfileItem(mContext);
        if (mProfileItem != null) {
            mProfileTempItem = new LSProfileItem(mProfileItem);
        }

        if (mProfileItem != null) {
            setEnabledAll(rootView, true);
            // Hardy
            // 刷新界面
            ReloadData();
        } else {
            setEnabledAll(rootView, false);
        }

        // 请求个人资料
        GetMyProfile();

        // 请求匹配女士
//        QueryLadyMatch();
        // 刷新界面
//        ReloadData();
    }

    public static void setEnabledAll(View v, boolean enabled) {
        // old
//        v.setEnabled(enabled);
        // 2018/9/29 Hardy
        if (v.getId() != R.id.buttonCancel) {
            v.setEnabled(enabled);
        }

        v.setFocusable(enabled);

        if (v instanceof ViewGroup) {
            ViewGroup vg = (ViewGroup) v;
            for (int i = 0; i < vg.getChildCount(); i++) {
                setEnabledAll(vg.getChildAt(i), enabled);
            }
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        // 如果有需要, 则请求个人资料

        // 刷新界面
        ReloadData();
    }

    /**
     * 点击取消
     *
     * @param v
     */
    public void onClickCancel(View v) {
        finish();
    }

    /**
     * 点击查看头像
     *
     * @param view
     */
    public void onClickImageViewHeader(View view) {
        // 2018/9/27 查看大图头像
        openIconAct();
    }

    /**
     * 点击上传头像
     *
     * @param view
     */
    public void onClickImageUpload(View view) {
        // 2018/9/27 上传大图头像
        showIconUploadDialog();
    }

//    /**
//     * 点击上传头像
//     *
//     * @param view
//     */
//    public void onClickImageViewTakePhoto(View view) {
//        //先进行权限检测
//        PermissionManager permissionManager = new PermissionManager(mContext, new PermissionManager.PermissionCallback() {
//            @Override
//            public void onSuccessful() {
//                MaterialThreeButtonDialog dialog = new MaterialThreeButtonDialog(mContext, MyProfileDetailNewActivity.this);
//                dialog.show();
//            }
//
//            @Override
//            public void onFailure() {
//            }
//        });
//
//        permissionManager.requestPhoto();
//    }
//
//
//    @Override
//    public void OnFirstButtonClick(View v) {
//        File tempFile = new File(FileCacheManager.getInstance().GetTempCameraImageUrl());
//
//        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
//        //7。0＋拍照图片存取兼容 使用：FileProvider.getUriForFile
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//            intent.putExtra(
//                    MediaStore.EXTRA_OUTPUT,
//                    FileProvider.getUriForFile(mContext, getPackageName() + ".provider", tempFile)
//            );
//            // 给目标应用一个临时授权
//            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION
//                    | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
//        } else {
//            intent.putExtra(
//                    MediaStore.EXTRA_OUTPUT,
//                    Uri.fromFile(tempFile)
//            );
//        }
//        startActivityForResult(intent, RESULT_LOAD_IMAGE_CAPTURE);
//    }
//
//    @Override
//    public void OnSecondButtonClick(View v) {
//        try {
//            Intent intent = CompatUtil.getSelectPhotoFromAlumIntent();
//            startActivityForResult(intent, RESULT_LOAD_IMAGE_ALBUMN);
//        } catch (Exception e) {
//            Intent intent = new Intent();
//            intent.setType("image/*");
//            intent.setAction(Intent.ACTION_GET_CONTENT);
//            startActivityForResult(intent, RESULT_LOAD_IMAGE_ALBUMN);
//        }
//    }
//
//    @Override
//    public void OnCancelButtonClick(View v) {
//
//    }


    @Override
    public void onClick(View v) {
        boolean isIdClick = false;
        int id = v.getId();
        if (id == android.R.id.button1) {
            isIdClick = true;
            finish();
        }
//        else if (id == R.id.buttonMoreSelfInfo) {
//            isIdClick = true;
//            if (mMore) {
//                buttonMoreSelfInfo.setText("more");
//                textViewSelfInfo.setMaxLines(4);
//            } else {
//                buttonMoreSelfInfo.setText("less");
//                textViewSelfInfo.setMaxLines(999);
//            }
//            mMore = !mMore;
//        }
        if (isIdClick) {
            return;
        }

        int tagId = (int) v.getTag();
        if (tagId == R.id.layoutSelfIntro) {
            // 打开编辑个人简介
            Intent intent = new Intent(mContext, MyProfileDetailSelfIntroActivity.class);
            if (mProfileItem != null) {
                intent.putExtra(MyProfileDetailSelfIntroActivity.SELF_INTRO, mProfileItem.resume);
            }
            startActivityForResult(intent, RESULT_SELF_INTRO);
        } else if (tagId == R.id.layoutMyInterests) {
//            // 打开编辑兴趣爱好
            Intent intent = new Intent(mContext, MyProfileDetailInterestActivity.class);
            if (mProfileItem != null) {
                intent.putStringArrayListExtra(MyProfileDetailInterestActivity.INTEREST, mProfileItem.interests);
            }
            startActivityForResult(intent, RESULT_INTEREST);
        } else if (tagId == R.id.layoutHeight) {
            // 打开身高
            String[] array = getResources().getStringArray(R.array.height_live);
            MaterialDialogSingleChoice dialog = new MaterialDialogSingleChoice(
                    mContext,
                    array,
                    new MaterialDialogSingleChoice.OnClickCallback() {

                        @Override
                        public void onClick(AdapterView<?> adptView, View v, int which) {
                            if (which > -1 && which < Height.values().length) {
                                mProfileTempItem.height = Height.values()[which];
                                ReloadData();
                                UploadProfile();
                            }
                        }
                    },
                    mProfileItem.height.ordinal());

            dialog.setTitle("Your height");
            dialog.show();
            dialog.setCanceledOnTouchOutside(true);
        } else if (tagId == R.id.layoutWeight) {
            String[] array = getResources().getStringArray(R.array.weight_live);

            MaterialDialogSingleChoice dialog = new MaterialDialogSingleChoice(
                    mContext,
                    array,
                    new MaterialDialogSingleChoice.OnClickCallback() {

                        @Override
                        public void onClick(AdapterView<?> adptView, View v, int which) {
                            if (which > -1 && which < Weight.values().length) {
                                mProfileTempItem.weight = Weight.values()[which];
                                ReloadData();
                                UploadProfile();
                            }
                        }
                    },
                    mProfileItem.weight.ordinal());

            dialog.setTitle("Your weight");
            dialog.show();
            dialog.setCanceledOnTouchOutside(true);
        } else if (tagId == R.id.layoutSmoke) {
            String[] array = getResources().getStringArray(R.array.smoke_live);

            MaterialDialogSingleChoice dialog = new MaterialDialogSingleChoice(
                    mContext,
                    array,
                    new MaterialDialogSingleChoice.OnClickCallback() {

                        @Override
                        public void onClick(AdapterView<?> adptView, View v, int which) {
                            if (which > -1 && which < Smoke.values().length) {
                                mProfileTempItem.smoke = Smoke.values()[which];
                                ReloadData();
                                UploadProfile();
                            }
                        }
                    },
                    mProfileItem.smoke.ordinal());

            dialog.setTitle("Do you smoke?");
            dialog.show();
            dialog.setCanceledOnTouchOutside(true);
        } else if (tagId == R.id.layoutEducation) {
            String[] array = getResources().getStringArray(R.array.education_live);

            MaterialDialogSingleChoice dialog = new MaterialDialogSingleChoice(
                    mContext,
                    array,
                    new MaterialDialogSingleChoice.OnClickCallback() {

                        @Override
                        public void onClick(AdapterView<?> adptView, View v, int which) {
                            if (which > -1 && which < Education.values().length) {
                                mProfileTempItem.education = Education.values()[which];
                                ReloadData();
                                UploadProfile();
                            }
                        }
                    },
                    mProfileItem.education.ordinal());

            dialog.setTitle("What is you education level?");
            dialog.show();
            dialog.setCanceledOnTouchOutside(true);
        } else if (tagId == R.id.layoutProfession) {
            String[] array = getResources().getStringArray(R.array.profression_live);

            MaterialDialogSingleChoice dialog = new MaterialDialogSingleChoice(
                    mContext,
                    array,
                    new MaterialDialogSingleChoice.OnClickCallback() {

                        @Override
                        public void onClick(AdapterView<?> adptView, View v, int which) {
                            if (which > -1 && which < Profession.values().length) {
                                mProfileTempItem.profession = Profession.values()[which];
                                ReloadData();
                                UploadProfile();
                            }
                        }
                    },
                    mProfileItem.profession.ordinal());

            dialog.setTitle("Your profession");
            dialog.show();
            dialog.setCanceledOnTouchOutside(true);
        } else if (tagId == R.id.layoutPrimaryLanguage) {
            String[] array = getResources().getStringArray(R.array.language_live);

            MaterialDialogSingleChoice dialog = new MaterialDialogSingleChoice(
                    mContext,
                    array,
                    new MaterialDialogSingleChoice.OnClickCallback() {

                        @Override
                        public void onClick(AdapterView<?> adptView, View v, int which) {
                            if (which > -1 && which < Language.values().length) {
                                mProfileTempItem.language = Language.values()[which];
                                ReloadData();
                                UploadProfile();
                            }
                        }
                    },
                    mProfileItem.language.ordinal());

            dialog.setTitle("What language do you speak?");
            dialog.show();
            dialog.setCanceledOnTouchOutside(true);
        } else if (tagId == R.id.layoutHaveChildren) {
            String[] array = getResources().getStringArray(R.array.children_live);

            MaterialDialogSingleChoice dialog = new MaterialDialogSingleChoice(
                    mContext,
                    array,
                    new MaterialDialogSingleChoice.OnClickCallback() {

                        @Override
                        public void onClick(AdapterView<?> adptView, View v, int which) {
                            if (which > -1 && which < Children.values().length) {
                                mProfileTempItem.children = Children.values()[which];
                                ReloadData();
                                UploadProfile();
                            }
                        }
                    },
                    mProfileItem.children.ordinal());

            dialog.setTitle("Do you have children?");
            dialog.show();
            dialog.setCanceledOnTouchOutside(true);
        } else if (tagId == R.id.layoutCurrentIncome) {
            String[] array = getResources().getStringArray(R.array.income_live);

            MaterialDialogSingleChoice dialog = new MaterialDialogSingleChoice(
                    mContext,
                    array,
                    new MaterialDialogSingleChoice.OnClickCallback() {

                        @Override
                        public void onClick(AdapterView<?> adptView, View v, int which) {
                            if (which > -1 && which < Income.values().length) {
                                mProfileTempItem.income = Income.values()[which];
                                ReloadData();
                                UploadProfile();
                            }
                        }
                    },
                    mProfileItem.income.ordinal());

            dialog.setTitle("Your income");
            dialog.show();
            dialog.setCanceledOnTouchOutside(true);
        } else if (tagId == R.id.layoutZodiac) {
            String[] array = getResources().getStringArray(R.array.zodiac_live);

            MaterialDialogSingleChoice dialog = new MaterialDialogSingleChoice(
                    mContext,
                    array,
                    new MaterialDialogSingleChoice.OnClickCallback() {

                        @Override
                        public void onClick(AdapterView<?> adptView, View v, int which) {
                            if (which > -1 && which < Zodiac.values().length) {
                                mProfileTempItem.zodiac = Zodiac.values()[which];
                                ReloadData();
                                UploadProfile();
                            }
                        }
                    },
                    mProfileItem.zodiac.ordinal());

            dialog.setTitle("Your zodiac");
            dialog.show();
            dialog.setCanceledOnTouchOutside(true);
        }
    }

    /**
     * 初始化界面
     */
    private void InitView() {
        setContentView(R.layout.activity_my_profile_detail_new_live);
        rootView = findViewById(R.id.rootView);

        //APP BAR
//        MaterialAppBar appbar = (MaterialAppBar) findViewById(R.id.appbar);
//        appbar.setTouchFeedback(MaterialAppBar.TOUCH_FEEDBACK_HOLO_LIGHT);
//        appbar.addButtonToLeft(android.R.id.button1, "", R.drawable.ic_close_grey600_24dp);
//        appbar.setTitle(getString(R.string.title_activity_profile_detail), getResources().getColor(R.color.text_color_dark));
//        appbar.setOnButtonClickListener(this);

        // Hardy
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
//            ImageButton imgBtnCancel = (ImageButton) findViewById(R.id.buttonCancel);
//            ((LinearLayout.LayoutParams) imgBtnCancel.getLayoutParams()).topMargin += DisplayUtil.getStatusBarHeight(this);

            View headView = findViewById(R.id.act_my_profile_detail_new_ll_head_view);
            headView.setPadding(headView.getPaddingLeft(), headView.getPaddingTop() + DisplayUtil.getStatusBarHeight(this),
                    headView.getPaddingRight(), headView.getPaddingBottom());
            headView.setLayerType(View.LAYER_TYPE_SOFTWARE, null); //头像网络慢有时为黑:https://blog.csdn.net/huyawenz/article/details/78863636
        }


        /**
         * 用户头像
         */
        imageViewHeader = (ImageView) findViewById(R.id.imageViewHeader);
        mIvIconUpload =  findViewById(R.id.my_profile_iv_upload);
        // TODO: 2019/8/13 test
        mIvIconUpload.setVisibility(View.VISIBLE);
        /**
         *  用户名称
         */
        textViewName = (TextView) findViewById(R.id.textViewName);

        /**
         * 国家/年龄
         */
        textViewAge = (TextView) findViewById(R.id.textViewAge);
        textViewCountry = (TextView) findViewById(R.id.textViewCountry);

        /**
         * 展开个人资料
         */

//        titleMyMatchCriteria = (MyProfileDetailEditItemView) findViewById(R.id.layoutMatchCriteria);
//        titleMyInterests = (MyProfileDetailEditItemView) findViewById(R.id.layoutMyInterests);
//        titleMyselfIntro = (MyProfileDetailEditItemView) findViewById(R.id.layoutSelfIntro);
        titleMyselfIntro = (ProfileItemView) findViewById(R.id.layoutSelfIntro);
        titleMyInterests = (ProfileItemView) findViewById(R.id.layoutMyInterests);
        titleYourInformation = (ProfileItemView) findViewById(R.id.layoutYourInformation);

//        titleMyselfIntro.textViewValue.setVisibility(View.GONE);
//        titleMyInterests.textViewValue.setVisibility(View.GONE);
//        titleMyMatchCriteria.textViewValue.setVisibility(View.GONE);

//        titleMyselfIntro.textViewLeft.setTypeface(null, Typeface.BOLD);
//        titleMyMatchCriteria.textViewLeft.setTypeface(null, Typeface.BOLD);
//        titleMyInterests.textViewLeft.setText(getString(R.string.my_interest));
//        titleMyInterests.textViewLeft.setTypeface(null, Typeface.BOLD);
        titleMyInterests.setTextLeft(getString(R.string.my_interest));
        titleMyInterests.setTextLeftBold(true);
        titleMyInterests.setBottomLineLeftMarginDefault();
        titleMyInterests.setRightIcon2Arrow();
        titleMyInterests.setItemHeightSmall();

        titleMyselfIntro.setTextLeft(getString(R.string.My_selfintro));
        titleMyselfIntro.setTextLeftBold(true);
        titleMyselfIntro.setBottomLineLeftMarginDefault();
        titleMyselfIntro.setRightIcon2Arrow();
        titleMyselfIntro.setItemHeightSmall();
        titleMyselfIntro.setTextRightColorInt(ContextCompat.getColor(this,
                R.color.text_color_grey_light));
        titleMyselfIntro.setTextRightBold(false);

        titleYourInformation.setTextLeft(getString(R.string.Your_Information));
        titleYourInformation.setTextLeftBold(true);
        titleYourInformation.setBottomLineLeftMarginDefault();
        titleYourInformation.setItemHeightSmall();


        textViewSelfInfo = (TextView) findViewById(R.id.textViewSelfInfo);
//        buttonMoreSelfInfo = (Button) findViewById(R.id.buttonMoreSelfInfo);
//        buttonMoreSelfInfo.setOnClickListener(this);

        /**
         * 个人简介
         */
//        textViewSelfInfo = (TextView) findViewById(R.id.textViewSelfInfo);
//        MyProfileDetailEditItemView view = (MyProfileDetailEditItemView) findViewById(R.id.layoutSelfIntro);
//        view.imageViewRight.setTag(R.id.textViewSelfInfo);
//        view.imageViewRight.setOnClickListener(this);
        titleMyselfIntro.setTag(R.id.layoutSelfIntro);
        titleMyselfIntro.setOnClickListener(this);

//        /**
//         * 匹配说明
//         */
//        textViewMatchCriteria = (TextView) findViewById(R.id.textViewMatchCriteria);
//        view = (MyProfileDetailEditItemView) findViewById(R.id.layoutMatchCriteria);
//        view.textViewLeft.setText(R.string.My_match_criteria);
//        view.imageViewRight.setTag(R.id.textViewMatchCriteria);
//        view.imageViewRight.setOnClickListener(this);

        /**
         * 兴趣爱好
         */
//        view = (MyProfileDetailEditItemView) findViewById(R.id.layoutMyInterests);
//        view.textViewLeft.setText(R.string.my_interest);
//        view.imageViewRight.setTag(R.id.layoutMyInterests);
//        view.imageViewRight.setOnClickListener(this);
        titleMyInterests.setTag(R.id.layoutMyInterests);
        titleMyInterests.setOnClickListener(this);


        wrapListView = (WrapListView) findViewById(R.id.wrapListView);
        wrapListView.setDividerWidth(5);
        wrapListView.setDividerHeight(10);
        wrapListView.setAdapter(interestLabelAdapter);


        // Hardy
        List<ProfileItemView> itemViewList = new ArrayList<>();
        int colorLeftText = ContextCompat.getColor(this, R.color.text_color_grey_light);
        int colorRightText = ContextCompat.getColor(this, R.color.text_color_dark);

//        layoutMemberId = (MyProfileDetailEditItemView) findViewById(R.id.layoutMemberId);
//        layoutMemberId.textViewLeft.setText("Member ID");
//        layoutMemberId.textViewValue.setText("");
//        layoutMemberId.imageViewRight.setVisibility(View.INVISIBLE);
        layoutMemberId = (ProfileItemView) findViewById(R.id.layoutMemberId);
        layoutMemberId.setTextLeft("Member ID:");
        layoutMemberId.setTextRightColorInt(colorRightText);
        layoutMemberId.setTextLeftColorInt(colorLeftText);
        layoutMemberId.setItemHeightSmall();
        layoutMemberId.setTextRightBold(false);

        /**
         * 身高
         */
//        layoutHeight = (MyProfileDetailEditItemView) findViewById(R.id.layoutHeight);
//        layoutHeight.textViewLeft.setText("Height");
//        layoutHeight.imageViewRight.setTag(R.id.layoutHeight);
//        layoutHeight.imageViewRight.setOnClickListener(this);
        layoutHeight = (ProfileItemView) findViewById(R.id.layoutHeight);
        layoutHeight.setTag(R.id.layoutHeight);
        layoutHeight.setTextLeft("Height:");
        itemViewList.add(layoutHeight);

        /**
         * 体重
         */
//        layoutWeight = (MyProfileDetailEditItemView) findViewById(R.id.layoutWeight);
//        layoutWeight.textViewLeft.setText("Weight");
//        layoutWeight.imageViewRight.setTag(R.id.layoutWeight);
//        layoutWeight.imageViewRight.setOnClickListener(this);
        layoutWeight = (ProfileItemView) findViewById(R.id.layoutWeight);
        layoutWeight.setTag(R.id.layoutWeight);
        layoutWeight.setTextLeft("Weight:");
        itemViewList.add(layoutWeight);

        /**
         * 吸烟状态
         */
//        layoutSmoke = (MyProfileDetailEditItemView) findViewById(R.id.layoutSmoke);
//        layoutSmoke.textViewLeft.setText("Smoke");
//        layoutSmoke.imageViewRight.setTag(R.id.layoutSmoke);
//        layoutSmoke.imageViewRight.setOnClickListener(this);
        layoutSmoke = (ProfileItemView) findViewById(R.id.layoutSmoke);
        layoutSmoke.setTag(R.id.layoutSmoke);
        layoutSmoke.setTextLeft("Smoke:");
        itemViewList.add(layoutSmoke);

//        /**
//         * 喝酒状态
//         */
//        layoutDrink = (MyProfileDetailEditItemView) findViewById(R.id.layoutDrink);
//        layoutDrink.textViewLeft.setText("Drink");
//        layoutDrink.imageViewRight.setTag(R.id.layoutDrink);
//        layoutDrink.imageViewRight.setOnClickListener(this);

        /**
         * 教育程度
         */
//        layoutEducation = (MyProfileDetailEditItemView) findViewById(R.id.layoutEducation);
//        layoutEducation.textViewLeft.setText("Education");
//        layoutEducation.imageViewRight.setTag(R.id.layoutEducation);
//        layoutEducation.imageViewRight.setOnClickListener(this);
        layoutEducation = (ProfileItemView) findViewById(R.id.layoutEducation);
        layoutEducation.setTag(R.id.layoutEducation);
        layoutEducation.setTextLeft("Education:");
        itemViewList.add(layoutEducation);

        /**
         * 职业
         */
//        layoutProfession = (MyProfileDetailEditItemView) findViewById(R.id.layoutProfession);
//        layoutProfession.textViewLeft.setText("Profession");
//        layoutProfession.imageViewRight.setTag(R.id.layoutProfession);
//        layoutProfession.imageViewRight.setOnClickListener(this);
        layoutProfession = (ProfileItemView) findViewById(R.id.layoutProfession);
        layoutProfession.setTag(R.id.layoutProfession);
        layoutProfession.setTextLeft("Profession:");
        itemViewList.add(layoutProfession);

//        /**
//         * 信仰
//         */
//        layoutEthnicity = (MyProfileDetailEditItemView) findViewById(R.id.layoutEthnicity);
//        layoutEthnicity.textViewLeft.setText("Ethnicity");
//        layoutEthnicity.imageViewRight.setTag(R.id.layoutEthnicity);
//        layoutEthnicity.imageViewRight.setOnClickListener(this);

//        /**
//         * 种族
//         */
//        layoutReligion = (MyProfileDetailEditItemView) findViewById(R.id.layoutReligion);
//        layoutReligion.textViewLeft.setText("Religion");
//        layoutReligion.imageViewRight.setTag(R.id.layoutReligion);
//        layoutReligion.imageViewRight.setOnClickListener(this);

        /**
         * 语言
         */
//        layoutPrimaryLanguage = (MyProfileDetailEditItemView) findViewById(R.id.layoutPrimaryLanguage);
//        layoutPrimaryLanguage.textViewLeft.setText("Primary Language");
//        layoutPrimaryLanguage.imageViewRight.setTag(R.id.layoutPrimaryLanguage);
//        layoutPrimaryLanguage.imageViewRight.setOnClickListener(this);
        layoutPrimaryLanguage = (ProfileItemView) findViewById(R.id.layoutPrimaryLanguage);
        layoutPrimaryLanguage.setTag(R.id.layoutPrimaryLanguage);
        layoutPrimaryLanguage.setTextLeft("Primary Language:");
        itemViewList.add(layoutPrimaryLanguage);
        /**
         * 子女情况
         */
//        layoutHaveChildren = (MyProfileDetailEditItemView) findViewById(R.id.layoutHaveChildren);
//        layoutHaveChildren.textViewLeft.setText("Have Children");
//        layoutHaveChildren.imageViewRight.setTag(R.id.layoutHaveChildren);
//        layoutHaveChildren.imageViewRight.setOnClickListener(this);
        layoutHaveChildren = (ProfileItemView) findViewById(R.id.layoutHaveChildren);
        layoutHaveChildren.setTag(R.id.layoutHaveChildren);
        layoutHaveChildren.setTextLeft("Children:");
        itemViewList.add(layoutHaveChildren);

        /**
         * 收入情况
         */
//        layoutCurrentIncome = (MyProfileDetailEditItemView) findViewById(R.id.layoutCurrentIncome);
//        layoutCurrentIncome.textViewLeft.setText("Current Income");
//        layoutCurrentIncome.imageViewRight.setTag(R.id.layoutCurrentIncome);
//        layoutCurrentIncome.imageViewRight.setOnClickListener(this);
        layoutCurrentIncome = (ProfileItemView) findViewById(R.id.layoutCurrentIncome);
        layoutCurrentIncome.setTag(R.id.layoutCurrentIncome);
        layoutCurrentIncome.setTextLeft("Current Income:");
        itemViewList.add(layoutCurrentIncome);

        /**
         * 星座
         */
//        layoutZodiac = (MyProfileDetailEditItemView) findViewById(R.id.layoutZodiac);
//        layoutZodiac.textViewLeft.setText("Zodiac");
        layoutZodiac = (ProfileItemView) findViewById(R.id.layoutZodiac);
        layoutZodiac.setTag(R.id.layoutZodiac);
        layoutZodiac.setTextLeft("Zodiac:");
        itemViewList.add(layoutZodiac);

//		layoutZodiac.imageViewRight.setOnClickListener(new OnClickListener() {
//			
//			@Override
//			public void onClick(View v) {
//
//			}
//		});
//        layoutZodiac.setVisibility(View.GONE);


        // Hardy
        for (ProfileItemView itemView : itemViewList) {
            itemView.setTextRightColorInt(colorRightText);
            itemView.setTextLeftColorInt(colorLeftText);
            itemView.setRightIcon2Arrow();
            itemView.setItemHeightSmall();
            itemView.setTextRightBold(false);
            itemView.setOnClickListener(this);
        }

        // 固定图片背景
//        ImageView mIvHeadViewBg = (ImageView) findViewById(R.id.act_my_profile_detail_new_iv_head_bg);
//        PicassoLoadUtil.loadRes(mIvHeadViewBg, R.drawable.bg_profile_detail);

        // 我的兴趣——无数据的 View
        mTvInterestNoData = (TextView) findViewById(R.id.act_my_profile_detail_new_tv_interest_no_data);
        showInterestDataView(false);

        // 我的个人介绍——无数据的 View
        mTvAboutYouNoData = (TextView) findViewById(R.id.act_my_profile_detail_new_tv_about_you_no_data);
        showAboutYouNoDataView(false);
    }

    private void showInterestDataView(boolean hasData) {
        mTvInterestNoData.setVisibility(hasData ? View.GONE : View.VISIBLE);
        wrapListView.setVisibility(hasData ? View.VISIBLE : View.GONE);
    }

    private void showAboutYouNoDataView(boolean hasData) {
        mTvAboutYouNoData.setVisibility(hasData ? View.GONE : View.VISIBLE);
        findViewById(R.id.act_my_profile_detail_new_ll_about_you).setVisibility(hasData ? View.VISIBLE : View.GONE);
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject obj = (HttpRespObject) msg.obj;

        if (msg.what >= RequestFlag.values().length) {
            return;
        }

        switch (RequestFlag.values()[msg.what]) {
//            case REQUEST_UPDATE_PROFILE_IMAGE_SUCCESS:
//                hideProgressDialog();
//                BroadcastManager.sendBroadcast(this, new Intent(BROADCAST_ACTION_IMAGE_ICON_CHANGE));
//                // 上传头像成功
//                // 重新获取个人信息
//                GetMyProfile();
//                break;

            case REQUEST_PROFILE_SUCCESS:
                hideProgressDialog();
                // 缓存数据
                mProfileItem = (LSProfileItem) obj.data;
                if (mProfileItem != null) {
                    mProfileTempItem = new LSProfileItem(mProfileItem);
                }
                MyProfilePerfenceLive.SaveProfileItem(mContext, mProfileItem);

                // 2019/8/13 Hardy
                setLsProfileItem(mProfileItem);

                // 刷新界面
                ReloadData();
                break;

            case REQUEST_UPDATE_PROFILE_SUCCESS:
                showToastDone("Done");
                //拷贝临时存储到显示item
                if (mProfileTempItem != null) {
                    mProfileItem.copy(mProfileTempItem);
                }

                // 缓存数据
                MyProfilePerfenceLive.SaveProfileItem(mContext, mProfileItem);

                ReloadData();
                break;

//            case REQUEST_QUERYLADYMATCH_SUCCESS:
//                cancelToast();
//
//                // 获取匹配女士成功
//                // 缓存数据
//                mLadyMatch = (LadyMatch) obj.body;
//                MyProfilePerfence.SaveLadyMatch(mContext, mLadyMatch);
//
//                ReloadData();
//                break;

            case REQUEST_FAIL: {
                hideProgressDialog();
                cancelToastImmediately();
                ToastUtil.showToast(mContext, obj.errMsg);
            }
            break;

            default:
                break;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode) {
            case RESULT_SELF_INTRO: {
                // 编辑个人简介返回
                if (resultCode == RESULT_OK) {
                    String resume = data.getExtras().getString(MyProfileDetailSelfIntroActivity.SELF_INTRO);

                    mProfileItem.resume_status = LSProfileItem.ResumeStatus.UnVerify;
                    mProfileItem.resume_content = resume;

                    //同步到临时资料
                    mProfileTempItem.resume_status = LSProfileItem.ResumeStatus.UnVerify;
                    mProfileTempItem.resume_content = resume;

                    // 刷新界面
                    ReloadData();

                    // 上传资料
//                    UploadProfile();
                }
            }
            break;

            case RESULT_MATCH_CRITERIA: {
                // 编辑匹配女士
                if (resultCode == RESULT_OK) {

                }
            }
            break;

            case RESULT_INTEREST: {
                // 编辑兴趣爱好
                if (resultCode == RESULT_OK) {
                    ArrayList<String> interests = data.getExtras().getStringArrayList(MyProfileDetailInterestActivity.INTEREST);
                    mProfileItem.interests = interests;
                    //修改临时提交对象，防止其他修改上传时，本地未同步
                    mProfileTempItem.interests = interests;

                    // 刷新界面
                    ReloadData();

                    // 上传资料
//                    UploadProfile();
                }
            }
            break;


//            case RESULT_LOAD_IMAGE_CAPTURE: {
//                if (resultCode == RESULT_OK) {
//                    File tempCameraImager = new File(FileCacheManager.getInstance().GetTempCameraImageUrl());
//                    File tempImager = new File(FileCacheManager.getInstance().GetTempImageUrl());
//
//                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//                        doStartPhotoZoom(
//                                FileProvider.getUriForFile(mContext, getPackageName() + ".provider", tempCameraImager),
//                                Uri.fromFile(tempImager)    //照片 截取输出的outputUri， 只能使用 Uri.fromFile，不能用FileProvider.getUriForFile
//                                //不然会报：Permission Denial: writing android.support.v4.content.FileProvider
//                        );
//                    } else {
//                        doStartPhotoZoom(
//                                Uri.fromFile(tempCameraImager),
//                                Uri.fromFile(tempImager)
//                        );
//                    }
//                }
//            }
//            break;
//
//            case RESULT_LOAD_IMAGE_ALBUMN: {
//                if (resultCode == RESULT_OK && null != data) {
//                    Uri selectedImage = data.getData();
//                    String picturePath = CompatUtil.getSelectedPhotoPath(this, selectedImage);
//                    if (!StringUtil.isEmpty(picturePath)) {
//                        File pic = new File(picturePath);
//                        File picCut = new File(FileCacheManager.getInstance().GetTempImageUrl());
//
//                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//                            doStartPhotoZoom(
//                                    FileProvider.getUriForFile(mContext, getPackageName() + ".provider", pic),
//                                    Uri.fromFile(picCut)    //照片 截取输出的outputUri， 只能使用 Uri.fromFile，不能用FileProvider.getUriForFile
//                                    //不然会报：Permission Denial: writing android.support.v4.content.FileProvider
//                            );
//                        } else {
//                            doStartPhotoZoom(
//                                    Uri.fromFile(pic),
//                                    Uri.fromFile(picCut)
//                            );
//                        }
//
//                    }
//                }
//            }
//            break;
//
//            case RESULT_LOAD_IMAGE_CUT: {
//                if (resultCode == RESULT_OK) {
//                    // 上传头像
//                    showProgressDialog("Uploading...");
//                    RequestOperator.getInstance().UploadHeaderPhoto(
//                            FileCacheManager.getInstance().GetTempImageUrl(),
//                            new OnRequestCallback() {
//
//                                @Override
//                                public void OnRequest(boolean isSuccess, String errno, String errmsg) {
//                                    Message msg = Message.obtain();
//                                    RequestBaseResponse obj = new RequestBaseResponse(isSuccess, errno, errmsg, null);
//                                    if (isSuccess) {
//                                        // 上传头像成功
////                                        msg.what = RequestFlag.REQUEST_UPLOAD_SUCCESS.ordinal();
//                                        msg.what = RequestFlag.REQUEST_UPDATE_PROFILE_IMAGE_SUCCESS.ordinal();
//                                    } else {
//                                        // 上传头像失败
//                                        msg.what = RequestFlag.REQUEST_FAIL.ordinal();
//                                    }
//                                    msg.obj = obj;
//                                    sendUiMessage(msg);
//                                }
//                            });
//                }
//            }
//            break;
            default:
                break;
        }
    }

    @Override
    protected void onUploadIconSuccess() {

    }

    @Override
    protected void onLoadUserInfo() {
        GetMyProfile();
    }

    @Override
    protected boolean isRegisterGetUserInfoBroadcast() {
        return true;
    }

//    /**
//     * 裁剪图片方法实现
//     */
//    public void doStartPhotoZoom(Uri src, Uri dest) {
//        Intent intent = new Intent("com.android.camera.action.CROP");
//        // 给目标应用一个临时授权
//        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION
//                | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
//        intent.setDataAndType(src, "image/*");
//        // 下面这个crop=true是设置在开启的Intent中设置显示的VIEW可裁剪
//        intent.putExtra("crop", "true");
//
//        // aspectX aspectY 是宽高(x y方向上)的比例，其小于1的时候可以操作截图框,若不设定，则可以任意宽度和高度
//        intent.putExtra("aspectX", 4);
//        intent.putExtra("aspectY", 5);
//        intent.putExtra("scale", true);
//
//        intent.putExtra("output", dest);// 指定裁剪后的图片存储路径
//        intent.putExtra("outputX", 400);// outputX outputY裁剪保存的宽高(使各手机截取的图片质量一致)
//        intent.putExtra("outputY", 500);
//
//        intent.putExtra("noFaceDetection", true);// 取消人脸识别功能(系统的裁剪图片默认对图片进行人脸识别,当识别到有人脸时，会按aspectX和aspectY为1来处理)
//        intent.putExtra("return-data", false);// 将相应的数据与URI关联起来，返回裁剪后的图片URI,true返回bitmap
//        intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
//        startActivityForResult(intent, RESULT_LOAD_IMAGE_CUT);
//    }

    /**
     * 获取个人信息
     */
    private void GetMyProfile() {
        // 此处应有菊花
        showProgressDialog("Loading...");
//        RequestJniOther.getInstance().GetMyProfile(new OnGetMyProfileCallback() {
        LiveDomainRequestOperator.getInstance().GetMyProfile(new OnGetMyProfileCallback() {
            @Override
            public void onGetMyProfile(boolean isSuccess, int errno, String errmsg, LSProfileItem item) {
                Message msg = Message.obtain();
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

//    /**
//     * 获取配皮女士
//     */
//    private void QueryLadyMatch() {
//        // 此处应有菊花
//        RequestOperator.getInstance().QueryLadyMatch(new OnQueryLadyMatchCallback() {
//            @Override
//            public void OnQueryLadyMatch(boolean isSuccess, String errno,
//                                         String errmsg, LadyMatch item) {
//                Message msg = Message.obtain();
//                RequestBaseResponse obj = new RequestBaseResponse(isSuccess, errno, errmsg, item);
//                if (isSuccess) {
//                    // 获取配皮女士成功
//                    msg.what = RequestFlag.REQUEST_QUERYLADYMATCH_SUCCESS.ordinal();
//                } else {
//                    // 获取个人信息失败
//                    msg.what = RequestFlag.REQUEST_FAIL.ordinal();
//                }
//                msg.obj = obj;
//                sendUiMessage(msg);
//            }
//        });
//    }

    /**
     * 上传个人信息
     */
    private void UploadProfile() {
        // 此处应有菊花
        showToastProgressing("Updating...");
//        RequestOperator.getInstance().UpdateProfile(
        LiveDomainRequestOperator.getInstance().UpdateProfile(
                mProfileTempItem.weight,
                mProfileTempItem.height,
                mProfileTempItem.language,
                mProfileTempItem.ethnicity,
                mProfileTempItem.religion,
                mProfileTempItem.education,
                mProfileTempItem.profession,
                mProfileTempItem.income,
                mProfileTempItem.children,
                mProfileTempItem.smoke,
                mProfileTempItem.drink,
                mProfileTempItem.resume,
                mProfileTempItem.interests.toArray(new String[mProfileTempItem.interests.size()]),
                mProfileTempItem.zodiac,
                new OnUpdateMyProfileCallback() {

                    @Override
                    public void onUpdateMyProfile(boolean isSuccess, int errno,
                                                  String errmsg, boolean rsModified) {
                        Message msg = Message.obtain();
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

    /**
     * 刷新界面
     */
    private void ReloadData() {
        if (mProfileItem != null) {
            /**
             * 头像
             */
            String url = mProfileItem.photoURL;
            if (mProfileItem.showPhoto()) {
                int wh = DisplayUtil.dip2px(mContext, 100);
                PicassoLoadUtil.loadUrlNoMCache(imageViewHeader, url, R.drawable.ic_user_icon, wh, wh);
            } else {
                imageViewHeader.setImageResource(R.drawable.ic_user_icon);
            }

            // TODO: 2019/8/13 Hardy  暂时注释
            mIvIconUpload.setVisibility(mProfileItem.showUpload() ? View.VISIBLE : View.GONE);

            /**
             * 名称
             */
            textViewName.setText(UserInfoUtil.getUserFullName(mProfileItem.firstname, mProfileItem.lastname));

            /**
             * 国家/年龄
             */
            textViewAge.setText(mProfileItem.age + "");
            textViewCountry.setText(mProfileItem.country.name());

            /**
             * 个人简介
             * Hardy
             * 1 未审核 显示审核中的个人描述
             * 2 审核通过 3 审核不通过 显示 JJ 个人描述
             */
            if (mProfileItem.resume_status == LSProfileItem.ResumeStatus.UnVerify) {
//                textViewSelfInfo.setText(mProfileItem.resume_content);
                doSetAboutContent(mProfileItem.resume_content);
                showAboutYouNoDataView(TextUtils.isEmpty(mProfileItem.resume_content) ? false : true);

                titleMyselfIntro.setRightIconNull();
                titleMyselfIntro.setOnClickListener(null);
                titleMyselfIntro.setTextRight("Pending approved");
            } else {
//                textViewSelfInfo.setText(mProfileItem.resume);
                doSetAboutContent(mProfileItem.resume);
                showAboutYouNoDataView(TextUtils.isEmpty(mProfileItem.resume) ? false : true);

                titleMyselfIntro.setRightIcon2Arrow();
                titleMyselfIntro.setOnClickListener(this);
                titleMyselfIntro.setTextRight("");
            }


            /**
             * 兴趣爱好
             */
            mList.clear();
            if (mProfileItem.interests != null) {
                for (String item : mProfileItem.interests) {
                    if (!TextUtils.isEmpty(item)) {    //接口返回 "interests":"",C解析变成第一个item为""的数组,在JAVA这处理一下. 不然没兴趣时,会有一个空的兴趣.
//                        mList.add(InterestToString(item));

                        // 2018/10/31 Hardy 不转换，直接在 adapter 里根据 id 获取名字和 icon 资源 id
                        mList.add(item);
                    }
                }
            }
            interestLabelAdapter.notifyDataSetChanged();
            // hardy
            showInterestDataView(ListUtils.isList(mList));


//            /**
//             * 匹配说明
//             */
//            textViewMatchCriteria.setText(MatchCriteriaToString());

            /**
             * 详细资料项目
             */
//            layoutMemberId.textViewValue.setText(mProfileItem.manid.toUpperCase(Locale.ENGLISH));
//            layoutHeight.textViewValue.setText(getResources().getStringArray(R.array.height)[mProfileItem.height.ordinal()]);
//            layoutWeight.textViewValue.setText(getResources().getStringArray(R.array.weight)[mProfileItem.weight.ordinal()]);
//            layoutSmoke.textViewValue.setText(getResources().getStringArray(R.array.smoke)[mProfileItem.smoke.ordinal()]);
//            layoutDrink.textViewValue.setText(getResources().getStringArray(R.array.drink)[mProfileItem.drink.ordinal()]);
//            layoutEducation.textViewValue.setText(getResources().getStringArray(R.array.education)[mProfileItem.education.ordinal()]);
//            layoutProfession.textViewValue.setText(getResources().getStringArray(R.array.profression_live)[mProfileItem.profession.ordinal()]);
//            layoutEthnicity.textViewValue.setText(getResources().getStringArray(R.array.ethnicity)[mProfileItem.ethnicity.ordinal()]);
//            layoutReligion.textViewValue.setText(getResources().getStringArray(R.array.religion)[mProfileItem.religion.ordinal()]);
//            layoutPrimaryLanguage.textViewValue.setText(getResources().getStringArray(R.array.language_live)[mProfileItem.language.ordinal()]);
//            layoutHaveChildren.textViewValue.setText(getResources().getStringArray(R.array.children_live)[mProfileItem.children.ordinal()]);
//            layoutCurrentIncome.textViewValue.setText(getResources().getStringArray(R.array.income_live)[mProfileItem.income.ordinal()]);

            layoutMemberId.setTextRight(mProfileItem.manid.toUpperCase(Locale.ENGLISH));
            layoutHeight.setTextRight(getResources().getStringArray(R.array.height_live)[mProfileItem.height.ordinal()]);
            layoutWeight.setTextRight(getResources().getStringArray(R.array.weight_live)[mProfileItem.weight.ordinal()]);
            layoutSmoke.setTextRight(getResources().getStringArray(R.array.smoke_live)[mProfileItem.smoke.ordinal()]);
            layoutEducation.setTextRight(getResources().getStringArray(R.array.education_live)[mProfileItem.education.ordinal()]);
            layoutProfession.setTextRight(getResources().getStringArray(R.array.profression_live)[mProfileItem.profession.ordinal()]);
            layoutPrimaryLanguage.setTextRight(getResources().getStringArray(R.array.language_live)[mProfileItem.language.ordinal()]);
            layoutHaveChildren.setTextRight(getResources().getStringArray(R.array.children_live)[mProfileItem.children.ordinal()]);
            layoutCurrentIncome.setTextRight(getResources().getStringArray(R.array.income_live)[mProfileItem.income.ordinal()]);
            layoutZodiac.setTextRight(getResources().getStringArray(R.array.zodiac_live)[mProfileItem.zodiac.ordinal()]);
        }
        // Hardy
        else {
            showInterestDataView(false);
            showAboutYouNoDataView(false);

        }

        if (mProfileItem != null) {
            setEnabledAll(rootView, true);
        } else {
            setEnabledAll(rootView, false);
        }
    }

    /**
     * 关于
     *
     * @param content
     */
    private void doSetAboutContent(String content) {
        if (content.length() > MAX_ABOUT_LENGTH) {
            doSetAboutSimpleContent(content);
        } else {
            textViewSelfInfo.setText(content);
        }
    }

    /**
     * 关于设置为只显示:200字 + MORE
     *
     * @param content
     */
    private void doSetAboutSimpleContent(final String content) {
        String simpleContent = content.substring(0, MAX_ABOUT_LENGTH);
        textViewSelfInfo.setText(simpleContent);
        //more
        SpannableString spanText = new SpannableString(getString(R.string.more));
        spanText.setSpan(new ClickableSpan() {
            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(Color.BLUE);       //设置文件颜色
                ds.setUnderlineText(false);      //设置下划线
            }

            @Override
            public void onClick(View widget) {
                doSetAboutFullContent(content);
            }
        }, 0, spanText.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        textViewSelfInfo.setHighlightColor(Color.TRANSPARENT); //设置点击后的颜色为透明，否则会一直出现高亮
        textViewSelfInfo.append(" ");
        textViewSelfInfo.append(spanText);
        textViewSelfInfo.setMovementMethod(LinkMovementMethod.getInstance());//开始响应点击事件

    }

    /**
     * 关于设置为显示:全部字 + LESS
     *
     * @param content
     */
    private void doSetAboutFullContent(final String content) {
        textViewSelfInfo.setText(content);
        //less
        SpannableString spanText = new SpannableString(getString(R.string.less));
        spanText.setSpan(new ClickableSpan() {
            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(Color.BLUE);       //设置文件颜色
                ds.setUnderlineText(false);      //设置下划线
            }

            @Override
            public void onClick(View widget) {
                doSetAboutSimpleContent(content);
            }
        }, 0, spanText.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        textViewSelfInfo.setHighlightColor(Color.TRANSPARENT); //设置点击后的颜色为透明，否则会一直出现高亮
        textViewSelfInfo.append(" ");
        textViewSelfInfo.append(spanText);
        textViewSelfInfo.setMovementMethod(LinkMovementMethod.getInstance());//开始响应点击事件

    }

//    /**
//     * 获取匹配条件女士简介字符串
//     *
//     * @return
//     */
//    private String MatchCriteriaToString() {
//        String result = "";
//
//        if (mLadyMatch != null) {
//            // age
//            String format = getResources().getString(R.string.my_profile_match_criteria_age);
//            result += String.format(format, mLadyMatch.age1, mLadyMatch.age2);
//            result += " ";
//
//            // children
//            switch (mLadyMatch.children) {
//                case Yes: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_children_yes);
//                }
//                break;
//                default: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_children_no);
//                }
//                break;
//            }
//            result += " ";
//
//            // education
//            switch (mLadyMatch.education) {
//                case Unknow: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_education_height_school);
//                }
//                break;
//                case SecondaryHighSchool: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_education_height_school);
//                }
//                break;
//                case VocationalSchool: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_education_vocational_school);
//                }
//                break;
//                case College: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_education_college);
//                }
//                break;
//                case Bachelor: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_education_bachelor);
//                }
//                break;
//                case Master: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_education_master);
//                }
//                break;
//                case Doctorate: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_education_doctorate);
//                }
//                break;
//                case PostDoctorate: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_education_post_doctorate);
//                }
//                break;
//                default: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_education_height_school);
//                }
//                break;
//            }
//            result += " ";
//
//            // married
//            switch (mLadyMatch.marry) {
//                case Unknow: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_married_single);
//                }
//                break;
//                case NeverMarried: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_married_single);
//                }
//                break;
//                case Divorced: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_married_divorced);
//                }
//                break;
//                case Widowed: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_married_widowed);
//                }
//                break;
//                case Separated: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_married_separated);
//                }
//                break;
//                case Married: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_married_married);
//                }
//                break;
//                default: {
//                    result += getResources().getString(R.string.my_profile_match_criteria_married_single);
//                }
//                break;
//            }
//        }
//
//        return result;
//    }
}
