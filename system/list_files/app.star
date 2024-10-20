load ("exec.in", "exec")

def run(dry_run, args):
   if args.dir == "." or args.dir.startswith("./") or args.dir == ".." or args.dir.startswith("../"):
       return ace.result("Validation failed", param_errors={"dir": "relative paths not supported"})

   cmd_args = ["-Lla" if args.detail else "-La", args.dir]
   out = exec.run("ls", cmd_args)
   if out.error:
       return ace.result(out.error)
   return ace.result("File listing for " + args.dir, out.value)

app = ace.app("List Files",
   actions=[ace.action("List Files", "/", run, description="Show the ls -a output for specified directory")],
   permissions=[
     ace.permission("exec.in", "run", ["ls"]),
   ],
)

