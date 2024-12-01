load ("exec.in", "exec")
load ("fs.in", "fs")

def run(dry_run, args):
   if not args.file:
      return ace.result("Validation failed", param_errors={"file": "Input file has to be uploaded"})

   out = exec.run("nl", [args.file], stdout_file=True)
   if out.error:
       return ace.result(out.error)
   file_handle = fs.load_file(out.value)
   return ace.result("Added line numbers", [file_handle.value], report=ace.DOWNLOAD)

app = ace.app("Number Lines",
   actions=[ace.action("Number Lines", "/", run, description="Add line numbers to given file")],
   permissions=[
     ace.permission("exec.in", "run", ["nl"]),
     ace.permission("fs.in", "load_file"),
   ],
)

