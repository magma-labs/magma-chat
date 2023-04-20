import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()
    console.log('Chat controller connected')
    this.element.focus()
  }

  submit(event) {
    // submit the parent form
    this.element.closest('form').submit()
  }

  keydown(event) {
    if(event.keyCode === 13) {
      if (event.metaKey || (!this.element.dataset.grow && !event.shiftKey)) {
        event.preventDefault();
        this.stimulate('ChatReflex#prompt')
      }
    }
  }

  beforePrompt(element, reflex, noop, reflexId) {
    element.value = ""
  }

  afterPrompt(element, reflex, noop, reflexId) {
    element.focus()
  }
}
