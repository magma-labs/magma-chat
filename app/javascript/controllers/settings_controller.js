import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()
    this.setup()
  }

  setup() {
    this.element.querySelectorAll('input[type="checkbox"]').forEach((element) => {
      element.addEventListener('click', this.submitCheckbox.bind(this))
    })
    this.element.querySelectorAll('input[type="range"]').forEach((element) => {
      element.addEventListener('input', this.input.bind(this))
      element.addEventListener('mouseup', this.submit.bind(this))
    })
    this.element.querySelectorAll('select').forEach((element) => {
      element.addEventListener('change', this.submit.bind(this))
    })
  }

  input(event) {
    var sv = event.target.closest(".field").querySelector(".setting_value")
    if(sv) {
      sv.innerHTML = event.target.value
    }
  }

  submit(event) {
    var name = event.target.name.match(/\[(.*?)\]/)[1];
    this.stimulate('Settings#change', event.target.closest("form").dataset.gid, name, event.target.value)
  }

  submitCheckbox(event) {
    var name = event.target.name.match(/\[(.*?)\]/)[1];
    this.stimulate('Settings#change', event.target.closest("form").dataset.gid, name, event.target.checked)
  }
}
