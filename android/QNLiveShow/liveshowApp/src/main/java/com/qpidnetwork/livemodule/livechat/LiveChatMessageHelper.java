package com.qpidnetwork.livemodule.livechat;

import android.content.Context;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.SendType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.FunctionType;


/**
 * Livechat 相关公共转换工具类
 * @author Hunter
 * @since 2016.4.13
 */
public class LiveChatMessageHelper {
	
	public static FunctionType getFunctionTypeByMsgType(LCMessageItem.MessageType type){
		FunctionType functionType = null;
		switch (type) {
		case Text:
			functionType = FunctionType.CHAT_TEXT;
			break;
		case Emotion:
			functionType = FunctionType.CHAT_EMOTION;
			break;
		case Voice:
			functionType = FunctionType.CHAT_VOICE;
			break;
		case Photo:
			functionType = FunctionType.CHAT_PRIVATEPHOTO;
			break;
		case MagicIcon:
			functionType = FunctionType.CHAT_MAGICICON;
			break;

		default:
			break;
		}
		return functionType;
	}
	
	public static String getNoSupportMessage(Context context, LCMessageItem.MessageType type){
		String message = "";
		switch (type) {
		case Text:
			message = context.getString(R.string.livechat_text_notsupported_error);
			break;
		case Emotion:
			message = context.getString(R.string.livechat_emotion_notsupported_error);
			break;
		case Voice:
			message = context.getString(R.string.livechat_voice_notsupported_error);
			break;
		case Photo:
			message = context.getString(R.string.livechat_photo_notsupported_error);
			break;
		case MagicIcon:
			message = context.getString(R.string.livechat_magicIcon_notsupported_error);
			break;

		default:
			break;
		}
		return message;
	}

	/**
	 * livechat聊天信息与列表提示转换
	 * @param context
	 * @param msgItem
	 * @return
	 */
	public static String generateMsgHint(Context context, LCMessageItem msgItem) {
		String msg = "";
		/**
		 * <string-array name="livechat_msg_in_type"> <item
		 * name="received_system_message">You have a system messge</item> <item
		 * name="send_a_photo">You sent a photo</item> <item
		 * name="send_a_premium_sticker">You sent a premium sticker</item> <item
		 * name="send_a_voice_message">You sent a voice message</item> <item
		 * name="receive_a_photo">%s sent a photo</item> <item
		 * name="receive_a_premium_sticker">$s sent a premium sticker</item>
		 * <item name="receive_a_voice_message">%s sent a voice message</item>
		 * </string-array>
		 */
		String[] msgs_ = context.getResources().getStringArray(R.array.live_livechat_msg_in_type);
		switch (msgItem.msgType) {
			case Text:
				msg = (msgItem.getTextItem().message != null) ? msgItem
						.getTextItem().message : "";
				break;
			case Warning: // 警告消息
				msg = msgs_[0];
				break;
			case Emotion: // 高级表情
				if (msgItem.sendType == SendType.Send) {
					msg = msgs_[2];
				} else {
					LCUserItem userItem = msgItem.getUserItem();
					String userName =  userItem.userName;
					msg = String.format(msgs_[5], userName);
				}
				break;
			case Voice: // 语音
				if (msgItem.sendType == SendType.Send) {
					msg = msgs_[3];
				} else {
					msg = String.format(msgs_[6], msgItem.getUserItem().userName);
				}
				break;
			case Photo: // 私密照
				if (msgItem.sendType == SendType.Send) {
					msg = msgs_[1];
				} else {
					msg = String.format(msgs_[4], msgItem.getUserItem().userName);
				}
				break;
			case Video:
				if (msgItem.sendType == SendType.Send) {
					msg = msgs_[7];
				} else {
					msg = String.format(msgs_[8], msgItem.getUserItem().userName);
				}
				break;
			case MagicIcon: // 小高级表情
				if (msgItem.sendType == SendType.Send) {
					msg = msgs_[9];
				} else {
					LCUserItem userItem = msgItem.getUserItem();
					String userName =  userItem.userName;
					msg = String.format(msgs_[10], userName);
				}
				break;
			case System: // 系统消息
			case Custom: // 自定义消息
			case Unknow:
			default:
				// do nothing

		}

		return msg;
	}
}
