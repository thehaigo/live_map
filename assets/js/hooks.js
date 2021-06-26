import { Loader } from "@googlemaps/js-api-loader";
let Hooks = {};

Hooks.Map = {
  mounted() {
    this.handleEvent("init_map", ({ points }) => {
      const loader = new Loader({
        apiKey: "your API key",
        version: "weekly",
      });

      loader.load().then(() => {
        const center = {
          lat: 33.30639,
          lng: 130.41806,
        };

        const map = new google.maps.Map(document.getElementById("map"), {
          center: center,
          zoom: 9,
        });
        window.map = map;
      });
    });
  },
};

export default Hooks;
