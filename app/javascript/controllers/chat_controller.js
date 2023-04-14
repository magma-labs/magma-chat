import ApplicationController from './application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()
    console.log('Chat controller connected')
  }

  submit(event) {
    // submit the parent form
    this.element.closest('form').submit()
  }

  keydown(event) {
    if (event.metaKey && event.keyCode === 13) {
      event.preventDefault();
      console.log('User typed cmd/ctrl + enter!');
      this.element.blur()
    }
  }

  beforePrompt(element, reflex, noop, reflexId) {
    element.value = ""
  }

  afterPrompt(element, reflex, noop, reflexId) {
    element.focus()
  }
}
