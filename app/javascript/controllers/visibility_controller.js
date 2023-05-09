import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "hideable" ]

  showTargets() {
    this.hideableTargets.forEach(el => {
      el.classlist.remove("hidden")
    });
  }

  hideTargets() {
    this.hideableTargets.forEach(el => {
      el.classlist.add("hidden")
    });
  }

  toggleTargets() {
    this.hideableTargets.forEach((el) => {
      el.classList.toggle("hidden")
    });
  }
}
