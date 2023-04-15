import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()
    console.log("GrowController#connect called!");
    this._toggle()
  }

  toggle(event) {
    this._toggle()
    this.stimulate('Chat#toggle_grow', this.element, {}, this.element.checked)
  }

  _toggle(event) {
    // is this.element checked?
    if (this.element.checked) {
      document.getElementById('prompt_text').classList.add('hidden')
      document.getElementById('prompt_textarea').classList.remove('hidden')
      document.getElementById('prompt_textarea').focus()
    } else {
      document.getElementById('prompt_text').classList.remove('hidden')
      document.getElementById('prompt_textarea').classList.add('hidden')
      document.getElementById('prompt_text').focus()
    }
  }

  afterToggle(element, reflex, noop, reflexId) {
    console.log("GrowController#afterToggle called!");
    this._toggle()
  }
}
