import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "sidebaroverlay", "revealbutton", "hidebutton"]

  reveal() {
    this.sidebarTarget.style.left = "0";
    this.sidebaroverlayTarget.classList.remove("hidden");
    this.revealbuttonTarget.classList.add("hidden");
    this.hidebuttonTarget.classList.remove("hidden");
  }

  hide() {
    this.sidebarTarget.style.left = "-100%";
    this.sidebaroverlayTarget.classList.add("hidden");
    this.revealbuttonTarget.classList.remove("hidden");
    this.hidebuttonTarget.classList.add("hidden");
  }

}
