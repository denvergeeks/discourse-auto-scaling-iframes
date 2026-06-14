import { apiInitializer } from "discourse/lib/api";

const BREAKPOINT = 2030;
const THROTTLE = 30;

/**
 * Returns a CSS transform string for cross-browser compatibility.
 */
function transformStr(obj) {
  let val = "";
  for (const j in obj) {
    val += j + "(" + obj[j] + ") ";
  }
  val += "translateZ(0)";
  return (
    "-webkit-transform: " +
    val +
    "; -moz-transform: " +
    val +
    "; transform: " +
    val
  );
}

/**
 * Checks whether `el` is immediately followed (in the DOM) by a paragraph
 * whose trimmed text content equals "{autoscale}". If found, removes that
 * marker paragraph and returns true; otherwise returns false.
 */
function consumeAutoscaleMarker(el) {
  let sibling = el.nextSibling;

  // Skip past whitespace-only text nodes
  while (sibling && sibling.nodeType === Node.TEXT_NODE && !sibling.textContent.trim()) {
    sibling = sibling.nextSibling;
  }

  if (
    sibling &&
    sibling.nodeType === Node.ELEMENT_NODE &&
    sibling.tagName === "P" &&
    sibling.textContent.trim() === "{autoscale}"
  ) {
    sibling.remove();
    return true;
  }

  return false;
}

/**
 * Attaches a throttled resize listener that CSS-transforms the iframe
 * to compensate for viewports narrower than BREAKPOINT.
 * iframeHeight is derived from the 16/9 aspect ratio at call time.
 */
function applyScaling(iframe) {
  // Read the live rendered width to derive height from 16:9 aspect ratio.
  // getBoundingClientRect is more reliable than getComputedStyle here because
  // the element is freshly inserted and layout may not have flushed yet for
  // getComputedStyle height when aspect-ratio is in play.
  let iframeHeight = iframe.getBoundingClientRect().height;

  // Fallback: compute from width if layout hasn't painted yet (height === 0)
  if (!iframeHeight) {
    const w = iframe.getBoundingClientRect().width || iframe.offsetWidth || window.innerWidth;
    iframeHeight = w * (9 / 16);
  }

  let timestamp = 0;

  function onResize() {
    const now = +new Date();
    const winWidth = window.innerWidth;
    const noResizing = winWidth > BREAKPOINT;

    if (now - timestamp < THROTTLE || noResizing) {
      if (noResizing && iframe.hasAttribute("style")) {
        iframe.removeAttribute("style");
      }
      return;
    }

    timestamp = now;

    const scale = Math.pow(winWidth / BREAKPOINT, 1.2);
    const width = 100 / scale;
    const height = iframeHeight / scale;
    const offsetLeft = (width - 100) / 2;

    iframe.setAttribute(
      "style",
      transformStr({
        scale,
        translateX: "-" + offsetLeft + "%",
      }) +
        "; width: " +
        width +
        "%; height: " +
        height +
        "px"
    );
  }

  window.addEventListener("resize", onResize, false);

  // Apply immediately; defer one frame so layout has had a chance to paint
  // and getBoundingClientRect returns a non-zero height.
  requestAnimationFrame(() => {
    // Re-read height after first paint if the initial read was zero
    if (!iframeHeight) {
      const rect = iframe.getBoundingClientRect();
      iframeHeight = rect.height || rect.width * (9 / 16);
    }
    onResize();
  });
}

export default apiInitializer((api) => {
  api.decorateCookedElement(
    (cooked) => {
      cooked.querySelectorAll("iframe").forEach((iframe) => {
        if (!consumeAutoscaleMarker(iframe)) {
          return; // no {autoscale} marker — leave this iframe alone
        }
        iframe.classList.add("scaling");
        applyScaling(iframe);
      });
    },
    { id: "auto-scaling-iframes" }
  );
});
