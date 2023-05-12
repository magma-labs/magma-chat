import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()

    // add listener for esc key
    document.addEventListener('keyup', this.handleKeyup.bind(this))
  }

  handleKeyup(event) {
    if (event.key === 'Escape') {
      this.element.value = ''
      window.location.reload()
    }
  }
}
