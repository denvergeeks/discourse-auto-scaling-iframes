import { apiInitializer } from "discourse/lib/api";

const resizeObservers = new WeakMap();

function isAutoscaleText(value) {
  return value?.trim() === "{autoscale}";
}

function getDesktopWidth() {
  return Math.max(320, Number(settings.desktop_width) || 1440);
}

function getAspectRatioValues() {
  const width = Math.max(1, Number(settings.aspect_ratio_width) || 16);
  const height = Math.max(1, Number(settings.aspect_ratio_height) || 9);
  return { width, height };
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

function unwrapResponsiveIframe(iframe) {
  const responsiveWrap = iframe.parentElement;

  if (!responsiveWrap?.classList.contains("responsive-iframe-wrap")) {
    return iframe;
  }

  const parent = responsiveWrap.parentNode;
  parent.insertBefore(iframe, responsiveWrap);
  responsiveWrap.remove();

  iframe.classList.remove("responsive-iframe");

  return iframe;
}

function wrapIframe(iframe) {
  if (iframe.parentElement?.classList.contains("autoscale-iframe-wrap")) {
    return iframe.parentElement;
  }

  const cleanIframe = unwrapResponsiveIframe(iframe);

  const wrapper = document.createElement("div");
  wrapper.className = "autoscale-iframe-wrap";

  cleanIframe.classList.remove("responsive-iframe");
  cleanIframe.classList.add("autoscale-iframe");

  cleanIframe.parentNode.insertBefore(wrapper, cleanIframe);
  wrapper.appendChild(cleanIframe);

  return wrapper;
}

function updateScaledIframe(wrapper, iframe) {
  const wrapperWidth = wrapper.clientWidth;

  if (!wrapperWidth) {
    return;
  }

  const desktopWidth = getDesktopWidth();
  const aspect = getAspectRatioValues();
  const desktopHeight = desktopWidth * (aspect.height / aspect.width);

  if (wrapperWidth >= desktopWidth) {
    wrapper.style.height = `${desktopHeight}px`;
    iframe.style.width = "100%";
    iframe.style.height = `${desktopHeight}px`;
    iframe.style.transform = "";
    iframe.style.transformOrigin = "";
    return;
  }

  const scale = Math.pow(wrapperWidth / desktopWidth, 1.2);
  const compensatedWidthPercent = 100 / scale;
  const visibleHeight = wrapperWidth * (aspect.height / aspect.width);
  const compensatedHeightPx = visibleHeight / scale;

  wrapper.style.height = `${visibleHeight}px`;

  iframe.style.width = `${compensatedWidthPercent}%`;
  iframe.style.height = `${compensatedHeightPx}px`;
  iframe.style.transform = `scale(${scale})`;
  iframe.style.transformOrigin = "top left";
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
        const autoscaleIframe = wrapper.querySelector("iframe");

        if (!autoscaleIframe) {
          return;
        }

        attachScaling(wrapper, autoscaleIframe);
      });
    },
    { id: "auto-scaling-iframes" }
  );
});
