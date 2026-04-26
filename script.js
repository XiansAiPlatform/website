(function () {
  "use strict";

  const prefersReducedMotion = window.matchMedia(
    "(prefers-reduced-motion: reduce)"
  ).matches;

  const header = document.querySelector("[data-header]");
  const navToggle = document.querySelector("[data-nav-toggle]");
  const navList = document.querySelector("[data-nav-list]");

  if (header) {
    const onScroll = () => {
      if (window.scrollY > 8) {
        header.classList.add("is-scrolled");
      } else {
        header.classList.remove("is-scrolled");
      }
    };
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
  }

  if (navToggle && navList) {
    const closeNav = () => {
      navToggle.setAttribute("aria-expanded", "false");
      navList.classList.remove("is-open");
    };

    navToggle.addEventListener("click", () => {
      const isOpen = navToggle.getAttribute("aria-expanded") === "true";
      navToggle.setAttribute("aria-expanded", String(!isOpen));
      navList.classList.toggle("is-open", !isOpen);
    });

    navList.querySelectorAll("a").forEach((link) => {
      link.addEventListener("click", closeNav);
    });

    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape") closeNav();
    });
  }

  if ("IntersectionObserver" in window && !prefersReducedMotion) {
    const revealEls = document.querySelectorAll("[data-reveal]");
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible");
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.12, rootMargin: "0px 0px -40px 0px" }
    );
    revealEls.forEach((el) => observer.observe(el));
  } else {
    document
      .querySelectorAll("[data-reveal]")
      .forEach((el) => el.classList.add("is-visible"));
  }

  if (prefersReducedMotion) {
    document.documentElement.style.scrollBehavior = "auto";
  }

  const navLinks = Array.from(document.querySelectorAll("[data-nav-link]"));
  if (navLinks.length && "IntersectionObserver" in window) {
    const linkBySection = new Map();
    const sections = [];
    navLinks.forEach((link) => {
      const id = (link.getAttribute("href") || "").replace(/^#/, "");
      const section = id ? document.getElementById(id) : null;
      if (section) {
        linkBySection.set(section, link);
        sections.push(section);
      }
    });

    const setActive = (link) => {
      navLinks.forEach((l) => l.classList.toggle("is-active", l === link));
    };

    const visible = new Set();
    const spy = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) visible.add(entry.target);
          else visible.delete(entry.target);
        });

        if (visible.size === 0) return;
        const topMost = sections
          .filter((s) => visible.has(s))
          .sort((a, b) => a.getBoundingClientRect().top - b.getBoundingClientRect().top)[0];
        const link = linkBySection.get(topMost);
        if (link) setActive(link);
      },
      {
        rootMargin: `-${(window.innerHeight || 800) * 0.35}px 0px -45% 0px`,
        threshold: 0,
      }
    );

    sections.forEach((s) => spy.observe(s));
  }

  const yearEl = document.querySelector("[data-year]");
  if (yearEl) {
    yearEl.textContent = String(new Date().getFullYear());
  }

  document.querySelectorAll("[data-carousel]").forEach((carousel) => {
    const track = carousel.querySelector("[data-carousel-track]");
    const slides = Array.from(
      carousel.querySelectorAll("[data-carousel-slide]")
    );
    const prev = carousel.querySelector("[data-carousel-prev]");
    const next = carousel.querySelector("[data-carousel-next]");
    const dots = Array.from(
      carousel.querySelectorAll("[data-carousel-go]")
    );

    if (!track || slides.length === 0) return;

    const total = slides.length;
    const AUTOPLAY_MS = 7000;
    let index = 0;
    let timer = null;

    const update = () => {
      track.style.transform = `translateX(-${index * 100}%)`;
      slides.forEach((slide, i) => {
        slide.setAttribute("aria-hidden", i === index ? "false" : "true");
      });
      dots.forEach((dot, i) => {
        const active = i === index;
        dot.classList.toggle("is-active", active);
        dot.setAttribute("aria-selected", active ? "true" : "false");
        dot.tabIndex = active ? 0 : -1;
      });
    };

    const go = (i) => {
      index = ((i % total) + total) % total;
      update();
    };

    const stop = () => {
      if (timer) {
        clearInterval(timer);
        timer = null;
      }
    };

    const start = () => {
      if (prefersReducedMotion) return;
      stop();
      timer = setInterval(() => go(index + 1), AUTOPLAY_MS);
    };

    if (prev) {
      prev.addEventListener("click", () => {
        go(index - 1);
        start();
      });
    }
    if (next) {
      next.addEventListener("click", () => {
        go(index + 1);
        start();
      });
    }
    dots.forEach((dot) => {
      dot.addEventListener("click", () => {
        const target = parseInt(dot.getAttribute("data-carousel-go"), 10);
        if (!Number.isNaN(target)) {
          go(target);
          start();
        }
      });
    });

    carousel.addEventListener("mouseenter", stop);
    carousel.addEventListener("mouseleave", start);
    carousel.addEventListener("focusin", stop);
    carousel.addEventListener("focusout", start);

    carousel.addEventListener("keydown", (event) => {
      if (event.key === "ArrowLeft") {
        event.preventDefault();
        go(index - 1);
        start();
      } else if (event.key === "ArrowRight") {
        event.preventDefault();
        go(index + 1);
        start();
      }
    });

    let touchStartX = null;
    let touchStartY = null;
    carousel.addEventListener(
      "touchstart",
      (event) => {
        if (event.touches.length !== 1) return;
        touchStartX = event.touches[0].clientX;
        touchStartY = event.touches[0].clientY;
        stop();
      },
      { passive: true }
    );
    carousel.addEventListener("touchend", (event) => {
      if (touchStartX === null) return;
      const dx = event.changedTouches[0].clientX - touchStartX;
      const dy = event.changedTouches[0].clientY - touchStartY;
      if (Math.abs(dx) > 40 && Math.abs(dx) > Math.abs(dy)) {
        go(dx < 0 ? index + 1 : index - 1);
      }
      touchStartX = null;
      touchStartY = null;
      start();
    });

    if ("IntersectionObserver" in window) {
      const visibilityObserver = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) start();
            else stop();
          });
        },
        { threshold: 0.25 }
      );
      visibilityObserver.observe(carousel);
    } else {
      start();
    }

    update();
  });
})();
