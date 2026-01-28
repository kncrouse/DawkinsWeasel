# Changelog

All notable changes to the Dawkins Weasel model are documented in this file.

Versioning intent:
**MAJOR**: conceptual or behavioral changes to the model
**MINOR**: refactors, documentation/interface clarity, compatibility updates, non-breaking improvements
**PATCH**: metadata or textual corrections with no functional changes



## [1.2.0] – 2026-01-28 (CoMSES published)

### Added
- Substantially revised **Info tab documentation**, written to NetLogo conventions and instructional use:
  -- Explicit identification of the model as an illustration of **cumulative selection**, using Dawkins’s own terminology
  -- Clearer, standardized definitions of: **target-phrase**, **mutation-rate**, **offspring-per-generation** (previously named number-of-offspring), **with-selection**
  -- Added **Things to Try** section to support guided exploration in teaching contexts
- End-of-run summary message expanded to report **all simulation settings**, including target phrase, mutation rate, offspring per generation, and whether selection was **on** or **off**

### Changed
- Refactored **go** procedure to improve clarity and maintainability:
  -- Explicit separation of per-generation stepping and stopping conditions
  -- No change to model behavior or pedagogical intent
- Interface wording refined for clarity and consistency with Info tab
- Updated compatibility statement to the NetLogo version current at release time

### Compatibility
- Compatible with both **NetLogo 6.4.0** and **NetLogo 7.0.3 or later** (latest release available at time of development)

### Unchanged
- Core Dawkins Weasel mechanism
- Output behavior (one line per generation plus final summary)
- Intended instructional use of the model



## [1.1.0] – 2020-02-04 (CoMSES published)

### Changed
- Internal code readability and commenting improvements
- Minor cleanup without altering execution behavior or output structure
- Updated Info tab version and citation text

### Compatibility
- Compatible with NetLogo 6.1.1
  (released September 2019)



## [1.0.2] – 2019-11-21 (CoMSES published)

### Changed
- **No code changes** relative to version 1.0.1
- Updated version number and citation text only

### Compatibility
- Compatible with NetLogo 6.1.1
  (released September 2019)



## [1.0.1] – 2019-11-21 (CoMSES published)

### Changed
- Simplified internal state representation:
  -- Consolidated separate evolving strings into a single parent-string
- Streamlined **go** control flow while preserving behavior
- Refactored output formatting into a dedicated helper procedure

### Output
- Output Area logging present (as in v1.0.0), with cleaner implementation

### Compatibility
- Compatible with NetLogo 6.1.1
  (released September 2019)



## [1.0.0] – 2018-02-08 (CoMSES published)

### Notes
- Initial public release of the Dawkins Weasel model
- Implements the Dawkins Weasel thought experiment with optional cumulative selection
- Uses separate state variables for selection and no-selection runs

### Output
- Output Area present, implemented using early output-type / output-print patterns

### Compatibility
- Compatible with NetLogo 6.0.2
  (released August 2017)


