const insertScore = () => {
  const meta = document.querySelector('#score');
  const information = document.querySelector('#missing-info')
  const newScore = document.querySelector('#score-data')
  const missingInfo = document.querySelector('#missing-data')

  if (meta || information) {
    const score = meta.getAttribute("content")
    newScore.insertAdjacentHTML('beforeend', `<div class="circle"><p>${score}%</p></div>`)
    const info = JSON.parse(document.querySelector("#missing-information").dataset.info).join('')
    missingInfo.insertAdjacentHTML('beforeend', `<ul>${info}</ul>`)
  }
}

export { insertScore };
