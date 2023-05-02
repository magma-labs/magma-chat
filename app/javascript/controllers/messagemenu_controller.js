import { Controller } from "@hotwired/stimulus"
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    useClickOutside(this)
    // call clickOutside on escape keypress
    document.addEventListener('keydown', (event) => {
      if (event.key === "Escape") {
        this.close(event)
      }
    })

    this.menuTarget.addEventListener('click', (event) => {
      this.close(event)
    })
  }

  clickOutside(event) {
    this.close()
  }

  close() {
    this.element.closest('.message').classList.remove("highlight")
    this.buttonTarget.classList.remove("bg-gray-600")
    this.menuTarget.classList.add("hidden")
  }

  toggle(event) {
    this.buttonTarget.classList.toggle("bg-gray-600")
    this.menuTarget.classList.toggle("hidden")
    this.element.closest('.message').classList.toggle("highlight")
  }


}
