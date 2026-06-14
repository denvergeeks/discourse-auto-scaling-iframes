import { apiInitializer } from "discourse/lib/api";

const BREAKPOINT = 2030;
const THROTTLE = 30;

function transformStr(obj) {
  let val = "";

  for (const key in obj) {
    val += `${key}(${obj[key]}) `;
  }

  val += "translateZ(0)";

  return `-webkit-transform: ${val}; -moz-transform: ${val}; transform: ${val}`;
}

function isAutoscaleText(value) {
  return value?.trim() === "{autoscale}";
}

function consumeAutoscaleMarker(iframe) {
  let sibling = iframe.nextSibling;

  while (sibling) {
    if (sibling.nodeType === Node.TEXT_NODE) {
      const text = sibling.textContent || "";

      if (!text.trim()) {
        sibling = sibling.nextSibling;
        continue;
      }

      if (isAutoscaleText(text)) {
        sibling.remove();
        return true;
      }

      return false;
    }

    if (sibling.nodeType === Node.ELEMENT_NODE) {
      if (
        sibling.classList?.contains("cooked-selection-barrier") ||
        sibling.tagName === "BR"
      ) {
        sibling = sibling.nextSibling;
        continue;
      }

      if (isAutoscaleText(sibling.textContent)) {
        sibling.remove();
        return true;
      }

      return false;
    }

    sibling = sibling.nextSibling;
  }

  return false;
}

function applyScaling(iframe) {
  let timestamp = 0;
  const baseWidth = BREAKPOINT;
  const baseHeight = baseWidth * (9 / 16);

  function resetInlineStyles() {
    iframe.style.removeProperty("transform");
    iframe.style.removeProperty("-webkit-transform");
    iframe.style.removeProperty("-moz-transform");
    iframe.style.removeProperty("width");
    iframe.style.removeProperty("height");
  }

  function onResize() {
    const now = Date.now();
    const winWidth = window.innerWidth;

    if (now - timestamp < THROTTLE) {
      return;
    }

    timestamp = now;

    if (winWidth > BREAKPOINT) {
      resetInlineStyles();
      return;
    }

    const scale = Math.pow(winWidth / BREAKPOINT, 1.2);
    const width = 100 / scale;
    const height = baseHeight / scale;
    const offsetLeft = (width - 100) / 2;

    iframe.style.cssText = `${transformStr({
      scale,
      translateX: `-${offsetLeft}%`,
    })}; width: ${width}%; height: ${height}px;`;
  }

  window.addEventListener("resize", onResize, false);
  onResize();
}

export default apiInitializer((api) => {
  api.decorateCookedElement(
    (cooked) => {
      cooked.querySelectorAll("iframe").forEach((iframe) => {
        if (!consumeAutoscaleMarker(iframe)) {
          return;
        }

        iframe.classList.add("scaling");
        applyScaling(iframe);
      });
    },
    { id: "auto-scaling-iframes" }
  );
});
