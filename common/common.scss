import { apiInitializer } from "discourse/lib/api";

const resizeObservers = new WeakMap();

function isAutoscaleText(value) {
  return value?.trim() === "{autoscale}";
}

function getDesktopWidth() {
  return Math.max(320, Number(settings.desktop_width) || 1440);
}

function getAspectRatio() {
  const width = Math.max(1, Number(settings.aspect_ratio_width) || 16);
  const height = Math.max(1, Number(settings.aspect_ratio_height) || 9);
  return height / width;
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

  iframe.classList.remove("responsive-iframe");
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

  const desktopWidth = getDesktopWidth();
  const aspectRatio = getAspectRatio();

  const scale = Math.min(1, wrapperWidth / desktopWidth);
  const iframeWidth = desktopWidth;
  const iframeHeight = desktopWidth * aspectRatio;
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
    iframe.classList.remove("responsive-iframe");
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
          iframe.classList.remove("responsive-iframe");
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
