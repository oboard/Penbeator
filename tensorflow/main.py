
# import matplotlib.pyplot as plt
# audio_binary = tf.io.read_file("samples/1/1.wav")
# audio, rate = tf.audio.decode_wav(contents=audio_binary)
# # plt.plot(audio)
# # plt.show()
# waveform = tf.squeeze(audio, axis=-1)
# input_len = 16000
# waveform = waveform[:input_len]
# zero_padding = tf.zeros([16000] - tf.shape(waveform),dtype=tf.float32)
# waveform = tf.cast(waveform, dtype=tf.float32)
# equal_length = tf.concat([waveform, zero_padding], 0)
# spectrogram = tf.signal.stft(equal_length, frame_length=255, frame_step=128)
# spectrogram = tf.abs(spectrogram)
# spectrogram = spectrogram[..., tf.newaxis]
import tensorflow as tf
import numpy as np
import librosa
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'


def load_data():
    x_train = []
    y_train = []
    x_test = []
    y_test = []

    # 加载训练数据
    for label in [1, 2, 3, 4]:
        for file in os.listdir(f"data/{label}"):
            if file.startswith("."):
                continue
            audio_data_path = f"data/{label}/{file}"
            audio, _ = librosa.load(f"data/{label}/{file}")
            # audio_data, sample_rate = librosa.load(audio_data_path)
            # mfccs = librosa.feature.mfcc(audio_data, sample_rate)
            # print(mfccs)
            x_train.append(audio)
            y_train.append(label)

    # 加载测试数据
    for label in [1, 2]:
        for file in os.listdir(f"test/{label}"):
            if file.startswith("."):
                continue
            # audio, _ = librosa.load(f"test/{label}/{file}")
            audio_data_path = f"test/{label}/{file}"
            audio_data, sample_rate = librosa.load(audio_data_path)
            mfccs = librosa.feature.mfcc(audio_data, sample_rate)
            x_test.append(mfccs)
            y_test.append(label)
    # 将 audio_data 转换为 NumPy 数组
    x_train = np.array(x_train)
    y_train = np.array(y_train, dtype=int)
    x_test = np.array(x_test)
    y_test = np.array(y_test, dtype=int)
    return (x_train, y_train), (x_test, y_test)


# 载入训练数据
(x_train, y_train), (x_test, y_test) = load_data()

# 定义模型
model = tf.keras.Sequential()
model.add(tf.keras.layers.Conv2D(
    32, (3, 3), activation='relu', input_shape=(28, 28, 1)))
model.add(tf.keras.layers.MaxPooling2D((2, 2)))
model.add(tf.keras.layers.Flatten())
model.add(tf.keras.layers.Dense(64, activation='relu'))
model.add(tf.keras.layers.Dense(10, activation='softmax'))

# 编译模型
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# 训练模型
model.fit(x_train, y_train, epochs=5)

# 评估模型
model.evaluate(x_test, y_test)

# 使用模型预测
predictions = model.predict(x_test)
print(predictions)
