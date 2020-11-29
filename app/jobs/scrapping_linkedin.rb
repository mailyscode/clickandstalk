require 'amazing_print'
require 'nokogiri'
require 'json'
require 'open-uri'

REGEX = /<code.+>\n.+linkedin.voyager.dash.deco.identity.profile.FullProfileWithEntities.+"bpr-guid-(?<number>\d+)".+\n<\/code>/

cookie = 'bcookie="v=2&f58d3c69-aef1-4bc9-8a4c-acb72be95771"; lissc=1; bscookie="v=1&20201129102309ee5b0465-ef13-409a-8480-39d9647f53f4AQGhnDXuEcINs6KOGewflax03yAHcnbL"; li_gc=MTsyMTsxNjA2NjQ1Mzk5OzI7MDIx1lOAkPyiwhObp9a296KD3jpI2QD/5TdsecM5+sWTWI0=; li_rm=AQENDn7BPnmKAgAAAXYTh0-Z5SZv4h0Z4Sn-lXmY8_DZzMdkLSLRd9ZZg6d-W4qGnEZt0pIV2J5uorf4S3Q9s9_lANZWAuKHpGvDCpzAKHqMY_H-_hDvp6xv; _ga=GA1.2.962298148.1606645404; _gid=GA1.2.905994353.1606645404; _gat=1; AMCVS_14215E3D5995C57C0A495C55%40AdobeOrg=1; aam_uuid=22135691800873043941416996258899395133; li_at=AQEDATNYHJcFYd28AAABdhOHaHgAAAF2N5PseFYAa8le3wem3b1Qp-ZS6x3Wx_IJSFQRyTH5X_KNbSZrHp-iK0NaB_nOdtQalRULjNT7PbBrOZ9n7QaIxjH6Tfznu4vGh3jtrA6ukytNcVMqlv53dWez; liap=true; JSESSIONID="ajax:5429456736043900841"; lang=v=2&lang=fr-fr; li_mc=MTsyMTsxNjA2NjQ1NDEwOzI7MDIx59959eyMoYUWCQ5uhP+VEqEmqTs3QnnPcVBHM5k7moQ=; lidc="b=VB03:s=V:r=V:g=4078:u=6:i=1606645410:t=1606731504:v=1:sig=AQGHQSVnQ6w2m2SP9cj5Fe8cTPSW8lJG"; spectroscopyId=ad781578-6f34-4bf8-a2c7-8e00704167f8; AMCV_14215E3D5995C57C0A495C55%40AdobeOrg=-637568504%7CMCIDTS%7C18596%7CMCMID%7C21952258699507596811397525096527262198%7CMCAAMLH-1607250215%7C6%7CMCAAMB-1607250215%7C6G1ynYcLPuiQxYZrsz_pkqfLG9yMXBpb2zX5dvJdYQJzPXImdj0y%7CMCOPTOUT-1606652615s%7CNONE%7CvVersion%7C5.1.1%7CMCCIDH%7C661940655'

url = URI.encode('https://www.linkedin.com/in/lior-levy-a3941018b')
# vebjørn-bræck-støen-132583188
file = URI.open(url, "cookie" => cookie).read
number = file.match(REGEX)[:number]
doc = Nokogiri::HTML(file)

data = JSON.parse(doc.css("#bpr-guid-#{number}").text.strip)
# ap data['included'].map {|included| included["$type"]}

# PROFILE
profile = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Profile"}
ap profile.map { |s|
  {
    profile_picture: s["profilePicture"].nil? ? false : ("#{s["profilePicture"]["displayImageReference"]["vectorImage"]["rootUrl"]}#{s["profilePicture"]["displayImageReference"]["vectorImage"]["artifacts"][2]["fileIdentifyingUrlPathSegment"]}"),
    full_name: "#{s["firstName"]} #{s["lastName"]}",
    headline: s["headline"].nil? ? false : s["headline"],
    summary: s["summary"].nil? ? false : s["summary"].gsub(/\n/, ' ')
  }
}

# GEO
geo = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.common.Geo"}
ap geo.map { |s| { geo: s["defaultLocalizedName"] } }

# Connections
# OLD CODE SECTION

# INDUSTRY
industry = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.common.Industry"}
ap industry.map { |s|
  {
    name: s["name"],
  }
}

# COMPANIES
companies = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.organization.Company"}
ap companies.map { |s|
  {
    name: s["name"],
  }
}

# EXPERIENCES
experiences = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Position"}
ap experiences.map { |s|
  {
    company: s["companyName"],
    date: s["dateRange"].nil? ? false : (s["dateRange"]["end"].nil? ? "#{s["dateRange"]["start"]["year"]}" : "#{s["dateRange"]["start"]["year"]} - #{s["dateRange"]["end"]["year"]}"),
    title: s["title"],
    location: s["locationName"]
  }
}

# SCHOOLS
schools = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.organization.School"}
ap schools.map { |s|
  {
    name: s["name"],
  }
}

# EDUCATION
education = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Education"}
ap education.map { |s|
  {
    school: s["schoolName"],
    date: s["dateRange"].nil? ? false : (s["dateRange"]["end"].nil? ? "#{s["dateRange"]["start"]["year"]}" : "#{s["dateRange"]["start"]["year"]} - #{s["dateRange"]["end"]["year"]}"),
    degree: s["degreeName"],
    field: s["fieldOfStudy"],
    grade: s["grade"],
    other_activites: s["activities"]
  }
}

# SKILLS
skills = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Skill"}
ap skills.map { |s| s["multiLocaleName"].values.first }
ap skills.count

# HONORS
honors = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Honor"}
ap honors.map { |s|
  {
    title: s["title"],
    issuer: s["issuer"],
    description: s["description"]
  }
}
ap honors.count

# LANGUAGES
languages = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Language"}
ap languages.map { |s|
  {
    name: s["name"],
    proficiency: s["proficiency"],
  }
}
ap languages.count

