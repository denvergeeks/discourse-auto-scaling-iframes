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

The component includes the following theme settings:

- `desktop_width` — the virtual desktop width in pixels used before scaling.
- `aspect_ratio_width` — the width part of the preview ratio.
- `aspect_ratio_height` — the height part of the preview ratio.
- `iframe_border` — the CSS border applied to the wrapper.

### Recommended defaults

- `desktop_width`: `1440`
- `aspect_ratio_width`: `16`
- `aspect_ratio_height`: `9`

### Tuning guidance

- Increase `desktop_width` to show more of the embedded site at once, but the preview will become smaller.
- Decrease `desktop_width` to make the embedded site larger and easier to read.
- Change the aspect ratio if your embedded content is better suited to `4:3`, `3:2`, or an ultrawide layout.

## Example

```html
<iframe src="https://blog.discourse.org/"></iframe>
{autoscale}
```

With default settings, the iframe is rendered as a 1440px-wide desktop preview and scaled down to fit the topic post width.

## Limitations

### Iframe permissions

This component cannot bypass `X-Frame-Options` or `Content-Security-Policy` restrictions set by the remote site. If a site blocks iframe embedding, the preview will not load regardless of the theme component. Discourse also maintains iframe-related security restrictions in core. [web:83]

### Marker placement

The `{autoscale}` marker must appear immediately after the iframe in the cooked post content for the component to detect it correctly.

This works:

```html
<iframe src="https://example.com"></iframe>
{autoscale}
```

This may not work:

```html
<iframe src="https://example.com"></iframe>

Some other text here

{autoscale}
```

### Readability tradeoff

A full desktop-page preview is useful for visual context, but small text inside the embedded page may become hard to read at narrower post widths. In those cases, lower the `desktop_width` setting.

## Technical notes

- Built as a **theme component**, not a plugin, because this is purely frontend behavior applied to cooked post content. [web:177][web:178]
- Uses `api.decorateCookedElement(...)`, which is the supported JS API approach for altering cooked post HTML in themes. [web:12][web:179]
- Uses `ResizeObserver` so scaling updates when the post container changes width, not only when the browser window resizes. [web:122]

## File structure

Relevant files in this component:

- `settings.yml`
- `locales/en.yml`
- `common/common.scss`
- `javascripts/discourse/api-initializers/auto-scaling-iframes.gjs`

This aligns with the standard structure for Discourse themes and theme components. [web:13][web:118]

## Support

This component is intended for self-hosted Discourse forums where staff want a lightweight way to embed desktop-style previews inside posts without building a plugin.
