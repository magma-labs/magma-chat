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
  }

  content(event) {
    var copyText = this.element.dataset.content;
    navigator.clipboard.writeText(copyText).then(function() {
      console.log('Async: Copying to clipboard was successful!', copyText);
    }
    , function(err) {
      console.error('Async: Could not copy text: ', err);
    });
  }
}
