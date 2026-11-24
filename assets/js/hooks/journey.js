// assets/js/hooks/journey_hooks.js
// Hooks for the Journey LiveView planner.
// Import and register these in your app.js Hooks object.

/**
 * CountUp — animates the budget number when the summary step renders.
 * Usage: <div id="cost-counter" phx-hook="CountUp" data-target="3500">$0</div>
 */
export const CountUp = {
  mounted() {
    this.animate();
  },

  updated() {
    this.animate();
  },

  animate() {
    const target = parseInt(this.el.dataset.target || "0", 10);
    let current = 0;
    const step = Math.ceil(target / 60);
    const iv = setInterval(() => {
      current = Math.min(current + step, target);
      this.el.textContent = "$" + current.toLocaleString();
      if (current >= target) clearInterval(iv);
    }, 16);
  },
};

/**
 * CopyItinerary — copies inner text of a target element to clipboard.
 * Usage: <button phx-hook="CopyItinerary" data-target="itinerary-text">Copy</button>
 */
export const CopyItinerary = {
  mounted() {
    this.el.addEventListener("click", () => {
      const targetId = this.el.dataset.target;
      const target = document.getElementById(targetId);
      if (!target) return;

      navigator.clipboard
        .writeText(target.innerText)
        .then(() => {
          const original = this.el.textContent;
          this.el.textContent = "✓ Copied!";
          setTimeout(() => (this.el.textContent = original), 1800);
        })
        .catch(() => {
          // Fallback for older browsers
          const range = document.createRange();
          range.selectNodeContents(target);
          window.getSelection().removeAllRanges();
          window.getSelection().addRange(range);
          document.execCommand("copy");
          window.getSelection().removeAllRanges();
        });
    });
  },
};

/**
 * StepSlide — optional: smooth scroll-to-top on step change.
 * Usage: <div id="step-X" phx-hook="StepSlide">
 */
export const StepSlide = {
  updated() {
    this.el.scrollIntoView({ behavior: "smooth", block: "start" });
  },
};

/** Lets visitors explicitly drag selected stops into their preferred order. */
export const DestinationSort = {
  mounted() {
    this.el.addEventListener("dragstart", (event) => {
      const item = event.target.closest("[data-stop-id]")
      if (!item) return
      event.dataTransfer.effectAllowed = "move"
      event.dataTransfer.setData("text/plain", item.dataset.stopId)
      item.classList.add("is-dragging")
    })

    this.el.addEventListener("dragend", (event) => {
      event.target.closest("[data-stop-id]")?.classList.remove("is-dragging")
    })

    this.el.addEventListener("dragover", (event) => {
      if (event.target.closest("[data-stop-id]")) event.preventDefault()
    })

    this.el.addEventListener("drop", (event) => {
      event.preventDefault()
      const fromId = event.dataTransfer.getData("text/plain")
      const target = event.target.closest("[data-stop-id]")
      if (!fromId || !target || fromId === target.dataset.stopId) return

      const ids = [...this.el.querySelectorAll("[data-stop-id]")].map((node) => node.dataset.stopId)
      const from = ids.indexOf(fromId)
      const to = ids.indexOf(target.dataset.stopId)
      if (from < 0 || to < 0) return
      ids.splice(to, 0, ids.splice(from, 1)[0])
      this.pushEvent("reorder_destinations", { ids })
    })
  }
}

// ── Registration helper ────────────────────────────────────────────────────
// In your app.js, do:
//
//   import { CountUp, CopyItinerary, StepSlide } from "./hooks/journey_hooks";
//   const Hooks = { CountUp, CopyItinerary, StepSlide };
//   let lv = new LiveSocket("/live", Socket, { hooks: Hooks, ... });
