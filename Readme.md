！ Readme



# Quickstart

Three steps to build and test a custom Tracking Differentiator.

Step One:

Clone this repository and make sure all dependencies are met.

```clike
git clone 
```

Open a Matlab CLI and excute the script below:

```matlab
addFolders
```

Step Two:

Implement a simple non-linear function as the core function in the TD module, then build it. In the test below, we use a preset `atan`.

```matlab
sysName = 'atanTd';
buildTdModule(sysName, )
```

If you get some error like:

```matlab
Error buildTdFuncs:
There is no block named 'VoidTrackerDerivates/VoidTrackerDerivates'
```

Check whether all scripts and libraries are added into the searching path.

Step Three:

Excute the script `genSweep` to finish a quick frenquency-sweep test

```
genSweep; % 

```



# Main Idea

