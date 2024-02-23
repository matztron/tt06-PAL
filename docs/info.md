<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project is a PAL (programmable array logic device). It is programmed with a shift register.
At every posedge of the clock the shift register takes in a value from the config_bit pin.
When the configuration is done the PAL implements the programmed combinatorial function. 
In the repo I also included an (if I forgot to include it check my github profile for the easy_PAL repo) python script to generate bitstreams that are put in the shift register

## How to test

By irst shifting in a bitstream configuration into the device the AND/OR matrix of the device can be programmed to implement boolean functions with a set of inputs and outputs.

## External hardware

No external HW is needed. However to see your glorious boolean functions come to life you might want to connect some switches to the inputs and LEDs to the outputs. 
