package net.qdating.player;

/**
 * 音频渲染接口JNI
 * @author max
 *
 */
public interface ILSAudioRendererJni {
	void renderAudioFrame(byte[] data, int sampleRate, int channelPerFrame, int bitPerSample);
	void reset();
}
