import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()
    console.log('Conversation controller connected', this.element)
    this.element.focus()
    var submitButton = document.getElementById('prompt_submit')
    if(submitButton) {
      submitButton.addEventListener('click', this.prompt.bind(this))
    }
  }

  submit(event) {
    // submit the parent form
    this.element.closest('form').submit()
  }

  keydown(event) {
    if(event.keyCode === 13) {
      if (event.metaKey || (!this.element.dataset.grow && !event.shiftKey)) {
        event.preventDefault();
        this.prompt(event)
      }
    }
  }

  prompt(event) {
    if (this.element.value.length === 0) {
      return;
    }
    this.stimulate('ConversationReflex#prompt')
  }

  beforePrompt(element, reflex, noop, reflexId) {
    element.value = ""
  }

  afterPrompt(element, reflex, noop, reflexId) {
    element.focus()
  }
}
