import { Loader } from "@googlemaps/js-api-loader";
let Hooks = {};

Hooks.Map = {
  mounted() {
    this.handleEvent("init_map", ({ point, devices }) => {
      const loader = new Loader({
        apiKey: "your google map api key",
        version: "weekly",
      });
      loader.load().then(() => {
        const center = !point ?
          { lat: 33.30639, lng: 130.41806 }
          :
          { lat: point.lat, lng: point.lng }

        const map = new google.maps.Map(document.getElementById("map"), {
          center: center,
          zoom: 12,
        });
        window.map = map;
        devices.forEach(device => window.map.data.addGeoJson(device))
      });
    });

    this.handleEvent("location_update", ({ uuid, latlng, point, points, viewing,tracking }) => {
      window.map.data.forEach(device => {
        if(device.i.name == `${uuid}Point`) {
          window.map.data.remove(device)
          window.map.data.addGeoJson(point)
        }
        if(viewing && device.i.name == `${uuid}LineString`) {
          window.map.data.remove(device)
          window.map.data.addGeoJson(points)
        }
        if(tracking) {
          window.map.setCenter(latlng)
        }
      })

    });

    this.handleEvent("track_device",({ point }) => {
      window.map.setCenter({ lat: point.lat, lng: point.lng })
    });

    this.handleEvent("view_device_log", ({ uuid, json, viewing }) => {
      if(viewing) {
        window.map.data.addGeoJson(json)
      } else {
        window.map.data.forEach(device => {
          if(device.i.name == `${uuid}LineString`) {
            window.map.data.remove(device)
          }
        })
      }
    })
  }
};

export default Hooks;
