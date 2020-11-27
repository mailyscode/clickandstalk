require 'amazing_print'
require 'nokogiri'
require 'json'
require 'open-uri'

REGEX = /<code.+>\n.+linkedin.voyager.dash.deco.identity.profile.FullProfileWithEntities.+"bpr-guid-(?<number>\d+)".+\n<\/code>/

cookie = 'bcookie="v=2&8530704d-5e36-4096-86d6-4c2e6f9e1ab6"; lissc=1; bscookie="v=1&20201114184658f96bd148-54bb-4580-8972-44ec5115921eAQFG1RjMSQmbEPZtZieP1s9tVSgavezt"; _ga=GA1.2.1076496540.1605972952; li_rm=AQENbPpMLBqhmQAAAXXrcozbnZGVisKPopD4YJky8i3sQUpFDc9M-GpcZyFcApoXvcqVOTy_sDwFZwcnpe5NXIFa8Yy5L_ZZuRqTfwV6FbCIKE5gg1CzZtDm; li_gc=MTsyMTsxNjA1OTczMTE1OzI7MDIxMmUdt/pjxwaHlsPVr3Qc2F132mVIEZLHU58adPtCvYA=; aam_uuid=17968991075470074003363689154560337265; G_ENABLED_IDPS=google; VID=V_2020_11_24_11_1215; _gcl_au=1.1.2120236101.1606234607; mbox=session#f6084102c7e948f4bebbd8c75d008108#1606301123|PC#f6084102c7e948f4bebbd8c75d008108.37_0#1621852035; gpv_pn=business.linkedin.com%2Ftalent-solutions%2Fats-partners%2Fpartner-application%2F3qa; s_tslv=1606300034704; _gid=GA1.2.219243348.1606488415; spectroscopyId=e607aef7-3732-4b45-830f-4df2c6f165f2; UserMatchHistory=AQJy4GiuOlW87QAAAXYKz_KVOXgMEfOETWDti3XEyYjIbMiDcgKWAHEMdJwvPCBp7II9c7d5ssaoSMLMrokBWGvSDArirWiemfqGpqOLBR_hZ_4QOWX3bIn2rKiBec9EP3hMUKNIU4TyehUqy_ldJCnzEKGmqvMsjgCHHqBtUotgDYUNnCZMTkqXqH36RQr1faV0e8grXjXNX0AuVeyFAuIic-Jy3O-TNFSvBlQDrJfcvEAxnC5iM0vnhf5w13UHyuuAXCjDUA; AnalyticsSyncHistory=AQL6d4ZQao-ilgAAAXYKz_VPI1S8tOIv6xyw8zninGivXJ9fWawNfMz2cXW9Ul-LqpSr99XGfPPCFNYwpfqIuw; lms_ads=AQFHxL2X69My8gAAAXYKz_a3_FSwN7L_QWoXq7vybepUpbgaT2ScFwwY7kvS-tQLSC5Eu9lmapETANOdHBWZNQvir6uq7p9q; lms_analytics=AQFHxL2X69My8gAAAXYKz_a3_FSwN7L_QWoXq7vybepUpbgaT2ScFwwY7kvS-tQLSC5Eu9lmapETANOdHBWZNQvir6uq7p9q; AMCVS_14215E3D5995C57C0A495C55%40AdobeOrg=1; li_at=AQEDATNYHJcCFWdsAAABdgrRNcYAAAF2Lt25xk4AkxmPxszevxyr7_quHQ9p14p7o-NA1H4hz884n7zCGwWZ-Hmby12zvH3qW40BaMjJ2XGdKNEX8hOoKUYBNSrxzWIijiUhNmAIzpN9mgrxE34NCPLT; liap=true; JSESSIONID="ajax:5808635831702217369"; lang=v=2&lang=fr-fr; lidc="b=VB03:s=V:r=V:g=4078:u=6:i=1606499251:t=1606557935:v=1:sig=AQHtzDdVbYgAfu7qwkclU2j9VXJGxotk"; AMCV_14215E3D5995C57C0A495C55%40AdobeOrg=-637568504%7CMCIDTS%7C18594%7CMCMID%7C17386544876998313953341976906988115642%7CMCAAMLH-1607104055%7C6%7CMCAAMB-1607104055%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1606506455s%7CNONE%7CvVersion%7C5.1.1%7CMCCIDH%7C661940655; li_mc=MTsyMTsxNjA2NTAwNTIwOzI7MDIx7RU3qg9ZJtAFY2+jeqjBSeQKuOkSvGxaO/VvP8TAmCM='

file = URI.open("https://www.linkedin.com/in/#{username_linkedin}", "cookie" => cookie).read

number = file.match(REGEX)[:number]

doc = Nokogiri::HTML(file)

# File.write('data.json', doc.css("#bpr-guid-#{number}").text.strip)

data = JSON.parse(doc.css("#bpr-guid-#{number}").text.strip)

# ap data['included'].map {|included| included["$type"]}

skills = data['included'].select {|included| included["$type"] == "com.linkedin.voyager.dash.identity.profile.Skill"}

ap skills.map { |s| s["multiLocaleName"].values.first }
