require 'amazing_print'
require 'nokogiri'
require 'json'
require 'open-uri'

REGEX = /<code.+>\n.+linkedin.voyager.dash.deco.identity.profile.FullProfileWithEntities.+"bpr-guid-(?<number>\d+)".+\n<\/code>/

cookie = 'bcookie="v=2&f58d3c69-aef1-4bc9-8a4c-acb72be95771"; lissc=1; bscookie="v=1&20201129102309ee5b0465-ef13-409a-8480-39d9647f53f4AQGhnDXuEcINs6KOGewflax03yAHcnbL"; li_gc=MTsyMTsxNjA2NjQ1Mzk5OzI7MDIx1lOAkPyiwhObp9a296KD3jpI2QD/5TdsecM5+sWTWI0=; li_rm=AQENDn7BPnmKAgAAAXYTh0-Z5SZv4h0Z4Sn-lXmY8_DZzMdkLSLRd9ZZg6d-W4qGnEZt0pIV2J5uorf4S3Q9s9_lANZWAuKHpGvDCpzAKHqMY_H-_hDvp6xv; _ga=GA1.2.962298148.1606645404; _gid=GA1.2.905994353.1606645404; _gat=1; AMCVS_14215E3D5995C57C0A495C55%40AdobeOrg=1; aam_uuid=22135691800873043941416996258899395133; li_at=AQEDATNYHJcFYd28AAABdhOHaHgAAAF2N5PseFYAa8le3wem3b1Qp-ZS6x3Wx_IJSFQRyTH5X_KNbSZrHp-iK0NaB_nOdtQalRULjNT7PbBrOZ9n7QaIxjH6Tfznu4vGh3jtrA6ukytNcVMqlv53dWez; liap=true; JSESSIONID="ajax:5429456736043900841"; lang=v=2&lang=fr-fr; li_mc=MTsyMTsxNjA2NjQ1NDEwOzI7MDIx59959eyMoYUWCQ5uhP+VEqEmqTs3QnnPcVBHM5k7moQ=; lidc="b=VB03:s=V:r=V:g=4078:u=6:i=1606645410:t=1606731504:v=1:sig=AQGHQSVnQ6w2m2SP9cj5Fe8cTPSW8lJG"; spectroscopyId=ad781578-6f34-4bf8-a2c7-8e00704167f8; AMCV_14215E3D5995C57C0A495C55%40AdobeOrg=-637568504%7CMCIDTS%7C18596%7CMCMID%7C21952258699507596811397525096527262198%7CMCAAMLH-1607250215%7C6%7CMCAAMB-1607250215%7C6G1ynYcLPuiQxYZrsz_pkqfLG9yMXBpb2zX5dvJdYQJzPXImdj0y%7CMCOPTOUT-1606652615s%7CNONE%7CvVersion%7C5.1.1%7CMCCIDH%7C661940655'

file = URI.open("https://www.linkedin.com/in/gaelle-shearn", "cookie" => cookie).read

number = file.match(REGEX)[:number]

doc = Nokogiri::HTML(file)


data = JSON.parse(doc.css("#bpr-guid-#{number}").text.strip)

ap data['included'].map {|included| included["$type"]}

skills = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Skill"}

ap skills.map { |s| s["multiLocaleName"].values.first }

education = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Education"}

ap education.map { |s| s["multiLocaleName"].values.first }

File.write('data.json', education)
