// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let queuedAnimation = () => {};

let Hooks = {
  RunAnimation: {
    mounted() {},
    updated() {
      // Clear and re-set the image src so the browser knows to stop displaying the old src.
      // (The thumbnail will cover while the full image src is loading.)
      const currentImageFull = document.getElementById("current_image_full");
      const src = currentImageFull.src;
      currentImageFull.src = "";
      currentImageFull.src = src;

      // Remove & re-apply the animation class to trigger the correct animation
      const animationClass = this.el.getAttribute("data-animation-class") || "";
      const currentImageDiv = document.getElementById("current_image");
      currentImageDiv.classList.remove(
        "animate-turn-left",
        "animate-turn-right",
        "animate-zoom-in",
        "animate-zoom-out",
        "animate-look-up",
        "animate-look-down"
      );
      void currentImageDiv.offsetWidth;
      currentImageDiv.classList.add(animationClass);
    },
  },
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
