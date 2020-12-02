const insertScore = () => {
  const meta = document.querySelector('#score');
  const newScore = document.querySelector('#score-data')
  if (meta) {
    const score = meta.getAttribute("content")
    newScore.insertAdjacentHTML('beforeend', `<div class="circle"><p>${score}%</p></div>`)
  }
}

export { insertScore };
