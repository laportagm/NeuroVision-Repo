// Shared constants for highlight shaders

// State colors
const vec4 COLOR_IDLE = vec4(0.8, 0.8, 0.8, 1.0);
const vec4 COLOR_HOVER = vec4(0.3, 0.6, 1.0, 1.0);
const vec4 COLOR_SELECTED = vec4(0.2, 0.8, 0.4, 1.0);
const vec4 COLOR_FOCUSED = vec4(1.0, 0.6, 0.2, 1.0);
const vec4 COLOR_MULTI_SELECT = vec4(0.8, 0.3, 0.8, 1.0);

// Animation timings
const float TRANSITION_SPEED = 0.2;
const float PULSE_BASE_SPEED = 1.0;
const float GLOW_FALLOFF = 8.0;

// Effect intensities
const float RIM_INTENSITY_IDLE = 0.0;
const float RIM_INTENSITY_HOVER = 0.8;
const float RIM_INTENSITY_SELECTED = 1.2;
const float RIM_INTENSITY_FOCUSED = 1.5;
