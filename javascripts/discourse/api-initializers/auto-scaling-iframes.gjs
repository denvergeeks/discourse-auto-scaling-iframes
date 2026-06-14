import { apiInitializer } from "discourse/lib/api";

const BREAKPOINT = 2030;
const THROTTLE = 30;

function transformStr(obj) {
  let val = "";
  for (const j in obj) {
    val += j + "(" + obj[j] + ") ";
  }
  val += "translateZ(0)";
  return (
    "-webkit-transform: " +
    val +
    "; " +
    "-moz-transform: " +
    val +
    "; " +
    "transform: " +
    val
  );
}

function applyScaling(iframe) {
  const iframeHeight = parseInt(getComputedStyle(iframe).height, 10);
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
  onResize(); // apply immediately on decoration
}

export default apiInitializer((api) => {
  api.decorateCookedElement(
    (cooked) => {
      const iframes = cooked.querySelectorAll("iframe");
      iframes.forEach((iframe) => {
        iframe.classList.add("scaling");
        applyScaling(iframe);
      });
    },
    { id: "auto-scaling-iframes" }
  );
});
