load ("http.in", "http")

def get_url(command, query):
    query = query.replace(" ", "-")
    url = 'https://api.weatherapi.com/v1/%s.json?key={{ secret "default" "weatherapi_key"}}&q=%s' % (command, query)
    if command == "forecast":
        url += "&days=3"
    return url

def suggest(args):
  if not args.city:
    return "City has to be specified partially"

  resp = http.get(get_url("search", args.city)).value
  if resp.status_code != 200:
     return "Failed to get weather for " + args.city + " : " + resp.body()

  return {"city": [city["url"] for city in resp.json()]}

def alerts(dry_run, args):
  if not args.city:
    return ace.result("Validation failed", param_errors={"city": "City has to be specified"})

  resp = http.get(get_url("alerts", args.city)).value
  if resp.status_code != 200:
     return "Failed to get alerts for " + args.city + " : " + resp.body()

  if args.detail:
     return ace.result("Alerts for " + args.city, [resp.json()], ace.JSON)

  ret = []
  for a in resp.json()["alerts"]["alert"]:
     ret.append({"TimeBegin": a["effective"], "TimeEnd": a["expires"], "Headline": a["headline"], "Areas": a["areas"], " Severity": a["severity"], "Description": a["desc"]})
  return ace.result("Alerts for " + args.city, ret, ace.TABLE)

def weather(dry_run, args, forecast=False):
  if not args.city:
    return ace.result("Validation failed", param_errors={"city": "City has to be specified"})

  resp = http.get(get_url("forecast" if forecast else "current", args.city)).value
  if resp.status_code != 200:
     return "Failed to get weather for " + args.city + " : " + resp.body()

  if args.detail:
     return ace.result("Forecast" if forecast else "Current" + " weather for " + args.city, [resp.json()], ace.JSON)

  if forecast:
    fl = resp.json()["forecast"]["forecastday"]
    return ace.result("Forecast weather for " + args.city, 
            [get_forecast(args, fl[0]), get_forecast(args, fl[1]), get_forecast(args, fl[2])], report=ace.TABLE)
  else:
    return ace.result("Current weather for " + args.city, [get_weather(args, resp.json()["current"])], report=ace.TABLE)

def get_weather(args, w):
  if args.unit == "Celsius":
     return {"Time": w["last_updated"], "Temp(C)": w["temp_c"], "Temp-HeatIndex(C)": w["feelslike_c"], "Wind(kph)": w["wind_kph"], "Humidity": w["humidity"], "Condition": w["condition"]["text"]} 
  else: 
     return {"Time": w["last_updated"], "Temp F)": w["temp_f"], "Temp-HeatIndex(F)": w["feelslike_f"], "Wind(mph)": w["wind_mph"], "Humidity": w["humidity"], "Condition": w["condition"]["text"]} 

def get_forecast(args, wt):
  w = wt["day"]
  if args.unit == "Celsius":
     return {" Date": wt["date"], "Temp Max(C)": w["maxtemp_c"], "Temp Min(C)": w["mintemp_c"], "Wind Max(kph)": w["maxwind_kph"], "Humidity Avg": w["avghumidity"], "Total Precip(mm)": w["totalprecip_mm"], "Condition": w["condition"]["text"]} 
  else:
     return {" Date": wt["date"], "Temp Max(F)": w["maxtemp_f"], "Temp Min(F)": w["mintemp_f"], "Wind Max(mph)": w["maxwind_mph"], "Humidity Avg": w["avghumidity"], "Total Precip(in)": w["totalprecip_in"], "Condition": w["condition"]["text"]} 

app = ace.app("Weather",
   actions=[
      ace.action("Current Weather", "/", weather, suggest, description="Current weather for city"),
      ace.action("Forecast Weather", "/forecast", lambda dry_run, args: weather(dry_run, args, True), suggest, description="Forecast weather for city"),
      ace.action("Alerts", "/alerts", alerts, suggest, description="Alerts for city", hidden=["unit"])
   ],
   permissions=[ace.permission("http.in", "get"), secrets=[["weatherapi_key"]]]
)