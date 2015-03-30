St8.lua
=======
A tiny double-stacked state manging library for Lua/LÖVE

Concept
-------
St8 keeps two _Stacks_ of _States_:

              Movement  `^` 
            Input State `Isecondary stack`
    Menu  -    Game     `I`  - Pause Menu Overlay 
    `--------------primary stack--------------->`

All _States_ in the currently active _Stack_ will run in parallel (i.e. receive events)

Usage
-----
You can add and remove _Stacks_ (elements on the primary stack) using `pause` and `remove`.
You can add and remove _States_ (elements on the secondary stack) using `push` and `pop`.

All methods accept a variable number of arguments, these arguments will be passed on both to the last _State_(s) **and** the new ones.
`push` and `pause` accept lists or single _States_ as arguments.

Events
------
St8 covers all of LÖVE's callbacks (as of 0.9.2). Event callback methods receive one additional parameter (as the first one).
This is the return value of the _State_ above the one receiving the event currently; For the topmost _State_ it will always be `nil`.
The return value of the last _State_ of the current _Stack_ will be returned. This happens regardless of whether the LÖVE callback expects a return value and can be used to pass messages between _States_ of a _Stack_.
