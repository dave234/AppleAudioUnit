//
//  ParameterizedAudioUnit.m
//  AppleAudioUnit
//
//  Created by David O'Neill on 12/16/18.
//

#import "ParameterizedAudioUnit.h"
#import <pthread.h>

static const float kDefaultRampDurationSeconds = 0.03;
static const int kDefaultRampSliceSize = 16;

typedef struct ParameterUIState {
    CWIFT_BOOL  uiSetValue;
    float       uiValue;
    float       uiRampDuration;
} ParameterUIState;

@implementation ParameterizedAudioUnit {
    int _parameterCount;
    pthread_mutex_t _renderMutex;
    ParameterUIState *_parameterUIStates;
    float _renderSampleRate;
    AAUParameterState *_parameterStates;
}

@synthesize parameterTree = _parameterTree;

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    _rampingSliceSize = kDefaultRampSliceSize;
    _isImplicitRampingEnabled = true;
    _parameterTree = self.parameterTree; // Maintain super's intended override mechanism.
    if (self && _parameterTree && [self valideateParameters:outError]) {
        [self createParameterStates];
    }
    return self;
}

- (void)setParameterTree:(AUParameterTree *)parameterTree {
    [self destroyParameterStates];
    _parameterTree = parameterTree;
    [self createParameterStates];
}

- (AUParameterTree *)parameterTree {
    return _parameterTree;
}

- (void)createParameterStates {
    [self destroyParameterStates];

    if (_parameterTree == NULL) {
        return;
    }
    
    _parameterCount = (int)_parameterTree.allParameters.count;
    if (_parameterCount <= 0) {
        return;
    }

    pthread_mutex_init(&_renderMutex, NULL);
    _parameterStates = malloc(sizeof(AAUParameterState) * _parameterCount);
    _parameterUIStates = malloc(sizeof(ParameterUIState) * _parameterCount);

    for (int i = 0; i < _parameterCount; i++) {
        AUParameter *parameter = [_parameterTree parameterWithAddress:i];
        _parameterUIStates[i].uiSetValue = 0;
        _parameterUIStates[i].uiValue = 0;
        _parameterUIStates[i].uiRampDuration = kDefaultRampDurationSeconds;
        AAUParameterStateSetValue(&_parameterStates[i], parameter.value);
    }

    __unsafe_unretained ParameterizedAudioUnit *welf = self;
    _parameterTree.implementorValueObserver = ^(AUParameter * _Nonnull param, AUValue value) {
        pthread_mutex_lock(&welf->_renderMutex);
        welf->_parameterUIStates[param.address].uiSetValue = true;
        welf->_parameterUIStates[param.address].uiValue = value;
        pthread_mutex_unlock(&welf->_renderMutex);
    };

    _parameterTree.implementorValueProvider = ^AUValue(AUParameter * _Nonnull param) {
        return AAUParameterStateGetValue(&welf->_parameterStates[param.address]);
    };

}

-(void) destroyParameterStates {
    if (_parameterStates != NULL)
        free(_parameterStates);

    if (_parameterUIStates != NULL)
        free(_parameterUIStates);

    _parameterStates = NULL;
    _parameterUIStates = NULL;
}

-(void)dealloc {
    pthread_mutex_destroy(&_renderMutex);
    [self destroyParameterStates];
}

- (void)setRampDuration:(float)seconds parameterAddress:(AUParameterAddress)address {
    NSAssert(address >= 0 || address < _parameterCount, @"Invalid parameter address");
    ParameterUIState *state = &_parameterUIStates[address];
    state->uiRampDuration = seconds;
}

- (BOOL)valideateParameters:(NSError **)outError {
    NSArray <AUParameter *> *parameters = [_parameterTree.allParameters sortedArrayUsingSelector:@selector(address)];
    if (parameters.count > 0 && (parameters.firstObject.address != 0 || parameters.lastObject.address != parameters.count - 1)) {

        NSString *message = @"ParameterizedAudioUnit requires parameter addresses \
        to be a sequence starting at 0 and incremeting by 1, example: [0, 1, 2, 3, 4]";
        if (outError) {
            *outError = [NSError errorWithDomain:@"AppleAudioUnit" code:0 userInfo:@{NSLocalizedDescriptionKey: message}];
        } else {
            NSLog(@"%@", message);
        }
        return false;
    }
    return true;
}

-(BOOL)allocateRenderResourcesAndReturnError:(NSError * _Nullable __autoreleasing *)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return false;
    }
    _renderSampleRate = self.outputBusses[0].format.sampleRate;
    return true;
}

static void preRenderParameterUpdate(__unsafe_unretained ParameterizedAudioUnit *welf) {
    if (welf->_parameterCount < 1 || pthread_mutex_trylock(&welf->_renderMutex) != 0) {
        return;
    }
    for (int i = 0; i < welf->_parameterCount; i++) {
        ParameterUIState *uiState = &welf->_parameterUIStates[i];
        AAUParameterState *renderState = &welf->_parameterStates[i];
        if (!uiState->uiSetValue)
            continue;

        if (uiState->uiRampDuration != 0) {
            AAUParameterStateSetRamp(renderState,
                                    renderState->value,
                                    uiState->uiValue,
                                    uiState->uiRampDuration * welf->_renderSampleRate);
        } else {
            AAUParameterStateSetValue(renderState, uiState->uiValue);
        }
        uiState->uiSetValue = false;
    }
    pthread_mutex_unlock(&welf->_renderMutex);
}

- (ProcessEventsBlock)processEventsBlock:(AVAudioFormat *)format {

    ProcessEventsBlock superProcessEvents = [super processEventsBlock:format];
    __unsafe_unretained ParameterizedAudioUnit *welf = self;
    return ^(AudioBufferList        *inBuffer,
             AudioBufferList        *outBuffer,
             const AudioTimeStamp   *timestamp,
             AVAudioFrameCount       frameCount,
             const AURenderEvent    *eventsListHead) {

        preRenderParameterUpdate(welf);
        superProcessEvents(inBuffer, outBuffer, timestamp, frameCount, eventsListHead);
    };
}

//-(AAUParameterState *)parameterStates {
//    return _parameterStates;
//}

-(ProcessParameterEventBlock)processParameterEventBlock {

    __unsafe_unretained ParameterizedAudioUnit *welf = self;
    BOOL isImplicitRampingEnabled = self.isImplicitRampingEnabled;

    return ^(const AudioTimeStamp   * _Nonnull timestamp,
             AVAudioFrameCount                 timeStampOffset,
             AUParameterEvent       * _Nonnull event,
             BOOL                              isRamped) {

        AAUParameterState *parameterState = &welf->_parameterStates[event->parameterAddress];
        if (isImplicitRampingEnabled && isRamped) {
            AAUParameterStateSetRamp(parameterState, parameterState->value, event->value, event->rampDurationSampleFrames);
        } else {
            AAUParameterStateSetValue(parameterState, event->value);
        }
    };
}

-(ProcessSliceBlock) processSliceBlock {
    ProcessAudioBlock processAudioBlock = self.processAudioBlock;
    if (!processAudioBlock) {
        return NULL;
    }
    __unsafe_unretained ParameterizedAudioUnit *welf = self;
    int parameterCount = (int)_parameterTree.allParameters.count;
    BOOL hasInput = self.shouldAllocateInputBus;
    return ^(AudioBufferList        * _Nullable inBuffer,
             AudioBufferList        * _Nonnull  outBuffer,
             const AudioTimeStamp   * _Nonnull  timestamp,
             AVAudioFrameCount                  timeStampOffset,
             AVAudioFrameCount                  frameCount) {

        int channelCount = outBuffer->mNumberBuffers;
        float parameters[MAX(parameterCount, 1)];

        // Copy parameter values to parameter buffer. Check if ramping.
        BOOL isRamping = false;
        for (int i = 0; i < parameterCount; i++) {
            parameters[i] = welf->_parameterStates[i].value;
            isRamping = isRamping || AAUParameterStateIsRamping(&welf->_parameterStates[i]);
        }

        // Map bufferlist to channel buffers.
        float *inChannels[channelCount];
        float *outChannels[channelCount];
        for (int i = 0; i < channelCount; i++) {
            if (hasInput) {
                inChannels[i] = inBuffer->mBuffers[i].mData;
            }
            outChannels[i] = outBuffer->mBuffers[i].mData;
        }

        if (isRamping == false) {
            // Process buffers in one slice
            processAudioBlock(hasInput ? inChannels : NULL, outChannels, channelCount, timestamp, timeStampOffset, frameCount, parameters);
        } else {

            // Process audio block in <= parameterRampSliceSized chunks.
            int sliceSize = welf->_rampingSliceSize;
            int i = 0;

            while (i < frameCount) {

                sliceSize = MIN(sliceSize, frameCount - i);
                processAudioBlock(hasInput ? inChannels : NULL, outChannels, channelCount, timestamp, timeStampOffset + i, sliceSize, parameters);

                // Advance parameter states.
                for (int p = 0; p < parameterCount; p++) {
                    parameters[p] = AAUParameterStateAdvance(&welf->_parameterStates[p], sliceSize);
                }

                // Advance channel buffer pointers.
                for (int c = 0; c < channelCount; c++) {
                    if (hasInput) {
                        inChannels[c] += sliceSize;
                    }
                    outChannels[c] += sliceSize;
                }

                i += sliceSize;
            }
        }
    };
}

- (ProcessAudioBlock)processAudioBlock {
    return NULL;
}

-(AUParameter *)parameterWithAddress:(AUParameterAddress)address {
    if (_parameterTree == NULL)
        return NULL;

    return [_parameterTree parameterWithAddress:address];
}

@end
