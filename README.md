## Arcenciel: Physical Knobs for Virtual Machines

![Hero](docs/images/hero.jpg)

*"Touch the cloud; feel its thunder beneath your fingertips."*

### Introduction

Arcenciel is a declarative microframework for the [Monome](http://monome.org/) Arc OSC controller. 

All sufficiently complex systems have *phases* and *transitions*.
Discovering the boundary of each is challenging and often defies intuition.
Trajectories can be stable, metastable, or chaotic.
Small variations in the parameters of the system can manifest as large, unexpected effects.
How can we thoroughly and naturally explore the space of all states?

Consider this idea: Play your benchmarks like a *musical instrument*.

Here's an [inspiring example](https://vimeo.com/21596928) of the Arc's potential.

*Monome has discontinued all models of the Arc controller and the supply is therefore strictly limited.*
*Each unit is a stunningly beautiful masterpiece: a rare combination of technology and aesthetic joy.*
*If you're among the lucky few who own this extraordinary recherché, love and cherish it forever.*
*The Arc's value handily surpasses its weight in gold.*

### Dependencies

Arcenciel uses the OSC protocol (UDP).
SerialOSC interfaces each Arc with the host machine.

To get started on Mac OS X, you'll need to:

* Install the [FTDI virtual COM port (VCP) driver](http://www.ftdichip.com/Drivers/VCP.htm).
* Install the [SerialOSC server](https://github.com/monome/serialosc/releases/tag/1.2).
* Restart your computer.

Test your configuration by running the bundled demonstration script:

```
$ gem install arcenciel
$ arcenciel-demo
[ARC] Added device (m0000171; UDP 19930).
[ARC] Assigning control 'Arc' to device...
[ARC] Illuminated encoder 'First' (0). Press any key.
[ARC] Illuminated encoder 'Second' (1). Press any key.
[ARC] Assigned control 'Arc'.
```

### Usage

The Arc reacts to tactile interactions with its rotary encoders:

* Angular motion
* Threshold pressure

From events generated by the device, Arcenciel emulates *logical knobs*.
Each knob has a distinct configuration: a name, a value type, a range, and a precision (degrees per sweep).
When the value of a knob changes, the provided callback is invoked.

Arcenciel discovers all connected devices and assigns each to a logical controller (defining one or more knobs).
When a device is assigned to a controller, for each of its knobs, Arcenciel illuminates the rotary encoder's ring and requests that you to confirm the assignment.

Knobs are defined using these attributes:

* Name
* Initial value
* Minimum and maximum value (individually or as a range)
* Sweep (degrees of rotation for the entire range)
* Value type (integer or float)

### Example

Here's a sample that targets a single Arc (two-encoder version).

* Emulate two knobs: "Query rate" and "Rows scanned."
* Use a distinct range and sweep for each knob, with integer values.
* Invoke a distinct callback for each knob.

Implementation:

```
require 'arcenciel'

Arcenciel.run! do
  knob do
    name "Query rate"

    min 0
    max 100
    type :integer
    sweep 1440

    on_value do |rate|
      puts "A: #{name}: #{rate}"
    end
  end

  knob do
    name "Rows scanned"

    min 0
    max 10000
    type :integer
    sweep 360

    on_value do |rows|
      puts "B: #{name}: #{rows}"
    end
  end
end
```

### Special Thanks

* The Monome minimalists, for a solid concept and outstanding craftsmanship.
* The generous dudes who sold me their Arcs, without which this project would not be possible.
