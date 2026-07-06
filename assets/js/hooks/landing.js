// Enroute Home — Landing page hooks
// Merge these into your existing `Hooks` object passed to LiveSocket in app.js:
//
//   import { ScrollNav, Reveal } from "./landing_hooks"
//   let Hooks = { ...existingHooks, ScrollNav, Reveal }

export const ScrollNav = {
  mounted() {
    this.onScroll = () => {
      if (window.scrollY > 24) {
        this.el.classList.add("zm-is-scrolled");
      } else {
        this.el.classList.remove("zm-is-scrolled");
      }
    };
    window.addEventListener("scroll", this.onScroll, { passive: true });
    this.onScroll();
  },
  destroyed() {
    window.removeEventListener("scroll", this.onScroll);
  },
};

// Progressive enhancement: elements with `.zm-reveal` are visible by
// default (see landing.css). Only once this hook mounts do we "arm"
// the element (hide it) and wait for it to scroll into view before
// revealing it again. If JS never runs, nothing ever hides.
export const Reveal = {
  mounted() {
    // Arm on next frame so the initial (visible) paint isn't skipped
    // if the element is already in the viewport on load.
    requestAnimationFrame(() => {
      this.el.classList.add("zm-reveal-armed");
    });

    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("zm-is-visible");
            this.observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.15 }
    );
    this.observer.observe(this.el);
  },
  destroyed() {
    if (this.observer) this.observer.disconnect();
  },
};