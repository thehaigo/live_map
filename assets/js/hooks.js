import { Loader } from "@googlemaps/js-api-loader";
let Hooks = {};

Hooks.Map = {
  mounted() {
    const loader = new Loader({
      apiKey: "your google map api key",
      version: "weekly",
      language: "en",
    });
    this.handleEvent("init_map", ({ point, devices }) => {
      loader.load().then(() => {
        const center = !point
          ? { lat: 33.30639, lng: 130.41806 }
          : { lat: point.lat, lng: point.lng };

        const map = new google.maps.Map(document.getElementById("map"), {
          center: center,
          zoom: 12,
        });
        window.map = map;
        window.markers = [];

        devices.forEach((point) => {
          let marker = new google.maps.Marker({
            position: { lat: point.lat, lng: point.lng },
          });
          marker.setMap(window.map);
          window.markers = [
            ...window.markers,
            { uuid: point.uuid, marker: marker },
          ];
        });
      });
    });

    this.handleEvent(
      "location_update",
      ({ uuid, latlng, points, viewing, tracking }) => {
        if (tracking) {
          window.map.setCenter(latlng);
        }

        const device = window.markers.find((m) => m.uuid == uuid);
        if (device) {
          device.marker.setPosition(latlng);
        } else {
          const marker = new google.maps.Marker({
            position: latlng,
            animation: google.maps.Animation.DROP,
          });
          marker.setMap(window.map);
          window.markers = [...window.markers, { uuid: uuid, marker: marker }];
        }
        window.map.data.forEach((device) => {
          if (viewing && device.i.name == `${uuid}LineString`) {
            window.map.data.remove(device);
            window.map.data.addGeoJson(points);
          }
        });
      }
    );

    this.handleEvent("track_device", ({ point }) => {
      window.map.setCenter({ lat: point.lat, lng: point.lng });
    });

    this.handleEvent("view_device_log", ({ uuid, json, viewing }) => {
      if (viewing) {
        window.map.data.addGeoJson(json);
      } else {
        window.map.data.forEach((device) => {
          if (device.i.name == `${uuid}LineString`) {
            window.map.data.remove(device);
          }
        });
      }
    });
  },
};

export default Hooks;
