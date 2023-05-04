import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ['select']

  play() {
    var id = this.selectTarget.value
    if (id != '') {
      var audio = document.getElementById(`voice_preview_${id}`)
      audio.volume = 0.5
       audio.play()
    }
  }
}
