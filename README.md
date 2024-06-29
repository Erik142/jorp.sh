# jorp.sh

jorp.sh - jorp backwards spells proj, an abbrevation for project - is a terminal multiplexer project/session manager. jorp.sh aims to be a simple, extensible project manager for terminal-based projects. Below you will find a video seeing the project in action.

## Installation

Simply clone the git repository, and execute jorp.sh:

```bash
git clone https://github.com/Erik142/jorp.sh.git
cd jorp.sh/
./jorp.sh
```

## Configuration

By default, jorp.sh is configured to use the internal backends in the application:

- git: Search for local git repositories and open a new session inside the git repository
- scratch: Create a "scratchpad" session
- path: Specify a custom path and open a new session in that path
- tmux: Use tmux as the terminal multiplexer of choice (currently the only supported multiplexer, with plans to support others in the future)

## Usage

Simply invoke

```bash
jorp.sh
```

or

```bash
jorp.sh --help
```

for usage instructions.
