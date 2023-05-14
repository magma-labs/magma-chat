import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()
    console.log('Botsettings controller connected')
  }

  toggle_setting() {
    this.stimulate('Bot#toggle_setting', this.element, {}, this.element.checked)
  }

  before
}
