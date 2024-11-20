load("clace.in", "clace")

app = ace.app("List Apps", custom_layout=True,
              routes=[
                ace.html("/", partial="search_results")
              ],
              permissions=[
                  ace.permission("clace.in", "list_apps"),
              ],
              style=ace.style("daisyui", themes=["emerald", "night"])
       )

def handler(req):
    query = req.Query.get("q")
    query = query[0] if query else ""
    internal = req.Query.get("internal")
    internal = internal[0] == "true" if internal else False

    return {
        "query": query,
        "internal": internal,
        "apps": clace.list_apps(query, internal).value
    }
