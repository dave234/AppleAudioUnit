//
//  AudioBufferListHelper.h
//  AppleAudioUnit
//
//  Created by David O'Neill on 12/16/18.
//

#ifndef AudioBufferListHelper_h
#define AudioBufferListHelper_h

#include <stdio.h>
#include <AudioToolBox/AudioToolBox.h>

void    bufferListPrepare(AudioBufferList *audioBufferList, int channelCount, int frameCount);
void    bufferListClear(AudioBufferList *audioBufferList);
size_t  bufferListByteSize(int channelCount);
Boolean bufferListHasNullData(AudioBufferList *bufferList);
void    bufferListPointChannelDataToBuffer(AudioBufferList *bufferList, float *buffer);

// This will prepare slice and point it's buffers to bufferlist's buffers + offset. Used for partial rendering of bufferList.
AudioBufferList *bufferListPrepareSlice(AudioBufferList *bufferList, AudioBufferList *slice, int offset, int frameCount);
#endif /* AudioBufferListHelper_h */
