import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    var current_bot_id = document.querySelector("#conversation_bot_id").value
    if (current_bot_id == this.element.dataset.id) {
      this.element.classList.add("selected")
      this.setPlaceholder(this.element.dataset.name)
    }
    else {
      this.element.classList.remove("selected")
    }
    // on double click, put "Hello" in the conversation_first_message field and fire its change event
    this.element.addEventListener("dblclick", (event) => {
      document.querySelector("#conversation_first_message").value = this.element.dataset.hello
      document.querySelector("#conversation_first_message").dispatchEvent(new Event('change', { bubbles: true }))
    })
  }

  select() {
    document.querySelector("#conversation_bot_id").value = this.element.dataset.id
    document.querySelectorAll("[data-controller='botselect']").forEach((element) => {
      element.classList.remove("selected")
    })
    this.element.classList.add("selected")
    this.setPlaceholder(this.element.dataset.placeholder)
  }

  setPlaceholder(placeholder) {
    document.querySelector("#conversation_first_message").setAttribute("placeholder", placeholder)
    document.querySelector("#conversation_first_message").focus()
  }
}
