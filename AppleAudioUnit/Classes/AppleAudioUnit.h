//
//  AppleAudioUnit.h
//  AppleAudioUnit
//
//  Created by David O'Neill on 2/10/19.
//

#import "AAUDsp.h"
#import "BufferedAudioUnit.h"
#import "ParameterizedAudioUnit.h"
#import "AudioComponentDescription-Cwift.h"
#import "EventSlicedAudioUnit.h"

@interface AppleAudioUnit : ParameterizedAudioUnit
@property (readonly) AAUDsp _Nullable dsp;
- (void)setRenderer:(AAUDsp _Nonnull)renderer
     renderCallback:(AAUDspRenderCallback _Nonnull)renderCallback
       midiCallback:(AAUDspMidiCallback _Nullable)midiCallback
   allocateCallback:(AAUDspAllocateCallback _Nullable)allocateCallback
    releaseCallback:(AAUDspReleaseCallback _Nullable)releaseCallback;
@end
