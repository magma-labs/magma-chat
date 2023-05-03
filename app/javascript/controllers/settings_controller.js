import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()
    this.setup()
  }

  setup() {
    this.element.querySelectorAll('input').forEach((element) => {
      element.addEventListener('input', this.input.bind(this))
      element.addEventListener('mouseup', this.submit.bind(this))
    })
    this.element.querySelectorAll('select').forEach((element) => {
      element.addEventListener('change', this.submit.bind(this))
    })
  }

  input(event) {
    var name = event.target.name.match(/\[(.*?)\]/)[1];
    console.log(event.target.closest("form").dataset.gid, name, event.target.value)
    event.target.closest(".field").querySelector(".setting_value").innerHTML = event.target.value
  }

  submit(event) {
    var name = event.target.name.match(/\[(.*?)\]/)[1];
    this.stimulate('Settings#change', event.target.closest("form").dataset.gid, name, event.target.value)
  }
}
