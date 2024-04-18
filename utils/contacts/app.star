load("store.in", "store")
load("http.in", "http")

LIMIT = 1000


def create_contact(req):
    contact = doc.contact(first_name="", last_name="", email="", gender="",
                          ip_address="")
    if "first_name" in req.Form:
        contact.first_name = req.Form["first_name"][0]
    if "last_name" in req.Form:
        contact.last_name = req.Form["last_name"][0]
    if "email" in req.Form:
        contact.email = req.Form["email"][0]
    if "gender" in req.Form:
        contact.gender = req.Form["gender"][0]
    if "ip_address" in req.Form:
        contact.ip_address = req.Form["ip_address"][0]

    ret = store.insert(table.contact, contact)
    if not ret:
        print(ret.error)
        return ace.response(ret, "error")

    return ace.redirect(req.AppPath)


def get_handler(req):
    search = req.Query.get("search")
    id = req.Query.get("id")

    if id:
        id = int(id[0])
    if search:
        search = search[0]
    return get_contacts(search, id)


def search_handler(req):
    search = req.Form.get("search")[0]
    return get_contacts(search, None)


def get_contacts(search, id):
    cond = {}
    if search:
        searchValue = "%" + search + "%"
        cond = {"$or": [{"first_name": {"$like": searchValue}}, {"last_name": {"$like": searchValue}},
                        {"email": {"$like": searchValue}}]}
    if id:
        cond["_id"] = {"$lt": id}

    ret = store.select(table.contact, cond, limit=LIMIT,
                       sort=["_id:desc"])
    if not ret:
        print(ret.error)
        return ace.response({"error": ret.error}, "error", code=404)

    contacts = [row for row in ret.value]
    return {"Contacts": contacts, "Search": search}


def delete_contact(req):
    id = req.UrlParams["id"]
    if not id:
        return ace.response({"error": "id is required"}, "error")
    id = int(id)
    ret = store.delete_by_id(table.contact, id)
    if not ret:
        print(ret.error)
        return ace.response({"error": ret.error}, "error")

    return ace.response({}, "empty", redirect=req.AppPath)


def bulk_load(req):
    ret = http.get(
        "https://raw.githubusercontent.com/1cg/size_comparison/main/data.json")
    if not ret:
        print(ret.error)
        return ace.response({"error": ret.error}, "error")

    data = ret.value.json()
    count = 0
    for row in data:
        count += 1
        contact = doc.contact(first_name=row["first_name"], last_name=row["last_name"],
                              email=row["email"], gender=row["gender"], ip_address=row["ip_address"])
        ret = store.insert(table.contact, contact)

    return ace.response({"status": "ok", count: count})


app = ace.app("Contacts",
              custom_layout=True,
              routes=[
                  ace.html("/", "index.go.html", "contact_body", handler=get_handler,
                           fragments=[
                               ace.fragment("create",  method="POST",
                                            handler=create_contact),
                               ace.fragment("search", "contact_body", method="POST",
                                            handler=search_handler),
                               ace.fragment("{id}", "contact_body", method="DELETE",
                                            handler=delete_contact),
                           ]),
                  ace.api("/bulk_load", handler=bulk_load)
              ],
              permissions=[
                  ace.permission("store.in", "select"),
                  ace.permission("store.in", "insert"),
                  ace.permission("store.in", "delete_by_id"),
                  ace.permission("http.in", "get"),
              ],
              style=ace.style("daisyui", themes=[
                  "lemonade", "dim"]),
              )
