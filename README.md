![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)

# Easy_pal

easy_pal is a simple and naive PAL implementation that can be (re)programmed via a shift-register chain.
The PAL is fully parametric and thus number of inputs (N), number of intermediate stages (P) and the number of outputs (M) can be configured in a flexible way in the verilog sources.

<img src="/Images/example_n4_p4_o3_no_connections.png" alt="drawing" width="600"/>

## Example configuration
To generate a bitstream the python script has to be run.
In the top of the file the logic function and the size of the PAL-device has to be provided.
After displaying the truth table the script generates the following output:

<img src="/Images/example_python_output.png" alt="drawing" width="200"/>

The logic function was given in the following way in the Python code:
"O0 = ~I0 | I1 & ~(I2 & I3) "

Looking at the following waveform we can see that it does indeed work! :)

<img src="/Images/example_waveform.png" alt="drawing" width="400"/>

## Files
There is only a hand-full of important files.
Files used for hardware:
- PAL.v
- crosspoint.v
- reduce.v
- stride.v
- sr.v

There are testbenches for some of the sub-components. If the oss-cad tools are installed these can be run via the scripts in the run-folder.
The testbench.v is the general testbench. Here bitstreams that were generated via the python script "generate_bitstream.py" can be inserted and tested.

## Limitations / Ideas for further expansion
There are plenty of limitations with the current implementation.
### Bitstream generation
The generation of the bitstream currently is very naive.
The python script to generate the bitstream currently does the folloing
1. Take the arbitrary boolean expression and convert it to DNF form
2. Verify that the number of terms that are connected by ORs are <= P (number of intermediate stages)
3. AND Matrix: Generate a bitstream based on that by using one column per set of AND-connected variables.
4. OR Matrix: Set all bits to 1 (only 1 output is supported!)

Ideas for expansions are obvious:
Programmable inversion of outputs; Feedback paths from output to input also come to mind
(see datasheet of a commercial PAL device: https://www.ti.com/lit/ds/symlink/pal16r8am.pdf?ts=1709131093901&ref_url=https%253A%252F%252Fwww.google.com%252F )

### Hardware optimizations
A flipflop chain for configuration is simple but also costly in terms of hardware. 
A row/column based frame-based configuration like it is used in FPGAs could benefit the design.
Not having a flipflop chain would free up logic resuources that could otherwise be used for cool new features like sequential logic in the device.

# Tiny Tapeout Verilog Project Template

- [Read the documentation for project](docs/info.md)

## What is Tiny Tapeout?

TinyTapeout is an educational project that aims to make it easier and cheaper than ever to get your digital designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

## Verilog Projects

1. Add your Verilog files to the `src` folder.
2. Edit the [info.yaml](info.yaml) and update information about your project, paying special attention to the `source_files` and `top_module` properties. If you are upgrading an existing Tiny Tapeout project, check out our [online info.yaml migration tool](https://tinytapeout.github.io/tt-yaml-upgrade-tool/).
3. Edit [docs/info.md](docs/info.md) and add a description of your project.
4. Optionally, add a testbench to the `test` folder. See [test/README.md](test/README.md) for more information.

The GitHub action will automatically build the ASIC files using [OpenLane](https://www.zerotoasiccourse.com/terminology/openlane/).

## Enable GitHub actions to build the results page

- [Enabling GitHub Pages](https://tinytapeout.com/faq/#my-github-action-is-failing-on-the-pages-part)

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://docs.google.com/document/d/1aUUZ1jthRpg4QURIIyzlOaPWlmQzr-jBn3wZipVUPt4)

## What next?

- [Submit your design to the next shuttle](https://app.tinytapeout.com/).
- Edit [this README](README.md) and explain your design, how it works, and how to test it.
- Share your project on your social network of choice:
  - LinkedIn [#tinytapeout](https://www.linkedin.com/search/results/content/?keywords=%23tinytapeout) [@TinyTapeout](https://www.linkedin.com/company/100708654/)
  - Mastodon [#tinytapeout](https://chaos.social/tags/tinytapeout) [@matthewvenn](https://chaos.social/@matthewvenn)
  - X (formerly Twitter) [#tinytapeout](https://twitter.com/hashtag/tinytapeout) [@matthewvenn](https://twitter.com/matthewvenn)
