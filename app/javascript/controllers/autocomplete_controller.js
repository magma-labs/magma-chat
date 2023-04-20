import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()
    this.list = document.getElementById('autocompleteList');

    this.element.addEventListener('change', this.blur.bind(this));
    //this.element.addEventListener('keydown', this.handleTabKey.bind(this));


    for (const item of this.element.children) {
      item.addEventListener('click', function () {
        this.element.value = item.innerText;
        this.blur()
      });
    }
  }

  input() {
    const search = this.element.value.toLowerCase();
    if (search.length === 0 || search[0] !== '/') {
      this.blur()
      return;
    }
    var count = 0;
    for (const item of this.list.children) {
      if (item.dataset.name.startsWith(search)) {
        item.classList.remove('hidden');
        count++;
      }
      else {
        item.classList.add('hidden');
      }
    }

    if (count === 0) {
      this.blur()
    }
    else {
      this.list.classList.remove('hidden');
    }
  }

  // TODO: This is not working. Why?
  // TODO: Defer fixing until we have up/down arrows for selection
  //
  // handleTabKey(event) {
  //   if (event.key === 'Tab') {
  //     const visibleItems = Array.from(this.list.children).filter(item => !item.classList.contains('hidden'));

  //     if (visibleItems.length === 1) {
  //       event.preventDefault(); // Prevent the input from losing focus
  //       this.element.value = visibleItems[0].dataset.name;
  //       this.blur();
  //     }
  //   }
  // }

  blur() {
    setTimeout(() => {
      this.list.classList.add('hidden');
    }, 200);
  }
}
