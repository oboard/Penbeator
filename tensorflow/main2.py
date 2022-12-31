import tensorflow as tf
import numpy as np
import librosa
import os

# 假设 data_dir 是数据文件夹的路径
data_dir = 'data'

# 初始化 audio_data 变量
audio_data = []
labels = []

# 设置时间序列长度
sequence_length = 2048  # 例如

# 遍历文件夹中的所有文件
for label in [1, 2, 3, 4]:
    data_dir = f"data/{label}"
    for file_name in os.listdir(data_dir):
        # 只处理 WAV 文件
        if file_name.endswith('.wav'):
            # 加载 WAV 文件
            file_path = os.path.join(data_dir, file_name)
            audio, sample_rate = librosa.load(file_path)
            audio = librosa.util.fix_length(audio, sequence_length)
            # 将 audio 添加到 audio_data 中
            # 将 audio 转换为单精度浮点数并添加到 audio_data 列表中
            audio_data.append(audio.astype(np.float32))
            # audio_data.append(audio)
            labels.append(label)

# 将 audio_data 转换为 NumPy 数组
audio_data = np.array(audio_data)
# 将 audio_data 转换为四维的 NumPy 数组，形状为 (batch_size, height, width, channels)
print(audio_data.shape)
# 假设 audio_data 是一个 (num_samples, num_timesteps) 的 NumPy 数组
num_samples, num_timesteps = audio_data.shape

# 将 audio_data 转换为二维的图像
images = []
for audio in audio_data:
    # 使用 librosa 将 audio 转换为二维的 STFT 矩阵
    stft = librosa.stft(audio, n_fft=sequence_length)

    # 将 STFT 矩阵转换为二维的图像
    image = np.abs(stft)

    # 将图像添加到 images 列表中
    images.append(image)

# 将 images 转换为四维的 NumPy 数组，形状为 (batch_size, height, width, channels)
audio_data = np.array(images, dtype=np.float32)

labels = np.array(labels, dtype=int)
# 假设 num_samples 是样本的数量
num_samples = len(audio_data)

# # 初始化 labels 变量
# labels = np.zeros(num_samples, dtype=int)

# # 假设 Bass Drum 对应标签 0，Tom Drum 对应标签 1，Crash Cymbal 对应标签 2
# # 假设前 num_bass_drum 个样本是 Bass Drum，接下来的 num_tom_drum 个样本是 Tom Drum，剩下的是 Crash Cymbal
# num_bass_drum = 30
# num_tom_drum = 29
# num_cat_drum = 19

# # 为 Bass Drum 标记标签
# labels[:num_bass_drum] = 1

# # 为 Tom Drum 标记标签
# labels[num_bass_drum:num_bass_drum+num_tom_drum] = 2

# # 为 Crash Cymbal 标记标签
# labels[num_bass_drum+num_tom_drum:num_cat_drum] = 3
# labels[num_bass_drum+num_tom_drum+num_cat_drum:] = 4


# 创建模型
model = tf.keras.Sequential()
model.add(tf.keras.layers.Conv2D(
    32, (3, 3), activation='relu', input_shape=(32, 1025, 5)))
model.add(tf.keras.layers.MaxPooling2D((2, 2)))
model.add(tf.keras.layers.Conv2D(64, (3, 3), activation='relu'))
model.add(tf.keras.layers.MaxPooling2D((2, 2)))
model.add(tf.keras.layers.Conv2D(64, (3, 3), activation='relu'))
model.add(tf.keras.layers.Flatten())
model.add(tf.keras.layers.Dense(64, activation='relu'))
model.add(tf.keras.layers.Dense(3, activation='softmax'))

# 编译模型
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# 训练模型
# audio_data.reshape(0, 32, 1025, 5)
model.fit(audio_data, labels, epochs=10)
model.summary()
