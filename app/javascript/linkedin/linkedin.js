const insertScore = () => {
  const meta = document.querySelector('#score');
  const newScore = document.querySelector('#score-bar')
  if (meta) {
    const score = meta.getAttribute("content")
    newScore.insertAdjacentHTML('beforeend', score + " %")
  }
}

export { insertScore };
