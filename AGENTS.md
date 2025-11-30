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

1.  **Mudlet Lua Functions**: [Manual:Lua Functions](https://wiki.mudlet.org/w/Special:MyLanguage/Manual:Lua_Functions)
    *   Primary reference for all Mudlet-specific API calls.
2.  **Geyser UI Manager**: [Geyser Reference](https://www.mudlet.org/geyser/files/geyser/Geyser.html)
    *   Use this for creating windows, labels, gauges, and other UI elements.
3.  **Geyser Manual**: [Geyser Manual](https://wiki.mudlet.org/w/Manual:Geyser)
    *   Extra documentation for Geyser, including many details about stylesheets. 

## Project Structure

*   `mfile`: Muddler project configuration.
*   `src/scripts/GroundZero/`: Contains the Lua scripts and `scripts.json` definition.
