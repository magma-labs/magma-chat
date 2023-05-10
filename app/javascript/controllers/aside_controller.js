import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="aside"
export default class extends Controller {
  connect() {
  }

  reveal() {
    document.getElementById("aside").style.right = "0";
    document.getElementById("aside-overlay").classList.remove("hidden");
  }

  hide() {
    document.getElementById("aside").style.right = "-100%";
    document.getElementById("aside-overlay").classList.add("hidden");
  }

}
