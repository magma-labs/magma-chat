import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  change(event) {
    var image_url = event.target.value;
    var image = document.querySelector("#bot_image");
    // if image starts with https://, show it
    if (image_url && image_url.startsWith("https://")) {
      image.style.display = "block";
      image.src = image_url;
    }
    else {
      image.style.display = "none";
    }
  }
}
