import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if(this.element.dataset.select) {
      this.element.select()
    } else {
      this.element.focus()
      var val = this.element.value; //store the value of the element
      this.element.value = ''; //clear the value of the element
      this.element.value = val; //set that value back, leaving the cursor at the end
    }
  }
}
