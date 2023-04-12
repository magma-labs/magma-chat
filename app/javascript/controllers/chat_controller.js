import ApplicationController from './application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()
    console.log("ChatController#connect called!");
    this.element.focus()
  }

  submit(event) {
    // submit the parent form
    this.element.closest('form').submit()
  }

  beforePrompt(element, reflex, noop, reflexId) {
    element.value = ""
  }
}
