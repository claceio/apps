param("city", description="The city to look up", default="San Francisco")

param("unit", type=STRING, description="Unit for temperature, Celsius/Fahrenheit", default="Celsius")

param("options-unit", type=LIST, description="Options for unit", default=["Celsius", "Fahrenheit"])

param("detail", type=BOOLEAN, description="Whether to show detailed response", default=False)