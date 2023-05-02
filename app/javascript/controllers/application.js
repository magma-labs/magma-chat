import { Application } from "@hotwired/stimulus"
import consumer from "channels/consumer"
import Notification from 'stimulus-notification'

const application = Application.start()
application.register('notification', Notification)

// Configure Stimulus development experience
application.debug = false
application.consumer = consumer
window.Stimulus   = application

export { application }
