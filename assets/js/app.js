// =============================================================
//  app.js — EnrouteHaye / Kuomboka
//  Single LiveSocket setup. All hooks declared once.
//  Offline-capable — no external CDN dependencies.
// =============================================================

import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import { hooks as colocatedHooks } from "phoenix-colocated/enroute_haye"
import topbar from "../vendor/topbar"
import { CountUp, CopyItinerary, StepSlide } from "./hooks/journey"
import BookingsChart from "./hooks/bookings_chart"

// ── Helpers ──────────────────────────────────────────────────
function $(sel, ctx = document) { return ctx.querySelector(sel) }
function $$(sel, ctx = document) { return [...ctx.querySelectorAll(sel)] }

// ── Hooks ─────────────────────────────────────────────────────

/**
 * LoaderHook — hides the splash screen once LiveView mounts,
 * then triggers hero reveal animations.
 * Attach with: phx-hook="LoaderHook" on the #loader element.
 */
const LoaderHook = {
  mounted() {
    const loader = document.getElementById("loader")
    if (!loader) return

    setTimeout(() => {
      loader.classList.add("hidden")
      revealHero()
    }, 1200)
  }
}

/**
 * Navbar — shows/hides the fixed nav based on scroll position.
 * Attach with: phx-hook="Navbar" on the <nav> element.
 */
const Navbar = {
  mounted() {
    const nav = document.getElementById("navbar-hook")
    if (!nav) return

    const THRESHOLD = window.innerHeight * 0.55

    const onScroll = () => {
      nav.classList.toggle("visible", window.scrollY > THRESHOLD)
    }

    window.addEventListener("scroll", onScroll, { passive: true })
    this._cleanup = () => window.removeEventListener("scroll", onScroll)
  },
  destroyed() { this._cleanup?.() }
}

/**
 * Particles — canvas-based animated gold dust.
 * Attach with: phx-hook="Particles" on a <canvas> element.
 */
const Particles = {
  mounted() {
    const canvas = this.el
    const ctx = canvas.getContext("2d")
    let animId
    const COUNT = 55
    const particles = []

    const resize = () => {
      canvas.width  = canvas.parentElement.offsetWidth
      canvas.height = canvas.parentElement.offsetHeight
    }
    resize()
    window.addEventListener("resize", resize, { passive: true })

    for (let i = 0; i < COUNT; i++) {
      particles.push({
        x:     Math.random() * canvas.width,
        y:     Math.random() * canvas.height,
        r:     Math.random() * 1.5 + 0.3,
        dx:    (Math.random() - 0.5) * 0.3,
        dy:   -(Math.random() * 0.4 + 0.1),
        alpha: Math.random() * 0.5 + 0.1,
        phase: Math.random() * Math.PI * 2
      })
    }

    const draw = (t) => {
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      const time = t * 0.001

      particles.forEach(p => {
        const a = p.alpha * (0.6 + 0.4 * Math.sin(time + p.phase))
        ctx.beginPath()
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2)
        ctx.fillStyle = `rgba(255, 215, 0, ${a})`
        ctx.fill()

        p.x += p.dx
        p.y += p.dy

        if (p.y < -4)               { p.y = canvas.height + 4; p.x = Math.random() * canvas.width }
        if (p.x < -4)                 p.x = canvas.width + 4
        if (p.x > canvas.width + 4)   p.x = -4
      })

      animId = requestAnimationFrame(draw)
    }

    animId = requestAnimationFrame(draw)

    this._cleanup = () => {
      cancelAnimationFrame(animId)
      window.removeEventListener("resize", resize)
    }
  },
  destroyed() { this._cleanup?.() }
}

/**
 * Player — simulated audio progress bar.
 * Swap the interval simulation for a real <audio> element in production.
 * Attach with: phx-hook="Player" on the player container div.
 */
const Player = {
  mounted() {
    const el       = this.el
    const playBtn  = $("#play-btn",       el)
    const skipBack = $("#skip-back",      el)
    const skipFwd  = $("#skip-fwd",       el)
    const track    = $("#progress-track", el)
    const fill     = $("#progress-fill",  el)
    const currTime = $("#current-time",   el)
    const volRange = $("#volume-range",   el)

    const DURATION = 225 // 3:45 in seconds
    let isPlaying = false
    let progress  = 0
    let intervalId

    const formatTime = (secs) => {
      const m = Math.floor(secs / 60)
      const s = Math.floor(secs % 60)
      return `${m}:${s.toString().padStart(2, "0")}`
    }

    const setProgress = (pct) => {
      progress = Math.max(0, Math.min(100, pct))
      fill.style.width = progress + "%"
      currTime.textContent = formatTime((progress / 100) * DURATION)
    }

    const pause = () => {
      isPlaying = false
      playBtn.textContent = "▶"
      clearInterval(intervalId)
    }

    const play = () => {
      isPlaying = true
      playBtn.textContent = "⏸"
      intervalId = setInterval(() => {
        setProgress(progress + (100 / DURATION / 10))
        if (progress >= 100) pause()
      }, 100)
    }

    playBtn?.addEventListener("click",  () => isPlaying ? pause() : play())
    skipBack?.addEventListener("click", () => { pause(); setProgress(progress - 10) })
    skipFwd?.addEventListener("click",  () => { pause(); setProgress(progress + 10) })
    track?.addEventListener("click",    (e) => setProgress((e.offsetX / track.offsetWidth) * 100))
    volRange?.addEventListener("input", (e) => console.log("Volume:", e.target.value))

    this._cleanup = () => clearInterval(intervalId)
  },
  destroyed() { this._cleanup?.() }
}

/**
 * AudioPlayerHook — ambient drum button in the hero.
 * Replace console.info with audioEl.play() / .pause() in production.
 * Attach with: phx-hook="AudioPlayerHook" on the ambient button.
 */
const AudioPlayerHook = {
  mounted() {
    this.el.addEventListener("click", () => {
      console.info("Ambient drum audio toggled.")
    })
  }
}

/**
 * TrackPlay — wires up each track's Play button in the Audio Manager.
 * Reads src/title/artist/cover from data-* attributes (safe, no JS injection).
 * Updates the persistent player bar at the bottom of the page.
 * Attach with: phx-hook="TrackPlay" on each play button.
 */
const TrackPlay = {
  mounted() {
    this.el.addEventListener("click", () => {
      const src    = this.el.dataset.src
      const title  = this.el.dataset.title
      const artist = this.el.dataset.artist
      const cover  = this.el.dataset.cover

      // Load and play audio
      const audio = document.getElementById("native-audio")
      audio.src = src
      audio.play()

      // Update player bar text
      document.getElementById("player-title").textContent  = title  || "Unknown Track"
      document.getElementById("player-artist").textContent = artist || "—"

      // Update player bar cover art
      const c = document.getElementById("player-cover")
      if (cover) {
        c.innerHTML = `<img src="${cover}" style="width:100%;height:100%;object-fit:cover;border-radius:0.4rem;" />`
      } else {
        c.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor"
          style="width:1rem;height:1rem;color:rgba(255,255,255,0.3);">
          <path d="M12 3v10.55A4 4 0 1014 17V7h4V3h-6z"/>
        </svg>`
      }
    })
  }
}

// ── Page utilities ────────────────────────────────────────────

/** Adds .visible to .scroll-reveal elements as they enter the viewport. */
function initScrollReveal() {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible")
        observer.unobserve(entry.target)
      }
    })
  }, { threshold: 0.12, rootMargin: "0px 0px -40px 0px" })

  $$(".scroll-reveal").forEach(el => observer.observe(el))
}

/** Triggers staggered .visible on hero .reveal elements after loader hides. */
function revealHero() {
  $$(".reveal").forEach((el, i) => {
    setTimeout(() => el.classList.add("visible"), i * 80)
  })
}

/** Smooth-scrolls all in-page anchor links. */
function initSmoothScroll() {
  $$('a[href^="#"]').forEach(link => {
    link.addEventListener("click", (e) => {
      const target = document.querySelector(link.getAttribute("href"))
      if (!target) return
      e.preventDefault()
      target.scrollIntoView({ behavior: "smooth", block: "start" })
    })
  })
}

// ── LiveSocket (single instance) ─────────────────────────────
const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  ?.getAttribute("content")

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: {
    ...colocatedHooks,
    LoaderHook,
    Navbar,
    Particles,
    Player,
    AudioPlayerHook,
    CountUp,
    CopyItinerary,
    StepSlide,
    BookingsChart,
    TrackPlay,       // ← Audio Manager track play buttons
  }
})

// Progress bar on live navigation / form submits
topbar.config({ barColors: { 0: "#ffd700" }, shadowColor: "rgba(0,0,0,.3)" })
window.addEventListener("phx:page-loading-start", () => topbar.show(300))
window.addEventListener("phx:page-loading-stop",  () => topbar.hide())

liveSocket.connect()
window.liveSocket = liveSocket

// ── Development helpers ───────────────────────────────────────
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({ detail: reloader }) => {
    reloader.enableServerLogs()

    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup",  _e => keyDown = null)
    window.addEventListener("click", e => {
      if (keyDown === "c") {
        e.preventDefault(); e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if (keyDown === "d") {
        e.preventDefault(); e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

// ── DOM ready ─────────────────────────────────────────────────
document.addEventListener("DOMContentLoaded", () => {
  initScrollReveal()
  initSmoothScroll()
})

// Re-run scroll-reveal after every LiveView DOM patch
document.addEventListener("phx:update", initScrollReveal)