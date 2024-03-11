<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project is a PAL (programmable array logic device). It is programmed with a shift register.

### Pin assignment

### Programming
At every rising edge of the programming-clock the shift register takes in a value from the config_bit pin.
When the configuration is done the PAL implements the programmed combinatorial function(s). 
However in order to get the programmed function(s) to generate outputs the enable pin has to be asserted.

### Generate bitstreams
To generate bitstreams for the shift register a Python script is provided in this repository.
It is important to set the right 

## How to test

By irst shifting in a bitstream configuration into the device the AND/OR matrix of the device can be programmed to implement boolean functions with a set of inputs and outputs.

## External hardware

No external HW is needed. However to see your glorious boolean functions come to life you might want to connect some switches to the inputs and LEDs to the outputs. 
