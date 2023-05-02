import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  href(event) {
    event.preventDefault();
    var copyText = this.element.href;
    navigator.clipboard.writeText(copyText).then(function() {
      console.log('Async: Copying to clipboard was successful!');
    }
    , function(err) {
      console.error('Async: Could not copy text: ', err);
    });
    this.notify()
  }

  content(event) {
    var copyText = this.element.dataset.content;
    navigator.clipboard.writeText(copyText).then(function() {
      console.log('Async: Copying to clipboard was successful!', copyText);
    }
    , function(err) {
      console.error('Async: Could not copy text: ', err);
    });
    this.notify()
  }

  target(event) {
    console.log('clipboard target invoked');
    event.preventDefault();
    var targetId = this.element.dataset.target;
    var copyText = document.getElementById(targetId).innerText;
    navigator.clipboard.writeText(copyText).then(function() {
      console.log('Async: Copying to clipboard was successful!');
    }
    , function(err) {
      console.error('Async: Could not copy text: ', err);
    });
    this.notify()
  }

  notify() {
    document.querySelector("#awesome-notification p").innerText = this.element.dataset.message;
    window.dispatchEvent(new CustomEvent('awesome'))
  }
}
