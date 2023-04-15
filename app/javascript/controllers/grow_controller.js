import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  toggle(event) {
    this.stimulate('Chat#toggle_grow', this.element, {}, this.element.checked)
  }
}
