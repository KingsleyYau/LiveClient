package com.qpidnetwork.livemodule.liveshow.livechat;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.Html;
import android.text.Html.ImageGetter;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.style.ImageSpan;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.CustomerHtmlTagHandler;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.FileInputStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 表情HTML解释类
 * 
 */
public class ExpressionImageGetter implements ImageGetter {

	private Context context;
//	private TypedArray expressionsIcon;
	private Pattern p;

	private int imgType;// 1为按钮，2为普通表情，3为高级表情,4为国家按字母排序的搜索图片
//	private int msgForward;// 高级表情来源1为发出，0为收到

	private int imgWidth;
	private int imgHeight;
	private int textSize;

	public ExpressionImageGetter(Context context) {
		// this.context = context;
		// this.optionGroup = SpinnerDataParser.getOptionGroup(context,
		// "expressions");
		this.context = context;
//		this.expressionsIcon = context.getResources().obtainTypedArray(R.array.expressions);
		// this.p = Pattern.compile("/[0-9]+\\.");
		this.p = Pattern.compile("\\[img:[0-9]+\\]");
		textSize = context.getResources().getDimensionPixelSize(R.dimen.expre_drawable_size);
	}

	public ExpressionImageGetter(Context context, int imgWidth, int imgHeight) {
		this(context);
		this.imgWidth = imgWidth;
		this.imgHeight = imgHeight;
		textSize = context.getResources().getDimensionPixelSize(R.dimen.expre_drawable_size);
	}

	@SuppressWarnings("deprecation")
	@Override
	public Drawable getDrawable(String source) {
		// String key = source;
		Drawable drawable = null;
		String drawableName = null;

		int drawableId;

		// if (source.lastIndexOf("b") >= 0) {// 按钮
		if (source.contains("<img src=\"b")) {
			imgType = 1;
		} else if (source.contains("<img src=\"i")) {// 高级表情
			imgType = 3;
			source = source.substring(1, source.length());
		} else if (source.contains("<img src=\"s")) {
			imgType = 4;// 国家按字母排序的搜索图片
		} else {// 普通表情
			imgType = 2;
		}

		try {
			if (imgType == 3) {// 高级表情存SD卡
				drawableName = source;
				// String path = EmotionUtil.getEmotionThumbPath(context,
				// source, msgForward);
				String path = "";// TODO 获取高级表情路径
				FileInputStream is = new FileInputStream(path);
				drawable = Drawable.createFromStream(is, "");// 第二个参数是标签可有可无
			} else {
				if (imgType == 1) {
					drawableName = source;
				} else if (imgType == 2) {
					drawableName = source;
				} else if (imgType == 4) {

				}
				drawableId = R.drawable.class.getField(drawableName).getInt(null);
				drawable = context.getResources().getDrawable(drawableId);
			}

			if (imgType == 1) {
				doSetPicSize(drawable, R.dimen.btnWidth, R.dimen.btnHeight);
			} else if (imgType == 2 || imgType == 4) {
				// doSetPicSize(drawable, R.dimen.imgWidth,
				// R.dimen.imgHeight);
				drawable.setBounds(0, 0, (imgWidth == 0 ? drawable.getIntrinsicWidth() : imgWidth), (imgHeight == 0 ? drawable.getIntrinsicHeight()
						: imgHeight));
			} else if (imgType == 3) {
				doSetPicSize(drawable, R.dimen.emtWidth, R.dimen.emtHeight);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		// try {
		// // int index = Integer.parseInt(key);
		// // drawable = expressionsIcon.getDrawable(index);
		// String drawableName = source;
		// int drawableId =
		// R.drawable.class.getField(drawableName).getInt(null);
		// drawable =
		// QpidApp.application.getResources().getDrawable(drawableId);
		// drawable.setBounds(0, 0, (imgWidth == 0 ?
		// drawable.getIntrinsicWidth() : imgWidth), (imgHeight == 0 ?
		// drawable.getIntrinsicHeight()
		// : imgHeight));
		// } catch (Exception e) {
		// e.printStackTrace();
		// }
		return drawable;
	}

	/**
	 * 设置图片尺寸
	 * 
	 * @param drawable
	 * @param widthID
	 * @param heightID
	 */
	private void doSetPicSize(Drawable drawable, int widthID, int heightID) {
		int width = context.getResources().getDimensionPixelSize(widthID);
		int height = context.getResources().getDimensionPixelSize(heightID);
		if (drawable != null) {
			if (imgType == 1) {
				drawable.setBounds(20, 0, (width == 0 ? drawable.getIntrinsicWidth() : width), (height == 0 ? drawable.getIntrinsicHeight() : height));
			} else {
				drawable.setBounds(0, 0, (width == 0 ? drawable.getIntrinsicWidth() : width), (height == 0 ? drawable.getIntrinsicHeight() : height));
			}
		}
	}

	public void setTextSize(int textSize) {
		this.textSize = textSize;
	}

	/**
	 * 处理表情文本
	 * 
	 * @param input
	 * @return
	 */
	@SuppressWarnings("deprecation")
	public Spanned getExpressMsgHTML_bak(String input) { // 表情与文字的情况下，文字有时候居中，有时候靠下
		SpannableString span = new SpannableString(input);
		Matcher m = p.matcher(input);
		while (m.find()) {
			int start = m.start();
			int end = m.end();
			// 取[img:5]中的数字5
			String val = input.substring(start + 5, end - 1);
			int imgId = 0;
			try {
				imgId = R.drawable.class.getField("e" + val).getInt(null); // 图片的对应为R.drawable.e5
			} catch (Exception e) {
				e.printStackTrace();
			}
			if (imgId != 0) {
				Drawable drawable = context.getResources().getDrawable(imgId);
				if (drawable != null) {
					drawable.setBounds(0, 0, textSize, textSize);
				}
				ImageSpan imgSpan = new ImageSpan(drawable, ImageSpan.ALIGN_BOTTOM);
				span.setSpan(imgSpan, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
			}
		}
		return span;
	}

	// /**
	// * 处理表情文本
	// *
	// * @param input
	// * @return
	// */
	// public Spanned getExpressMsgHTMLSmall(String input) {
	// SpannableString span = new SpannableString(input);
	// Matcher m = p.matcher(input);
	// while(m.find()) {
	// int start = m.start();
	// int end = m.end();
	// //取[img:5]中的数字5
	// String val = input.substring(start + 5, end - 1);
	// int imgId = 0;
	// try {
	// imgId = R.drawable.class.getField("es" + val).getInt(null);
	// //图片的对应为R.drawable.e5
	// } catch(Exception e) {
	// e.printStackTrace();
	// }
	// if(imgId != 0) {
	// ImageSpan imgSpan = new ImageSpan(context, imgId);
	// span.setSpan(imgSpan, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
	// }
	// }
	// return span;
	// }

	/**
	 * 获取表情文本（HTML格式）
	 * 
	 * @param input 要处理的文本
	 * @param msgForward 文本来源{ MsgBean#FORWARD_IN} or
	 *            { MsgBean#FORWARD_OUT}
	 * @return
	 */
	public Spanned getExpressMsgHTML(String input, int msgForward) {
//		this.msgForward = msgForward;
		String msg = input.replace("[img:", "<img src=\"e");
		msg = msg.replace("[btn:", "<img src=\"b");
		msg = msg.replace("[emt:", "<img src=\"i");
		msg = msg.replace("]", "\">");
		Spanned span = Html.fromHtml(msg, this, null);
		return span;
	}

	/**
	 * 获取表情文本（HTML格式）
	 * 
	 * @param input
	 * @return
	 */
	public Spanned getExpressMsgHTML(String input) {
		String msg = input.replace("[img:", "<img src=\"e");
		msg = msg.replace("[btn:", "<img src=\"b");
		msg = msg.replace("[emt:", "<img src=\"i");
		msg = msg.replace("[s:", "<img src=\"");
		msg = msg.replace("]", "\">");
		Spanned span = Html.fromHtml(msg, this, null);
		return span;
	}
}
