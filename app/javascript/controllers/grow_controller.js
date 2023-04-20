import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()
    console.log('Grow controller connected')
    this.input = document.querySelector('#prompt_textarea')
  }

  toggle(event) {
    event.preventDefault()
    this.stimulate('Chat#toggle_grow', this.element, {}, this.element.checked)
  }

  beforeToggleGrow(element, reflex, noop, reflexId) {
    console.log('beforeToggleGrow')
    this.value  = this.input.value;
  }

  afterToggleGrow(element, reflex, noop, reflexId) {
    console.log('afterToggleGrow')
    this.input.value = this.value
    this.input.parentNode.dataset.replicatedValue = this.value
    setTimeout(() => {
      this.input.focus()
    }, 200);
  }
}
