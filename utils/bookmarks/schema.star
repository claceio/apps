type("bookmark",
     fields=[
         field("url", STRING),
         field("tags", LIST),
     ],
     indexes=[
         index(["url"], unique=True)
     ])

type("tag",
     fields=[
         field("tag", STRING),
         field("urls", LIST),
     ],
     indexes=[
         index(["tag"], unique=True)
     ])
