package com.example.acousticlocalization;

import android.media.AudioFormat;
import android.media.AudioRecord;


import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

class Global {
    static final int SamplingRate = 40960;
    static final int Channel = AudioFormat.CHANNEL_IN_MONO;
    static final int Encoding = AudioFormat.ENCODING_PCM_16BIT;
    static final int BufferSize = AudioRecord.getMinBufferSize(SamplingRate, Channel, Encoding);

    static final int SignalLength = 1024;
    static final int BaseFrequency = 400;
    static final int OffsetFrequency = 10;
    static final int CarrierFrequency = 5000;
    static final int PSKLength = 2;
    static final int OFDMLength = 8;
    static final int CPLength = 32;
    static final int HeadChirpLength = 1024;
    static final int TailChirpLength = 512;
    static final int HeadChirpBeginFrequency = 200;
    static final int HeadChirpEndFrequency = 600;
    static final int TailChirpBeginFrequency = 600;
    static final int TailChirpEndFrequency = 1000;
    static final int SignalRealLength = CPLength + SignalLength;

    static final String RawFileName = "raw.wav";
    static final String RecordFileName = "received.wav";

    static void DecimalToBitArray(boolean[] data, int b, int value) {
        for (int i = b; i < b + PSKLength; i++) {
            data[i] = value % 2 == 1;
            value /= 2;
        }
    }

    private static double[] ByteArrayToDoubleArray(byte[] b) {
        double[] result = new double[b.length / 2];
        for (int i = 0; i < result.length; i++) {
            result[i] = ((short) b[2 * i + 1] << 8) | ((short) b[2 * i] & 0xff);
            result[i] /= Short.MAX_VALUE;
        }
        return result;
    }

    static String BitArrayToString(boolean[] value) {
        StringBuilder stringBuilder = new StringBuilder();
        for (int i = 8; i < value.length; i += 8) {
            int number = 0;
            for (int j = 7; j >= 0; j--) {
                number <<= 1;
                number += value[i + j] ? 1 : 0;
            }
            stringBuilder.append((char) number);
        }
        return stringBuilder.toString();
    }

    static double[] ReadWaveFile(String name) throws IOException {
        FileInputStream fileInputStream = new FileInputStream(name);
        byte[] chunk = new byte[4];
        for (int i = 0; i < 11; i++)
            fileInputStream.read(chunk);
        long size = 0;
        for (int i = 3; i >= 0; i--)
            size = (size << 8) | (chunk[i] & 0xff);
        byte[] content = new byte[(int) size];
        fileInputStream.read(content);
        return ByteArrayToDoubleArray(content);
    }

    static void WriteWaveFileHeader(FileOutputStream fileOutputStream, long audioLength,
                                    long dataLength, long sampleRate, int channels, long byteRate)
            throws IOException {
        byte[] header = new byte[44];
        header[0] = 'R';
        header[1] = 'I';
        header[2] = 'F';
        header[3] = 'F';
        header[4] = (byte) (dataLength & 0xff);
        header[5] = (byte) ((dataLength >> 8) & 0xff);
        header[6] = (byte) ((dataLength >> 16) & 0xff);
        header[7] = (byte) ((dataLength >> 24) & 0xff);
        header[8] = 'W';
        header[9] = 'A';
        header[10] = 'V';
        header[11] = 'E';
        header[12] = 'f';
        header[13] = 'm';
        header[14] = 't';
        header[15] = ' ';
        header[16] = 16;
        header[17] = 0;
        header[18] = 0;
        header[19] = 0;
        header[20] = 1;
        header[21] = 0;
        header[22] = (byte) channels;
        header[23] = 0;
        header[24] = (byte) (sampleRate & 0xff);
        header[25] = (byte) ((sampleRate >> 8) & 0xff);
        header[26] = (byte) ((sampleRate >> 16) & 0xff);
        header[27] = (byte) ((sampleRate >> 24) & 0xff);
        header[28] = (byte) (byteRate & 0xff);
        header[29] = (byte) ((byteRate >> 8) & 0xff);
        header[30] = (byte) ((byteRate >> 16) & 0xff);
        header[31] = (byte) ((byteRate >> 24) & 0xff);
        header[32] = (byte) (2 * 16 / 8);
        header[33] = 0;
        header[34] = 16;
        header[35] = 0;
        header[36] = 'd';
        header[37] = 'a';
        header[38] = 't';
        header[39] = 'a';
        header[40] = (byte) (audioLength & 0xff);
        header[41] = (byte) ((audioLength >> 8) & 0xff);
        header[42] = (byte) ((audioLength >> 16) & 0xff);
        header[43] = (byte) ((audioLength >> 24) & 0xff);
        fileOutputStream.write(header, 0, 44);
    }
}