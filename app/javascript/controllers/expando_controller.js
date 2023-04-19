import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    event.preventDefault();
    var element = event.target;
    var target = this.element.querySelector(element.dataset.collapsible);
    console.log(element, target)
    target.classList.toggle('expando-collapsed');
    target.classList.toggle('expando-expanded');
    element.classList.toggle('rotate-90');
  }
}
