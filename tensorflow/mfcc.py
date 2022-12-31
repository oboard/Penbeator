import tensorflow as tf
import matplotlib.pyplot as plt
import librosa
audio_binary = tf.io.read_file("data/1/1_20221227-200636.wav")
audio, rate = tf.audio.decode_wav(contents=audio_binary)
mfccs = librosa.feature.mfcc(audio, rate)
plt.plot(mfccs)
plt.show()
# waveform = tf.squeeze(audio, axis=-1)
# input_len = 16000
# waveform = waveform[:input_len]
# zero_padding = tf.zeros([16000] - tf.shape(waveform), dtype=tf.float32)
# waveform = tf.cast(waveform, dtype=tf.float32)
# equal_length = tf.concat([waveform, zero_padding], 0)
# spectrogram = tf.signal.stft(equal_length, frame_length=255, frame_step=128)
# spectrogram = tf.abs(spectrogram)
# spectrogram = spectrogram[..., tf.newaxis]
