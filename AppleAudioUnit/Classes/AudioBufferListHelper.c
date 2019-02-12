//
//  AudioBufferListHelper.c
//  AppleAudioUnit
//
//  Created by David O'Neill on 12/16/18.
//

#include "AudioBufferListHelper.h"

// Private AudioBufferList helpers.
void bufferListPrepare(AudioBufferList *audioBufferList,
                              int             channelCount,
                              int             frameCount) {

    audioBufferList->mNumberBuffers = channelCount;
    for (int channelIndex = 0; channelIndex < channelCount; channelIndex++) {
        audioBufferList->mBuffers[channelIndex].mNumberChannels = 1;
        audioBufferList->mBuffers[channelIndex].mDataByteSize = frameCount * sizeof(float);
    }
}

void bufferListClear(AudioBufferList *audioBufferList) {
    for (int i = 0; i < audioBufferList->mNumberBuffers; i++) {
        memset(audioBufferList->mBuffers[i].mData, 0, audioBufferList->mBuffers[i].mDataByteSize);
    }
}

size_t bufferListByteSize(int channelCount) {
    return sizeof(AudioBufferList) + (sizeof(AudioBuffer) * (channelCount - 1));
}

Boolean bufferListHasNullData(AudioBufferList *bufferList) {
    return bufferList->mBuffers[0].mData == NULL;
}

void bufferListPointChannelDataToBuffer(AudioBufferList *bufferList, float *buffer) {
    int frameCount = bufferList->mBuffers[0].mDataByteSize / sizeof(float);
    for (int channelIndex = 0; channelIndex < bufferList->mNumberBuffers; channelIndex++) {
        int offset = channelIndex * frameCount;
        bufferList->mBuffers[channelIndex].mData = buffer + offset;
    }
}

AudioBufferList *bufferListPrepareSlice(AudioBufferList *bufferList, AudioBufferList *slice, int offset, int frameCount) {
    bufferListPrepare(slice, bufferList->mNumberBuffers, frameCount);
    for (int channelIndex = 0; channelIndex < bufferList->mNumberBuffers; channelIndex++) {
        slice->mBuffers[channelIndex].mData = ((float*)bufferList->mBuffers[channelIndex].mData) + offset;
    }
    return slice;
}
