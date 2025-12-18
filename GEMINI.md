# Agent Context for GroundZero

This project contains Mudlet scripts for the Nukefire MUD.
It is built using `muddler`.

## Build System: Muddler

This project uses **muddler** to compile the scripts into a Mudlet package (`.mpackage`).
*   **Configuration**: `mfile` in the root directory.
*   **Source**: `src/` directory.
*   **Documentation**: [Muddler Wiki](https://github.com/demonnic/muddler/wiki) - **IMPORTANT**: Refer to this for how to structure files and `scripts.json`.

## Mudlet API References

When writing Lua code for this project, refer to the following documentation:
**IMPORTANT**: Always reference these APIs, as Mudlet isn't a primary trained upon code set.

1.  **Mudlet Lua Functions**: [Manual:Lua Functions](https://wiki.mudlet.org/w/Special:MyLanguage/Manual:Lua_Functions)
    *   Primary reference for all Mudlet-specific API calls.
2.  **Geyser UI Manager**: [Geyser Reference](https://www.mudlet.org/geyser/files/geyser/Geyser.html)
    *   Use this for creating windows, labels, gauges, and other UI elements.
3.  **Geyser Manual**: [Geyser Manual](https://wiki.mudlet.org/w/Manual:Geyser)
    *   Extra documentation for Geyser, including many details about stylesheets. 
4.  **MDK**: [MDK Manual](https://github.com/demonnic/MDK and https://demonnic.github.io/mdk/current/)
    *   Extra documentation for MDK, including many details about stylesheets. 
    *   **IMPORTANT**: This is the primary reference for all MDK-specific API calls, including EMCO.
    *   **IMPORTANT**: Always check here for functions, examples, and ways of doing things that are not covered by the Mudlet Manual.
5.  **Mudlet Scripting Manual**: [Manual:Scripting](https://wiki.mudlet.org/w/Special:MyLanguage/Manual:Scripting)
    *   Extra documentation for Mudlet, including many details about triggers, aliases, and more.

## Project Structure

*   `mfile`: Muddler project configuration.
*   `src/scripts/GroundZero/`: Contains the Lua scripts and `scripts.json` definition.
*   **IMPORTANT**: Triggers should almost always raise an event rather than perform actions directly. This allows for greater modularity and reusability.