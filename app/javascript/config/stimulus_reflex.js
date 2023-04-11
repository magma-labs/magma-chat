import { application } from "../controllers/application"
import controller from "../controllers/application_controller"
import StimulusReflex from "stimulus_reflex"

StimulusReflex.initialize(application, { controller, isolate: true })

// consider removing these options in production
StimulusReflex.debug = true
// end remove
