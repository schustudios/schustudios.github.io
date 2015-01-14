---
---
# Helper.coffee
#
# Holds methods used throughout the application

String::startsWith ?= (s) -> @[...s.length] is s
String::endsWith   ?= (s) -> s is '' or @[-s.length..] is s