# Tracking Differentiator building & testing packages

A development package for differential trackers, containing building and testing scripts. Specific features introductions are:

+ Custom Tracking Differentiator Builder.
+ automated testing tools in Simulink.
+ Simple and flexible workflow from building to simulation.

[Chinese version]()

## Quick start

1. Step One: *Prerequisites*

Clone this repository:

```cmd
git clone PACRian/simModels
```

Add the required directories to the working path in the main folder.

```cmd
addFolders
```

Then you will find that `simtools`, `buildtools` and `utiltis`  are added to the searching path list with their subdirectories. Otherwise, please add the above directory manually. Also, don't forget to start a Simulink context first.

2. Step Two: *Building*

Build a tracking differentiator using `buildTrackingDifferentiator`, specify the module name and custom non-linear function name. Here's an example showing how to create an ASinh-TD, custom core function supported(See another example [here]()):

```matlab
arshTdName = 'arshTd';
buildTrackingDifferentiator('sysName', arshTdName, 'funcName', 'arsh');
```

3. Step Three: *Test & Simulation*

Suppose we want to estimate the frequency characteristics(respect to the tracking signal) of that ASinh-TD built from last step. Use option `setSweepSuite`  in the test-suite and then open the [Frenquency Response Analyzer](https://www.mathworks.com/matlabcentral/fileexchange/85448-frequency-response-analyzer) tool to do a frenquency sweep(Learn more about how to use the testing tool [here](https://www.arrayofengineers.com/post/measuring-the-bandwidth-a-beginner-s-guide-to-frequency-analysis-for-your-simulink-model)).

```matlab
setTestSuite('setSweepSuite', 'moduleName', arshTdName);
```

<img src="https://pico-bucket-test-1258276012.cos.ap-beijing.myqcloud.com/img/sweepSimexp.png" style="zoom: 60%;" />

<div style="text-align: center; font-family:"Times New Roman", Times, serif;"> Model diagram and its frenquency sweep test </div>

It is expected, as the [paper](https://www.cnki.com.cn/Article/CJFDTotal-KZYC201406029.htm) has given that curve, the full demonstration code can be checked [here]().

If you just want to see the response at a few single frequencies, select `setSineSuite` in the test-suite, then do auto-simulaiton by calling `multiModelSim`, below is the timing diagram and inner phase flow at At test sine-wave frequency 1Hz and 2Hz. For sample code see [here](), and look at the the [example directory]() for more knowledge. 

```matlab
setTestSuite('setSineSuite', 'moduleName', arshTdName);            
% Config test - suite
fList = [1 2];
sims = multiModelSim('arshTd', '/sineIn', {'Frequency'}, 2*pi*fList);
sims = getsimLogs(sims);
% Do simulation

% Plotting below(Omitted)
```

<img src="https://pico-bucket-test-1258276012.cos.ap-beijing.myqcloud.com/img/td_x1x2phaseflow.svg" style="zoom:90%;" />

<div style="text-align: center; font-family:"Times New Roman", Times, serif;"> Timing diagram & Phase flow of unit sinusoidal response at specific frequency </div>

For detailed usage about building and testing utilties, read the instructions for the next section.



## Detailed usage description

### `buildTrackingDifferentiator`

To build a custom Tracking Differentiator Simulink model, use function  `buildTrackingDifferentiator`, syntax below:

```matlab
moduleNames = buildTrackingDifferentiator(Name, Value)
```

Its function is to build a custom TD block in the current folder, and return the specified module name. The full process and properties can be adjusted by one or more `Name, Value` pairs. Below is some important arguments:

**Input Arguments**

+ `sysName`| [Default `'TrackingDifferentiator'`]: The Simulink model name, for example if we want to build a TD model named `testTd`,  use `buildTrackingDifferentiator('sysName', 'testTd')`. If no error poped, a `testTd.slx` file would be created in the current folder.

+ `funcName`| [Default `'sigmoid'`]:   The name of the core non-linear function to be set in the Td module, two ways can be implemented here: 1. use preset functions like `sigmoid`, `atan`(Check available preset function [here](https://github.com/PACRian/simModels/blob/main/buildtools/buildTdFuncs.m#L77)), examples like: `buildTrackingDifferentiator('funcName', 'sigmoid')`; 2. define a custom functions with `.m` extension, make sure it sits in the searching path. Then pass its function name as the `funcName` value.

  *Notes*: The form of the custom core function must be written as:

  ```matlab
  function y=customCoreTDFunc(x, a, b)
  % y = ...
  ```

  where `a, b` are the parameters controlling the strech scale, and `x, y`  are the function input and output. If If the number of control parameters is less than two, leave the unused one as `~`. 

+ `wksSigName` | [Default `'SigIn'`]: The "From Workspace" block name, it can further take variable in the main base as the input signal of this tracking differentiator.

+ `trackSigName` | [Default `'TrackSig'`]: The tracking signal name, will be used as the signal name for future logging.

+ `diffSigName` | [Default `'DiffSig'`]: The differential-tracking signal name, simillar to above parameter.

+ `returnType` | [Default `'all'`]: Take value in `'all', 'td', 'towk'`, the name of the module to which these declarations are exported.

**Returns**

List of module names in the build context, relates to `returnType`. For example, if a `testTd` model is built(Using `sigmoid` function, default mode). Results of three options are like below:

+ If `'returnType'` is set to `'all'`, returns are `{'testTd/sigmoid_TrackingDifferentiator', 'testTd/SigIn', 'testTd/TrackSig', 'testTd/DiffSig'}`;
+ If `'returnType'` is set to `'td'`, returns are `{'testTd/sigmoid_TrackingDifferentiator'}`;
+ If `'returnType'` is set to `'towk'`, returns are `{'testTd/TrackSig', 'testTd/DiffSig'}`.

The above is not a complete list of all parameters, read the comments [here] for more detailed knowledge.

### `setTestSuite`

On the basis of the built model,  make further modifications according to the test requirements, syntax below:

```matlab
setTestSuite(testsuite, Name, Value)
```

Detailed  `Name, Value` pairs need to be set up according to the specific `testsuite`, below is some common usage:

1. `setTestSuite('setSweepSuite', Name, Value)`

   Configure the TD model accordingly for frequency sweep testing.

2. `setTestSuite('setSineSuite', Name, Value)`

   Configure the model environment for sinusoidal response experiment.

[TODO]

## Main idea

[TODO]

## Changelog

Commit 

1. Add `save_sytem` process when test suite is finished, in `setTestSuite`.
2. Add "DOUBLE BUILD" to supress "Empty struct" error when build a TD block, in `buildTrackingDifferentiator`

