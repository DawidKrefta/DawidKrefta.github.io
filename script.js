const navLinks = document.querySelectorAll(".topbar__nav a");
const observedSections = document.querySelectorAll("main section[id]");
const progressIndicator = document.getElementById("progress-indicator");

const sectionObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) {
        return;
      }

      navLinks.forEach((link) => {
        const isActive = link.getAttribute("href") === `#${entry.target.id}`;
        link.classList.toggle("is-active", isActive);
      });
    });
  },
  {
    rootMargin: "-40% 0px -45% 0px",
    threshold: 0,
  }
);

observedSections.forEach((section) => sectionObserver.observe(section));

const updateScrollProgress = () => {
  const scrollTop = window.scrollY;
  const scrollable = document.documentElement.scrollHeight - window.innerHeight;
  const progress = scrollable > 0 ? (scrollTop / scrollable) * 100 : 0;
  progressIndicator.style.height = `${Math.min(progress, 100)}%`;
};

window.addEventListener("scroll", updateScrollProgress, { passive: true });
window.addEventListener("resize", updateScrollProgress);
updateScrollProgress();
