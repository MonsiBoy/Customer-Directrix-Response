# Customer Directrix Response Scripts

## Dataset Creator
Run `Data_Maker.m` first to create all desired datasets. A sample format and used datasets can be found in [Dataset Files](https://github.com/MonsiBoy/Customer-Directrix-Response/tree/main/Dataset%20Files). Before proceeding the scripts will be using the following name convention, it is imperative to follow this convention to ensure that no edits will be necessary to run the scripts:

16k-participants<case number><test><trial>.xlsx
(ex. 16k-participants1TL1)

The `Batch_Simulator.m` is designed to run n number of trials. The number of trials will be left to discretion of the user. 

With that, there are a few data that the user must prepare beforehand before running `Data_Maker.m`. Each case will have different data to prepare, to determine which data should be prepared please check [Dataset Files](https://github.com/MonsiBoy/Customer-Directrix-Response/tree/main/Dataset%20Files), before proceeding

### Example
To illustrate an example a 5 trial run for Case 1 will be discussed. Case 1 requires constant Load curves, Aggregated Load Curves, Coalitions, Discrete Responses, Customer Capacities, Customer Time Slots. 

Once these data are prepped prepare a template for this case and make 5 (1 for each trials) copies each file will have a unique name that follows the naming convetion. So for example the names for Skewed to the Left case  are:

- 16k-participants1TL1
- 16k-participants1TL2
- 16k-participants1TL3
- 16k-participants1TL4
- 16k-participants1TL5

Repeat this for all cases. Moreover Cases that asks for Descriptions please put the appropriate descriptor that will distinguish said case from others.

**Note:**
In all cases you only need to input the Trial # meaning you will no longer need to put in "16k-participants<case><case type>"

## Simulator

Once you have obtained the desired datasets ensure that `simulator.m` and the dataset files are within the same path. Choose the desired option as prompted by the script. 

The `simulator.m` has a version that runs all trials of a particular case called `batch_simulator.m`. Currently it is fixed to run on 16k participants, this can be easily changed by changing the `Participants` variable of said script.