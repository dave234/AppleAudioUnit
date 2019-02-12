//
//  AppleAudioUnit.h
//  AppleAudioUnit
//
//  Created by David O'Neill on 2/10/19.
//

#import "AppleAudioUnit.h"


@implementation AppleAudioUnit {
    AAUDspRenderCallback    _renderCallback;
    AAUDspMidiCallback      _midiCallback;
    AAUDspAllocateCallback  _allocateCallback;
    AAUDspReleaseCallback   _releaseCallback;
}

- (void)setRenderer:(AAUDsp _Nonnull)dsp
     renderCallback:(AAUDspRenderCallback _Nonnull)renderCallback
       midiCallback:(AAUDspMidiCallback)midiCallback
   allocateCallback:(AAUDspAllocateCallback _Nullable)allocateCallback
    releaseCallback:(AAUDspReleaseCallback _Nullable)releaseCallback {

    _dsp = dsp;
    _renderCallback = renderCallback;
    _allocateCallback = allocateCallback;
    _releaseCallback = releaseCallback;
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError * _Nullable __autoreleasing *)outError {
    if (![self allocateRenderResourcesAndReturnError:outError]) {
        return false;
    }
    if (_dsp && _allocateCallback) {
        AVAudioFormat *format = self.outputBusses[0].format;
        _allocateCallback(_dsp, format.sampleRate, format.channelCount, self.maximumFramesToRender);
    }
    return true;
}

- (void)deallocateRenderResources {
    if (_dsp && _releaseCallback) {
        _releaseCallback(_dsp);
    }
    [super deallocateRenderResources];
}

- (ProcessMidiEventBlock)processMidiEventBlock {
    AAUDspMidiCallback midiCallback = _midiCallback;
    AAUDsp dsp = _dsp;
    if (dsp == NULL || midiCallback == NULL) {
        return super.processMidiEventBlock;
    }

    return ^(const AudioTimeStamp   *timestamp,
             AVAudioFrameCount      timeStampOffset,
             AUMIDIEvent            *event,
             BOOL                   isSysEx) {

        midiCallback(dsp, event->data, event->length, isSysEx);
    };
}

- (ProcessAudioBlock)processAudioBlock {
    AAUDsp dsp = _dsp;
    AAUDspRenderCallback renderCallback = _renderCallback;
    if (dsp == NULL || renderCallback == NULL) {
        return super.processAudioBlock;
    }

    return ^(float                  **inChannels,
             float                  **outChannels,
             int                    channelCount,
             const AudioTimeStamp   *timestamp,
             int                    timeStampOffset,
             int                    frameCount,
             float                  *parameters) {

        renderCallback(dsp, inChannels, outChannels, channelCount, frameCount, parameters);
    };
}
@end
