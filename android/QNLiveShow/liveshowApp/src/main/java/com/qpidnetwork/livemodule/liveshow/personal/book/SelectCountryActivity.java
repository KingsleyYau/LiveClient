package com.qpidnetwork.livemodule.liveshow.personal.book;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.SectionIndexer;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.IndexableListView;
import com.qpidnetwork.livemodule.utils.StringMatcher;

import java.util.Arrays;
import java.util.List;

/**
 * SelectCountry模块
 * @author Max.Chiu
 */
public class SelectCountryActivity extends BaseActionBarFragmentActivity implements OnItemClickListener {
	public static String RESULT_COUNTRY_CODE = "countryCode";
    public static String RESULT_COUNTRY_INDEX = "country";
	public static String WITHOUT_CODE = "WITHOUT_CODE"; 
	
	private IndexableListView listView;
	private String[] mCountries;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setCustomContentView(R.layout.activity_live_select_country);

		//设置头
		setTitle(getString(R.string.live_book_choose_country_code_title), R.color.theme_default_black);

		//view
		InitView();
	}
	
	@Override
	protected void onResume() {
		super.onResume();
	}
	
	/**
	 * 点击取消
	 * @param v
	 */
	public void onClickCancel(View v) {
		((Activity) mContext).setResult(RESULT_CANCELED, null);
		finish();
	}

	public void InitView() {
		listView = (IndexableListView) findViewById(R.id.listView);
		
//		boolean bWithoutCode = false;
//		Bundle bundle = getIntent().getExtras();
//		if( bundle != null) {
//			bWithoutCode = bundle.getBoolean(WITHOUT_CODE);
//		}
		
//		String[] countries;
//		if( bWithoutCode ) {
//			countries = getResources().getStringArray(R.array.country_without_code);
//		} else {
			mCountries = getResources().getStringArray(R.array.live_country);
//		}


//		MaterialAppBar appbar = (MaterialAppBar)findViewById(R.id.appbar);
//		appbar.addButtonToLeft(R.id.common_button_back, "", R.drawable.ic_close_grey600_24dp);
//		appbar.setOnButtonClickListener(this);
//
//		appbar.setTitle(getString(R.string.Select_country), getResources().getColor(R.color.text_color_dark));
		CountryAdapter adapter = new CountryAdapter(this,
                android.R.layout.simple_list_item_1, Arrays.asList(mCountries));
        
		listView.setAdapter(adapter);
		listView.setFastScrollEnabled(true);
		listView.setOnItemClickListener(this);
	}
	@Override
	public void onItemClick(AdapterView<?> parent, View view,
			int position, long id) {
		Intent intent = new Intent();
		intent.putExtra(RESULT_COUNTRY_CODE , mCountries[position]);
//		intent.putExtra(RESULT_COUNTRY_INDEX, position);
//		((Activity) mContext).setResult(RESULT_OK, intent);
//		((Activity)mContext).finish();
		setResult(RESULT_OK, intent);
		finish();
	}

	private class CountryAdapter extends ArrayAdapter<String> implements SectionIndexer {
		private String mSections = "#ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		private Context context;

		public CountryAdapter(Context context, int textViewResourceId,
							  List<String> objects) {
			super(context, textViewResourceId, objects);
			this.context = context;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			// TODO Auto-generated method stub
			TextView textView = (TextView) super.getView(position, convertView, parent);
			textView.setTextColor(context.getResources().getColor(R.color.listview_divider_grey));
			textView.setLayoutParams(new  android.widget.AbsListView.LayoutParams( android.widget.AbsListView.LayoutParams.MATCH_PARENT, (int)(48.0f * context.getResources().getDisplayMetrics().density)));
			textView.setTextColor(context.getResources().getColor(R.color.text_color_dark));
			return textView;
		}

		@Override
		public int getPositionForSection(int section) {
			// If there is no item for current section, previous section will be selected
			for (int i = section; i >= 0; i--) {
				for (int j = 0; j < getCount(); j++) {
					if (i == 0) {
						// For numeric section
						for (int k = 0; k <= 9; k++) {
							if (StringMatcher.match(String.valueOf(getItem(j).charAt(0)), String.valueOf(k)))
								return j;
						}
					} else {
						if (StringMatcher.match(String.valueOf(getItem(j).charAt(0)), String.valueOf(mSections.charAt(i))))
							return j;
					}
				}
			}
			return 0;
		}

		@Override
		public int getSectionForPosition(int position) {
			return 0;
		}

		@Override
		public Object[] getSections() {
			String[] sections = new String[mSections.length()];
			for (int i = 0; i < mSections.length(); i++)
				sections[i] = String.valueOf(mSections.charAt(i));
			return sections;
		}
	}
}
