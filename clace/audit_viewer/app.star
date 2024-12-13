load("clace.in", "clace")

app = ace.app("Clace Audit Events", custom_layout=True,
              routes=[
                ace.html("/", partial="audit_body")
              ],
              permissions=[
                  ace.permission("clace.in", "list_all_apps"),
                  ace.permission("clace.in", "list_audit_events"),
              ],
              style=ace.style("daisyui", themes=["emerald", "night"])
       )

def query(req, key):
    return req.Query.get(key)[0] if req.Query.get(key) else ""

def handler(req):
    all_apps = clace.list_all_apps(include_internal=True)
    if all_apps.error:
        ace.response(all_apps.error, code=500)

    ret = clace.list_audit_events(app_glob=query(req, "appGlob"),
                                     user_id=query(req, "userId"),
                                     event_type=query(req, "eventType"),
                                     operation=query(req, "operation"),
                                     target=query(req, "target"),
                                     status=query(req, "status"),
                                     start_date=query(req, "startDate"),
                                     end_date=query(req, "endDate"),
                                     rid=query(req, "rid"),
                                     before_timestamp=query(req, "beforeTimestamp"),
                                     )
    if ret.error:
        ace.response(ret.error, code=500)

    queryTimestamp = ret.value[-1]["create_time_epoch"] if len(ret.value) > 0 else ""
    nextPage = req.AppPath + "/?appGlob=" + query(req, "appGlob") + "&userId=" + query(req, "userId") + "&eventType=" + query(req, "eventType") + \
        "&operation=" + query(req, "operation") + "&target=" + query(req, "target") + "&status=" + query(req, "status") + "&startDate=" +  \
        query(req, "startDate") + "&endDate=" + query(req, "endDate") + "&rid=" + query(req, "rid") + "&beforeTimestamp=" + queryTimestamp
    
    return {
        "Apps": all_apps.value,
        "NextPage": nextPage,
        "Events": ret.value,
    }
