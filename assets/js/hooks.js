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
        const center = points.length == 0 ?
          { lat: 33.30639, lng: 130.41806 }
          :
          { lat: parseFloat(points[0].lat), lng: parseFloat(points[0].lng) }

        const map = new google.maps.Map(document.getElementById("map"), {
          center: center,
          zoom: 9,
        });
        window.map = map;

        points.forEach((point) => {
          this.addMarker(point)
        });
      });
    });
    this.handleEvent("created_point", ({ point }) => {
      this.addMarker(point)
    });
  },
  addMarker(point) {
    const marker = new google.maps.Marker({
      position: { lat: parseFloat(point.lat), lng: parseFloat(point.lng)},
      animation: google.maps.Animation.DROP,
      icon: {
          path: google.maps.SymbolPath.CIRCLE,
          fillColor: '#00F',
          fillOpacity: 0.6,
          strokeColor: '#00A',
          strokeOpacity: 0.9,
          strokeWeight: 1,
          scale: 2
      }
   })
   marker.setMap(window.map)
  }
};

export default Hooks;
