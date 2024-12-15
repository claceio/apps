load ("exec.in", "exec")
load ("fs.in", "fs")

def run(dry_run, args):
   if not args.file:
      return ace.result("Validation failed", param_errors={"file": "Input file has to be uploaded"})

   run_ret = exec.run("nl", [args.file], stdout_file=True)
   if run_ret.error:
      return ace.result(run_ret.error)

   load_ret = fs.serve_tmp_file(run_ret.value, name="num_" + args.file.rsplit("/", 1)[-1])
   ace.audit("num_lines", load_ret.value["name"])
   return ace.result("Added line numbers", [load_ret.value], report=ace.DOWNLOAD)

app = ace.app("Number Lines",
   actions=[ace.action("Number Lines", "/", run, description="Add line numbers to given file")],
   permissions=[
     ace.permission("exec.in", "run", ["nl"]),
     ace.permission("fs.in", "serve_tmp_file"),
   ],
)

