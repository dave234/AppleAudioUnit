//
//  EventSlicedAudioUnit.h
//  AppleAudioUnit
//
//  Created by David O'Neill on 12/16/18.
//

#import "BufferedAudioUnit.h"

typedef void(^ProcessSliceBlock)(AudioBufferList        * _Nullable inBuffer,
                                 AudioBufferList        * _Nonnull  outBuffer,
                                 const AudioTimeStamp   * _Nonnull  timestamp,
                                 AVAudioFrameCount                  timeStampOffset,
                                 AVAudioFrameCount                  frameCount);

typedef void(^ProcessMidiEventBlock)(const AudioTimeStamp   * _Nonnull  timestamp,
                                     AVAudioFrameCount                  timeStampOffset,
                                     AUMIDIEvent            * _Nonnull  event,
                                     BOOL                               isSysEx);

typedef void(^ProcessParameterEventBlock)(const AudioTimeStamp   * _Nonnull timestamp,
                                          AVAudioFrameCount                 timeStampOffset,
                                          AUParameterEvent       * _Nonnull event,
                                          BOOL                              isRamped);

@interface EventSlicedAudioUnit : BufferedAudioUnit

// Overrides for subclasses.
- (ProcessSliceBlock _Nullable)processSliceBlock;
- (ProcessMidiEventBlock _Nullable)processMidiEventBlock;
- (ProcessParameterEventBlock _Nullable)processParameterEventBlock;

@end
