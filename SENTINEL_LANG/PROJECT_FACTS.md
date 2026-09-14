# Sentinel Lang — Canonical Project Facts

GRAY_WHALE_CO is an independent personal project umbrella created by kotarimorm.

GRAY_WHALE_CO is not a registered company.

Sentinel Lang is an experimental OSDev-first programming language developed under GRAY_WHALE_CO.

## Current Status

- Current public version: `v0.6-alpha`
- Main target: `x64`
- Secondary target: `x16` boot sectors
- Output: readable NASM assembly and flat binaries
- Compiler backend: private
- Documentation, specification, roadmap and test reports: public

## Language Model

Sentinel uses:

- numbered function steps
- `local` for persistent flat storage
- `stand` for temporary function values
- `give` for explicit step data flow
- `redo` for mutation
- `create` for function declarations
- `start` for function execution
- `get` and `result` for returned values

Sentinel examples must be written using the current `SPECIFICATION.md`.

Do not invent syntax from C, C++, Python or older Sentinel versions.
