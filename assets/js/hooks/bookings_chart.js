// assets/js/hooks/bookings_chart.js
// Register in app.js:  import BookingsChart from "./hooks/bookings_chart"
//                      let liveSocket = new LiveSocket("/live", Socket, { hooks: { BookingsChart, ...otherHooks } })

const MONTHS = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

const BookingsChart = {
  mounted() {
    const data   = JSON.parse(this.el.dataset.monthly || "[]")
    const canvas = document.createElement("canvas")
    this.el.appendChild(canvas)

    // Chart.js must be loaded globally — add to vendor or import at top of app.js
    this.chart = new Chart(canvas, {
      type: "bar",
      data: {
        labels: MONTHS,
        datasets: [{
          label: "Bookings",
          data,
          backgroundColor: "rgba(139,26,26,0.15)",
          borderColor:     "#8B1A1A",
          borderWidth:     1.5,
          borderRadius:    4,
          borderSkipped:   false,
        }]
      },
      options: {
        responsive:          true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: "#fff",
            titleColor:      "#1f2937",
            bodyColor:       "#6b7280",
            borderColor:     "#E8E2D9",
            borderWidth:     1,
            padding:         10,
            callbacks: {
              label: ctx => ` ${ctx.parsed.y} bookings`
            }
          }
        },
        scales: {
          x: {
            grid:  { display: false },
            ticks: { color: "#9ca3af", font: { size: 11 } }
          },
          y: {
            beginAtZero: true,
            grid:        { color: "rgba(232,226,217,0.6)" },
            ticks:       { color: "#9ca3af", font: { size: 11 }, precision: 0 }
          }
        }
      }
    })
  },

  updated() {
    // Re-render if data changes (e.g. live updates)
    const data = JSON.parse(this.el.dataset.monthly || "[]")
    if (this.chart) {
      this.chart.data.datasets[0].data = data
      this.chart.update()
    }
  },

  destroyed() {
    if (this.chart) this.chart.destroy()
  }
}

export default BookingsChart