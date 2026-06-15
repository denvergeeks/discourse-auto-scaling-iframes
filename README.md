# Discourse Auto-Scaling iFrames

A Discourse theme component that adds an optional (miniaturized) desktop-style iframe mode for cooked post content that auto-scales with window resizing.

When an iframe is immediately followed by an `{autoscale}` marker, the component:

- removes the marker from cooked content,
- unwraps any existing `responsive-iframe-wrap`,
- wraps the iframe in an `autoscale-iframe-wrap`,
- scales the iframe down to fit the available cooked width,
- preserves the configured visible aspect ratio,
- keeps the iframe visually aligned with the wrapper,
- and, when a user resizes the window, autoscales the iFrame as well as the contents inside the iFrame.

## How it works

Add an iframe to a post, then place `{autoscale}` immediately after it.

Example:

```html
<iframe src="https://blog.discourse.org/"></iframe>{autoscale}
```

The iframe will render inside a fixed visible viewport using the configured aspect ratio, while its internal content is scaled to simulate a desktop-width preview.

## Settings

- `desktop_width`: The virtual desktop width used before scaling.
- `aspect_ratio_width`: Visible viewport aspect-ratio width.
- `aspect_ratio_height`: Visible viewport aspect-ratio height.
- `iframe_border`: Border applied as a non-layout overlay on the wrapper.

## Notes

- This component is intended for cooked post content.
- It is designed to coexist with a responsive iframe component by unwrapping `responsive-iframe-wrap` before applying autoscale behavior.
- Resize observers are cleaned up when wrappers are removed from the DOM.

<img width="576" height="797" alt="discourse-auto-scaling-iframes-theme-component" src="https://github.com/user-attachments/assets/7d01620e-8f51-4c63-be46-f78ac30d79a4" />

