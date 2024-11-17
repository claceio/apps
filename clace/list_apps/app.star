load("clace.in", "clace")

app = ace.app("List Apps", custom_layout=True,
              routes=[ace.html("/")],
              permissions=[
                  ace.permission("clace.in", "list_apps"),
              ],
              style=ace.style("daisyui", themes=["emerald", "night"])
       )

def handler(req):
    return clace.list_apps().value
