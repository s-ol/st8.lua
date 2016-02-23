St8.lua ![](https://img.shields.io/travis/S0lll0s/st8.lua.svg) ![](https://img.shields.io/coveralls/S0lll0s/st8.lua.svg)
=======
A tiny double-stacked state manging library for Lua/LÖVE

Concept
-------
St8 keeps two _Stacks_ of _States_:

              Movement                            ^
             Input State                          | secondary stacks
    Menu  -    Game      - Pause Menu Overlay     |
    ---------------primary stack--------------->

All _States_ in the currently active _Stack_ will run in parallel (i.e. receive events)

Usage
-----
Require `st8.lua` to and keep the return value around.
Call `hook()` to hook `st8.lua` up to the LÖVE handlers/callbacks.
Using `order(event, order)` the execution order for a single event can be changed, pass anything but `"bottom"` or `"bottom-up"` to execute the events top-down.
The *bottom-up* order is recommended for example for the `draw` callback.

You can add and remove _Stacks_ (elements on the primary stack) using `pause(state_or_stack)` and `resume()`.  
You can add and remove _States_ (elements on the secondary stack) using `push(state)` and `pop()`.  
You can swap States using `swap(old, new)` and remove a specific State using `remove(state)`.

All methods accept additional arguments, these will be passed on both to the last _State_(s) **and** the new ones.
`pause` accepts lists or single _States_ as arguments.

Events
------
St8 covers all of LÖVE's callbacks.
Event callback methods receive one additional parameter (as the first one).
This is the return value of the _State_ above the one receiving the event currently; For the topmost _State_ it will always be `nil`.
The return value of the last _State_ of the current _Stack_ will be returned.
This can be used to pass messages between _States_ of a _Stack_.

Example
-------
You can find a small example showing off some of the features in the `example` folder.
