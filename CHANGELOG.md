# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Documentation configuration with ExDoc support
- MermaidJS flowchart diagram for InteractiveState field dependencies
- Comprehensive module documentation for `RendevousHashVisual.InteractiveState`

### Changed
- Refactored `InteractiveSvgLive` to eliminate code duplication in `handle_event/3` functions
- Replaced generic `@impl true` with specific `@impl Phoenix.LiveView` annotations
- Added alias for `RendevousHashVisual.InteractiveState` as `State` in LiveView

## [0.1.0] - 2025-09-01

### Added
- Initial Phoenix LiveView application for interactive Rendevous Hash visualization
- `RendevousHashVisual.InteractiveState` module with reactive struct pattern
- Real-time interactive controls for:
  - Text input (Actor ID)
  - Regions configuration (comma-separated)
  - Zones configuration (comma-separated)
  - VM count per availability zone (slider and text input)
  - Replication factor (slider and text input)
  - Topology constraints toggle
- Dynamic SVG visualization generation with `SvgAnimator` for animated displays
- Responsive web interface with Tailwind CSS styling
- Statistics dashboard showing current state metrics
- Phoenix LiveView integration with real-time updates

### Features
- **Interactive Controls**: Live adjustment of visualization parameters
- **Animated SVG**: Smooth transitions for replication factor changes
- **Topology Awareness**: Optional geographic distribution constraints
- **Real-time Updates**: Instant visualization refresh on parameter changes
- **Responsive Design**: Mobile-friendly interface with grid layout
- **State Management**: Reactive struct pattern with computed field dependencies

### Technical Implementation
- Phoenix LiveView for real-time interactivity
- ReactiveStruct pattern for state management with computed fields
- SVG generation and animation capabilities
- Modular component architecture
- Comprehensive event handling for all UI interactions

### Dependencies
- Phoenix Framework (~> 1.8.0)
- Phoenix LiveView (~> 1.1.0)
- Tailwind CSS for styling
- Custom Rendevous Hash implementation
- ReactiveStruct for state management