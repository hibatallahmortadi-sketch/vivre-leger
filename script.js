// Menu mobile
const burger = document.querySelector('.burger');
const liens = document.querySelector('.liens');
if (burger) burger.addEventListener('click', () => liens.classList.toggle('ouvert'));

// Apparition douce au défilement
const obs = new IntersectionObserver(entrees => entrees.forEach(e => {
  if (e.isIntersecting) { e.target.classList.add('vu'); obs.unobserve(e.target); }
}), { threshold: .1 });
document.querySelectorAll('.revele').forEach(el => obs.observe(el));
