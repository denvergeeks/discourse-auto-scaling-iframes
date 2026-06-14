import { apiInitializer } from "discourse/lib/api";

const DESKTOP_WIDTH = 1440;
const ASPECT_RATIO = 9 / 16;

const resizeObservers = new WeakMap();

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

function wrapIframe(iframe) {
  if (iframe.parentElement?.classList.contains("autoscale-iframe-wrap")) {
    return iframe.parentElement;
  }

  const wrapper = document.createElement("div");
  wrapper.className = "autoscale-iframe-wrap";

  iframe.classList.add("autoscale-iframe");

  iframe.parentNode.insertBefore(wrapper, iframe);
  wrapper.appendChild(iframe);

  return wrapper;
}

function updateScaledIframe(wrapper, iframe) {
  const wrapperWidth = wrapper.clientWidth;

  if (!wrapperWidth) {
    return;
  }

  const scale = Math.min(1, wrapperWidth / DESKTOP_WIDTH);
  const iframeWidth = DESKTOP_WIDTH;
  const iframeHeight = DESKTOP_WIDTH * ASPECT_RATIO;
  const wrapperHeight = iframeHeight * scale;

  wrapper.style.height = `${wrapperHeight}px`;
  wrapper.style.setProperty("--autoscale-factor", scale);

  iframe.style.width = `${iframeWidth}px`;
  iframe.style.height = `${iframeHeight}px`;
}

function attachScaling(wrapper, iframe) {
  if (resizeObservers.has(wrapper)) {
    updateScaledIframe(wrapper, iframe);
    return;
  }

  const resizeObserver = new ResizeObserver(() => {
    updateScaledIframe(wrapper, iframe);
  });

  resizeObserver.observe(wrapper);
  resizeObservers.set(wrapper, resizeObserver);

  updateScaledIframe(wrapper, iframe);
}

export default apiInitializer((api) => {
  api.decorateCookedElement(
    (cooked) => {
      cooked.querySelectorAll("iframe").forEach((iframe) => {
        if (
          iframe.classList.contains("autoscale-iframe") ||
          iframe.parentElement?.classList.contains("autoscale-iframe-wrap")
        ) {
          return;
        }

        if (!consumeAutoscaleMarker(iframe)) {
          return;
        }

        const wrapper = wrapIframe(iframe);
        attachScaling(wrapper, iframe);
      });
    },
    { id: "auto-scaling-iframes" }
  );
});
