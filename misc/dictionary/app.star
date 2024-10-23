load ("http.in", "http")

def run(dry_run, args):
   if not args.word:
       return ace.result("Validation failed", param_errors={"word": "word has to be specified"})
   if args.word.find(" ") != -1:
       return ace.result("Validation failed", param_errors={"word": "word cannot have spaces"})

   out = http.get("https://api.dictionaryapi.dev/api/v2/entries/en/" + args.word)
   if out.error:
       return ace.result(out.error)

   resp = out.value.json()
   if len(resp) == 0 or type(resp) != "list":
       return ace.result("Failed to get definition for " + args.word)
   word = resp[0]
   
   if args.show == "basic":
       defs = ["Word : " + word["word"], "Phonetic: " + word["phonetic"]]
       for m in word["meanings"]:
          for d in m["definitions"]:
              defs.append(m["partOfSpeech"] + " : " + d["definition"])

       return ace.result("Basic definition for " + word["word"], defs, ace.TEXT)

   if args.show == "summary":
       defs = []
       for m in word["meanings"]:
          for d in m["definitions"]:
             defs.append({
               "PartOfSpeech": m["partOfSpeech"],
               "Definition": d["definition"],
               "Example": d.get("example", "")
             })
       return ace.result("Summary definition for " + word["word"], defs, ace.TABLE)
       
   if args.show == "detail":
        return ace.result("Detail definition for " + word["word"], [word], ace.JSON)

   if args.show == "custom":
        return ace.result("Word definition for " + word["word"], [word], "custom_report")


app = ace.app("Word Lookup",
   actions=[ace.action("Word Lookup", "/", run, description="Directory lookup for word meaning")],
   permissions=[
     ace.permission("http.in", "get"),
   ],
   style=ace.style("daisyui"),
)

