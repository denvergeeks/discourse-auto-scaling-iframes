import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {


  api.decorateCookedElement(
    (cooked) => {
          iframe.classList.add("scaling");
          return;
        }

(function (win, doc) {

  var BREAKPOINT = 2030;

  var THROTTLE = 30;
  
  var IFRAME_HEIGHT;

  var iframe = doc.getElementsByTagName('iframe')[0],
      timestamp = 0;

  IFRAME_HEIGHT = parseInt(getComputedStyle(iframe).height, 10);

  function transformStr(obj) {
    var obj = obj || {},
        val = '',
        j;
    for ( j in obj ) {
      val += j + '(' + obj[j] + ') ';
    }
    val += 'translateZ(0)';
    return '-webkit-transform: ' + val + '; ' +
            '-moz-transform: ' + val + '; ' +
            'transform: ' + val;
  }
  
  function onResize() {
  
    var now = +new Date,
        winWidth = win.innerWidth,
        noResizing = winWidth > BREAKPOINT,
        scale,
        width,
        height,
        offsetLeft;
    
    if ( now - timestamp < THROTTLE || noResizing ) {
      noResizing && iframe.hasAttribute('style') && iframe.removeAttribute('style');
      return onResize;
    }
    
    timestamp = now;

    scale = Math.pow(winWidth / BREAKPOINT, 1.2);

    width = 100 / scale;

    height = IFRAME_HEIGHT / scale;
 
    offsetLeft = (width - 100) / 2;
    
    iframe.setAttribute('style', transformStr({
      scale: scale,
      translateX: '-' + offsetLeft + '%'
    }) + '; width: ' + width + '%; ' + 'height: ' + height + 'px');
    
    return onResize;
  
  }
  
  win.addEventListener('resize', onResize(), false);

})(window.self, document);

      });
    },
  );



});
