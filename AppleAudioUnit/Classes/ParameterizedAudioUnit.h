//
//  ParameterizedAudioUnit.h
//  AppleAudioUnit
//
//  Created by David O'Neill on 12/16/18.
//

#import "AAUParameterState.h"
#import "EventSlicedAudioUnit.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct RenderParameter {
    float value;
    float isRamping;
    float isChanged;
} RenderParameter;

typedef void(^ProcessAudioBlock)(float                  * _Nullable * _Nonnull  inChannels,
                                 float                  * _Nonnull  * _Nonnull  outChannels,
                                 int                                            channelCount,
                                 const AudioTimeStamp   * _Nonnull              timestamp,
                                 int                                            timeStampOffset,
                                 int                                            frameCount,
                                 float                                          *parameters);

@interface ParameterizedAudioUnit : EventSlicedAudioUnit
@property int rampingSliceSize; // Defaults to 16.
@property BOOL isImplicitRampingEnabled; // Defaults to yes.
- (void)setParameterTree:(AUParameterTree *)parameterTree;
- (void)setRampDuration:(float)seconds parameterAddress:(AUParameterAddress)address;
- (AUParameter * _Nullable)parameterWithAddress:(AUParameterAddress)address;
- (ProcessAudioBlock)processAudioBlock;
@end

NS_ASSUME_NONNULL_END
