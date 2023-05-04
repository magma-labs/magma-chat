import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()
    console.log('Chat controller connected', this.element)
    this.element.focus()
    var submitButton = document.getElementById('prompt_submit')
    if (submitButton) {
      submitButton.addEventListener('click', this.prompt.bind(this))
    }
  }

  submit(event) {
    // submit the parent form
    this.element.closest('form').submit()
  }

  keydown(event) {
    if (event.keyCode === 13) {
      if (event.metaKey || (!this.element.dataset.grow && !event.shiftKey)) {
        event.preventDefault();
        this.prompt(event)
      }
    }
  }

  prompt(event) {
    if (this.element.value.length === 0) {
      return;
    }

    const xhr = new XMLHttpRequest();
    xhr.open("GET", "/chats");
    xhr.setRequestHeader("Content-Type", "application/json");

    const token = document.head.querySelector(
      'meta[name="csrf-token"]'
    ).content;

    xhr.setRequestHeader("X-CSRF-Token", token);

    xhr.onreadystatechange = () => {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
          this.stimulate('ChatReflex#prompt');
        } else if (xhr.status === 401) {
          window.location.href = "/";
        }
      }
    };

    xhr.send();
  }

  beforePrompt(element, reflex, noop, reflexId) {
    element.value = ""
  }

  afterPrompt(element, reflex, noop, reflexId) {
    element.focus()
  }  prompt(event) {
    if (this.element.value.length === 0) {
      return;
    }

    const xhr = new XMLHttpRequest();
    xhr.open("GET", "/chats");
    xhr.setRequestHeader("Content-Type", "application/json");

    const token = document.head.querySelector(
      'meta[name="csrf-token"]'
    ).content;

    xhr.setRequestHeader("X-CSRF-Token", token);

    xhr.onreadystatechange = () => {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
          this.stimulate('ChatReflex#prompt');
        } else if (xhr.status === 401) {
          window.location.href = "/";
        }
      }
    };

    xhr.send();
  }
}
