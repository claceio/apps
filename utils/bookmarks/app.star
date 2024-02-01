load("store.in", "store")


def create_bookmark(req):
    url = ""
    if "url" in req.Form:
        url = req.Form["url"][0]
    if not url:
        return ace.response("no url specified", "error", code=404)

    tags = []
    if "tags" in req.Form:
        tags = req.Form["tags"]

    cleaned_tags = []
    for tag in tags:
        tag = tag.strip().lower()
        cleaned_tags.append(tag)
    tags = cleaned_tags

    bookmark = doc.bookmark(url, tags)
    ret = store.insert(table.bookmark, bookmark)
    if not ret:
        print(ret.error)
        return ace.response(ret, "error", code=404)

    for tag in tags:
        tag_doc = None
        ret = store.select_one(table.tag, {"tag": tag})
        if ret:
            tag_doc = ret.value

        if tag_doc:
            # Update existing tag
            print("updating tag", tag_doc.urls, "with url", url)
            tag_doc.urls.append(url)
            ret = store.update(table.tag, tag_doc)
            if not ret:
                print("error updating", ret.error)
                return ace.response({"error": ret.error}, "error", code=404)
        else:
            # Create new tag
            tag_doc = doc.tag(tag, [url])
            ret = store.insert(table.tag, tag_doc)
            if not ret:
                print("error inserting", ret.error)
                return ace.response({"error": ret.error}, "error", code=404)

    return ace.redirect(req.AppPath)


def get_bookmarks(req):
    ret = store.select(table.bookmark, {}, limit=100,
                       sort=["_created_at:desc"])
    if not ret:
        print(ret.error)
        return ace.response({"error": ret.error}, "error", code=404)

    bookmarks = []
    for row in ret.value:
        bookmarks.append(row)

    ret = store.select(table.tag, {}, sort=["_updated_at:desc"])
    if not ret:
        print(ret.error)
        return ace.response({"error": ret.error}, "error", code=404)

    tags = []
    for row in ret.value:
        tags.append(row.tag)

    return {"Bookmarks": bookmarks, "Tags": tags}


def get_tags(req):
    ret = store.select(table.tag, {}, limit=100,
                       sort=["_updated_at:desc"])
    if not ret:
        return ace.response({"error": ret.error}, "error", code=404)

    tags = []
    for row in ret.value:
        tags.append(row)

    return {"Tags": tags}


app = ace.app("Bookmark Manager",
              custom_layout=True,
              pages=[
                  ace.page("/", "index.go.html", "", handler=get_bookmarks,
                           fragments=[
                               ace.fragment("create", method="POST",
                                            handler=create_bookmark),
                           ]),
                  ace.page("/tags", "tag.go.html", handler=get_tags),
              ],
              permissions=[
                  ace.permission("store.in", "select"),
                  ace.permission("store.in", "insert"),
                  ace.permission("store.in", "update"),
                  ace.permission("store.in", "select_one"),
              ],
              style=ace.style("daisyui", themes=[
                              "lemonade", "dim"]),
              libraries=[
                  "https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/js/tom-select.complete.min.js"],
              )
