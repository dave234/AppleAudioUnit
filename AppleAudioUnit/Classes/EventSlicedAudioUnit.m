//
//  EventSlicedAudioUnit.m
//  AppleAudioUnit
//
//  Created by David O'Neill on 12/16/18.
//

#import "EventSlicedAudioUnit.h"
#import "AudioBufferListHelper.h"

static const int kMaxChannelCount = 16;

@implementation EventSlicedAudioUnit

-(ProcessEventsBlock)processEventsBlock:(AVAudioFormat *)format {

    ProcessSliceBlock processSliceBlock = self.processSliceBlock;
    ProcessMidiEventBlock processMidiEventBlock = self.processMidiEventBlock;
    ProcessParameterEventBlock processParameterEventBlock = self.processParameterEventBlock;
    BOOL hasInput = self.shouldAllocateInputBus;

    if (processSliceBlock == NULL && processMidiEventBlock == NULL && processParameterEventBlock == NULL) {
        return [super processEventsBlock:format];
    }



    // This calls subclasses processMidiEventBlock, processParameterEventBlock, then processSliceBlock.
    return ^(AudioBufferList        *inBuffer,
             AudioBufferList        *outBuffer,
             const AudioTimeStamp   *timestamp,
             AVAudioFrameCount       frameCount,
             const AURenderEvent    *eventsListHead) {

        // If no events, process in one slice.
        if (eventsListHead == NULL) {
            if (processSliceBlock != NULL) {
                processSliceBlock(inBuffer, outBuffer, timestamp, 0, frameCount);
            }
            return;
        }

        // Guard against stack overflow in variable stack allocation below.
        assert(outBuffer->mNumberBuffers <= kMaxChannelCount);

        // inSliceMem and outSliceMem are stack allocations for inBufferSlice and outBufferSlice.
        // We only need a local var for our slices, but AudioBufferList is a variable sized struct.
        char inSliceMem[bufferListByteSize(outBuffer->mNumberBuffers)];
        char outSliceMem[bufferListByteSize(outBuffer->mNumberBuffers)];

        AudioBufferList *inBufferSlice = hasInput ? (AudioBufferList *)inSliceMem : NULL;
        AudioBufferList *outBufferSlice = (AudioBufferList *)outSliceMem;

        // Iterate linked list of events, call Midi or Parameter block for each event, and render slices of audio in-bewteen non-simultaneous events.
        AURenderEvent *event = (AURenderEvent *)eventsListHead;
        while (event != NULL) {

            // Cast to header in order to get type and eventSampleTime.
            AURenderEventHeader *header = &event->head;
            AVAudioFrameCount timestampOffset = (AVAudioFrameCount)header->eventSampleTime - timestamp->mSampleTime;
            AURenderEventType type = header->eventType;

            switch (type) {
                case AURenderEventMIDI:
                case AURenderEventMIDISysEx:
                    if (processMidiEventBlock != NULL) {
                        processMidiEventBlock(timestamp, timestampOffset, &event->MIDI, type == AURenderEventMIDISysEx);
                    }
                    break;

                case AURenderEventParameter:
                case AURenderEventParameterRamp:
                    if (processParameterEventBlock != NULL) {
                        processParameterEventBlock(timestamp, timestampOffset, &event->parameter, type == AURenderEventParameterRamp);
                    }
                    break;
            }

            // If this is the last event or the next event has a different sample time render a slice.
            AURenderEventHeader *nextHeader = header->next ? &header->next->head : NULL;
            if (processSliceBlock != NULL && (!nextHeader || nextHeader->eventSampleTime != header->eventSampleTime)) {

                // Render to next event sample time or to end if no next event.
                AVAudioFramePosition sliceEnd = nextHeader == NULL ? timestamp->mSampleTime + frameCount : nextHeader->eventSampleTime;
                AVAudioFrameCount sliceFrameCount = (AVAudioFrameCount)(sliceEnd - header->eventSampleTime);

                if (hasInput)
                    bufferListPrepareSlice(inBuffer, (AudioBufferList *)inSliceMem, timestampOffset, sliceFrameCount);

                bufferListPrepareSlice(outBuffer, outBufferSlice, timestampOffset, sliceFrameCount);
                processSliceBlock(inBufferSlice, outBufferSlice, timestamp, timestampOffset, sliceFrameCount);
            }

            event = header->next;
        }

    };
}

- (ProcessSliceBlock)processSliceBlock {
    return NULL;
}

- (ProcessMidiEventBlock)processMidiEventBlock {
    return NULL;
}

- (ProcessParameterEventBlock)processParameterEventBlock {
    return NULL;
}

@end

