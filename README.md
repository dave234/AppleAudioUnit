# AppleAudioUnit

This is very much a WIP, but here's how it works at the moment. 

Implementing an AUAudioUnit requires some boilerplate and some domain specific knowledge. These classes take an opinionated approach to aiding in the implementation of the essential and the most common use cases. Here are the classes in order of Parent -> Child.


### [BufferedAudioUnit][0]
To ensure that there are buffers to render to, BufferedAudioUnit manages this. It works by allocating memory and implementing internalRenderBlock where it pulls the input block, then calls it's own processEventsBlock where there is a single input (if effect) and output buffer to read from and write to. ProcessEventsBlock is intended to be implemented by subclasses. 

### [EventSlicedAudioUnit][1]
In order to achieve sample accuracy with regard to MIDI and parameter events, a partial rendering strategy is used. EventSlicedAudioUnit implements processEventsBlock, where it parses each event, calling either processMidiEventBlock or processParameterEventBlock for each simultaneous event, then calling processSliceBlock for a sample count that leads to the either the next group of simultaneous events, or render-end.

### [ParameterizedAudioUnit][2]
This very opinionated class facilitates the backing memory, ramping, and threading considerations necessary to implement audio unit parameters. It does so by inspecting the (subclasses) `parameterTree` property, then allocating an array of data structures that are used for managing each parameter's value and ramping state. It implements all three of EventSlicedAudioUnit's blocks, and calls it's own processAudioBlock which has a much simpler function signature. ProcessAudioBlock is sliced even further for parameter ramping and is intended to be implemented by subclasses, accessing only the parameter value without need to manually ramp and slice. This is perhaps the most opinionated bit, all parameters returned by a subclasses `parameterTree` property must use ParameterAddresses starting at 0 and incrementing to (parameter count - 1). Then, within the processAudioBlock, parameters are retrieved from a float* by subscripting with the address.

### [AppleAudioUnit][3]
This class isn't yet working, so probably shouldn't be in here, but the idea is that it is a C interface to all of the functionality described above. It will work by passing around pointers to a dsp object, and calling function pointer callbacks with that dsp object. The ultimate goal of this class is to fully separate the Apple platform code from the DSP code in order to promote cross platform dsp implementations and integrations.

During the POC of AppleAudioUnit I'm slowly coming to the conclusion that it may be too opinionated for some, but I feel that it will handily suit the 80% use case, so I will continue to develop this when I find time.

[0]:https://github.com/dave234/AppleAudioUnit/blob/master/AppleAudioUnit/Classes/BufferedAudioUnit.h
[1]:https://github.com/dave234/AppleAudioUnit/blob/master/AppleAudioUnit/Classes/EventSlicedAudioUnit.h
[2]:https://github.com/dave234/AppleAudioUnit/blob/master/AppleAudioUnit/Classes/ParameterizedAudioUnit.h
[3]:https://github.com/dave234/AppleAudioUnit/blob/master/AppleAudioUnit/Classes/AppleAudioUnit.h
