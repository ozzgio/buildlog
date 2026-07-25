// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const tallyScriptSrc = "https://tally.so/widgets/embed.js"

const loadTallyEmbeds = () => {
  if (window.Tally?.loadEmbeds) {
    window.Tally.loadEmbeds()
  }
}

const ensureTallyEmbedsLoaded = () => {
  if (!document.querySelector("iframe[data-tally-src]")) return

  const existingScript = document.querySelector(`script[src="${tallyScriptSrc}"]`)

  if (existingScript) {
    if (existingScript.dataset.loaded === "true" || window.Tally?.loadEmbeds) {
      loadTallyEmbeds()
    } else {
      existingScript.addEventListener("load", loadTallyEmbeds, { once: true })
    }

    return
  }

  const script = document.createElement("script")
  script.src = tallyScriptSrc
  script.async = true
  script.addEventListener(
    "load",
    () => {
      script.dataset.loaded = "true"
      loadTallyEmbeds()
    },
    { once: true }
  )
  document.head.appendChild(script)
}

document.addEventListener("DOMContentLoaded", ensureTallyEmbedsLoaded)
document.addEventListener("turbo:load", ensureTallyEmbedsLoaded)
document.addEventListener("turbo:render", ensureTallyEmbedsLoaded)
