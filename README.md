# Discourse Auto-Scaling Iframes

A Discourse theme component that turns marked iframes in cooked post content into desktop-style scaled previews.

When an iframe is immediately followed by `{autoscale}`, the component:

- removes the `{autoscale}` marker,
- wraps the iframe in a clipping container,
- renders the iframe at a fixed virtual desktop width,
- scales it down to fit the width of the post content.

This allows a full desktop page to remain visible inside the iframe instead of showing only a narrow mobile-sized slice.

## Installation

1. In Discourse, go to **Admin → Appearance → Themes & components**. [web:180]
2. Install this repository as a **theme component** from its Git URL, or upload it locally. [web:180]
3. Add the component to the active theme using **Included components** or the component’s **Include component on these themes** setting. [web:180]

## Usage

In a post, place `{autoscale}` immediately after the iframe:

```html
<iframe src="https://example.com"></iframe>
{autoscale}
```

Only iframes followed by `{autoscale}` are modified. All other iframes are left alone.

## How it works

The component uses Discourse’s cooked-post decoration API to scan rendered post HTML and find marked iframes. The callback receives the post root element, which allows the component to safely inspect and modify the cooked content after rendering. [web:179][web:12]

For each marked iframe, the component wraps it in a container that stays at 100% width of the `.cooked` content area. The iframe itself is given a fixed “desktop canvas” width and then scaled with CSS transforms so the full embedded page is visible inside the wrapper. This wrapper-based scaling pattern is the clean way to make oversized iframe content fit a smaller responsive container. [web:53][web:107]

## Theme settings

The component includes 
