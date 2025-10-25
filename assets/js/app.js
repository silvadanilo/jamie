// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

const PlacesAutocomplete = {
  mounted() {
    this.retryCount = 0
    this.maxRetries = 20
    this.initAutocomplete()
  },
  
  updated() {
    if (!this.autocomplete) {
      this.retryCount = 0
      this.initAutocomplete()
    }
  },
  
  initAutocomplete() {
    if (this.autocomplete) return
    
    if (typeof google === 'undefined' || !google.maps || !google.maps.places || !google.maps.places.Autocomplete) {
      this.retryCount++
      if (this.retryCount < this.maxRetries) {
        setTimeout(() => this.initAutocomplete(), 100)
      } else {
        console.warn('Google Maps Places API not loaded. Please set GOOGLE_MAPS_API_KEY environment variable.')
      }
      return
    }
    
    const input = this.el
    const form = input.closest('form')
    
    // Get the IDs from data attributes
    const locationId = input.dataset.locationId
    const latitudeId = input.dataset.latitudeId
    const longitudeId = input.dataset.longitudeId
    const placeIdAttr = input.dataset.placeId
    
    // Use the classic Autocomplete API
    this.autocomplete = new google.maps.places.Autocomplete(input, {
      fields: ['place_id', 'geometry', 'name', 'formatted_address']
    })
    
    // Listen for place selection
    this.autocomplete.addListener('place_changed', () => {
      const place = this.autocomplete.getPlace()
      
      if (!place.geometry || !place.geometry.location) {
        return
      }
      
      const lat = place.geometry.location.lat()
      const lng = place.geometry.location.lng()
      const placeId = place.place_id
      const displayName = place.name || place.formatted_address
      
      // Find the hidden inputs by ID
      const locationInput = document.getElementById(locationId)
      const latInput = document.getElementById(latitudeId)
      const lngInput = document.getElementById(longitudeId)
      const placeIdInput = document.getElementById(placeIdAttr)
      
      // Update all the hidden inputs
      if (locationInput) locationInput.value = displayName
      if (latInput) latInput.value = lat
      if (lngInput) lngInput.value = lng
      if (placeIdInput) placeIdInput.value = placeId
      
      // Trigger a blur event on one of the visible inputs to make LiveView pick up the changes
      const titleInput = form.querySelector('input[name="occurence[title]"]')
      if (titleInput) {
        titleInput.dispatchEvent(new Event('blur', { bubbles: true }))
      }
    })
  },
  
  destroyed() {
    if (this.autocomplete) {
      google.maps.event.clearInstanceListeners(this.autocomplete)
      this.autocomplete = null
    }
  }
}

const Hooks = {
  PlacesAutocomplete
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Round datetime-local inputs to 15-minute intervals
document.addEventListener('DOMContentLoaded', () => {
  const roundTo15Minutes = (input) => {
    if (!input.value) return
    
    const date = new Date(input.value)
    const minutes = date.getMinutes()
    const roundedMinutes = Math.round(minutes / 15) * 15
    
    date.setMinutes(roundedMinutes)
    date.setSeconds(0)
    date.setMilliseconds(0)
    
    // Format as datetime-local string (YYYY-MM-DDTHH:mm)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const mins = String(date.getMinutes()).padStart(2, '0')
    
    input.value = `${year}-${month}-${day}T${hours}:${mins}`
  }
  
  // Handle datetime-local inputs
  document.addEventListener('change', (e) => {
    if (e.target.type === 'datetime-local' && e.target.step === '900') {
      roundTo15Minutes(e.target)
    }
  })
  
  // Also handle on blur to catch manual entries
  document.addEventListener('blur', (e) => {
    if (e.target.type === 'datetime-local' && e.target.step === '900') {
      roundTo15Minutes(e.target)
    }
  }, true)
})

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

