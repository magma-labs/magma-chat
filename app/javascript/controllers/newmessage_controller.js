import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("New message controller connected!")
    document.addEventListener("cable-ready:after-update", this.scroll.bind(this))
  }

  scroll() {
    const lastChild = this.element.lastElementChild
    // get the last child of this.element and scroll to the bottom of it
    lastChild.scrollIntoView()
  }
}
