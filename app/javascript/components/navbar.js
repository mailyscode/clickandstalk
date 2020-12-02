const initUpdateNavbarOnScroll = () => {
  const navbar = document.querySelector('.navbar-lewagon');
  const navlog = document.querySelector('.navlog');
  if (navbar) {
    if (navlog) {
      navlog.classList.add('text-white');
      window.addEventListener('scroll', () => {
        if (window.scrollY >= window.innerHeight) {
          navbar.classList.add('navbar-lewagon-white');
          navlog.classList.remove('text-white');
        } else {
          navbar.classList.remove('navbar-lewagon-white');
          navlog.classList.add('text-white');
        }
      });
    }
  }
}

export { initUpdateNavbarOnScroll };
