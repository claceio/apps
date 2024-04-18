load("store.in", "store")


def get_cleaned_tags(form):
    tags = []
    if "tags" in form:
        tags = form["tags"]

    cleaned_tags = []
    for tag in tags:
        tag = tag.strip().lower()
        if tag not in cleaned_tags:
            cleaned_tags.append(tag)
    return cleaned_tags


def create_bookmark(req):
    if not req.Form["url"] or not req.Form["url"][0]:
        return ace.response({"error": "no url specified"}, "error")
    url = req.Form["url"][0]
    tags = get_cleaned_tags(req.Form)

    store.begin()
    bookmark = doc.bookmark(url, tags)
    store.insert(table.bookmark, bookmark)

    for tag in tags:
        tag_doc = None
        ret = store.select_one(table.tag, {"tag": tag})
        if ret:
            # Update existing tag
            tag_doc = ret.value
            tag_doc.urls.append(url)
            store.update(table.tag, tag_doc)
        else:
            # Create new tag
            tag_doc = doc.tag(tag, [url])
            store.insert(table.tag, tag_doc)

    store.commit()
    return ace.redirect(req.AppPath)


def get_bookmarks(req):
    search_cond = req.Query.get("search")
    search = {}
    if search_cond and search_cond[0]:
        search = {"url": {"$like": "*" + search_cond[0] + "*"}}

    ret = store.select(table.bookmark, search, limit=100,
                       sort=["_updated_at:desc"])
    bookmarks = []
    for row in ret.value:
        bookmarks.append(row)

    ret = store.select(table.tag, {}, sort=["_updated_at:desc"])
    tags = []
    for row in ret.value:
        tags.append(row.tag)

    return {"Bookmarks": bookmarks, "Tags": tags}


def get_bookmark(req):
    url = req.Query.get("url")
    if not url:
        return ace.response({"error": "no bookmark url specified"})
    search = {"url": url[0]}
    bookmark = store.select_one(table.bookmark, search).value
    return bookmark


def edit_bookmark(req):
    url = req.Query.get("url")
    if not url:
        return ace.response({"error": "no bookmark url specified"})
    url = url[0]

    book = store.select_one(table.bookmark, {"url": url}).value
    tag_iter = store.select(table.tag, {}, sort=["_updated_at:desc"]).value

    tags = []
    for row in tag_iter:
        tags.append(
            {"name": row.tag, "value": "selected" if row.tag in book.tags else ""})

    val = {"url": book.url, "tags": tags}
    return val


def post_edit_bookmark(req):
    url = req.Query.get("url")[0]
    tags = get_cleaned_tags(req.Form)

    store.begin()
    bookmark = store.select_one(table.bookmark, {"url": url}).value

    added = []
    for tag in tags:
        if tag not in bookmark.tags:
            added.append(tag)

    removed = []
    for tag in bookmark.tags:
        if tag not in tags:
            removed.append(tag)

    # Remove url from removed tags
    for tag in removed:
        tag_doc = store.select_one(table.tag, {"tag": tag}).value
        tag_doc.urls.remove(url)
        if len(tag_doc.urls) == 0:
            store.delete_by_id(table.tag, tag_doc._id)
        else:
            store.update(table.tag, tag_doc)

    # Add url to added tags
    for tag in added:
        ret = store.select_one(table.tag, {"tag": tag})
        if ret:
            tag_doc = ret.value
            if url not in tag_doc.urls:
                tag_doc.urls.append(url)
                store.update(table.tag, tag_doc)
        else:
            tag_doc = doc.tag(tag, [url])
            store.insert(table.tag, tag_doc)

    bookmark.tags = tags
    store.update(table.bookmark, bookmark)
    store.commit()
    return bookmark


def delete_bookmark(req):
    if not req.Form["url"] or not req.Form["url"][0]:
        return ace.response({"error": "no url specified"}, "error")
    url = req.Form["url"][0]

    store.begin()
    bookmark = store.select_one(table.bookmark, {"url": url}).value
    for tag in bookmark.tags:
        tag_doc = store.select_one(table.tag, {"tag": tag}).value
        tag_doc.urls.remove(url)
        if len(tag_doc.urls) == 0:
            store.delete_by_id(table.tag, tag_doc._id)
        else:
            store.update(table.tag, tag_doc)

    store.delete_by_id(table.bookmark, bookmark._id)
    store.commit()


def get_tags(req):
    tag = req.Query.get("tag")
    search = {}
    if tag and tag[0]:
        search = {"tag": tag[0]}

    ret = store.select(table.tag, search, limit=100, sort=["_updated_at:desc"])
    tags = []
    for row in ret.value:
        tags.append(row)

    return {"Tags": tags}


def error_handler(req, ret):
    if req.IsPartial:
        return ace.response(ret, "error", retarget="#error_div", reswap="innerHTML")
    else:
        return ace.response(ret, "error.go.html")


app = ace.app("Bookmark Manager",
              custom_layout=True,
              routes=[
                  ace.html("/", "index.go.html", handler=get_bookmarks,
                           fragments=[
                               ace.fragment("bookmark", partial="row", method="GET",
                                            handler=get_bookmark),
                               ace.fragment("create", method="POST",
                                            handler=create_bookmark),
                               ace.fragment("/", partial="empty", method="DELETE",
                                            handler=delete_bookmark),
                               ace.fragment("edit", partial="edit_bookmark", method="GET",
                                            handler=edit_bookmark),
                               ace.fragment("edit", partial="row", method="POST",
                                            handler=post_edit_bookmark),
                           ]),
                  ace.html("/tags", "tag.go.html", handler=get_tags),
              ],
              permissions=[
                  ace.permission("store.in", "select"),
                  ace.permission("store.in", "insert"),
                  ace.permission("store.in", "update"),
                  ace.permission("store.in", "select_one"),
                  ace.permission("store.in", "begin"),
                  ace.permission("store.in", "commit"),
                  ace.permission("store.in", "delete_by_id"),
              ],
              style=ace.style("daisyui", themes=[
                  "lemonade", "dim"]),
              libraries=[
                  "https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/js/tom-select.complete.min.js"],
              )
